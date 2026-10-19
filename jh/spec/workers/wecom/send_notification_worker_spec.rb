# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Wecom::SendNotificationWorker, feature_category: :integrations do
  let_it_be(:user, reload: true) { create(:user) }
  let_it_be(:identity, refind: true) { create(:identity, user: user, provider: 'wecom', extern_uid: 'ww_corp:member') }
  let(:client) { instance_double(Gitlab::Wecom::AppClient) }
  let(:payload) do
    {
      'user_id' => user.id, 'recipient' => 'member', 'corp_id' => 'ww_corp',
      'attributes' => { 'title' => 'Notification', 'url' => 'https://gitlab.example.com/project' }
    }
  end

  before do
    allow(Gitlab::Wecom::App).to receive_messages(notifications_available?: true, corp_id: 'ww_corp')
    allow(Gitlab::Wecom::AppClient).to receive(:new).and_return(client)
    allow(client).to receive(:send_card).and_return(
      Gitlab::Wecom::AppClient::Result.new(message_id: 'message', invalid_user_ids: [])
    )
    JH::Users::WecomNotification.set(user, true)
  end

  def run
    described_class.new.perform('note_issue_email', payload)
  end

  it 'delivers the extracted content without rendering another email' do
    expect(Notify).not_to receive(:new)
    expect(client).to receive(:send_card).with(['member'], kind_of(Hash))

    run
  end

  [:opt_out, :unbound, :blocked, :changed_tenant, :changed_identity, :disabled].each do |condition|
    it "skips delivery when #{condition}" do
      case condition
      when :opt_out then JH::Users::WecomNotification.set(user, false)
      when :unbound then identity.destroy!
      when :blocked then user.block!
      when :changed_tenant then allow(Gitlab::Wecom::App).to receive(:corp_id).and_return('ww_other')
      when :changed_identity then identity.update!(extern_uid: 'ww_corp:other')
      when :disabled then allow(Gitlab::Wecom::App).to receive(:notifications_available?).and_return(false)
      end

      expect(client).not_to receive(:send_card)

      run
    end
  end

  it_behaves_like 'an idempotent worker' do
    let(:job_args) { ['note_issue_email', payload] }
  end
end
