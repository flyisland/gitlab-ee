# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Ai::Messaging::FeishuApprovalActionService, feature_category: :duo_agent_platform do
  let_it_be(:project) { create(:project) }
  let_it_be(:user, freeze: false) { create(:user, developer_of: project) }
  let_it_be(:workflow, freeze: false) do
    create(:duo_workflows_workflow, :tool_call_approval_required, project: project, user: user,
      workflow_definition: 'feishu_assistant/v1',
      messaging_callback_context: {
        'adapter' => 'feishu', 'app_id' => 'cli_app', 'chat_id' => 'oc_chat', 'sender_id' => 'feishu-user-1',
        'message_id' => 'om_question', 'status_ts' => 'card_open'
      })
  end

  let(:operator_user_id) { 'feishu-user-1' }
  let(:decision) { 'approve' }
  let(:value) do
    { 'duo_approval' => decision, 'workflow_id' => workflow.id, 'card_id' => 'card_open', 'fingerprint' => 'fp' }
  end

  let(:pending) { true }

  subject(:execute) { described_class.new(operator_user_id: operator_user_id, value: value).execute }

  before do
    stub_licensed_features(feishu_bot_integration: true)
    stub_application_setting(feishu_integration_enabled: true, feishu_app_key: 'cli_app', feishu_app_secret: 'secret')
    create(:feishu_bot_integration, :instance)
    create(:chat_name, user: user, team_id: Gitlab::Chatops::FeishuBotHandler::BIND_TEAM_ID, chat_id: 'feishu-user-1')
    stub_feature_flags(jh_feishu_duo_chat: user)
    allow(Ai::Messaging::ApprovalDecisionService).to receive(:pending?).and_return(pending)
  end

  def toast(type, content)
    { toast: { type: type, content: content } }
  end

  it 'hands the decision on the call the card was rendered for to a worker, as the invoker', :aggregate_failures do
    expect(Ai::Messaging::ApprovalDecisionService).to receive(:pending?).with(workflow, 'fp')
    expect(Ai::Messaging::ApprovalDecisionWorker).to receive(:perform_async)
      .with(workflow.id, user.id, true, 'fp', 'card_open')

    expect(execute).to eq(toast('success', s_('JH|DuoFeishu|Approved. Duo is continuing.')))
  end

  context 'when rejecting' do
    let(:decision) { 'reject' }

    it 'hands on a rejection and says so' do
      expect(Ai::Messaging::ApprovalDecisionWorker).to receive(:perform_async)
        .with(workflow.id, user.id, false, 'fp', 'card_open')

      expect(execute).to eq(toast('success', s_('JH|DuoFeishu|Cancelled that action.')))
    end
  end

  context 'when the request is no longer pending' do
    let(:pending) { false }

    it 'takes the buttons off the card and says why', :aggregate_failures do
      expect(Ai::Messaging::ApprovalDecisionWorker).not_to receive(:perform_async)
      expect(Ai::Messaging::Adapters::Feishu).to receive(:from_callback_context).and_wrap_original do |original, *a|
        original.call(*a).tap do |adapter|
          expect(adapter).to receive(:expire_approval_card).with('card_open', workflow)
        end
      end

      expect(execute).to match(toast('error', a_string_including('no longer waiting for your decision')))
    end
  end

  shared_examples 'a click that decides nothing' do |text|
    it 'answers without deciding' do
      expect(Ai::Messaging::ApprovalDecisionWorker).not_to receive(:perform_async)

      expect(execute).to match(toast('error', a_string_including(text)))
    end
  end

  context 'when someone else in the group clicks' do
    let(:operator_user_id) { 'feishu-user-2' }

    it_behaves_like 'a click that decides nothing', 'Only the person who started this session'
  end

  context 'when the invoker no longer has a bound account' do
    before do
      ChatName.delete_all
    end

    it_behaves_like 'a click that decides nothing', 'Connect your JiHu GitLab account'
  end

  context 'when the account is now bound to someone else' do
    before do
      ChatName.update_all(user_id: create(:user).id)
      stub_feature_flags(jh_feishu_duo_chat: true)
    end

    it 'leaves the ownership check to the decision' do
      expect(Ai::Messaging::ApprovalDecisionWorker).to receive(:perform_async)
        .with(workflow.id, ChatName.last.user_id, true, 'fp', 'card_open')

      execute
    end
  end

  context 'when the invoker is blocked' do
    before do
      user.block!
    end

    after do
      user.activate!
    end

    it_behaves_like 'a click that decides nothing', "don't have access to Duo"
  end

  context 'when the flag is off for the invoker' do
    before do
      stub_feature_flags(jh_feishu_duo_chat: false)
    end

    it_behaves_like 'a click that decides nothing', "don't have access to Duo"
  end

  context 'when the Feishu Bot integration is inactive' do
    before do
      Integrations::FeishuBot.for_instance.first.update_column(:active, false)
    end

    it_behaves_like 'a click that decides nothing', "don't have access to Duo"
  end

  context 'when the session is not a Feishu one' do
    before do
      workflow.update!(messaging_callback_context: workflow.messaging_callback_context.merge('adapter' => 'dingtalk'))
    end

    after do
      workflow.update!(messaging_callback_context: workflow.messaging_callback_context.merge('adapter' => 'feishu'))
    end

    it_behaves_like 'a click that decides nothing', 'no longer waiting for your decision'
  end

  context 'with a button that is not an approval' do
    let(:value) { { 'something' => 'else' } }

    it 'answers nothing' do
      expect(execute).to eq({})
    end
  end
end
