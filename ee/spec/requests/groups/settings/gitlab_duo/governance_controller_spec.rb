# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Groups::Settings::GitlabDuo::GovernanceController, feature_category: :ai_abstraction_layer do
  let_it_be(:user) { create(:user) }
  let_it_be(:group) { create(:group) }

  subject(:get_index) { get group_settings_gitlab_duo_governance_index_path(group) }

  before do
    stub_licensed_features(code_suggestions: true)
    add_on = create(:gitlab_subscription_add_on)
    create(:gitlab_subscription_add_on_purchase, quantity: 50, namespace: group, add_on: add_on)
    sign_in(user)
  end

  describe 'GET index' do
    before_all do
      group.add_owner(user)
    end

    context 'when show_gitlab_duo_settings_menu_item? returns true and feature flag is enabled', :saas do
      before do
        stub_saas_features(gitlab_com_subscriptions: true)
        allow(controller).to receive(:show_gitlab_duo_settings_menu_item?).and_return(true)
        stub_feature_flags(gitlab_duo_governance_settings: group)
      end

      it "renders index with 200 status code" do
        get_index

        expect(response).to have_gitlab_http_status(:ok)
      end
    end

    context 'when feature flag is disabled' do
      before do
        stub_saas_features(gitlab_com_subscriptions: true)
        allow(controller).to receive(:show_gitlab_duo_settings_menu_item?).and_return(true)
        stub_feature_flags(gitlab_duo_governance_settings: false)
      end

      it 'renders 404' do
        get_index

        expect(response).to have_gitlab_http_status(:not_found)
      end
    end

    context 'when show_gitlab_duo_settings_menu_item? returns false' do
      before do
        allow(controller).to receive(:show_gitlab_duo_settings_menu_item?).and_return(false)
        stub_feature_flags(gitlab_duo_governance_settings: group)
      end

      it 'renders 404' do
        get_index

        expect(response).to have_gitlab_http_status(:not_found)
      end
    end
  end
end
