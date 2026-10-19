# frozen_string_literal: true

require 'spec_helper'

RSpec.describe ::Ai::DuoWorkflows::CreateCompositeOauthAccessTokenService,
  feature_category: :duo_agent_platform do
  describe '#execute' do
    subject(:response) do
      described_class.new(
        current_user: user,
        organization: organization,
        service_account: service_account
      ).execute
    end

    let_it_be(:organization) { create(:organization) }
    let_it_be(:user) { create(:user, organizations: [organization]) }
    let_it_be(:service_account) { create(:user, :service_account, composite_identity_enforced: true) }
    let_it_be(:oauth_app) { create(:doorkeeper_application, scopes: %w[ai_workflows mcp user:*]) }

    before do
      stub_saas_features(duo_workflow: true)
      stub_feature_flags(duo_workflow_use_token_issuer: false)
      ::Ai::Setting.for_organization(organization).update!(duo_workflow_oauth_application_id: oauth_app.id)
    end

    it 'creates an OAuth access token with a two-hour lifetime' do
      expect(::Gitlab::Audit::Auditor).to receive(:audit).with(
        hash_including(
          name: 'composite_oauth_token_created',
          additional_details: hash_including(expires_in: 2.hours.to_i)
        )
      )

      expect(response).to be_success
      expect(response[:oauth_access_token].expires_in).to eq(2.hours.to_i)
    end

    context 'when duo_workflow_use_token_issuer is enabled' do
      let_it_be(:cloud_connector_key) { create(:cloud_connector_keys) }

      before do
        stub_feature_flags(duo_workflow_use_token_issuer: user)
        allow(::CloudConnector::CachingKeyLoader).to receive(:private_jwk).and_return(cloud_connector_key.to_jwk)
        allow(::CloudConnector::Keys).to receive(:valid).and_return([cloud_connector_key])
      end

      it 'returns a stateless token with a two-hour lifetime', :freeze_time do
        expect(response).to be_success

        token = response[:oauth_access_token]
        expect(token.plaintext_token).to start_with(::Authn::Tokens::StatelessAccessToken::TOKEN_PREFIX)
        expect(token.expires_in).to eq(2.hours.to_i)
        expect(token.expires_at).to eq(2.hours.from_now)
      end
    end
  end
end
