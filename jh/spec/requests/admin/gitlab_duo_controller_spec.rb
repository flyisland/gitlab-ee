# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Admin::GitlabDuoController, :with_current_organization, :enable_admin_mode,
  feature_category: :ai_abstraction_layer do
  let_it_be(:admin) { create(:admin) }
  let_it_be(:user) { create(:user) }
  let_it_be(:purchase) { create(:gitlab_subscription_add_on_purchase, :self_managed, :duo_enterprise) }
  let_it_be(:feature_setting) { create(:ai_feature_setting, :duo_agent_platform) }

  let(:license) { build(:license, data: build(:gitlab_license, :offline, plan: 'ultimate').export) }
  let(:unit_primitive) do
    build(:cloud_connector_unit_primitive, name: :self_hosted_models, add_ons: %w[duo_enterprise])
  end

  before do
    allow(License).to receive(:current).and_return(license)
    stub_licensed_features(ai_features: false)
    allow(Gitlab::CloudConnector::DataModel::UnitPrimitive).to receive(:find_by_name).and_call_original
    allow(Gitlab::CloudConnector::DataModel::UnitPrimitive).to receive(:find_by_name)
      .with(:self_hosted_models).and_return(unit_primitive)
  end

  context 'with an offline cloud license and no DAP self-hosted purchase' do
    it 'exposes the DWS URL setting and authorizes an assigned Duo Enterprise user', :aggregate_failures do
      create(:gitlab_subscription_user_add_on_assignment, user: user, add_on_purchase: purchase)
      sign_in(admin)

      get admin_gitlab_duo_path

      expect(response).to have_gitlab_http_status(:ok)
      expect(response.body).to have_css(
        '#js-gitlab-duo-admin-page[data-expose-duo-agent-platform-service-url="true"]'
      )
      expect(user.allowed_to_use(:duo_agent_platform, feature_setting: feature_setting)).to have_attributes(
        allowed?: true, enablement_type: 'duo_enterprise'
      )
    end

    it 'denies access to a user without an assigned seat' do
      expect(user.allowed_to_use(:duo_agent_platform, feature_setting: feature_setting)).not_to be_allowed
    end
  end
end
