# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Groups::SecretsController, feature_category: :secrets_management do
  let_it_be(:developer, freeze: false) { create(:user) }
  let_it_be(:reporter, freeze: false) { create(:user, :with_namespace) }
  let_it_be(:guest, freeze: false) { create(:user) }
  let_it_be(:planner, freeze: false) { create(:user) }
  let_it_be(:group) { create(:group) }
  let_it_be(:secrets_manager, freeze: false) { build(:group_secrets_manager, group: group) }

  shared_examples 'group secrets manager page' do
    it 'renders the group secrets index template' do
      subject

      expect(response).to have_gitlab_http_status(:ok)
      expect(response).to render_template('groups/secrets/index')
    end
  end

  shared_examples 'page not found' do
    it 'returns a "not found" response' do
      subject

      expect(response).to have_gitlab_http_status(:not_found)
    end
  end

  describe 'GET /:namespace/:group/-/secrets' do
    subject(:request) { get group_secrets_url(group), params: { group_id: group.to_param } }

    before_all do
      stub_feature_flags(group_secrets_manager: group)
      secrets_manager.activate!
      group.add_developer(developer)
      group.add_reporter(reporter)
      group.add_guest(guest)
      group.add_planner(planner)
    end

    before do
      # SM availability now requires (FF AND enrollment). Enroll the instance
      # by default so the positive-path tests are reachable. Negative-path
      # tests override either the FF or the enrollment as needed.
      stub_application_setting(secrets_manager_instance_enrolled: true)
    end

    context 'when all conditions are met' do
      before do
        stub_licensed_features(native_secrets_management: true)
        sign_in(reporter)
      end

      it_behaves_like 'group secrets manager page'
    end

    context 'when user has a role higher than reporter' do
      before do
        stub_licensed_features(native_secrets_management: true)
        sign_in(developer)
      end

      it_behaves_like 'group secrets manager page'
    end

    context 'when user does not have read_secret permission' do
      before do
        stub_licensed_features(native_secrets_management: true)
      end

      context 'with guest role' do
        before do
          sign_in(guest)
        end

        it_behaves_like 'page not found'
      end

      context 'with planner role' do
        before do
          sign_in(planner)
        end

        it_behaves_like 'page not found'
      end
    end

    context 'when feature flag is disabled' do
      before do
        stub_licensed_features(native_secrets_management: true)
        stub_feature_flags(group_secrets_manager: false)
        sign_in(reporter)
      end

      it_behaves_like 'page not found'
    end

    context 'when not enrolled' do
      before do
        stub_licensed_features(native_secrets_management: true)
        stub_application_setting(secrets_manager_instance_enrolled: false)
        sign_in(reporter)
      end

      it_behaves_like 'page not found'
    end

    context 'when feature license is disabled' do
      before do
        stub_licensed_features(native_secrets_management: false)
        sign_in(reporter)
      end

      it_behaves_like 'page not found'
    end

    context 'when secrets manager is not provisioned' do
      let_it_be(:group_without_sm) { create(:group) }

      subject(:request) { get group_secrets_url(group_without_sm), params: { group_id: group_without_sm.to_param } }

      before_all do
        group_without_sm.add_reporter(reporter)
      end

      before do
        stub_feature_flags(group_secrets_manager: group_without_sm)
        stub_licensed_features(native_secrets_management: true)
        sign_in(reporter)
      end

      it_behaves_like 'page not found'
    end

    context 'when secrets manager is not active' do
      let_it_be(:group_provisioning) { create(:group) }
      let_it_be(:provisioning_sm) { create(:group_secrets_manager, group: group_provisioning) }

      subject(:request) do
        get group_secrets_url(group_provisioning), params: { group_id: group_provisioning.to_param }
      end

      before_all do
        group_provisioning.add_reporter(reporter)
      end

      before do
        stub_feature_flags(group_secrets_manager: group_provisioning)
        stub_licensed_features(native_secrets_management: true)
        sign_in(reporter)
      end

      it_behaves_like 'page not found'
    end
  end
end
