# frozen_string_literal: true

require 'spec_helper'

RSpec.describe PasswordsController, :with_current_organization do
  include SetDefaultPreferredLanguage

  describe '#create' do
    let(:user) { create(:user) }

    subject(:perform_request) { post(user_password_path, params: { user: { email: user.email } }) }

    context 'when the I18n.locale is zh_CN' do
      before do
        set_default_preferred_language_to_zh_cn
      end

      it 'successfully sends password reset' do
        perform_request

        expect(response).to redirect_to(new_user_session_path)
        expect(flash[:notice]).to include '如果您的电子邮件地址存在于我们的数据库中，您将在几分钟后在您的电子邮件地址中收到一个密码恢复链接。'
      end
    end
  end

  describe '#update' do
    subject do
      put user_password_path, params: {
        user: {
          password: password,
          password_confirmation: password_confirmation,
          reset_password_token: reset_password_token
        }
      }
    end

    let(:password) { User.random_password }
    let(:password_confirmation) { password }
    let(:reset_password_token) { user.send_reset_password_instructions }
    let(:old_password_last_changed_at) { 1.day.ago }
    let(:user_detail) { build(:user_detail, password_last_changed_at: old_password_last_changed_at) }
    let(:user) do
      create(:user, password_automatically_set: true, password_expires_at: 10.minutes.ago, user_detail: user_detail)
    end

    context 'when password update is successful' do
      it 'updates password_last_changed_at' do
        expect(user.user_detail.password_last_changed_at).to be_within(10.seconds).of old_password_last_changed_at

        subject
        user.reset

        expect(user.user_detail.password_last_changed_at).to be_within(10.seconds).of Time.current
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context 'when password update is unsuccessful' do
      let(:password_confirmation) { 'not_the_same_as_password' }

      it 'does not update password_last_changed_at' do
        expect(user.user_detail.password_last_changed_at).to be_within(10.seconds).of old_password_last_changed_at

        subject
        user.reset

        expect(user.user_detail.password_last_changed_at).to be_within(10.seconds).of old_password_last_changed_at
        expect(response).to render_template(:edit)
      end
    end
  end

  describe 'GET #new', :saas do
    subject(:send_request) { get(new_user_password_path) }

    context 'when RealNameSystem is enabled', :phone_verification_code_enabled do
      it 'shows new page' do
        send_request

        expect(response.body).to include("js-reset-password")
      end
    end

    context 'when RealNameSystem is not enabled' do
      it 'shows new page' do
        send_request

        expect(response.body).not_to include("js-reset-password")
      end
    end
  end
end
