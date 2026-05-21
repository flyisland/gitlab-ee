# frozen_string_literal: true

require 'spec_helper'

RSpec.describe EE::SessionsHelper, feature_category: :system_access do
  describe '#registration_path_params' do
    context 'when onboarding feature is not available' do
      context 'when invite_email is provided' do
        it 'returns params with invite_email only' do
          invite_email = 'user@example.com'

          expect(helper.registration_path_params(invite_email)).to eq({
            invite_email: invite_email
          })
        end
      end
    end

    context 'when onboarding feature is available', :saas_onboarding do
      context 'when invite_email is provided' do
        it 'returns params with invite_email only' do
          invite_email = 'user@example.com'

          expect(helper.registration_path_params(invite_email)).to eq({
            invite_email: invite_email
          })
        end
      end

      context 'when invite_email is nil' do
        it 'returns params with from_sign_in set to true' do
          expect(helper.registration_path_params(nil)).to eq({
            invite_email: nil,
            from_sign_in: true
          })
        end
      end

      context 'when invite_email is blank' do
        it 'returns params with from_sign_in set to true' do
          expect(helper.registration_path_params('')).to eq({
            invite_email: '',
            from_sign_in: true
          })
        end
      end
    end
  end
end
