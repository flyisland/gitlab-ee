# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'OAuth Login', :with_current_organization, :allow_forgery_protection, feature_category: :system_access do
  include DeviseHelpers

  def enter_code(code)
    fill_in 'user_otp_attempt', with: code
    click_button 'Verify code'
  end

  def stub_omniauth_config(provider)
    OmniAuth.config.add_mock(provider, OmniAuth::AuthHash.new(provider: provider.to_s, uid: "12345"))
    stub_omniauth_provider(provider)
  end

  # cas3/dingtalk/wecom providers are injected in jh/config/initializers/8_devise.rb,
  # because upstream removed them from gitlab.yml.example
  providers = [:cas3, :dingtalk, :wecom]

  around do |example|
    with_omniauth_full_host { example.run }
  end

  def login_with_provider(provider, enter_two_factor: false, additional_info: {}, expect_fail: false)
    mock_auth_hash(provider.to_s, uid, user.email, additional_info: additional_info)
    click_oauth_provider(provider.to_s, remember_me: remember_me, expect_fail: expect_fail)
    enter_code(user.current_otp) if enter_two_factor
  end

  providers.each do |provider|
    context "when the user logs in using the #{provider} provider", :js do
      let(:uid) { 'my-uid' }
      let(:remember_me) { false }
      let(:user) { create(:omniauth_user, extern_uid: uid, provider: provider.to_s) }
      let(:two_factor_user) { create(:omniauth_user, :two_factor, extern_uid: uid, provider: provider.to_s) }

      if provider == :salesforce
        let(:additional_info) { { extra: { email_verified: true } } }
      else
        let(:additional_info) do
          {}
        end
      end

      context 'when login successful' do
        before do
          stub_omniauth_config(provider)
          # rubocop:disable RSpec/ExpectInHook -- add here to remove duplicate in spec
          expect(ActiveSession).to receive(:cleanup).with(user).at_least(:once).and_call_original
          # rubocop:enable RSpec/ExpectInHook
        end

        context 'when two-factor authentication is disabled' do
          it 'logs the user in' do
            login_with_provider(provider, additional_info: additional_info)

            expect(page).to have_current_path root_path, ignore_query: true
          end
        end

        context 'when two-factor authentication is enabled' do
          let(:user) { two_factor_user }

          it 'logs the user in' do
            login_with_provider(provider, additional_info: additional_info, enter_two_factor: true)

            expect(page).to have_current_path root_path, ignore_query: true
          end

          it 'when bypass-two-factor is enabled' do
            allow(Gitlab.config.omniauth).to receive_messages(allow_bypass_two_factor: true)
            login_via(provider.to_s, user, uid, remember_me: false, additional_info: additional_info)
            expect(page).to have_current_path root_path, ignore_query: true
          end

          it 'when bypass-two-factor is disabled' do
            allow(Gitlab.config.omniauth).to receive_messages(allow_bypass_two_factor: false)
            login_with_provider(provider, enter_two_factor: true, additional_info: additional_info)
            expect(page).to have_current_path root_path, ignore_query: true
          end
        end

        context 'when "remember me" is checked' do
          let(:remember_me) { true }

          context 'when two-factor authentication is disabled' do
            it 'remembers the user after a browser restart' do
              login_with_provider(provider, additional_info: additional_info)

              expect(page).to have_current_path root_path, ignore_query: true
              clear_browser_session

              visit(root_path)
              expect(page).to have_current_path root_path, ignore_query: true
            end
          end

          context 'when two-factor authentication is enabled' do
            let(:user) { two_factor_user }

            it 'remembers the user after a browser restart' do
              login_with_provider(provider, enter_two_factor: true, additional_info: additional_info)

              expect(page).to have_current_path root_path, ignore_query: true
              clear_browser_session

              visit(root_path)
              expect(page).to have_current_path root_path, ignore_query: true
            end
          end
        end

        context 'when "remember me" is not checked' do
          context 'when two-factor authentication is disabled' do
            it 'does not remember the user after a browser restart' do
              login_with_provider(provider, additional_info: additional_info)

              expect(page).to have_current_path root_path, ignore_query: true
              clear_browser_session

              visit(root_path)
              expect(page).to have_current_path new_user_session_path, ignore_query: true
            end
          end

          context 'when two-factor authentication is enabled' do
            let(:user) { two_factor_user }

            it 'does not remember the user after a browser restart' do
              login_with_provider(provider, enter_two_factor: true, additional_info: additional_info)

              expect(page).to have_current_path root_path, ignore_query: true
              clear_browser_session

              visit(root_path)
              expect(page).to have_current_path new_user_session_path, ignore_query: true
            end
          end
        end
      end

      context 'when user free trial blocked' do
        it 'show free trial block error message' do
          stub_omniauth_config(provider)
          allow(Gitlab).to receive(:com?).and_return(true)
          user.block!
          user.custom_attributes.create(user_id: user.id, value: Time.current.to_s,
            key: ::FreeTrial::BlockFreeTrialUserService::FREE_TRIAL_ENDS)

          login_with_provider(provider, additional_info: additional_info, expect_fail: true)

          expect(page).to have_content('Your free trial of JiHu GitLab has expired. ' \
            'Please contact 400-088-8738 for offline purchase assistant.')
        end
      end
    end
  end
end
