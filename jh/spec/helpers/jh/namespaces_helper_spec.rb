# frozen_string_literal: true

require 'spec_helper'

RSpec.describe NamespacesHelper, feature_category: :groups_and_projects do
  include NamespacesTestHelper
  include Devise::Test::ControllerHelpers

  let!(:user) { create(:user) }
  let!(:user_project_creation_level) { nil }

  let(:user_group) do
    create(:namespace, :with_ci_minutes,
      project_creation_level: user_project_creation_level,
      owner: user,
      ci_minutes_used: ci_minutes_used)
  end

  let(:ci_minutes_used) { 100 }

  before do
    allow(user).to receive(:require_email_skippable?).and_return(false)
    allow(helper).to receive(:current_user).and_return(user)
  end

  describe '#buy_additional_minutes_path' do
    subject { helper.buy_additional_minutes_path(namespace) }

    let(:namespace) { build_stubbed(:group) }

    it 'returns correct path' do
      more_minutes_url = helper.buy_minutes_subscriptions_path(selected_group: namespace.root_ancestor.id)
      is_expected.to eq more_minutes_url
    end
  end

  describe '#storage_usage_app_data' do
    subject { helper.namespace_subject_to_high_limit?(namespace) }

    let(:namespace) { build_stubbed(:group) }

    it 'returns correct path' do
      result = helper.namespace_subject_to_high_limit?(namespace)
      expect(result).to be false
    end
  end

  describe '#buy_storage_path' do
    subject { helper.buy_storage_path(namespace) }

    let(:namespace) { build_stubbed(:group) }

    it 'returns the correct path' do
      more_storage_url = ::Gitlab::Utils.add_url_parameters(
        ::Gitlab::Routing.url_helpers.subscription_portal_more_storage_url,
        gl_namespace_id: namespace.root_ancestor.id
      )

      is_expected.to eq more_storage_url
    end

    context 'for new_route_storage_purchase' do
      context 'when new_route_storage_purchase is enabled only for a specific namespace' do
        let(:enabled_namespace) { build_stubbed(:group) }

        before do
          stub_feature_flags(new_route_storage_purchase: false)
          stub_feature_flags(new_route_storage_purchase: enabled_namespace)
        end

        it 'returns GitLab purchase path for the disabled namespace' do
          expect(helper.buy_storage_path(enabled_namespace)).to eq(
            ::Gitlab::Utils.add_url_parameters(
              ::Gitlab::Routing.url_helpers.subscription_portal_more_storage_url,
              gl_namespace_id: enabled_namespace.root_ancestor.id
            )
          )
        end
      end
    end
  end
end
