# frozen_string_literal: true

require 'spec_helper'

RSpec.describe SessionsController, :with_current_organization do
  include SetDefaultPreferredLanguage

  describe '#create' do
    let(:user) { create(:user) }
    let(:wrong_password) { "wrong+#{user.password}" }

    subject(:perform_request) do
      post(
        user_session_path,
        params: { user: { login: user.username, password: wrong_password } }
      )
    end

    context 'when the I18n.locale is zh_CN' do
      before do
        set_default_preferred_language_to_zh_cn
      end

      context 'when Self-managed environment' do
        it 'invalid password' do
          perform_request

          expect(flash[:alert]).to include '无效的登录信息或密码。'
        end
      end

      context 'when Saas environment', :saas do
        it 'invalid password' do
          perform_request

          expect(flash[:alert]).to include '密码错误或该账户不存在，请检查后重试，非中国大陆手机号需添加地区码。'
        end
      end
    end

    context 'when log in when free trial ends' do
      let(:user) { create(:user, :blocked, password: 'P@ss1234') }

      subject(:post_user_session_path) do
        post(
          user_session_path,
          params: { user: { login: user.username, password: 'P@ss1234' } }
        )
      end

      context 'when Saas environment', :saas do
        it 'login successfully' do
          post_user_session_path

          expect(response).to redirect_to(root_path)
        end

        context 'when request other page' do
          before do
            sign_in(user)
          end

          it 'redirect to login page' do
            get new_project_path

            expect(response).to redirect_to(new_user_session_path)
            expect(flash[:alert]).to include 'Your account has been blocked.'
          end

          it 'show free trail ends error message' do
            user.custom_attributes.create(user_id: user.id, value: Time.current.to_s,
              key: ::FreeTrial::BlockFreeTrialUserService::FREE_TRIAL_ENDS)

            get new_project_path

            expect(flash[:alert]).to include 'Your free trial of JiHu GitLab has expired. ' \
              'Please contact 400-088-8738 for offline purchase assistant.'
          end
        end
      end
    end
  end
end
