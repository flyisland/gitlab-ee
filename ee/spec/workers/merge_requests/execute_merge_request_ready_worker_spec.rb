# frozen_string_literal: true

require 'spec_helper'

RSpec.describe MergeRequests::ExecuteMergeRequestReadyWorker, feature_category: :code_suggestions do
  let_it_be(:user) { create(:user) }
  let_it_be(:project) { create(:project) }
  let_it_be(:merge_request) { create(:merge_request, source_project: project, target_project: project) }

  let(:event) do
    MergeRequests::DraftStateChangeEvent.new(
      data: { current_user_id: user.id, merge_request_id: merge_request.id, new_draft_status: false }
    )
  end

  it_behaves_like 'subscribes to event'

  describe '#handle_event' do
    subject(:handle_event) { described_class.new.handle_event(event) }

    context 'when the merge request does not exist' do
      let(:event) do
        MergeRequests::DraftStateChangeEvent.new(
          data: { current_user_id: user.id, merge_request_id: non_existing_record_id, new_draft_status: false }
        )
      end

      it 'returns early without calling RunService' do
        expect(Ai::FlowTriggers::RunService).not_to receive(:new)

        handle_event
      end
    end

    context 'when the user does not exist' do
      let(:event) do
        MergeRequests::DraftStateChangeEvent.new(
          data: {
            current_user_id: non_existing_record_id,
            merge_request_id: merge_request.id,
            new_draft_status: false
          }
        )
      end

      it 'returns early without calling RunService' do
        expect(Ai::FlowTriggers::RunService).not_to receive(:new)

        handle_event
      end
    end

    context 'when no flow triggers exist' do
      it 'does not call RunService' do
        expect(Ai::FlowTriggers::RunService).not_to receive(:new)

        handle_event
      end
    end

    context 'when flow triggers exist' do
      let_it_be(:service_account) { create(:service_account) }
      let_it_be(:flow_trigger) do
        create(:ai_flow_trigger,
          project: project,
          user: service_account,
          event_types: [Ai::FlowTrigger::EVENT_TYPES[:merge_request_ready]]
        )
      end

      let(:run_service) { instance_double(Ai::FlowTriggers::RunService) }

      before do
        allow(Ai::FlowTriggers::RunService).to receive(:new).and_return(run_service)
        allow(run_service).to receive(:execute)
      end

      it 'creates and executes RunService for each trigger' do
        expect(Ai::FlowTriggers::RunService).to receive(:new).with(
          project: project,
          current_user: user,
          flow_trigger: flow_trigger,
          resource: merge_request
        ).and_return(run_service)

        expect(run_service).to receive(:execute).with({
          input: merge_request.iid.to_s,
          event: :merge_request_ready
        })

        handle_event
      end
    end
  end
end
