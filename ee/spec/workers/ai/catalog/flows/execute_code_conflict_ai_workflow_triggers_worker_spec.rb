# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Ai::Catalog::Flows::ExecuteCodeConflictAiWorkflowTriggersWorker,
  feature_category: :code_suggestions do
  let_it_be(:user) { create(:user) }
  let_it_be(:project) { create(:project) }
  let_it_be(:merge_request) do
    create(:merge_request, source_project: project, target_project: project, author: user)
  end

  let_it_be(:service_account) { create(:service_account) }
  let_it_be(:flow_trigger) do
    create(:ai_flow_trigger,
      project: project,
      user: service_account,
      event_types: [Ai::FlowTrigger::EVENT_TYPES[:merge_request_code_conflict]]
    )
  end

  let(:event) { MergeRequests::CodeConflictEvent.build(merge_request: merge_request) }

  it_behaves_like 'subscribes to event'

  describe '#handle_event' do
    subject(:handle_event) { described_class.new.handle_event(event) }

    let(:run_service) { instance_double(Ai::FlowTriggers::RunService) }
    let(:filter_evaluator) { instance_double(Ai::FlowTriggers::FilterEvaluator, allowed?: true) }

    before do
      allow(Ai::FlowTriggers::FilterEvaluator).to receive(:new).and_return(filter_evaluator)
      allow(Ai::FlowTriggers::RunService).to receive(:new).and_return(run_service)
      allow(run_service).to receive(:execute)
    end

    context 'when the event is not a MergeRequests::CodeConflictEvent' do
      let(:event) do
        MergeRequests::DraftStateChangeEvent.new(
          data: { current_user_id: user.id, merge_request_id: merge_request.id }
        )
      end

      it 'does not start a flow' do
        expect(run_service).not_to receive(:execute)

        handle_event
      end
    end

    context 'when the merge request does not exist' do
      let(:doomed_mr) do
        create(:merge_request, source_project: project, target_project: project, author: user, source_branch: 'doomed')
      end

      let(:event) { MergeRequests::CodeConflictEvent.build(merge_request: doomed_mr) }

      before do
        doomed_mr.destroy!
      end

      it 'does not start a flow' do
        expect(run_service).not_to receive(:execute)

        handle_event
      end
    end

    context 'when the user does not exist' do
      before do
        allow(event).to receive(:current_user).and_return(nil)
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
      it 'starts the flow and passes empty filter data (no action)', :aggregate_failures do
        expect(Ai::FlowTriggers::RunService).to receive(:new).with(
          project: project,
          current_user: user,
          flow_trigger: flow_trigger,
          resource: merge_request
        ).and_return(run_service)

        expect(run_service).to receive(:execute).with({
          input: merge_request.iid.to_s,
          event: :merge_request_code_conflict
        })

        expect(Ai::FlowTriggers::FilterEvaluator).to receive(:new).with(
          flow_trigger: flow_trigger,
          hook_scope: :merge_request_code_conflict,
          data: {}
        ).and_return(filter_evaluator)

        handle_event
      end

      context 'when RunService raises an error' do
        it 'tracks the exception and continues' do
          allow(run_service).to receive(:execute).and_raise(StandardError.new('boom'))

          expect(Gitlab::ErrorTracking).to receive(:track_exception).with(
            instance_of(StandardError),
            hash_including(
              flow_trigger_id: flow_trigger.id,
              resource_id: merge_request.id,
              container_id: project.id
            )
          )

          handle_event
        end
      end
    end
  end
end
