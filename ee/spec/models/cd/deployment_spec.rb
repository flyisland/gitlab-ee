# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Cd::Deployment, feature_category: :continuous_delivery do
  let_it_be(:application) { create(:cd_application) }
  let_it_be(:environment) { create(:cd_environment, group: application.group) }
  let_it_be(:version_set) { create(:cd_version_set, application: application) }
  let_it_be(:rollout) { create(:cd_rollout, version_set: version_set, environment: environment) }
  let_it_be(:version_set_entry) { create(:cd_version_set_entry, version_set: version_set) }

  describe 'associations' do
    it { is_expected.to belong_to(:rollout).required }
    it { is_expected.to belong_to(:version_set_entry).required }
    it { is_expected.to have_one(:service).through(:version_set_entry) }
    it { is_expected.to have_one(:version).through(:version_set_entry) }
    it { is_expected.to have_one(:environment).through(:rollout) }
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
        rollout: rollout,
        version_set_entry: version_set_entry)
    end

    it { is_expected.to be_valid }

    it 'rejects a second deployment for the same version set entry in the same rollout' do
      create(:cd_deployment,
        rollout: rollout,
        version_set_entry: version_set_entry)

      duplicate = build(:cd_deployment,
        rollout: rollout,
        version_set_entry: version_set_entry)

      expect(duplicate).not_to be_valid
      expect(duplicate.errors[:version_set_entry_id]).to include('already has a deployment in this rollout')
    end

    it 'rejects a version set entry from a different version set than the rollout' do
      other_version_set = create(:cd_version_set, application: application)
      foreign_entry = create(:cd_version_set_entry, version_set: other_version_set)

      deployment = build(:cd_deployment,
        rollout: rollout,
        version_set_entry: foreign_entry)

      expect(deployment).not_to be_valid
      expect(deployment.errors[:version_set_entry]).to include("must belong to the rollout's version set")
    end
  end

  describe 'sharding key' do
    subject do
      build(:cd_deployment,
        rollout: rollout,
        version_set_entry: version_set_entry)
    end

    it { is_expected.to populate_sharding_key(:organization_id).with(rollout.organization_id) }
  end

  describe 'state machine' do
    subject(:deployment) do
      create(:cd_deployment, rollout: rollout, version_set_entry: version_set_entry)
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

        # Creates a fresh deployment + rollout + version set entry to avoid
        # the (rollout_id, version_set_entry_id) uniqueness constraint.
        def build_deployment_in_state(state)
          fresh_rollout = create(:cd_rollout, version_set: version_set, environment: environment)
          fresh_entry = create(:cd_version_set_entry, version_set: version_set)
          deployment = create(:cd_deployment, rollout: fresh_rollout, version_set_entry: fresh_entry)
          deployment.update_column(:state, described_class.states[state.to_s])
          deployment
        end
      end
    end
  end
end
