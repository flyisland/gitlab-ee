# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Ai::DuoWorkflows::ResolveToolApprovalService, feature_category: :duo_agent_platform do
  let_it_be(:project) { create(:project) }
  let_it_be(:user) { create(:user, developer_of: project) }

  let(:workflow) do
    create(:duo_workflows_workflow, :tool_call_approval_required, project: project, user: user,
      messaging_callback_context: { 'adapter' => 'feishu' })
  end

  let(:request_entry) do
    {
      'message_type' => 'request',
      'message_id' => 'toolu_01issue',
      'content' => 'Tool create_issue requires approval',
      'tool_info' => { 'name' => 'create_issue', 'args' => { 'title' => 'Bug report' } }
    }
  end

  let(:fingerprint) { Ai::DuoWorkflows::PendingToolApproval.new(request_entry).fingerprint }
  let(:start_run_service) do
    instance_double(Ai::DuoWorkflows::ExecuteRunService, execute: ServiceResponse.success(payload: {}))
  end

  subject(:execute) do
    described_class.new(
      workflow: workflow,
      current_user: user,
      approved: approved,
      fingerprint: fingerprint,
      surface: 'feishu',
      message: message
    ).execute
  end

  before do
    allow(workflow).to receive(:latest_ui_chat_log).and_return([request_entry])
    allow(user).to receive(:can?).and_call_original
    allow(user).to receive(:can?).with(:update_duo_workflow, workflow).and_return(true)
  end

  context 'when a rejection carries the user\'s words' do
    let(:approved) { false }
    let(:message) { 'name it after the bug instead' }

    it 'hands them to the agent, remembers the answer and audits the denial', :aggregate_failures do
      expect(Ai::DuoWorkflows::ExecuteRunService).to receive(:new).with(
        workflow, event: { type: :approval, approved: false, message: message }
      ).and_return(start_run_service)
      expect(::Gitlab::Audit::Auditor).to receive(:audit).with(hash_including(
        name: 'duo_tool_call_denied',
        message: 'Denied tool call: create_issue',
        additional_details: hash_including(approval_surface: 'feishu')
      ))

      expect(execute).to be_success
      expect(workflow.reload.messaging_callback_context['answered_approval']).to eq(fingerprint)
    end

    it 'refuses a second answer to the same call' do
      allow(Ai::DuoWorkflows::ExecuteRunService).to receive(:new).and_return(start_run_service)
      execute

      second = described_class.new(
        workflow: workflow, current_user: user, approved: true, fingerprint: fingerprint, surface: 'feishu'
      ).execute

      expect(second).to be_error.and have_attributes(reason: :stale_request)
    end
  end

  context 'without a message' do
    let(:approved) { false }
    let(:message) { ' ' }

    it 'leaves the event as upstream builds it' do
      expect(Ai::DuoWorkflows::ExecuteRunService).to receive(:new).with(
        workflow, event: { type: :approval, approved: false }
      ).and_return(start_run_service)

      expect(execute).to be_success
    end
  end

  context 'when approving' do
    let(:approved) { true }
    let(:message) { 'ignored' }

    it 'drops the message, which only a rejection carries' do
      expect(Ai::DuoWorkflows::ExecuteRunService).to receive(:new).with(
        workflow, event: { type: :approval, approved: true }
      ).and_return(start_run_service)

      expect(execute).to be_success
    end
  end
end
