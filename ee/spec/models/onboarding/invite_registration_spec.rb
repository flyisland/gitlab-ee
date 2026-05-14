# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Onboarding::InviteRegistration, type: :undefined, feature_category: :onboarding do
  subject { described_class }

  describe '.tracking_label' do
    subject { described_class.tracking_label }

    it { is_expected.to eq('invite_registration') }
  end

  describe '.product_interaction' do
    subject { described_class.product_interaction }

    it { is_expected.to eq('Invited User') }
  end

  describe '.read_from_stored_user_location?' do
    it { is_expected.not_to be_read_from_stored_user_location }
  end

  describe '.preserve_stored_location?' do
    it { is_expected.not_to be_preserve_stored_location }
  end
end
