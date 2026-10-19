# frozen_string_literal: true

require 'spec_helper'

RSpec.describe ::RegistrationsHelper do
  describe '#signup_box_template' do
    let(:phone_verification_code_enabled) { nil }

    before do
      stub_feature_flags(registrations_with_phone: true)
      stub_application_setting(phone_verification_code_enabled: phone_verification_code_enabled)
    end

    subject { helper.signup_box_template }

    context 'when turn on phone verification on saas', :saas do
      let(:phone_verification_code_enabled) { true }

      it { is_expected.to eq 'devise/shared/swichable_signup_box' }
    end

    context 'when turn off phone verification on saas', :saas do
      let(:phone_verification_code_enabled) { false }

      it { is_expected.to eq 'devise/shared/signup_box' }
    end

    context 'when on self managed entity' do
      let(:phone_verification_code_enabled) { true }

      it { is_expected.to eq 'devise/shared/signup_box' }
    end
  end
end
