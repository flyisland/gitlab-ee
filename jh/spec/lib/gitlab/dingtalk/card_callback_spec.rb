# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Gitlab::Dingtalk::CardCallback, feature_category: :duo_agent_platform do
  let(:corp_id) { 'dingtalk_corpid' }
  let(:secret) { 'card-secret' }
  let(:timestamp) { (Time.current.to_f * 1000).to_i.to_s }
  let(:signature) { Base64.strict_encode64(OpenSSL::HMAC.digest('SHA256', secret, timestamp)) }
  let(:headers) { { 'X-Ddpaas-Signature-Timestamp' => timestamp, 'X-Ddpaas-Signature' => signature } }
  let(:content) do
    Gitlab::Json.generate(
      'cardPrivateData' => {
        'actionIds' => ['button'], 'params' => { 'decision' => 'approve', 'approval_token' => 't' }
      }
    )
  end

  let(:params) do
    { type: 'actionCallback', corpId: corp_id, userId: 'staff123', outTrackId: 'duo-card', content: content }
      .with_indifferent_access
  end

  subject(:callback) { described_class.new(params, headers) }

  before do
    stub_licensed_features(dingtalk_integration: true)
    stub_application_setting(dingtalk_integration_enabled: true, dingtalk_app_key: 'key',
      dingtalk_app_secret: 'secret', dingtalk_corpid: corp_id)
    create(:dingtalk_integration, :instance, corpid: corp_id, card_callback_secret: secret)
  end

  describe '.integration_for' do
    it 'finds the corp\'s integration when it has a secret' do
      expect(described_class.integration_for(corp_id)).to be_a(Integrations::Dingtalk)
    end

    it 'finds nothing for a corp without a secret' do
      Integrations::Dingtalk.find_by_corpid(corp_id).update!(card_callback_secret: '')

      expect(described_class.integration_for(corp_id)).to be_nil
    end

    it 'finds nothing for an inactive integration' do
      Integrations::Dingtalk.find_by_corpid(corp_id).update_column(:active, false)

      expect(described_class.integration_for(corp_id)).to be_nil
    end
  end

  describe '#verify!', :freeze_time, :clean_gitlab_redis_shared_state do
    it 'accepts a fresh timestamp signed with the corp\'s secret' do
      expect(callback.verify!).to be(callback)
    end

    it 'accepts a signature once #security' do
      described_class.new(params, headers).verify!

      expect { callback.verify! }.to raise_error(described_class::AuthenticationError, 'Replayed signature')
    end

    shared_examples 'a rejected callback' do |message|
      it 'raises', :aggregate_failures do
        expect { callback.verify! }.to raise_error(described_class::AuthenticationError, message)
      end
    end

    context 'with another secret #security' do
      let(:signature) { Base64.strict_encode64(OpenSSL::HMAC.digest('SHA256', 'other', timestamp)) }

      it_behaves_like 'a rejected callback', 'Invalid signature'
    end

    context 'with no signature' do
      let(:headers) { { 'x-ddpaas-signature-timestamp' => timestamp } }

      it_behaves_like 'a rejected callback', 'Invalid signature'
    end

    context 'with a timestamp outside the window' do
      let(:timestamp) { ((Time.current - 6.minutes).to_f * 1000).to_i.to_s }

      it_behaves_like 'a rejected callback', 'Stale timestamp'
    end

    context 'with a timestamp in seconds' do
      let(:timestamp) { Time.current.to_i.to_s }

      it_behaves_like 'a rejected callback', 'Malformed timestamp'
    end

    context 'for a corp with no callback secret' do
      let(:params) { super().merge(corpId: 'other_corp') }

      it_behaves_like 'a rejected callback', 'No card callback secret for this corp'
    end
  end

  describe 'the click' do
    it 'reads who clicked which card and what the button sent', :aggregate_failures do
      expect(callback).to be_action
      expect(callback.user_id).to eq('staff123')
      expect(callback.out_track_id).to eq('duo-card')
      expect(callback.action_params).to eq('decision' => 'approve', 'approval_token' => 't')
    end

    [
      ['not JSON', 'nope'],
      ['JSON of the wrong shape', '{"cardPrivateData":"x"}'],
      ['too large', "{\"x\":\"#{'a' * 17.kilobytes}\"}"]
    ].each do |description, body|
      it "reads no parameters from content that is #{description}" do
        params[:content] = body

        expect(callback.action_params).to eq({})
      end
    end
  end
end
