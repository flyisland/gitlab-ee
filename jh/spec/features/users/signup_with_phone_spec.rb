# frozen_string_literal: true

require 'spec_helper'

RSpec.describe "Signup with phone", :with_current_organization, :js do
  include RandomNumberString

  let(:username) { FFaker::InternetSE.login_user_name }
  let(:password) { User.random_password }
  let(:area_code) { '+86' }
  let(:phone) { "136#{random_number_string(11 - 3)}" }
  let(:verification_code) { random_number_string(6) }

  let(:full_phone) { "#{area_code}#{phone}" }
  let(:encrypted_phone) { ::Gitlab::CryptoHelper.aes256_gcm_encrypt(full_phone) }
  let(:visitor_id_code) { SecureRandom.hex(16) }

  before do
    stub_application_setting(require_admin_approval_after_user_signup: false)
    stub_feature_flags(arkose_labs_signup_challenge: false)
    allow(::Gitlab::ApplicationRateLimiter).to receive(:throttled?).and_return(false)

    allow_next_instance_of(::RegistrationsController) do |instance|
      allow(instance).to receive(:visitor_id_code).and_return visitor_id_code
    end
    Phone::VerificationCode.create!(visitor_id_code: visitor_id_code,
      code: verification_code, phone: encrypted_phone, created_at: 30.seconds.ago)

    visit new_user_registration_path(registration_type: :phone)
  end

  context 'with self-managed environment' do
    it 'renders registration form with email type' do
      expect(page).to have_field(_('First name'))
      expect(page).to have_field(_('Last name'))
      expect(page).not_to have_field(_('Phone'))
    end
  end

  context 'with SaaS environment', :saas, :phone_verification_code_enabled do
    def sign_up(form_data = {})
      page.within('.phone-registration-form') do
        fill_in 'new_user_username', with: form_data[:username] || username
        fill_in 'new_user_phone', with: form_data[:phone] || phone
        fill_in 'new_user_verification_code', with: form_data[:verification_code] || verification_code
        fill_in 'new_user_password', with: form_data[:password] || password

        click_button 'Continue'
      end
    end

    context 'when email is not required' do
      context 'in experience period' do
        before do
          allow(Gitlab::CurrentSettings.current_application_settings)
              .to receive(:commit_email_hostname).and_return("custom-host.com")
        end

        it 'creates a new user successfully as normal' do
          expect { sign_up }.to change { User.human.count }.by(1)

          user = User.last

          expect(page).to have_current_path users_sign_up_welcome_path
          expect(page).to have_content(
            format(s_('JH|Please complete your profile with email address at %{url} before %{expires_at}'),
              url: s_('JH|Profile Settings'),
              expires_at: user.phone_registration_experience_expires_at.strftime('%F %H:%M %:z')))
          expect(user.email).to match(/@custom-host.com\z/)
        end
      end

      context 'if experience expires' do
        context 'with email confirmation' do
          before do
            sign_up
          end

          let(:user) { User.last }

          subject(:send_confirmation_token) do
            _token, encrypted_token =
              ::Users::EmailVerification::GenerateTokenService.new(attr: :confirmation_token, user: user).execute

            user.update!(
              email: FFaker::Internet.email,
              confirmation_token: encrypted_token,
              confirmation_sent_at: Time.current)
          end

          it 'verifies confirmation of new real email' do
            travel_to 2.days.after do
              send_confirmation_token
              visit user_confirmation_path(confirmation_token: user.confirmation_token)

              expect(page).to have_content I18n.t 'devise.confirmations.confirmed'
              expect(page).not_to have_current_path user_confirmation_path
              expect(page).not_to have_current_path user_settings_profile_path
            end
          end
        end
      end
    end

    context 'when email is required' do
      before do
        stub_feature_flags(soft_email_required_flow: false)
      end

      it 'creates a new user successfully' do
        expect { sign_up }.to change { User.human.count }.by(1)
      end
    end

    context 'with incorrect verification code' do
      it 'alerts error message' do
        expect { sign_up(verification_code: '123312') }.not_to change { User.count }

        expect(page).to have_current_path(user_registration_path, ignore_query: true)
        expect(page).to have_field('Phone', with: phone)
        expect(page).to have_css('.register-with-phone.active')
        expect(page).to have_content s_('JH|RealName|Verification code is incorrect.')
      end
    end

    context 'with invalid password' do
      it 'renders error message' do
        expect { sign_up(password: '12345678') }.not_to change { User.count }

        expect(page).to have_current_path(user_registration_path, ignore_query: true)
        expect(page).to have_field('Phone', with: phone)
        expect(page).to have_content _('Password must not contain commonly used combinations of words and letters')
      end
    end
  end
end
