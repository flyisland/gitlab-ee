# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Ai::Messaging::DingtalkApprovalActionService, feature_category: :duo_agent_platform do
  let_it_be(:project) { create(:project) }
  let_it_be(:user, freeze: false) { create(:user, developer_of: project) }
  let_it_be_with_reload(:workflow) do
    create(:duo_workflows_workflow, :tool_call_approval_required, project: project, user: user,
      workflow_definition: 'dingtalk_assistant/v1',
      messaging_callback_context: {
        'adapter' => 'dingtalk', 'corp_id' => 'dingtalk_corpid', 'conversation_id' => 'cid',
        'conversation_type' => '2', 'sender_staff_id' => 'staff123', 'status_ts' => 'duo-card'
      })
  end

  let(:token) { Ai::Messaging::Adapters::Dingtalk.approval_token(workflow.id, 'fp', 'duo-card') }
  let(:decision) { 'approve' }
  let(:clicker) { 'staff123' }
  let(:out_track_id) { 'duo-card' }
  let(:callback) do
    instance_double(Gitlab::Dingtalk::CardCallback,
      action?: true, corp_id: 'dingtalk_corpid', user_id: clicker, out_track_id: out_track_id,
      action_params: { 'decision' => decision, 'approval_token' => token })
  end

  let(:hide_buttons) do
    { cardData: { cardParamMap: { 'approval_token' => '' } }, cardUpdateOptions: { updateCardDataByKey: true } }
  end

  subject(:execute) { described_class.new(callback).execute }

  before do
    stub_licensed_features(dingtalk_integration: true)
    stub_application_setting(dingtalk_integration_enabled: true, dingtalk_app_key: 'key',
      dingtalk_app_secret: 'secret', dingtalk_corpid: 'dingtalk_corpid')
    create(:chat_name, user: user, team_id: 'dingtalk_corpid', chat_id: 'staff123')
    stub_feature_flags(jh_dingtalk_duo_chat: user)
  end

  it 'hands the decision on the call the card was rendered for to a worker, as the invoker', :aggregate_failures do
    expect(Ai::Messaging::ApprovalDecisionWorker).to receive(:perform_async)
      .with(workflow.id, user.id, true, 'fp', 'duo-card')

    expect(execute).to eq(hide_buttons)
  end

  context 'when rejecting' do
    let(:decision) { 'reject' }

    it 'hands on a rejection' do
      expect(Ai::Messaging::ApprovalDecisionWorker).to receive(:perform_async)
        .with(workflow.id, user.id, false, 'fp', 'duo-card')

      execute
    end
  end

  shared_examples 'a click that decides nothing' do |reason|
    it 'answers with an empty body and says why in the log', :aggregate_failures do
      expect(Ai::Messaging::ApprovalDecisionWorker).not_to receive(:perform_async)
      expect(Gitlab::AppLogger).to receive(:info).with(hash_including(Labkit::Fields::ERROR_TYPE => reason))

      expect(execute).to eq({})
    end
  end

  context 'with a decision the buttons do not send' do
    let(:decision) { 'maybe' }

    it_behaves_like 'a click that decides nothing', 'not_an_approval'
  end

  context 'with a forged token #security' do
    let(:token) { "#{workflow.id}:fp:duo-card" }

    it_behaves_like 'a click that decides nothing', 'invalid_token'
  end

  context 'with a token from another card #security' do
    let(:out_track_id) { 'duo-other-card' }

    it_behaves_like 'a click that decides nothing', 'invalid_token'
  end

  context 'when someone else in the group clicks #security' do
    let(:clicker) { 'staff456' }

    before do
      create(:chat_name, user: create(:user, developer_of: project), team_id: 'dingtalk_corpid', chat_id: 'staff456')
    end

    it_behaves_like 'a click that decides nothing', 'not_requester'
  end

  context 'when the invoker has disconnected their account' do
    before do
      ChatName.find_by(chat_id: 'staff123').destroy!
    end

    it_behaves_like 'a click that decides nothing', 'not_connected'
  end

  context 'when the feature is off for the invoker' do
    before do
      stub_feature_flags(jh_dingtalk_duo_chat: false)
    end

    it_behaves_like 'a click that decides nothing', 'forbidden'
  end

  context 'without the license' do
    before do
      stub_licensed_features(dingtalk_integration: false)
    end

    it_behaves_like 'a click that decides nothing', 'unavailable'
  end

  context 'for a session started elsewhere' do
    before do
      workflow.update!(messaging_callback_context: workflow.messaging_callback_context.merge('adapter' => 'feishu'))
    end

    it_behaves_like 'a click that decides nothing', 'unknown_session'
  end
end
