# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Gitlab::Auth::OAuth::AuthHash do
  let(:username) { FFaker::NameCN.last_first }

  let(:auth_hash_params) do
    {
      provider: "gitlab",
      uid: SecureRandom.hex,
      info: {
        unionid: SecureRandom.hex,
        ding_id: SecureRandom.hex,
        name: username,
        username: username,
        openid: SecureRandom.hex
      }
    }
  end

  let(:auth_hash) { described_class.new(OmniAuth::AuthHash.new(auth_hash_params)) }

  describe '#email' do
    subject { auth_hash.email }

    before do
      allow(Gitlab::CurrentSettings.current_application_settings)
          .to receive(:commit_email_hostname).and_return("custom-host.com")
    end

    it 'avoids invalid characters' do
      is_expected.not_to match(/\p{Han}/)
    end

    it 'avoids email conflicts with same name users' do
      hostname = ::Gitlab::CurrentSettings.current_application_settings.commit_email_hostname
      is_expected.not_to eq "temp-email-for-oauth-#{username}@#{hostname}"
    end

    it 'returns a email with commit_email_hostname as domain' do
      is_expected.to match(/@custom-host.com\z/)
    end
  end

  describe '#info' do
    subject { auth_hash.info }

    context 'when email format is valid' do
      let(:valid_email) { 'user@example.com' }

      before do
        auth_hash_params[:info][:email] = valid_email
      end

      it 'keeps the email unchanged' do
        expect(subject['email']).to eq(valid_email)
      end
    end

    context 'when email format is invalid' do
      let(:invalid_email) { 'invalid-email' }

      before do
        auth_hash_params[:info][:email] = invalid_email
      end

      it 'sets email to nil' do
        expect(subject['email']).to be_nil
      end
    end
  end
end
