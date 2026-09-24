# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Nav::GitlabDuoSettingsPage, feature_category: :duo_chat do
  using RSpec::Parameterized::TableSyntax

  include ::Nav::GitlabDuoSettingsPage

  let(:owner) { build_stubbed(:user, group_view: :security_dashboard) }
  let(:current_user) { owner }
  let(:group) { create(:group, :private) }

  describe '#show_gitlab_duo_settings_app?' do
    context 'on saas' do
      let(:another_group) { build(:group) }

      before do
        stub_licensed_features(code_suggestions: true)
        stub_saas_features(gitlab_com_subscriptions: true)
        allow(group).to receive(:has_free_or_no_subscription?) { has_free_or_no_subscription? }
        create(:gitlab_subscription_add_on_purchase, :duo_pro, trial, namespace: group_with_duo_pro_trial)

        stub_feature_flags(jh_open_duo_chat: false)
      end

      where(:has_free_or_no_subscription?, :trial, :group_with_duo_pro_trial, :result) do
        true  | :trial         | ref(:another_group) | false
        false | :trial         | ref(:another_group) | false
        true  | :trial         | ref(:group)         | false
        false | :trial         | ref(:group)         | false
        true  | :expired_trial | ref(:group)         | false
        false | :expired_trial | ref(:group)         | false
      end

      with_them do
        it { expect(show_gitlab_duo_settings_app?(group)).to eq(result) }

        context 'when feature not available' do
          before do
            stub_licensed_features(code_suggestions: false)
          end

          it { expect(show_gitlab_duo_settings_app?(group)).to be_falsy }
        end
      end
    end

    context 'on self managed' do
      before do
        stub_licensed_features(code_suggestions: true)
        stub_saas_features(gitlab_com_subscriptions: false)
      end

      it { expect(show_gitlab_duo_settings_app?(group)).to be_falsy }
    end
  end
end
