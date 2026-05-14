# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Security::PipelineExecutionSchedulePolicies::TestRunCompletionWorker, '#perform',
  feature_category: :security_policy_management do
  let_it_be(:pipeline) { create(:ci_pipeline) }
  let_it_be(:test_run) { create(:security_pipeline_execution_policy_test_run, pipeline: pipeline, state: :running) }

  let(:event) { Ci::PipelineFinishedEvent.new(data: { pipeline_id: pipeline.id, status: status }) }
  let(:status) { 'success' }

  subject(:perform) { consume_event(subscriber: described_class, event: event) }

  describe 'subscriptions' do
    it_behaves_like 'subscribes to event'
  end

  describe '#handle_event' do
    it_behaves_like 'an idempotent worker'

    it 'marks the test run complete' do
      expect { perform }.to change { test_run.reload.state }.from('running').to('complete')
    end

    context 'when pipeline status is failed' do
      let(:status) { 'failed' }

      it 'marks the test run failed' do
        expect { perform }.to change { test_run.reload.state }.from('running').to('failed')
      end
    end

    context 'when pipeline status is canceled' do
      let(:status) { 'canceled' }

      it 'marks the test run complete' do
        expect { perform }.to change { test_run.reload.state }.from('running').to('complete')
      end
    end

    context 'when pipeline status is success' do
      let(:status) { 'success' }

      it 'marks the test run complete' do
        expect { perform }.to change { test_run.reload.state }.from('running').to('complete')
      end
    end

    context 'when test run does not exist' do
      let(:event) { Ci::PipelineFinishedEvent.new(data: { pipeline_id: non_existing_record_id, status: status }) }

      it 'logs an error and does not raise' do
        expect(Gitlab::AppLogger)
          .to receive(:error)
          .with(hash_including('message' => 'Test run not found for pipeline', 'pipeline_id' => non_existing_record_id))

        expect { perform }.not_to raise_error
      end
    end
  end
end
