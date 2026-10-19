# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Ai::Messaging::ApprovalDecisionService, :clean_gitlab_redis_shared_state,
  feature_category: :duo_agent_platform do
  include ExclusiveLeaseHelpers
  using RSpec::Parameterized::TableSyntax

  let_it_be(:project) { create(:project) }
  let_it_be(:user) { create(:user, developer_of: project) }

  let(:workflow) do
    create(:duo_workflows_workflow, :tool_call_approval_required, project: project, user: user,
      workflow_definition: 'feishu_assistant/v1', messaging_callback_context: { 'adapter' => 'feishu' })
  end

  let(:request_entry) do
    { 'message_type' => 'request', 'message_id' => 'toolu_1', 'content' => 'Create issue',
      'tool_info' => { 'name' => 'create_issue', 'args' => {} } }
  end

  let(:fingerprint) { Ai::DuoWorkflows::PendingToolApproval.new(request_entry).fingerprint }
  let(:adapter) do
    instance_double(Ai::Messaging::Adapters::Feishu, class: Ai::Messaging::Adapters::Feishu,
      roll_card_for_decision: true, deliver_error: nil)
  end

  let(:authorization) { ServiceResponse.success }
  let(:resolution) { ServiceResponse.success }
  let(:resolver) { instance_double(Ai::DuoWorkflows::ResolveToolApprovalService, execute: resolution) }

  subject(:execute) do
    described_class.new(
      workflow: workflow, current_user: user, adapter: adapter,
      approved: false, fingerprint: fingerprint, message: 'not that one', note: 'Cancelled.'
    ).execute
  end

  before do
    allow(workflow).to receive(:latest_ui_chat_log).and_return([request_entry])
    allow(Ai::DuoWorkflows::FlowExecutionAuthorizer).to receive(:for_background_caller)
      .and_return(instance_double(Ai::DuoWorkflows::FlowExecutionAuthorizer, execute: authorization))
    allow(Ai::DuoWorkflows::ResolveToolApprovalService).to receive(:new).and_return(resolver)
  end

  it 'rolls the card before the turn resumes, then resolves the call through upstream', :aggregate_failures do
    expect(adapter).to receive(:roll_card_for_decision).with(workflow: workflow, note: 'Cancelled.').ordered
    expect(Ai::DuoWorkflows::ResolveToolApprovalService).to receive(:new).with(
      workflow: workflow, current_user: user, approved: false, fingerprint: fingerprint,
      message: 'not that one', surface: 'feishu'
    ).ordered.and_return(resolver)

    expect(execute).to be_success.and have_attributes(payload: { card_rolled: true })
  end

  it 're-checks that the invoker may still run the flow' do
    expect(Ai::DuoWorkflows::FlowExecutionAuthorizer).to receive(:for_background_caller).with(
      current_user: user, container: project, workflow_definition: 'feishu_assistant/v1',
      resolve_service_account: false
    )

    execute
  end

  shared_examples 'a decision that touches nothing' do |reason|
    it 'neither rolls the card nor resolves the call', :aggregate_failures do
      expect(adapter).not_to receive(:roll_card_for_decision)
      expect(Ai::DuoWorkflows::ResolveToolApprovalService).not_to receive(:new)

      expect(execute).to be_error.and have_attributes(reason: reason)
    end
  end

  context 'when the invoker may no longer run the flow' do
    let(:authorization) { ServiceResponse.error(message: 'no', reason: :forbidden) }

    it_behaves_like 'a decision that touches nothing', :forbidden
  end

  context 'when the session is waiting on another call' do
    before do
      allow(workflow).to receive(:latest_ui_chat_log).and_return([request_entry.merge('message_id' => 'toolu_2')])
    end

    it_behaves_like 'a decision that touches nothing', :approval_not_pending
  end

  context 'when the call was already answered' do
    before do
      workflow.merge_messaging_callback_context!('answered_approval' => fingerprint)
    end

    it_behaves_like 'a decision that touches nothing', :approval_not_pending
  end

  context 'when another decision on the session is being made' do
    before do
      stub_exclusive_lease_taken("jh_ai_messaging_approval_decision:#{workflow.id}")
    end

    it_behaves_like 'a decision that touches nothing', :approval_not_pending

    it 'says why, for callers that must not act on it' do
      expect(execute.payload[:cause]).to eq(:decision_in_progress)
    end
  end

  context 'when upstream refuses the decision after the card was rolled' do
    where(:upstream_reason, :reason) do
      :stale_request   | :approval_not_pending
      :not_owner       | :forbidden
      :not_authorized  | :forbidden
      :continue_failed | :execute_workflow_failed
    end

    with_them do
      let(:resolution) { ServiceResponse.error(message: 'refused', reason: upstream_reason) }

      it 'settles the new card with why, rather than leave it waiting', :aggregate_failures do
        expect(adapter).to receive(:deliver_error)
          .with(callback_context: workflow.messaging_callback_context, error: reason)

        expect(execute).to be_error.and have_attributes(reason: reason, payload: { cause: upstream_reason })
      end
    end
  end

  describe '.pending?' do
    it 'is true only for the call the session waits on, while unanswered', :aggregate_failures do
      expect(described_class.pending?(workflow, fingerprint)).to be(true)
      expect(described_class.pending?(workflow, 'other')).to be(false)
      expect(described_class.pending?(workflow, '')).to be(false)

      workflow.merge_messaging_callback_context!('answered_approval' => fingerprint)

      expect(described_class.pending?(workflow, fingerprint)).to be(false)
    end
  end
end
