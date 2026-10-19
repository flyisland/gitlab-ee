# frozen_string_literal: true

require 'spec_helper'

# rubocop:disable RSpec/RepeatedExampleGroupBody -- just disable
RSpec.describe 'Login', :with_current_organization, :clean_gitlab_redis_sessions, :aggregate_failures, :js do
  include TermsHelper
  include SetDefaultPreferredLanguage

  let(:phone_without_area_code) { '15612341234' }
  let(:area_code) { '+86' }
  let(:full_phone_number) { "+86#{phone_without_area_code}" }
  let(:encrypted_phone) { ::Gitlab::CryptoHelper.aes256_gcm_encrypt(full_phone_number) }
  let(:password) { User.random_password }
  let!(:user_list) { create_list(:user, 2) }
  let(:verification_code) { '123456' }

  def user_sign_in
    visit new_user_session_path

    fill_in "user_login", with: login
    fill_in "user_password", with: password
    find('[data-testid="sign-in-button"]:enabled').click
  end

  describe 'with two-factor authentication' do
    shared_examples_for 'signing-in-with-two-factor' do
      context 'with two-factor enabled' do
        let!(:user) { create(:user, :two_factor, password: password, phone: encrypted_phone) }

        it 'requires OTP' do
          user_sign_in

          expect(page).to have_content(_('Enter authenticator app code'))

          fill_in "user_otp_attempt", with: user.reset.current_otp
          click_button _('Verify code')

          expect(page).to have_current_path(root_path, ignore_query: true)
        end
      end

      context 'without two-factor enabled' do
        let!(:user) { create(:user, password: password, phone: encrypted_phone) }

        it 'does not require OTP' do
          user_sign_in

          expect(page).to have_current_path(root_path, ignore_query: true)
        end
      end
    end

    context 'when it is JH COM' do
      before do
        allow(::Gitlab).to receive_messages(jh?: true, com?: true)
      end

      context 'when login with phone' do
        let(:login) { full_phone_number }

        it_behaves_like 'signing-in-with-two-factor'
      end

      context 'when login without phone area code' do
        let!(:user) { create(:user, password: password, phone: encrypted_phone) }
        let(:login) { phone_without_area_code }

        it 'allows to login' do
          user_sign_in

          expect(page).to have_current_path(root_path, ignore_query: true)
        end
      end

      context 'when login with email' do
        let(:login) { user.email }

        it_behaves_like 'signing-in-with-two-factor'
      end

      context 'when login with username' do
        let(:login) { user.username }

        it_behaves_like 'signing-in-with-two-factor'
      end
    end

    context 'when it not JH COM' do
      before do
        allow(::Gitlab).to receive(:com?).and_return(false)
      end

      context 'when login with phone' do
        let(:login) { full_phone_number }

        it 'returns login failed' do
          user_sign_in

          expect(page).not_to have_content(_('Enter verification code'))
          expect(page).to have_current_path(new_user_session_path, ignore_query: true)
        end
      end

      context 'when login with email' do
        let(:login) { user.email }

        it_behaves_like 'signing-in-with-two-factor'
      end

      context 'when login with username' do
        let(:login) { user.username }

        it_behaves_like 'signing-in-with-two-factor'
      end
    end
  end

  describe 'user login' do
    let(:user) { create(:user) }
    let(:wrong_password) { 'WRONG_PASSWORD' }

    it_behaves_like 'rendering language switch selector', :new_user_session_path

    context 'when it is not JH COM' do
      before do
        allow(Gitlab).to receive(:com?).and_return(false)
      end

      context 'when the locale is en' do
        it 'shows default error message' do
          submit_sign_in_form_for(user, password: wrong_password)

          expect(page).to have_content('Invalid login or password')
          expect(page).not_to have_content('mobile phone number')
        end
      end
    end

    context 'when it is JH COM' do
      before do
        allow(Gitlab).to receive_messages(com?: true, jh?: true)
      end

      it_behaves_like 'rendering language switch selector', :new_user_session_path

      context 'when the locale is zh_CN' do
        before do
          set_default_preferred_language_to_zh_cn
          visit new_user_session_path
          set_cookie('preferred_language', 'zh_CN')
        end

        it 'shows error message for mainland users' do
          submit_sign_in_form_for(user, password: wrong_password)

          expect(page).not_to have_content('mobile phone number is outside')
          expect(page).to have_content('非中国大陆手机号需添加地区码')
        end
      end

      context 'when the locale is en' do
        before do
          allow(Gitlab::I18n).to receive(:locale).and_return('en')
        end

        context 'without mainland phone' do
          it 'shows error message include word phone' do
            submit_sign_in_form_for(user, password: wrong_password)

            expect(page).to have_content('mobile phone number is outside')
          end
        end

        context 'with mainland phone' do
          let(:phone_without_area_code) { '15612341234' }
          let(:phone) { "+86#{phone_without_area_code}" }
          let!(:user) { create :user, phone: ::Gitlab::CryptoHelper.aes256_gcm_encrypt(phone) }

          context 'without area code' do
            it 'allows user to sign in' do
              sign_in_with phone: phone_without_area_code, password: user.password

              expect(page).to have_current_path root_path, ignore_query: true
            end
          end

          context 'with area code' do
            it 'allows user to sign in' do
              sign_in_with phone: phone, password: user.password

              expect(page).to have_current_path root_path, ignore_query: true
            end
          end
        end

        context 'with oversea phone' do
          let(:phone_without_area_code) { '5796003403' }
          let(:phone) { "+1#{phone_without_area_code}" }
          let!(:user) { create :user, phone: ::Gitlab::CryptoHelper.aes256_gcm_encrypt(phone) }

          context 'without area code' do
            it 'does not allow user to sign in' do
              sign_in_with phone: phone_without_area_code, password: user.password

              expect(page).to have_content('account doesn\'t exist')
            end
          end

          context 'with area code' do
            it 'allows user to sign in' do
              sign_in_with phone: phone, password: user.password

              expect(page).to have_current_path root_path, ignore_query: true
            end
          end
        end
      end

      context 'when :phone_authenticatable is enabled' do
        before do
          set_default_preferred_language_to_zh_cn
          visit new_user_session_path
          set_cookie('preferred_language', 'zh_CN')
        end

        it 'shows error message for mainland users' do
          submit_sign_in_form_for(user, password: wrong_password)

          expect(page).not_to have_content('mobile phone number is outside')
          expect(page).to have_content('非中国大陆手机号需添加地区码')
        end
      end

      context 'when :phone_authenticatable is not enabled' do
        before do
          stub_feature_flags(phone_authenticatable: false)
          set_default_preferred_language_to_zh_cn
          visit new_user_session_path
          set_cookie('preferred_language', 'zh_CN')
        end

        it 'shows error message for mainland users' do
          submit_sign_in_form_for(user, password: wrong_password)
          expect(page).to have_content('无效的登录信息或密码。')
          expect(page).not_to have_content('Invalid login or password.')
        end
      end

      def sign_in_with(phone:, password:)
        visit new_user_session_path

        fill_in "user_login", with: phone
        fill_in "user_password", with: password

        find('[data-testid="sign-in-button"]:enabled').click
      end
    end
  end

  describe 'username label with phone authentication', :js, :saas do
    it 'shows username, email or phone in label' do
      visit new_user_session_path

      within '[data-testid="sign-in-form"]' do
        expect(page).to have_selector('label', text: s_('JH|Username, email or phone'))
      end
    end
  end

  describe 'phone verification', :js, :saas, :phone_verification_code_enabled do
    let(:login) { user.username }
    let!(:user) { create(:user, password: password) }

    before do
      allow_any_instance_of(CheckPhoneAndCode).to \
        receive(:verification_message).and_return(nil)
    end

    context 'when terms are required' do
      before do
        enforce_terms
      end

      it 'redirects to terms path first' do
        user_sign_in

        expect_to_be_on_terms_page

        click_button _('Accept terms')

        expect(page).to have_current_path(phone_path)

        fill_in 'phone', with: phone_without_area_code
        fill_in 'verification_code', with: verification_code
        click_button _('Continue')

        expect(page).to have_current_path(root_path, ignore_query: true)
      end
    end

    context 'when terms are not required' do
      it 'redirects to phone path' do
        user_sign_in

        expect(page).to have_current_path(phone_path)
      end
    end

    context 'when user is skip_real_name_verification' do
      before do
        allow_next_found_instance_of(User) do |user|
          allow(user).to receive(:skip_real_name_verification?).and_return(true)
        end
      end

      it 'redirects to root path' do
        user_sign_in

        expect(page).to have_current_path(root_path)
      end
    end

    context 'when user is not skip_real_name_verification' do
      before do
        allow_next_found_instance_of(User) do |user|
          allow(user).to receive(:skip_real_name_verification?).and_return(false)
        end
      end

      it 'redirects to phone path' do
        user_sign_in

        expect(page).to have_current_path(phone_path)
      end
    end
  end

  describe 'via Group SAML', :saas do
    include LdapHelpers
    include UserLoginHelper
    include DeviseHelpers
    let(:saml_provider) { create(:saml_provider) }
    let(:group) { saml_provider.group }
    let(:identity) { create(:group_saml_identity, user: user, saml_provider: saml_provider) }

    before do
      stub_licensed_features(extended_audit_events: true)
      stub_licensed_features(group_saml: true)
      mock_group_saml(uid: identity.extern_uid)
    end

    around do |example|
      with_omniauth_full_host { example.run }
    end

    context 'with enforced terms' do
      include TermsHelper

      let(:user) { create(:user) }

      it 'shows the terms disclaimer' do
        enforce_terms

        visit sso_group_saml_providers_path(group)

        expect(page).to have_content(
          'By clicking Sign in or registering ' \
            'through a third party you accept the JiHu GitLab Terms of Use and ' \
            'acknowledge the Privacy Statement and Cookie Policy. ' \
            'If you are registering with an enterprise email address, ' \
            'JiHu(GitLab) will not notify you nor be held accountable ' \
            'while sharing your account data with corresponding companies.'
        )
      end
    end
  end
end
# rubocop:enable RSpec/RepeatedExampleGroupBody
