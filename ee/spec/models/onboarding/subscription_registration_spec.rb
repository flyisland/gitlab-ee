# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Onboarding::SubscriptionRegistration, type: :undefined, feature_category: :onboarding do
  subject { described_class }

  describe '.tracking_label' do
    subject { described_class.tracking_label }

    it { is_expected.to eq('subscription_registration') }
  end

  describe '.read_from_stored_user_location?' do
    it { is_expected.to be_read_from_stored_user_location }
  end

  describe '.preserve_stored_location?' do
    it { is_expected.to be_preserve_stored_location }
  end
end
