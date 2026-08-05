# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Cd::Rollout, feature_category: :continuous_delivery do
  let_it_be(:version_set) { create(:cd_version_set) }

  describe 'factory' do
    it 'creates a valid rollout using factory defaults' do
      expect(create(:cd_rollout)).to be_valid
    end
  end

  describe 'associations' do
    it { is_expected.to belong_to(:version_set).required }
    it { is_expected.to belong_to(:application).required }
    it { is_expected.to belong_to(:application_flow_definition).optional }
    it { is_expected.to have_many(:rollout_environments) }
    it { is_expected.to have_many(:rollout_transitions) }

    it 'orders rollout_environments by position ascending' do
      rollout = create(:cd_rollout)
      # Created out of position order so the assertion proves the association reorders them.
      second = create(:cd_rollout_environment, rollout: rollout, position: 2)
      first = create(:cd_rollout_environment, rollout: rollout, position: 1)

      expect(rollout.rollout_environments).to eq([first, second])
    end

    it 'orders rollout_transitions by created_at ascending' do
      rollout = create(:cd_rollout)
      newer = create(:cd_rollout_transition, rollout: rollout, created_at: 1.day.ago)
      older = create(:cd_rollout_transition, rollout: rollout, created_at: 2.days.ago)

      expect(rollout.rollout_transitions).to eq([older, newer])
    end
  end

  describe 'validations' do
    subject { build(:cd_rollout, version_set: version_set) }

    it { is_expected.to validate_length_of(:workflow_ref).is_at_most(255) }

    describe 'workflow_ref presence' do
      it 'is valid without a workflow_ref while pending' do
        expect(build(:cd_rollout, version_set: version_set, state: :pending, workflow_ref: nil)).to be_valid
      end

      %i[in_progress paused completed failed cancelled].each do |state|
        it "requires a workflow_ref when #{state}" do
          rollout = build(:cd_rollout, version_set: version_set, state: state, workflow_ref: nil)

          expect(rollout).not_to be_valid
          expect(rollout.errors[:workflow_ref]).to include("can't be blank")
        end

        it "is valid with a workflow_ref when #{state}" do
          expect(build(:cd_rollout, version_set: version_set, state: state, workflow_ref: 'wk:1/abc')).to be_valid
        end
      end
    end
  end

  describe 'enums' do
    it 'defines state enum' do
      is_expected.to define_enum_for(:state).with_values(
        pending: 0,
        in_progress: 1,
        paused: 2,
        completed: 3,
        failed: 4,
        cancelled: 5
      )
    end
  end

  describe 'sharding key' do
    subject { build(:cd_rollout, version_set: version_set) }

    it { is_expected.to populate_sharding_key(:organization_id).with(version_set.organization_id) }
  end

  describe 'defaults' do
    it 'defaults state to pending' do
      record = described_class.new

      expect(record.state).to eq('pending')
    end
  end

  describe 'state machine' do
    # A rollout being transitioned has already been kicked off, so it carries a
    # workflow_ref (required in every non-pending state).
    subject(:rollout) { create(:cd_rollout, version_set: version_set, workflow_ref: 'wk:1/abc') }

    it 'has an initial state of pending' do
      expect(rollout).to be_pending
    end

    describe 'states' do
      it 'declares all expected states' do
        is_expected.to have_states(
          :pending, :in_progress, :paused,
          :completed, :failed, :cancelled
        )
      end
    end

    describe 'event handling' do
      it { is_expected.to handle_events(:start, when: :pending) }
      it { is_expected.to reject_events(:start, when: :in_progress) }
      it { is_expected.to reject_events(:start, when: :completed) }

      it { is_expected.to handle_events(:pause, when: :in_progress) }
      it { is_expected.to reject_events(:pause, when: :pending) }
      it { is_expected.to reject_events(:pause, when: :paused) }

      it { is_expected.to handle_events(:resume, when: :paused) }
      it { is_expected.to reject_events(:resume, when: :in_progress) }
      it { is_expected.to reject_events(:resume, when: :pending) }

      it { is_expected.to handle_events(:complete, when: :in_progress) }
      it { is_expected.to reject_events(:complete, when: :pending) }
      it { is_expected.to reject_events(:complete, when: :failed) }

      it { is_expected.to handle_events(:fail_rollout, when: :in_progress) }
      it { is_expected.to reject_events(:fail_rollout, when: :pending) }
      it { is_expected.to reject_events(:fail_rollout, when: :failed) }

      it { is_expected.to handle_events(:cancel, when: :in_progress) }
      it { is_expected.to reject_events(:cancel, when: :pending) }
      it { is_expected.to reject_events(:cancel, when: :paused) }
      it { is_expected.to reject_events(:cancel, when: :completed) }
      it { is_expected.to reject_events(:cancel, when: :failed) }
      it { is_expected.to reject_events(:cancel, when: :cancelled) }
    end

    describe 'transitions' do
      using RSpec::Parameterized::TableSyntax

      where(:event, :from_state, :to_state) do
        :start         | :pending     | :in_progress
        :pause         | :in_progress | :paused
        :resume        | :paused      | :in_progress
        :complete      | :in_progress | :completed
        :fail_rollout  | :in_progress | :failed
        :cancel        | :in_progress | :cancelled
      end

      with_them do
        before do
          rollout.update_column(:state, described_class.states[from_state.to_s])
        end

        it "transitions from #{params[:from_state]} to #{params[:to_state]} on #{params[:event]}" do
          expect { rollout.public_send(:"#{event}!") }
            .to change { rollout.state }
            .from(from_state.to_s)
            .to(to_state.to_s)
        end
      end
    end

    describe 'callbacks' do
      describe 'setting started_at' do
        context 'when transitioning to in_progress for the first time' do
          it 'sets started_at' do
            freeze_time do
              rollout.start!

              expect(rollout.started_at).to be_like_time(Time.current)
            end
          end
        end

        context 'when resuming from paused' do
          before do
            rollout.update_columns(state: described_class.states['paused'], started_at: 1.hour.ago)
          end

          it 'does not overwrite started_at' do
            original_started_at = rollout.started_at

            rollout.resume!

            expect(rollout.started_at).to be_like_time(original_started_at)
          end
        end
      end

      describe 'setting finished_at' do
        it 'sets finished_at when entering a terminal state', :aggregate_failures do
          terminal_transitions = [
            { from: :in_progress, event: :complete, to: :completed },
            { from: :in_progress, event: :fail_rollout, to: :failed },
            { from: :in_progress, event: :cancel, to: :cancelled }
          ]

          terminal_transitions.each do |transition|
            # Each rollout needs its own application to satisfy the
            # one-active-rollout-per-application partial unique index.
            rollout = create(:cd_rollout, version_set: create(:cd_version_set), workflow_ref: 'wk:1/abc')
            rollout.update_column(:state, described_class.states[transition[:from].to_s])

            freeze_time do
              rollout.public_send(:"#{transition[:event]}!")

              expect(rollout.finished_at).to be_like_time(Time.current),
                "expected finished_at to be set when transitioning " \
                  "from #{transition[:from]} to #{transition[:to]} via #{transition[:event]}"
            end
          end
        end

        it 'does not set finished_at on non-terminal transitions', :aggregate_failures do
          non_terminal_transitions = [
            { from: :pending, event: :start, to: :in_progress },
            { from: :in_progress, event: :pause, to: :paused },
            { from: :paused, event: :resume, to: :in_progress }
          ]

          non_terminal_transitions.each do |transition|
            # Each rollout needs its own application to satisfy the
            # one-active-rollout-per-application partial unique index.
            rollout = create(:cd_rollout, version_set: create(:cd_version_set), workflow_ref: 'wk:1/abc')
            rollout.update_column(:state, described_class.states[transition[:from].to_s])

            rollout.public_send(:"#{transition[:event]}!")

            expect(rollout.finished_at).to be_nil,
              "expected finished_at to remain nil when transitioning " \
                "from #{transition[:from]} to #{transition[:to]} via #{transition[:event]}"
          end
        end
      end
    end
  end
end
