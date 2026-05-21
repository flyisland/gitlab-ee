# frozen_string_literal: true

require 'spec_helper'

RSpec.describe DuoChatPanel::TrialExpiredComponent, :aggregate_failures, feature_category: :duo_chat do
  let(:source) { nil }
  let(:user) { build_stubbed(:user) }

  subject(:component) { render_inline(described_class.new(source: source, user: user)) && page }

  describe 'rendering' do
    before do
      allow_next_instance_of(described_class) do |instance|
        allow(instance).to receive(:data).and_return({ is_trial_expired: 'true' })
      end
    end

    it 'renders the #duo-chat-panel element' do
      is_expected.to have_selector('#duo-chat-panel')
    end

    it 'has the duo-chat-panel class' do
      is_expected.to have_selector('.duo-chat-panel')
    end

    it 'renders the is_trial_expired data attribute on the element' do
      is_expected.to have_css('#duo-chat-panel[data-is-trial-expired="true"]')
    end
  end

  describe '#data', :saas_gitlab_com_subscriptions do
    let(:group) { build_stubbed(:group) }
    let(:source) { group }
    let(:premium_plan) { Hashie::Mash.new(id: 'premium_plan_id', code: ::Plan::PREMIUM) }
    let(:plans_data) { [premium_plan] }

    before do
      allow(group).to receive_messages(root_ancestor: group, plan_name_for_upgrading: ::Plan::FREE)
      allow(Ability).to receive(:allowed?).and_call_original
      allow_next_instance_of(::GitlabSubscriptions::FetchSubscriptionPlansService) do |service|
        allow(service).to receive(:execute).and_return(plans_data)
      end
    end

    it 'returns is_trial_expired as "true"' do
      is_expected.to have_css('#duo-chat-panel[data-is-trial-expired="true"]')
    end

    it 'returns can_start_trial as "false"' do
      is_expected.to have_css('#duo-chat-panel[data-can-start-trial="false"]')
    end

    describe 'auto_expand field' do
      context 'when user is not signed in' do
        let(:user) { nil }

        it 'is "false"' do
          is_expected.to have_css('#duo-chat-panel[data-auto-expand="false"]')
        end
      end

      context 'when user has not dismissed the callout' do
        it 'is "true"' do
          is_expected.to have_css('#duo-chat-panel[data-auto-expand="true"]')
        end
      end

      context 'when user has dismissed the legacy callout' do
        let(:user) do
          build_stubbed(:user, callouts: [
            build_stubbed(:callout, feature_name: 'duo_panel_empty_state_auto_expanded')
          ])
        end

        it 'is "false"' do
          is_expected.to have_css('#duo-chat-panel[data-auto-expand="false"]')
        end
      end

      context 'when user has dismissed the callout' do
        let(:user) do
          build_stubbed(:user, callouts: [
            build_stubbed(:callout, feature_name: 'duo_panel_auto_expanded')
          ])
        end

        it 'is "false"' do
          is_expected.to have_css('#duo-chat-panel[data-auto-expand="false"]')
        end
      end
    end

    context 'when source is nil' do
      let(:source) { nil }

      it 'returns can_buy_addon as "false"' do
        is_expected.to have_css('#duo-chat-panel[data-can-buy-addon="false"]')
      end

      it 'does not include buy_addon_path' do
        is_expected.not_to have_css('#duo-chat-panel[data-buy-addon-path]')
      end
    end

    context 'when user can edit billing' do
      before do
        allow(Ability).to receive(:allowed?).with(user, :edit_billing, group).and_return(true)
      end

      it 'returns can_buy_addon as "true"' do
        is_expected.to have_css('#duo-chat-panel[data-can-buy-addon="true"]')
      end

      it 'returns purchase URL for Premium plan' do
        expected_url = ::Gitlab::Utils.add_url_parameters(
          ::Gitlab::Routing.url_helpers.subscription_portal_new_subscription_url,
          { plan_id: premium_plan.id, gl_namespace_id: group.id }
        )
        is_expected.to have_css(
          "#duo-chat-panel[data-buy-addon-path=\"#{expected_url}\"]"
        )
      end
    end

    context 'when user cannot edit billing' do
      before do
        allow(Ability).to receive(:allowed?).with(user, :edit_billing, group).and_return(false)
      end

      it 'returns can_buy_addon as "false"' do
        is_expected.to have_css('#duo-chat-panel[data-can-buy-addon="false"]')
      end

      it 'does not include buy_addon_path' do
        is_expected.not_to have_css('#duo-chat-panel[data-buy-addon-path]')
      end
    end

    context 'when source is a project' do
      let(:project) { build_stubbed(:project, namespace: group) }
      let(:source) { project }

      before do
        allow(project).to receive(:root_ancestor).and_return(group)
        allow(Ability).to receive(:allowed?).with(user, :edit_billing, group).and_return(true)
      end

      it 'uses the root ancestor for permissions' do
        expected_url = ::Gitlab::Utils.add_url_parameters(
          ::Gitlab::Routing.url_helpers.subscription_portal_new_subscription_url,
          { plan_id: premium_plan.id, gl_namespace_id: group.id }
        )
        is_expected.to have_css('#duo-chat-panel[data-can-buy-addon="true"]')
        is_expected.to have_css(
          "#duo-chat-panel[data-buy-addon-path=\"#{expected_url}\"]"
        )
      end
    end

    context 'when premium plan is not available' do
      let(:plans_data) { [] }

      before do
        allow(Ability).to receive(:allowed?).with(user, :edit_billing, group).and_return(true)
      end

      it 'returns can_buy_addon as "true" with fallback pricing URL' do
        is_expected.to have_css('#duo-chat-panel[data-can-buy-addon="true"]')
        is_expected.to have_css(
          "#duo-chat-panel[data-buy-addon-path=\"#{::Gitlab::Routing.url_helpers.promo_pricing_url}\"]"
        )
      end
    end
  end

  describe '#data on self-managed' do
    let(:group) { build_stubbed(:group) }
    let(:source) { group }

    context 'when user is an admin' do
      let(:user) { build_stubbed(:user, :admin) }

      before do
        allow(user).to receive(:can_admin_all_resources?).and_return(true)
      end

      it 'returns can_buy_addon as "true"' do
        is_expected.to have_css('#duo-chat-panel[data-can-buy-addon="true"]')
      end

      it 'returns subscription portal URL for buy_addon_path' do
        portal_url = ::Gitlab::Routing.url_helpers.subscription_portal_url

        is_expected.to have_css(
          "#duo-chat-panel[data-buy-addon-path=\"#{portal_url}\"]"
        )
      end
    end

    context 'when user is not an admin' do
      it 'returns can_buy_addon as "false"' do
        is_expected.to have_css('#duo-chat-panel[data-can-buy-addon="false"]')
      end

      it 'does not include buy_addon_path' do
        is_expected.not_to have_css('#duo-chat-panel[data-buy-addon-path]')
      end
    end

    context 'when source is nil' do
      let(:source) { nil }
      let(:user) { build_stubbed(:user, :admin) }

      before do
        allow(user).to receive(:can_admin_all_resources?).and_return(true)
      end

      it 'returns can_buy_addon as "true"' do
        is_expected.to have_css('#duo-chat-panel[data-can-buy-addon="true"]')
      end
    end
  end
end
