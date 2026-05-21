# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Ai::Messaging::CallbackWorker, feature_category: :duo_agent_platform do
  subject(:worker) { described_class.new }

  let_it_be(:project) { create(:project) }
  let_it_be(:user) { create(:user, developer_of: project) }

  let(:callback_context) { { 'adapter' => 'test_adapter', 'channel_id' => 'C123' } }

  let(:workflow) do
    create(:duo_workflows_workflow,
      user: user,
      project: project,
      messaging_callback_context: callback_context)
  end

  let(:workload) { create(:ci_workload) }

  let(:event) do
    Ci::Workloads::WorkloadFinishedEvent.new(
      data: { workload_id: workload.id, status: status }
    )
  end

  let(:status) { 'finished' }

  let(:test_adapter_class) do
    Class.new(Ai::Messaging::Adapters::Base) do
      attr_reader :delivered_results, :delivered_errors, :completed_flows, :failed_flows

      def initialize
        @delivered_results = []
        @delivered_errors = []
        @completed_flows = []
        @failed_flows = []
      end

      def deliver_result(callback_context:, message:)
        @delivered_results << { callback_context: callback_context, message: message }
      end

      def deliver_error(callback_context:, error:)
        @delivered_errors << { callback_context: callback_context, error: error }
      end

      def on_flow_completed(callback_context:, workflow:)
        @completed_flows << { callback_context: callback_context, workflow: workflow }
      end

      def on_flow_failed(callback_context:, error:)
        @failed_flows << { callback_context: callback_context, error: error }
        deliver_error(callback_context: callback_context, error: error)
      end
    end
  end

  let(:test_adapter_instance) { test_adapter_class.new }

  before do
    create(:duo_workflows_workload, workflow: workflow, workload: workload, project: project)
    stub_const("#{described_class}::ADAPTER_REGISTRY", { 'test_adapter' => test_adapter_class })
    allow(test_adapter_class).to receive(:new).and_return(test_adapter_instance)
  end

  describe '#handle_event' do
    context 'when workload does not exist' do
      let(:event) do
        Ci::Workloads::WorkloadFinishedEvent.new(
          data: { workload_id: non_existing_record_id, status: 'finished' }
        )
      end

      it 'returns early without error' do
        expect { worker.handle_event(event) }.not_to raise_error
      end
    end

    context 'when workflow has no messaging_callback_context' do
      before do
        workflow.update_column(:messaging_callback_context, nil)
      end

      it 'skips processing' do
        worker.handle_event(event)
        expect(test_adapter_instance.delivered_results).to be_empty
      end
    end

    context 'when adapter is not registered' do
      let(:callback_context) { { 'adapter' => 'unknown', 'channel_id' => 'C123' } }

      it 'logs a warning and skips processing' do
        worker.handle_event(event)
        expect(test_adapter_instance.delivered_results).to be_empty
      end
    end

    context 'when flow finished successfully' do
      context 'with a final agent message in checkpoints' do
        before do
          create(:duo_workflows_checkpoint,
            workflow: workflow,
            project: project,
            checkpoint: {
              'channel_values' => {
                'ui_chat_log' => [
                  { 'message_type' => 'user', 'content' => 'Fix CI' },
                  { 'message_type' => 'agent', 'content' => 'I fixed the pipeline.' }
                ]
              }
            })
        end

        it 'delivers the result to the adapter' do
          worker.handle_event(event)

          expect(test_adapter_instance.delivered_results).to contain_exactly(
            hash_including(message: 'I fixed the pipeline.')
          )
        end

        it 'calls on_flow_completed' do
          worker.handle_event(event)

          expect(test_adapter_instance.completed_flows).to contain_exactly(
            hash_including(workflow: workflow)
          )
        end
      end

      context 'when latest checkpoint has nil checkpoint data' do
        let(:checkpoint_record) do
          create(:duo_workflows_checkpoint,
            workflow: workflow,
            project: project,
            checkpoint: { 'channel_values' => {} })
        end

        before do
          checkpoint_record
          allow(checkpoint_record).to receive(:checkpoint).and_return(nil)
          allow(workflow.checkpoints).to receive(:latest).and_return(checkpoint_record)
        end

        it 'calls on_flow_failed with :no_response' do
          worker.handle_event(event)

          expect(test_adapter_instance.failed_flows).to contain_exactly(
            hash_including(error: :no_response)
          )
        end
      end

      context 'when checkpoint has no channel_values' do
        before do
          create(:duo_workflows_checkpoint,
            workflow: workflow,
            project: project,
            checkpoint: { 'some_other_key' => 'value' })
        end

        it 'calls on_flow_failed with :no_response' do
          worker.handle_event(event)

          expect(test_adapter_instance.failed_flows).to contain_exactly(
            hash_including(error: :no_response)
          )
        end
      end

      context 'when chat log contains only user messages' do
        before do
          create(:duo_workflows_checkpoint,
            workflow: workflow,
            project: project,
            checkpoint: {
              'channel_values' => {
                'ui_chat_log' => [
                  { 'message_type' => 'user', 'content' => 'Fix CI' }
                ]
              }
            })
        end

        it 'calls on_flow_failed with :no_response' do
          worker.handle_event(event)

          expect(test_adapter_instance.failed_flows).to contain_exactly(
            hash_including(error: :no_response)
          )
        end
      end

      context 'when checkpoints have no agent message' do
        before do
          create(:duo_workflows_checkpoint,
            workflow: workflow,
            project: project,
            checkpoint: { 'channel_values' => { 'ui_chat_log' => [] } })
        end

        it 'calls on_flow_failed with :no_response' do
          worker.handle_event(event)

          expect(test_adapter_instance.failed_flows).to contain_exactly(
            hash_including(error: :no_response)
          )
        end
      end

      context 'when no checkpoints exist' do
        it 'calls on_flow_failed with :no_response' do
          worker.handle_event(event)

          expect(test_adapter_instance.failed_flows).to contain_exactly(
            hash_including(error: :no_response)
          )
        end
      end
    end

    context 'when flow failed' do
      let(:status) { 'failed' }

      it 'calls on_flow_failed with :flow_failed' do
        worker.handle_event(event)

        expect(test_adapter_instance.failed_flows).to contain_exactly(
          hash_including(error: :flow_failed)
        )
      end
    end
  end

  describe 'worker configuration' do
    it { expect(described_class.get_feature_category).to eq(:duo_agent_platform) }

    it 'subscribes to WorkloadFinishedEvent' do
      subscriptions = Gitlab::EventStore.instance.subscriptions[Ci::Workloads::WorkloadFinishedEvent]
      worker_classes = subscriptions.map(&:worker)
      expect(worker_classes).to include(described_class)
    end
  end
end
