# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Onboarding::SubscriptionSmRegistration, feature_category: :onboarding do
  subject { described_class }

  describe '.tracking_label' do
    subject { described_class.tracking_label }

    it { is_expected.to eq('subscription_sm_registration') }
  end

  describe '.get_started_subtext' do
    subject { described_class.get_started_subtext }

    let(:expected_subtitle) do
      s_('InProductMarketing|Create a GitLab account to purchase the Premium tier of GitLab Self-Managed.')
    end

    it { is_expected.to eq(expected_subtitle) }
  end

  describe '.read_from_stored_user_location?' do
    it { is_expected.to be_read_from_stored_user_location }
  end

  describe '.preserve_stored_location?' do
    it { is_expected.to be_preserve_stored_location }
  end

  describe '.unification_enabled?', :saas_onboarding do
    subject { described_class.unification_enabled? }

    context 'when subscription_sm_unification feature flag is enabled' do
      it { is_expected.to be(true) }
    end

    context 'when subscription_sm_unification feature flag is disabled' do
      before do
        stub_feature_flags(subscription_sm_unification: false)
      end

      it { is_expected.to be(false) }
    end

    context 'when onboarding is disabled' do
      before do
        stub_saas_features(onboarding: false)
      end

      it { is_expected.to be(false) }
    end
  end
end
