# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Cd::Deployment, feature_category: :continuous_delivery do
  let_it_be(:application) { create(:cd_application) }
  let_it_be(:service) { create(:cd_service, application: application) }
  let_it_be(:rollout_environment) { create(:cd_rollout_environment) }

  describe 'factory' do
    it 'creates a valid deployment using factory defaults' do
      expect(create(:cd_deployment)).to be_valid
    end
  end

  describe 'associations' do
    it { is_expected.to belong_to(:service).required }
    it { is_expected.to belong_to(:rollout_environment).required }
    it { is_expected.to have_many(:deployment_transitions) }

    it 'orders deployment_transitions by created_at ascending' do
      deployment = create(:cd_deployment)
      newer = create(:cd_deployment_transition, deployment: deployment, created_at: 1.day.ago)
      older = create(:cd_deployment_transition, deployment: deployment, created_at: 2.days.ago)

      expect(deployment.deployment_transitions).to eq([older, newer])
    end
  end

  describe 'enums' do
    it 'defines state enum' do
      is_expected.to define_enum_for(:state).with_values(
        pending: 0,
        deploying: 1,
        healthy: 2,
        degraded: 3,
        failed: 4,
        cancelled: 5
      )
    end
  end

  describe 'validations' do
    subject do
      build(:cd_deployment,
        service: service,
        rollout_environment: rollout_environment)
    end

    it { is_expected.to be_valid }

    it 'rejects a second deployment for the same service in the same rollout environment' do
      create(:cd_deployment,
        service: service,
        rollout_environment: rollout_environment)

      duplicate = build(:cd_deployment,
        service: service,
        rollout_environment: rollout_environment)

      expect(duplicate).not_to be_valid
      expect(duplicate.errors[:service_id]).to include('already has a deployment in this rollout environment')
    end
  end

  describe 'sharding key' do
    subject do
      build(:cd_deployment,
        service: service,
        rollout_environment: rollout_environment)
    end

    it { is_expected.to populate_sharding_key(:organization_id).with(service.organization_id) }
  end

  describe 'state machine' do
    subject(:deployment) do
      create(:cd_deployment, service: service, rollout_environment: rollout_environment)
    end

    it 'has an initial state of pending' do
      expect(deployment).to be_pending
    end

    describe 'states' do
      it 'declares all expected states' do
        is_expected.to have_states(
          :pending, :deploying, :healthy, :degraded,
          :failed, :cancelled
        )
      end
    end

    describe 'event handling' do
      it { is_expected.to handle_events(:start_deploying, when: :pending) }
      it { is_expected.to reject_events(:start_deploying, when: :deploying) }
      it { is_expected.to reject_events(:start_deploying, when: :healthy) }

      it { is_expected.to handle_events(:mark_healthy, when: :deploying) }
      it { is_expected.to reject_events(:mark_healthy, when: :pending) }
      it { is_expected.to reject_events(:mark_healthy, when: :degraded) }
      it { is_expected.to reject_events(:mark_healthy, when: :failed) }

      it { is_expected.to handle_events(:mark_degraded, when: :deploying) }
      it { is_expected.to reject_events(:mark_degraded, when: :pending) }
      it { is_expected.to reject_events(:mark_degraded, when: :healthy) }
      it { is_expected.to reject_events(:mark_degraded, when: :failed) }

      it { is_expected.to handle_events(:fail_deployment, when: :deploying) }
      it { is_expected.to reject_events(:fail_deployment, when: :pending) }
      it { is_expected.to reject_events(:fail_deployment, when: :healthy) }
      it { is_expected.to reject_events(:fail_deployment, when: :degraded) }
      it { is_expected.to reject_events(:fail_deployment, when: :failed) }

      it { is_expected.to handle_events(:cancel, when: :deploying) }
      it { is_expected.to reject_events(:cancel, when: :pending) }
      it { is_expected.to reject_events(:cancel, when: :healthy) }
      it { is_expected.to reject_events(:cancel, when: :degraded) }
      it { is_expected.to reject_events(:cancel, when: :failed) }
      it { is_expected.to reject_events(:cancel, when: :cancelled) }
    end

    describe 'transitions' do
      using RSpec::Parameterized::TableSyntax

      where(:event, :from_state, :to_state) do
        :start_deploying  | :pending   | :deploying
        :mark_healthy     | :deploying | :healthy
        :mark_degraded    | :deploying | :degraded
        :fail_deployment  | :deploying | :failed
        :cancel           | :deploying | :cancelled
      end

      with_them do
        before do
          deployment.update_column(:state, described_class.states[from_state.to_s])
        end

        it "transitions from #{params[:from_state]} to #{params[:to_state]} on #{params[:event]}" do
          expect { deployment.public_send(:"#{event}!") }
            .to change { deployment.state }
            .from(from_state.to_s)
            .to(to_state.to_s)
        end
      end
    end

    describe 'callbacks' do
      describe 'setting started_at' do
        context 'when transitioning to deploying for the first time' do
          it 'sets started_at' do
            freeze_time do
              deployment.start_deploying!

              expect(deployment.started_at).to be_like_time(Time.current)
            end
          end
        end
      end

      describe 'setting finished_at' do
        it 'sets finished_at when entering a terminal state', :aggregate_failures do
          terminal_transitions = [
            { from: :deploying, event: :mark_healthy, to: :healthy },
            { from: :deploying, event: :mark_degraded, to: :degraded },
            { from: :deploying, event: :fail_deployment, to: :failed },
            { from: :deploying, event: :cancel, to: :cancelled }
          ]

          terminal_transitions.each do |transition|
            deployment = build_deployment_in_state(transition[:from])

            freeze_time do
              deployment.public_send(:"#{transition[:event]}!")

              expect(deployment.finished_at).to be_like_time(Time.current),
                "expected finished_at to be set when transitioning " \
                  "from #{transition[:from]} to #{transition[:to]} via #{transition[:event]}"
            end
          end
        end

        it 'does not set finished_at on non-terminal transitions', :aggregate_failures do
          non_terminal_transitions = [
            { from: :pending, event: :start_deploying, to: :deploying }
          ]

          non_terminal_transitions.each do |transition|
            deployment = build_deployment_in_state(transition[:from])

            deployment.public_send(:"#{transition[:event]}!")

            expect(deployment.finished_at).to be_nil,
              "expected finished_at to remain nil when transitioning " \
                "from #{transition[:from]} to #{transition[:to]} via #{transition[:event]}"
          end
        end

        # Creates a fresh deployment with a unique (rollout_environment_id, service_id)
        # pair to avoid the uniqueness constraint.
        def build_deployment_in_state(state)
          fresh_service = create(:cd_service, application: application)
          deployment = create(:cd_deployment, service: fresh_service)
          deployment.update_column(:state, described_class.states[state.to_s])
          deployment
        end
      end
    end
  end
end
