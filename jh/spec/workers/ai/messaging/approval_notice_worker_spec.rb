# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Ai::Messaging::ApprovalNoticeWorker, feature_category: :duo_agent_platform do
  let_it_be(:callback_context) do
    {
      'adapter' => 'dingtalk',
      'corp_id' => 'corp-1',
      'conversation_id' => 'cid-1',
      'conversation_type' => '1',
      'sender_staff_id' => 'staff-1'
    }
  end

  let_it_be_with_reload(:workflow) do
    create(:duo_workflows_workflow, :tool_call_approval_required, messaging_callback_context: callback_context)
  end

  subject(:perform) { described_class.new.perform(workflow.id) }

  def stub_delivery(result)
    allow_next_instance_of(::Ai::Messaging::Adapters::Dingtalk) do |adapter|
      allow(adapter).to receive(:deliver_approval_request).and_return(result)
    end
  end

  it 'asks the invoker to decide' do
    stub_delivery(true)

    expect(described_class).not_to receive(:perform_in)

    perform
  end

  # The checkpoint carrying the request can land after the status change that
  # scheduled this, so a first look finding nothing is expected, not an error.
  it 'looks again when the pending call has not reached a checkpoint yet' do
    stub_delivery(false)

    expect(described_class).to receive(:perform_in).with(described_class::RETRY_IN, workflow.id, 2)

    perform
  end

  it 'gives up after the last attempt' do
    stub_delivery(false)

    expect(described_class).not_to receive(:perform_in)

    described_class.new.perform(workflow.id, described_class::MAX_ATTEMPTS)
  end

  context 'when the session is no longer waiting for a decision' do
    before do
      workflow.update_column(:status, ::Ai::DuoWorkflows::Workflow.state_machines[:status].states[:input_required].value)
    end

    it 'sends nothing' do
      expect(::Ai::Messaging::Adapters::Dingtalk).not_to receive(:from_callback_context)

      perform
    end
  end

  context 'with a Feishu session' do
    before do
      workflow.update!(messaging_callback_context: { 'adapter' => 'feishu', 'message_id' => 'om_question' })
    end

    it 'asks through the Feishu adapter' do
      expect_next_instance_of(::Ai::Messaging::Adapters::Feishu) do |adapter|
        expect(adapter).to receive(:deliver_approval_request).and_return(true)
      end

      perform
    end
  end

  context 'with a session from another surface' do
    before do
      workflow.update!(messaging_callback_context: callback_context.merge('adapter' => 'slack'))
    end

    it 'sends nothing' do
      expect(::Ai::Messaging::Adapters::Dingtalk).not_to receive(:from_callback_context)

      perform
    end
  end

  context 'when the workflow is gone' do
    it 'does nothing' do
      expect { described_class.new.perform(non_existing_record_id) }.not_to raise_error
    end
  end
end
