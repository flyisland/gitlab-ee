# frozen_string_literal: true

require('spec_helper')

RSpec.describe UserSettings::ProfilesController, :request_store do
  let_it_be(:user) { create(:user) }
  let_it_be(:admin) { create(:admin) }

  describe 'PUT update' do
    context 'when updating name' do
      subject(:update_request) { put :update, params: { user: { name: 'New Name' } } }

      shared_examples_for 'a user can update their name' do
        before do
          sign_in(current_user)
          allow(::Gitlab).to receive(:com?).and_return(true)
        end

        it 'updates their name' do
          update_request

          expect(response).to have_gitlab_http_status(:found)
          expect(current_user.reset.name).to eq('New Name')
        end

        context 'when RealNameSystem is enabled', :phone_verification_code_enabled do
          before do
            current_user.phone = ::Gitlab::CryptoHelper.aes256_gcm_encrypt('17766123456')
            current_user.save!
          end

          # See: https://jihulab.com/gitlab-cn/gitlab/-/issues/5067
          it 'updates their name multiple times' do
            put :update, params: { user: { name: 'New Name', phone: '17766123456' } }
            put :update, params: { user: { name: 'New Name2', phone: '17766123456' } }

            expect(response).to have_gitlab_http_status(:found)
            expect(current_user.reset.name).to eq('New Name2')
          end
        end
      end

      context 'when `disable_name_update_for_users` feature is available' do
        before do
          stub_licensed_features(disable_name_update_for_users: true)
        end

        context 'when the ability to update thier name is not disabled for users' do
          before do
            stub_application_setting(updating_name_disabled_for_users: false)
          end

          it_behaves_like 'a user can update their name' do
            let(:current_user) { user }
          end

          it_behaves_like 'a user can update their name' do
            let(:current_user) { admin }
          end
        end

        context 'when the ability to update their name is disabled for users' do
          before do
            stub_application_setting(updating_name_disabled_for_users: true)
          end

          context 'as a regular user' do
            before do
              sign_in(user)
            end

            it 'does not update their name' do
              update_request

              expect(response).to have_gitlab_http_status(:found)
              expect(user.reset.name).not_to eq('New Name')
            end
          end

          context 'as an admin in admin mode', :enable_admin_mode do
            it_behaves_like 'a user can update their name' do
              let(:current_user) { admin }
            end
          end
        end
      end

      context 'when `disable_name_update_for_users` feature is not available' do
        before do
          stub_licensed_features(disable_name_update_for_users: false)
        end

        it_behaves_like 'a user can update their name' do
          let(:current_user) { user }
        end

        it_behaves_like 'a user can update their name' do
          let(:current_user) { admin }
        end
      end
    end

    context 'when updating phone', :saas, :phone_verification_code_enabled do
      let(:valid_phone) { "+861561234#{rand(1000..9999)}" }
      let(:empty_phone) { "" }

      before do
        sign_in(user)
      end

      context "when phone is empty" do
        let(:encrypted_phone) { ::Gitlab::CryptoHelper.aes256_gcm_encrypt(valid_phone) }
        let(:user) { create(:user, phone: encrypted_phone) }

        context "when user is skip_real_name_verification" do
          before do
            allow_next_found_instance_of(User) do |user|
              allow(user).to receive(:skip_real_name_verification?).and_return(true)
            end
          end

          it "updates phone to empty" do
            put :update, params: { user: { phone: empty_phone } }

            expect(response).to have_gitlab_http_status(:found)
            expect(user.reset.phone).to eq('')
          end
        end

        context "when user is not skip_real_name_verification" do
          let!(:exist_user) { create(:user, phone: empty_phone) }

          before do
            allow_next_found_instance_of(User) do |user|
              allow(user).to receive(:skip_real_name_verification?).and_return(false)
            end
          end

          it "raises ActiveRecord::RecordNotUnique" do
            expect do
              put :update, params: { user: { phone: empty_phone } }
            end.to raise_error(ActiveRecord::RecordNotUnique)
          end
        end
      end
    end
  end
end
