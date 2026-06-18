# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Security::ScheduledPipelineExecutionPolicyTestRun, feature_category: :security_policy_management do
  describe 'associations' do
    it { is_expected.to belong_to(:security_policy).class_name('Security::Policy') }
    it { is_expected.to belong_to(:project) }
    it { is_expected.to belong_to(:pipeline).class_name('Ci::Pipeline').optional }

    describe '#pipeline' do
      it_behaves_like 'a partition-pruned pipeline association' do
        # .reload clears the :pipeline target cached by the attribute writer
        let(:related_resource) { create(:security_pipeline_execution_policy_test_run, pipeline: pipeline).reload }
      end
    end
  end

  describe 'validations' do
    let(:test_run) { build(:security_pipeline_execution_policy_test_run) }

    subject { test_run }

    it { is_expected.to be_valid }
    it { is_expected.to validate_presence_of(:security_policy) }
    it { is_expected.to validate_presence_of(:project) }

    context 'when security policy is not a pipeline_execution_schedule_policy' do
      let_it_be(:security_policy) { create(:security_policy, :pipeline_execution_policy) }
      let(:test_run) { build(:security_pipeline_execution_policy_test_run, security_policy: security_policy) }

      it { is_expected.not_to be_valid }
    end
  end

  describe 'enums' do
    it 'defines state enum with correct values' do
      is_expected.to define_enum_for(:state)
        .with_values(running: 0, complete: 1, failed: 2, pending: 3)
        .with_default(:pending)
    end
  end

  describe 'scopes' do
    describe '.for_pipeline_id' do
      subject(:for_pipeline_id) { described_class.for_pipeline_id(pipeline.id) }

      let_it_be(:project) { create(:project) }
      let_it_be(:pipeline) { create(:ci_pipeline, project: project) }
      let_it_be(:other_pipeline) { create(:ci_pipeline, project: project) }
      let_it_be(:test_run) { create(:security_pipeline_execution_policy_test_run, pipeline: pipeline) }
      let_it_be(:other_test_run) { create(:security_pipeline_execution_policy_test_run, pipeline: other_pipeline) }

      it 'returns only test runs for the specified pipeline' do
        is_expected.to contain_exactly(test_run)
      end
    end

    describe '.for_policy' do
      subject(:for_policy) { described_class.for_policy(test_run.security_policy) }

      let_it_be(:project) { create(:project) }
      let_it_be(:security_policy) { create(:security_policy, :pipeline_execution_schedule_policy) }
      let_it_be(:other_security_policy) { create(:security_policy, :pipeline_execution_schedule_policy) }
      let_it_be(:test_run) { create(:security_pipeline_execution_policy_test_run, security_policy: security_policy) }
      let_it_be(:other_test_run) do
        create(:security_pipeline_execution_policy_test_run, security_policy: other_security_policy)
      end

      it 'returns only test runs for the specified policy' do
        is_expected.to contain_exactly(test_run)
      end
    end

    describe '.with_associations' do
      let_it_be(:security_policy) { create(:security_policy, :pipeline_execution_schedule_policy) }
      let_it_be(:test_run_1) { create(:security_pipeline_execution_policy_test_run, security_policy: security_policy) }
      let_it_be(:test_run_2) { create(:security_pipeline_execution_policy_test_run, security_policy: security_policy) }

      subject(:with_associations) { described_class.with_associations }

      it 'preloads pipeline association' do
        expect(with_associations.first.association(:pipeline)).to be_loaded
      end

      it 'preloads project association' do
        expect(with_associations.first.association(:project)).to be_loaded
      end

      it 'orders by id descending' do
        expect(with_associations).to eq([test_run_2, test_run_1])
      end
    end
  end

  describe 'delegations' do
    let(:test_run) { create(:security_pipeline_execution_policy_test_run) }

    describe '#started_at' do
      it 'delegates to pipeline' do
        expect(test_run.started_at).to eq(test_run.pipeline.started_at)
      end
    end

    describe '#finished_at' do
      it 'delegates to pipeline' do
        expect(test_run.finished_at).to eq(test_run.pipeline.finished_at)
      end
    end

    describe '#duration' do
      it 'delegates to pipeline' do
        expect(test_run.duration).to eq(test_run.pipeline.duration)
      end
    end

    context 'when pipeline is nil' do
      let(:test_run) { create(:security_pipeline_execution_policy_test_run, pipeline: nil) }

      it 'returns nil for started_at' do
        expect(test_run.started_at).to be_nil
      end

      it 'returns nil for finished_at' do
        expect(test_run.finished_at).to be_nil
      end

      it 'returns nil for duration' do
        expect(test_run.duration).to be_nil
      end
    end
  end

  describe 'state transitions' do
    let(:test_run) { create(:security_pipeline_execution_policy_test_run, state: :running) }

    it 'starts in running state' do
      expect(test_run).to be_running
    end

    it 'can transition to complete' do
      test_run.update!(state: :complete)
      expect(test_run).to be_complete
    end

    it 'can transition to failed' do
      test_run.update!(state: :failed)
      expect(test_run).to be_failed
    end

    context 'when starting in pending state' do
      let(:test_run) { create(:security_pipeline_execution_policy_test_run, state: :pending, pipeline: nil) }

      it 'is in pending state' do
        expect(test_run).to be_pending
      end

      it 'can transition to running' do
        test_run.update!(state: :running)
        expect(test_run).to be_running
      end

      it 'can transition to failed' do
        test_run.update!(state: :failed)
        expect(test_run).to be_failed
      end
    end
  end

  describe '#completed?' do
    it 'returns false when pending' do
      test_run = build(:security_pipeline_execution_policy_test_run, state: :pending, pipeline: nil)

      expect(test_run.completed?).to be(false)
    end

    it 'returns false when running' do
      test_run = build(:security_pipeline_execution_policy_test_run, state: :running)

      expect(test_run.completed?).to be(false)
    end

    it 'returns true when complete' do
      test_run = build(:security_pipeline_execution_policy_test_run, state: :complete)

      expect(test_run.completed?).to be(true)
    end

    it 'returns true when failed' do
      test_run = build(:security_pipeline_execution_policy_test_run, state: :failed)

      expect(test_run.completed?).to be(true)
    end
  end

  describe 'error_message' do
    let(:test_run) { create(:security_pipeline_execution_policy_test_run, error_message: 'Test error') }

    it 'stores error message' do
      expect(test_run.error_message).to eq('Test error')
    end

    context 'when error_message exceeds limit' do
      let(:long_message) { 'a' * 256 }

      it 'truncates to 255 characters' do
        test_run = create(:security_pipeline_execution_policy_test_run, error_message: long_message)
        expect(test_run.error_message.length).to eq(255)
      end
    end
  end
end
