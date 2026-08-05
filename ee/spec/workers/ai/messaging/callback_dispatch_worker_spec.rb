# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Ai::Messaging::CallbackDispatchWorker, feature_category: :duo_agent_platform do
  it_behaves_like 'an Ai::Messaging callback dispatcher'

  describe 'worker configuration' do
    it 'runs at high urgency without external dependencies', :aggregate_failures do
      expect(described_class.get_urgency).to eq(:high)
      expect(described_class.worker_has_external_dependencies?).to be(false)
    end
  end

  describe '#handle_event forwarding' do
    let_it_be(:project) { create(:project) }
    let_it_be(:user) { create(:user, developer_of: project) }

    let(:workflow) do
      create(:duo_workflows_workflow,
        user: user,
        project: project,
        messaging_callback_context: { 'adapter' => 'external_adapter' })
    end

    let(:event) { Ai::DuoWorkflows::WorkflowStartedEvent.new(data: { workflow_id: workflow.id }) }

    let(:external_adapter_class) do
      Class.new(Ai::Messaging::Adapters::Base) do
        attr_reader :started_flows

        def self.adapter_key
          'external_adapter'
        end

        def self.has_external_dependencies?
          true
        end

        def self.from_callback_context(_ctx)
          new
        end

        def initialize
          @started_flows = []
        end

        def on_flow_started(callback_context:, workflow:) # rubocop:disable Lint/UnusedMethodArgument -- interface contract
          @started_flows << workflow
        end
      end
    end

    let(:adapter_instance) { external_adapter_class.new }

    before do
      stub_const('Ai::Messaging::AdapterRegistry::ADAPTERS', { 'external_adapter' => external_adapter_class }.freeze)
      allow(external_adapter_class).to receive(:from_callback_context).and_return(adapter_instance)
    end

    it 'forwards external-dependency adapters to CallbackWorker without processing inline', :aggregate_failures do
      expect(Ai::Messaging::CallbackWorker)
        .to receive(:perform_async)
        .with('Ai::DuoWorkflows::WorkflowStartedEvent', event.data.deep_stringify_keys.to_h)

      described_class.new.handle_event(event)

      expect(adapter_instance.started_flows).to be_empty
    end
  end

  describe 'event subscription' do
    let_it_be(:project) { create(:project) }
    let_it_be(:user) { create(:user, developer_of: project) }
    let_it_be(:workflow) { create(:duo_workflows_workflow, user: user, project: project) }
    let_it_be(:workload) { create(:ci_workload) }

    before do
      create(:duo_workflows_workload, workflow: workflow, workload: workload, project: project)
    end

    # Flag defaults to enabled in tests, so the dispatcher is the subscriber.
    it_behaves_like 'subscribes to event' do
      let(:event) do
        Ci::Workloads::WorkloadFinishedEvent.new(data: { workload_id: workload.id, status: 'finished' })
      end
    end

    it_behaves_like 'subscribes to event' do
      let(:event) { Ai::DuoWorkflows::WorkflowStartedEvent.new(data: { workflow_id: workflow.id }) }
    end

    context 'when gitlab_duo_note_callback_high_urgency is disabled' do
      before do
        stub_feature_flags(gitlab_duo_note_callback_high_urgency: false)
      end

      it_behaves_like 'ignores the published event' do
        let(:event) { Ai::DuoWorkflows::WorkflowStartedEvent.new(data: { workflow_id: workflow.id }) }
      end
    end
  end
end
