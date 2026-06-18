# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Ai::Catalog::Flows::ExecuteWorkItemCreatedWorkflowTriggersWorker, feature_category: :code_suggestions do
  let_it_be(:user) { create(:user) }
  let_it_be(:project) { create(:project) }
  let_it_be(:work_item) { create(:work_item, project: project, author: user) }
  let_it_be(:service_account) { create(:service_account) }
  let_it_be(:flow_trigger) do
    create(:ai_flow_trigger,
      project: project,
      user: service_account,
      event_types: [Ai::FlowTrigger::EVENT_TYPES[:work_item]]
    )
  end

  let(:cloud_event) do
    WorkItems::CreatedEvent.build(
      work_item: work_item,
      current_user: user
    )
  end

  let(:event) { cloud_event }

  it_behaves_like 'subscribes to event'

  describe '#handle_event' do
    subject(:handle_event) { described_class.new.handle_event(cloud_event) }

    let(:filter_evaluator) { instance_double(Ai::FlowTriggers::FilterEvaluator, allowed?: true) }
    let(:run_service) { instance_double(Ai::FlowTriggers::RunService) }

    before do
      allow(Ai::FlowTriggers::FilterEvaluator).to receive(:new).and_return(filter_evaluator)
      allow(Ai::FlowTriggers::RunService).to receive(:new).and_return(run_service)
      allow(run_service).to receive(:execute)
    end

    context 'when the event is not a WorkItems::CreatedEvent' do
      let(:cloud_event) do
        WorkItems::WorkItemCreatedEvent.new(
          data: {
            id: work_item.id,
            namespace_id: work_item.namespace_id
          }
        )
      end

      it 'does not start a flow' do
        expect(run_service).not_to receive(:execute)

        handle_event
      end
    end

    context 'when the work item does not exist' do
      let(:doomed_work_item) { create(:work_item, project: project, author: user) }

      let(:cloud_event) do
        WorkItems::CreatedEvent.build(
          work_item: doomed_work_item,
          current_user: user
        )
      end

      before do
        doomed_work_item.destroy!
      end

      it 'does not start a flow' do
        expect(run_service).not_to receive(:execute)

        handle_event
      end
    end

    context 'when the user does not exist' do
      before do
        allow(cloud_event).to receive(:current_user).and_return(nil)
      end

      it 'does not start a flow' do
        expect(run_service).not_to receive(:execute)

        handle_event
      end
    end

    context 'when the filter does not match' do
      let(:filter_evaluator) { instance_double(Ai::FlowTriggers::FilterEvaluator, allowed?: false) }

      it 'does not start a flow' do
        expect(run_service).not_to receive(:execute)

        handle_event
      end
    end

    context 'when flow triggers exist and conditions are met' do
      it 'evaluates the filter and starts a flow with the correct arguments', :aggregate_failures do
        expect(Ai::FlowTriggers::FilterEvaluator).to receive(:new).with(
          flow_trigger: flow_trigger,
          hook_scope: :work_item,
          data: { 'action' => 'created' }
        ).and_return(filter_evaluator)

        expect(Ai::FlowTriggers::RunService).to receive(:new).with(
          project: project,
          current_user: user,
          flow_trigger: flow_trigger,
          resource: work_item
        ).and_return(run_service)

        expect(run_service).to receive(:execute).with({
          input: work_item.iid.to_s,
          event: :work_item,
          action: 'created'
        })

        handle_event
      end

      context 'when RunService raises an error' do
        it 'tracks the exception and continues' do
          allow(run_service).to receive(:execute).and_raise(StandardError.new('boom'))

          expect(Gitlab::ErrorTracking).to receive(:track_exception).with(
            instance_of(StandardError),
            hash_including(
              flow_trigger_id: flow_trigger.id,
              resource_id: work_item.id,
              container_id: project.id
            )
          )

          handle_event
        end
      end
    end
  end
end
