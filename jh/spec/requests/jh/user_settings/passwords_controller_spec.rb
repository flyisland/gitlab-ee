# frozen_string_literal: true

require 'spec_helper'

RSpec.describe UserSettings::PasswordsController, :with_current_organization do
  describe '#create' do
    let(:password) { 'abc12345678' }
    let(:old_password_last_changed_at) { 91.days.ago }
    let(:user_detail) { build(:user_detail, password_last_changed_at: old_password_last_changed_at) }
    let(:user) { create(:user, password: password, user_detail: user_detail) }
    let(:new_password) { "new#{user.password}" }

    before do
      sign_in(user)
      stub_licensed_features(password_expiration: true)
      stub_application_setting(password_expires_in_days: 90)
    end

    subject(:post_api) do
      post('/-/user_settings/password',
        params: {
          user: { password: user.password, new_password: new_password, password_confirmation: new_password }
        })
    end

    context 'when reset the password successfully' do
      it 'password_last_changed_at should set to current time' do
        expect { post_api }.to change { user.user_detail.password_last_changed_at }
        expect(response).to redirect_to(root_path)
      end
    end

    context 'when reset the password unsuccessfully' do
      context 'when password is invalid' do
        before do
          allow_any_instance_of(User).to receive(:password_automatically_set).and_return(false)
          allow_any_instance_of(User).to receive(:valid_password?).and_return(false)
        end

        it 'does not updated password_last_changed_at' do
          expect { post_api }.not_to change { user.user_detail.password_last_changed_at }
          expect(response).to redirect_to(new_user_settings_password_path)
        end
      end

      context 'when UpdateService execute unsuccessfully' do
        before do
          allow_any_instance_of(Users::UpdateService).to receive(:execute).and_return({ status: :error })
        end

        it 'does not updated password_last_changed_at' do
          expect { post_api }.not_to change { user.user_detail.password_last_changed_at }
          expect(response).to render_template :new
        end
      end
    end
  end
end
