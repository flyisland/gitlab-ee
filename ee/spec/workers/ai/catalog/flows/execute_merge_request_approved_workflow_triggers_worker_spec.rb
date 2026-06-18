# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Ai::Catalog::Flows::ExecuteMergeRequestApprovedWorkflowTriggersWorker, feature_category: :code_suggestions do
  let_it_be(:user) { create(:user) }
  let_it_be(:project) { create(:project, :repository) }
  let_it_be(:merge_request) { create(:merge_request, source_project: project, target_project: project) }
  let_it_be(:service_account) { create(:service_account) }
  let_it_be(:flow_trigger) do
    create(:ai_flow_trigger,
      project: project,
      user: service_account,
      event_types: [Ai::FlowTrigger::EVENT_TYPES[:merge_request]]
    )
  end

  let(:approved_at) { Time.zone.parse('2026-05-08T10:00:00Z') }
  let(:cloud_event) do
    MergeRequests::ApprovedCloudEvent.build(
      merge_request: merge_request,
      current_user: user,
      approval: instance_double(Approval, created_at: approved_at)
    )
  end

  let(:event) { cloud_event }

  it_behaves_like 'subscribes to event'

  describe '#handle_event' do
    subject(:handle_event) { described_class.new.handle_event(cloud_event) }

    let(:approval_state) { instance_double(ApprovalState, approved?: true) }
    let(:approvals_relation) { instance_double(ActiveRecord::Relation) }
    let(:filter_evaluator) { instance_double(Ai::FlowTriggers::FilterEvaluator, allowed?: true) }
    let(:run_service) { instance_double(Ai::FlowTriggers::RunService) }

    before do
      allow_next_found_instance_of(MergeRequest) do |mr|
        allow(mr).to receive_messages(
          approval_state: approval_state,
          approvals: approvals_relation
        )
      end
      allow(approvals_relation).to receive(:maximum).with(:created_at).and_return(approved_at)
      allow(Ai::FlowTriggers::FilterEvaluator).to receive(:new).and_return(filter_evaluator)
      allow(Ai::FlowTriggers::RunService).to receive(:new).and_return(run_service)
      allow(run_service).to receive(:execute)
    end

    context 'when all conditions are met' do
      it 'dispatches RunService' do
        expect(run_service).to receive(:execute)

        handle_event
      end
    end

    context 'when the event is not a MergeRequests::ApprovedCloudEvent' do
      let(:cloud_event) do
        MergeRequests::ApprovedEvent.new(
          data: {
            current_user_id: user.id,
            merge_request_id: merge_request.id,
            approved_at: approved_at.iso8601
          }
        )
      end

      it 'returns early without calling RunService' do
        expect(run_service).not_to receive(:execute)

        handle_event
      end
    end

    context 'when the merge request does not exist' do
      let(:doomed_mr) do
        create(:merge_request, source_project: project, target_project: project, source_branch: 'doomed-branch')
      end

      let(:cloud_event) do
        MergeRequests::ApprovedCloudEvent.build(
          merge_request: doomed_mr,
          current_user: user,
          approval: instance_double(Approval, created_at: approved_at)
        )
      end

      before do
        doomed_mr.destroy!
      end

      it 'returns early without calling RunService' do
        expect(run_service).not_to receive(:execute)

        handle_event
      end
    end

    context 'when the user does not exist' do
      before do
        allow(cloud_event).to receive(:current_user).and_return(nil)
      end

      it 'returns early without calling RunService' do
        expect(run_service).not_to receive(:execute)

        handle_event
      end
    end

    context 'with approval-threshold checks' do
      context 'when the MR is not yet fully approved' do
        let(:approval_state) { instance_double(ApprovalState, approved?: false) }

        it 'does not dispatch flow triggers' do
          expect(run_service).not_to receive(:execute)

          handle_event
        end
      end

      context 'when a later approval exists (this approval did not cross the threshold)' do
        before do
          allow(approvals_relation).to receive(:maximum).with(:created_at)
            .and_return(approved_at + 1.minute)
        end

        it 'does not dispatch flow triggers' do
          expect(run_service).not_to receive(:execute)

          handle_event
        end
      end
    end

    context 'when the filter does not match (e.g. trigger configured for unapproved)' do
      let(:filter_evaluator) { instance_double(Ai::FlowTriggers::FilterEvaluator, allowed?: false) }

      it 'does not dispatch RunService' do
        expect(run_service).not_to receive(:execute)

        handle_event
      end
    end

    context 'when flow triggers exist and the threshold is crossed' do
      it 'evaluates the filter with action: approved' do
        expect(Ai::FlowTriggers::FilterEvaluator).to receive(:new).with(
          flow_trigger: flow_trigger,
          hook_scope: :merge_request,
          data: { 'action' => 'approved' }
        ).and_return(filter_evaluator)

        handle_event
      end

      it 'dispatches RunService with event: :merge_request and action: approved' do
        expect(Ai::FlowTriggers::RunService).to receive(:new).with(
          project: project,
          current_user: user,
          flow_trigger: flow_trigger,
          resource: merge_request
        ).and_return(run_service)

        expect(run_service).to receive(:execute).with({
          input: merge_request.iid.to_s,
          event: :merge_request,
          action: 'approved'
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
