# frozen_string_literal: true

# Inline dispatch behavior shared by both messaging callback workers: given a
# DB-only adapter, each worker resolves it and fires the matching lifecycle hook
# inline (CallbackDispatchWorker only forwards external-dependency adapters;
# CallbackWorker never forwards). Forwarding and subscription wiring are covered
# in each worker's own spec.
RSpec.shared_examples 'an Ai::Messaging callback dispatcher' do
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
      attr_reader :delivered_results, :delivered_errors, :started_flows, :completed_flows, :failed_flows

      def self.adapter_key
        'test_adapter'
      end

      # DB-only, so both workers process it inline (CallbackDispatchWorker does
      # not forward it).
      def self.has_external_dependencies?
        false
      end

      def self.from_callback_context(_ctx)
        new
      end

      def initialize
        @delivered_results = []
        @delivered_errors = []
        @started_flows = []
        @completed_flows = []
        @failed_flows = []
      end

      def on_flow_started(callback_context:, workflow:)
        @started_flows << { callback_context: callback_context, workflow: workflow }
      end

      def build_callback_context
        {}
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

      def on_flow_failed(callback_context:, error:, workflow: nil)
        @failed_flows << { callback_context: callback_context, error: error, workflow: workflow }
        deliver_error(callback_context: callback_context, error: error)
      end
    end
  end

  let(:test_adapter_instance) { test_adapter_class.new }

  before do
    create(:duo_workflows_workload, workflow: workflow, workload: workload, project: project)

    stub_const('Ai::Messaging::AdapterRegistry::ADAPTERS', { 'test_adapter' => test_adapter_class }.freeze)
    allow(test_adapter_class).to receive(:from_callback_context).and_return(test_adapter_instance)
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
        expect(Gitlab::AppLogger).to receive(:warn).with(hash_including(adapter: 'unknown'))

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

        it 'calls on_flow_failed with :no_response and the workflow' do
          worker.handle_event(event)

          expect(test_adapter_instance.failed_flows).to contain_exactly(
            hash_including(error: :no_response, workflow: workflow)
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

        it 'calls on_flow_failed with :no_response and the workflow' do
          worker.handle_event(event)

          expect(test_adapter_instance.failed_flows).to contain_exactly(
            hash_including(error: :no_response, workflow: workflow)
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

        it 'calls on_flow_failed with :no_response and the workflow' do
          worker.handle_event(event)

          expect(test_adapter_instance.failed_flows).to contain_exactly(
            hash_including(error: :no_response, workflow: workflow)
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

        it 'calls on_flow_failed with :no_response and the workflow' do
          worker.handle_event(event)

          expect(test_adapter_instance.failed_flows).to contain_exactly(
            hash_including(error: :no_response, workflow: workflow)
          )
        end
      end

      context 'when no checkpoints exist' do
        it 'calls on_flow_failed with :no_response and the workflow' do
          worker.handle_event(event)

          expect(test_adapter_instance.failed_flows).to contain_exactly(
            hash_including(error: :no_response, workflow: workflow)
          )
        end
      end
    end

    context 'when flow failed' do
      let(:status) { 'failed' }

      it 'calls on_flow_failed with :flow_failed and the workflow' do
        worker.handle_event(event)

        expect(test_adapter_instance.failed_flows).to contain_exactly(
          hash_including(error: :flow_failed, workflow: workflow)
        )
      end
    end

    context 'when handling a WorkflowStartedEvent' do
      let(:event) do
        Ai::DuoWorkflows::WorkflowStartedEvent.new(data: { workflow_id: workflow.id })
      end

      it 'calls on_flow_started with the workflow' do
        worker.handle_event(event)

        expect(test_adapter_instance.started_flows).to contain_exactly(
          hash_including(workflow: workflow)
        )
      end

      context 'when the workflow does not exist' do
        let(:event) do
          Ai::DuoWorkflows::WorkflowStartedEvent.new(data: { workflow_id: non_existing_record_id })
        end

        it 'returns early without error' do
          expect { worker.handle_event(event) }.not_to raise_error
          expect(test_adapter_instance.started_flows).to be_empty
        end
      end

      context 'when the workflow has no messaging_callback_context' do
        before do
          workflow.update_column(:messaging_callback_context, nil)
        end

        it 'skips processing' do
          worker.handle_event(event)
          expect(test_adapter_instance.started_flows).to be_empty
        end
      end

      context 'when on_flow_started raises an error' do
        before do
          allow(test_adapter_instance).to receive(:on_flow_started).and_raise(StandardError, 'started hook failed')
        end

        it 'tracks the exception without re-raising' do
          expect(::Gitlab::ErrorTracking).to receive(:track_and_log_exception)

          expect { worker.handle_event(event) }.not_to raise_error
        end
      end
    end

    context 'when deliver_result raises an error' do
      before do
        create(:duo_workflows_checkpoint,
          workflow: workflow,
          project: project,
          checkpoint: {
            'channel_values' => {
              'ui_chat_log' => [
                { 'message_type' => 'agent', 'content' => 'Result' }
              ]
            }
          })

        allow(test_adapter_instance).to receive(:deliver_result).and_raise(StandardError, 'delivery failed')
      end

      it 'tracks the exception and still calls on_flow_completed' do
        expect(::Gitlab::ErrorTracking).to receive(:track_and_log_exception).at_least(:once)

        worker.handle_event(event)

        expect(test_adapter_instance.completed_flows).to contain_exactly(
          hash_including(workflow: workflow)
        )
      end
    end

    context 'when on_flow_completed raises an error' do
      before do
        create(:duo_workflows_checkpoint,
          workflow: workflow,
          project: project,
          checkpoint: {
            'channel_values' => {
              'ui_chat_log' => [
                { 'message_type' => 'agent', 'content' => 'Result' }
              ]
            }
          })

        allow(test_adapter_instance).to receive(:on_flow_completed).and_raise(StandardError, 'completed hook failed')
      end

      it 'tracks the exception without re-raising' do
        expect(::Gitlab::ErrorTracking).to receive(:track_and_log_exception)

        expect { worker.handle_event(event) }.not_to raise_error
      end
    end
  end

  describe 'worker configuration' do
    it { expect(described_class.get_feature_category).to eq(:duo_agent_platform) }
  end
end
