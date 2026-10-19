# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Admin::IntegrationsController, feature_category: :integrations do
  let_it_be(:admin) { create(:admin) }
  let_it_be(:organization) { current_organization }

  before do
    sign_in(admin)
  end

  describe '#update' do
    context 'with the Feishu Bot integration' do
      let(:integration) do
        create(:feishu_bot_integration, :instance, project: nil, organization: organization,
          verification_token: 'old_token', encrypt_key: 'old_key')
      end

      let(:params) { { active: true, verification_token: 'new_token', encrypt_key: 'new_key' } }

      before do
        stub_application_setting(
          feishu_integration_enabled: true, feishu_app_key: 'app_key', feishu_app_secret: 'app_secret'
        )
        stub_licensed_features(feishu_bot_integration: true)
        allow(PropagateIntegrationWorker).to receive(:perform_async)

        put :update, params: { id: integration.to_param, service: params }
      end

      it 'saves the callback credentials' do
        expect(response).to have_gitlab_http_status(:found)
        expect(integration.reload).to have_attributes(verification_token: 'new_token', encrypt_key: 'new_key')
      end

      context 'when the credentials are left blank' do
        let(:params) { { active: true, verification_token: '', encrypt_key: '' } }

        it 'keeps the current credentials' do
          expect(response).to have_gitlab_http_status(:found)
          expect(integration.reload).to have_attributes(verification_token: 'old_token', encrypt_key: 'old_key')
        end
      end
    end
  end
end
