# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Ai::Messaging::ApprovalDecisionWorker, feature_category: :duo_agent_platform do
  let_it_be(:user) { create(:user) }
  let_it_be(:feishu_context) do
    {
      'adapter' => 'feishu', 'app_id' => 'cli_app', 'chat_id' => 'oc_chat', 'sender_id' => 'feishu-user-1',
      'message_id' => 'om_question', 'status_ts' => 'card_open'
    }
  end

  let_it_be_with_reload(:workflow) do
    create(:duo_workflows_workflow, user: user, messaging_callback_context: feishu_context)
  end

  let(:approved) { true }
  let(:result) { ServiceResponse.success(payload: { card_rolled: true }) }
  let(:service) { instance_double(Ai::Messaging::ApprovalDecisionService, execute: result) }

  subject(:perform) { described_class.new.perform(workflow.id, user.id, approved, 'fp', 'card_open') }

  before do
    allow(Ai::Messaging::ApprovalDecisionService).to receive(:new).and_return(service)
  end

  it 'decides through the shared service, from the session\'s own card' do
    expect(Ai::Messaging::ApprovalDecisionService).to receive(:new).with(
      workflow: workflow, current_user: user, adapter: an_instance_of(Ai::Messaging::Adapters::Feishu),
      approved: true, fingerprint: 'fp', note: 'Approved. Duo is continuing.'
    )

    perform
  end

  context 'when rejecting' do
    let(:approved) { false }

    it 'notes the cancellation on the settled card' do
      expect(Ai::Messaging::ApprovalDecisionService).to receive(:new)
        .with(hash_including(approved: false, note: 'Cancelled that action.'))

      perform
    end
  end

  context 'for a DingTalk session' do
    before do
      workflow.update!(messaging_callback_context: {
        'adapter' => 'dingtalk', 'corp_id' => 'corp', 'conversation_id' => 'cid', 'conversation_type' => '1',
        'sender_staff_id' => 'staff123', 'status_ts' => 'card_open'
      })
    end

    it 'decides through the DingTalk adapter' do
      expect(Ai::Messaging::ApprovalDecisionService).to receive(:new)
        .with(hash_including(adapter: an_instance_of(Ai::Messaging::Adapters::Dingtalk)))

      perform
    end
  end

  context 'when the decision is refused' do
    let(:result) do
      ServiceResponse.error(message: 'gone', reason: :approval_not_pending, payload: { cause: :stale_request })
    end

    it 'takes the buttons off the clicked card with why' do
      expect_next_instance_of(Ai::Messaging::Adapters::Feishu) do |adapter|
        expect(adapter).to receive(:expire_approval_card)
          .with('card_open', workflow, note: a_string_including('no longer waiting'))
      end

      perform
    end
  end

  context 'when a reply is deciding the same call' do
    let(:result) do
      ServiceResponse.error(message: 'busy', reason: :approval_not_pending, payload: { cause: :decision_in_progress })
    end

    it 'leaves the card to that decision' do
      allow_next_instance_of(Ai::Messaging::Adapters::Feishu) do |adapter|
        expect(adapter).not_to receive(:expire_approval_card)
      end

      perform
    end
  end

  it 'does nothing for a session that is gone' do
    expect(Ai::Messaging::ApprovalDecisionService).not_to receive(:new)

    described_class.new.perform(non_existing_record_id, user.id, true, 'fp', 'card_open')
  end

  it 'does nothing for a session no chat surface started' do
    workflow.update!(messaging_callback_context: { 'adapter' => 'slack' })

    expect(Ai::Messaging::ApprovalDecisionService).not_to receive(:new)

    perform
  end
end
