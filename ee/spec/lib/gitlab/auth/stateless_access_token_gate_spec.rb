# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Gitlab::Auth::StatelessAccessTokenGate, feature_category: :system_access do
  let_it_be(:cloud_connector_key) { create(:cloud_connector_keys) }
  let_it_be(:organization) { create(:organization) }
  let_it_be(:human_user) { create(:user, organizations: [organization]) }
  let_it_be(:service_account) { create(:user, :service_account, composite_identity_enforced: true) }

  before do
    allow(::CloudConnector::CachingKeyLoader).to receive(:private_jwk).and_return(cloud_connector_key.to_jwk)
    allow(::CloudConnector::Keys).to receive(:valid).and_return([cloud_connector_key])
  end

  def issue_token(user: human_user, identities: [])
    jwt = ::Authn::Tokens::StatelessAccessToken.issue(
      user: user, organization: organization, ttl: 1.hour.to_i, scopes: ['ai_workflows'], identities: identities
    ).plaintext_token
    ::Authn::Tokens::StatelessAccessToken.from_jwt(jwt)
  end

  describe '.enabled?' do
    context 'with a simple (non-composite) token' do
      it 'checks the flag against the token user when enabled' do
        stub_feature_flags(duo_workflow_use_token_issuer: human_user)

        expect(described_class.enabled?(issue_token)).to be(true)
      end

      it 'returns false when the flag is disabled for the token user' do
        stub_feature_flags(duo_workflow_use_token_issuer: false)

        expect(described_class.enabled?(issue_token)).to be(false)
      end
    end

    context 'with a composite-identity token' do
      let(:token) do
        issue_token(user: service_account, identities: [{ kind: 'user', local_id: human_user.id }])
      end

      it 'checks the flag against the embedded human, not the service account' do
        stub_feature_flags(duo_workflow_use_token_issuer: human_user)

        expect(described_class.enabled?(token)).to be(true)
      end

      it 'returns false when the flag is enabled only for the service account' do
        stub_feature_flags(duo_workflow_use_token_issuer: service_account)

        expect(described_class.enabled?(token)).to be(false)
      end
    end
  end

  describe '.issuance_enabled?' do
    it 'returns true when the flag is enabled for the user and a signing key exists' do
      stub_feature_flags(duo_workflow_use_token_issuer: human_user)

      expect(described_class.issuance_enabled?(human_user)).to be(true)
    end

    it 'returns false when the flag is disabled for the user' do
      stub_feature_flags(duo_workflow_use_token_issuer: false)

      expect(described_class.issuance_enabled?(human_user)).to be(false)
    end

    it 'returns false when the flag is enabled but no signing key is configured' do
      stub_feature_flags(duo_workflow_use_token_issuer: human_user)
      allow(::CloudConnector::Keys).to receive(:valid).and_return([])

      expect(described_class.issuance_enabled?(human_user)).to be(false)
    end
  end
end
