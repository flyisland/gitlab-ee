# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Phones', :with_current_organization, :aggregate_failures, feature_category: :user_profile do
  include TermsHelper

  let(:user) { create(:user) }
  let(:phone_number) { '15612341234' }
  let(:area_code) { '+86' }
  let(:full_phone_number) { "+86#{phone_number}" }
  let(:encrypted_phone) { ::Gitlab::CryptoHelper.aes256_gcm_encrypt(full_phone_number) }
  let(:gitlab_session) { 'b356c5e5f623717dbf219975b859f25f' }
  let(:verification_code) { '123456' }
  let(:params) { { area_code: area_code, phone: phone_number, verification_code: verification_code } }

  shared_examples_for 'phone verification is not available' do
    context 'when user is not logged in' do
      it 'redirects to sign in page' do
        subject

        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context 'when it is not JH SaaS' do
      it 'renders not found' do
        sign_in(user)

        subject

        expect(response).to have_gitlab_http_status(:not_found)
      end
    end
  end

  describe "GET #show" do
    subject(:visit_phone_page) { get phone_url }

    it_behaves_like 'phone verification is not available'

    context 'when it is JH SaaS', :saas, :phone_verification_code_enabled do
      context 'when user is logged in' do
        before do
          sign_in(user)
        end

        it 'shows page content' do
          visit_phone_page

          expect(phone_path).to eq('/-/users/phone')
          expect(response).to have_http_status(:ok)
        end

        it 'render phone page when in progress onboard' do
          user.update(onboarding_in_progress: true)
          stub_application_setting(check_namespace_plan: true)

          visit_phone_page

          expect(phone_path).to eq('/-/users/phone')
          expect(response).to have_http_status(:ok)
        end

        context 'when user has a phone' do
          let(:user) { create(:user, phone: encrypted_phone) }

          it 'redirects to root path' do
            visit_phone_page

            expect(response).to redirect_to(root_path)
            expect(flash[:notice]).to eq(s_("JH|RealName|You have already verified your phone."))
          end
        end
      end
    end
  end

  describe "POST #create" do
    subject(:verify_phone) { post verify_phone_url, params: params }

    it_behaves_like 'phone verification is not available'

    context 'when it is JH SaaS', :saas, :phone_verification_code_enabled do
      context 'when user is logged in' do
        before do
          sign_in(user)

          Phone::VerificationCode.create!(
            visitor_id_code: gitlab_session, code: verification_code, phone: encrypted_phone,
            created_at: Time.zone.now
          )
        end

        context 'when user phone is not verified' do
          context 'when cookies are not matched' do
            it 'shows verification_code error' do
              verify_phone

              expect(response).to redirect_to(phone_path)
              expect(flash[:alert]).to eq(s_('JH|RealName|Verification code is nonexist.'))
            end
          end

          context 'when cookies are matched' do
            context 'with wrong code' do
              let(:wrong_verification_code) { '456789' }
              let(:params) { { area_code: area_code, phone: phone_number, verification_code: wrong_verification_code } }

              it 'shows verification_code error' do
                expect_next_instance_of(::Users::PhonesController) do |instance|
                  expect(instance).to receive(:visitor_id_code).and_return(gitlab_session)
                end

                verify_phone

                expect(response).to redirect_to(phone_path)
                expect(flash[:alert]).to eq(s_('JH|RealName|Verification code is incorrect.'))
              end
            end

            context 'with correct code' do
              it 'redirects to welcome path' do
                expect_next_instance_of(::Users::PhonesController) do |instance|
                  expect(instance).to receive(:visitor_id_code).and_return(gitlab_session)
                end
                expect(user.reset.phone).to be_nil

                verify_phone

                expect(response).to redirect_to(users_sign_up_welcome_path)
                expect(flash[:notice]).to eq(s_("JH|RealName|You have already verified your phone."))
                expect(user.reset.phone).to eq(encrypted_phone)
              end

              context 'with unpermitted fields' do
                let(:first_name) { "#{user.first_name}wrong" }
                let(:params) do
                  {
                    first_name: first_name,
                    area_code: area_code,
                    phone: phone_number,
                    verification_code: verification_code
                  }
                end

                it 'only changes phone' do
                  expect_next_instance_of(::Users::PhonesController) do |instance|
                    expect(instance).to receive(:visitor_id_code).and_return(gitlab_session)
                  end
                  expect(user.reset.phone).to be_nil

                  verify_phone

                  expect(response).to redirect_to(users_sign_up_welcome_path)
                  expect(user.reset.phone).to eq(encrypted_phone)
                  expect(user.reset.first_name).not_to eq(first_name)
                end
              end
            end

            context 'when updating phone failed' do
              it 'returns a validation error' do
                allow_any_instance_of(::Users::UpdateService).to(
                  receive(:execute).and_return({ message: 'failed', status: :error }))

                expect_next_instance_of(::Users::PhonesController) do |instance|
                  expect(instance).to receive(:verify_code_received_by_phone).and_return(nil)
                end
                verify_phone

                expect(response).to redirect_to(phone_path)
                expect(flash[:alert]).to eq(s_('JH|RealName|Phone saved failed.'))
              end
            end

            context 'when updating with a duplicated phone' do
              let!(:new_user) { create :user, phone: encrypted_phone }

              it 'returns a validation error' do
                expect_next_instance_of(::Users::PhonesController) do |instance|
                  expect(instance).to receive(:visitor_id_code).and_return(gitlab_session)
                end

                verify_phone

                expect(response).to have_http_status(:unprocessable_entity)
              end
            end
          end
        end

        context 'when user phone has been verified' do
          let(:new_full_phone_number) { "+8618516264567" }
          let(:new_encrypted_phone) { ::Gitlab::CryptoHelper.aes256_gcm_encrypt(new_full_phone_number) }
          let(:user) { create(:user, phone: encrypted_phone) }

          it 'returns a validation error' do
            expect(user.phone).to eq(encrypted_phone)

            verify_phone

            expect(response).to have_http_status(:unprocessable_entity)

            expect(user.reset.phone).to eq(encrypted_phone)
            expect(user.phone).not_to eq(new_encrypted_phone)
          end
        end
      end
    end
  end

  describe 'Phone verification redirections', :saas, :phone_verification_code_enabled do
    describe 'sessionless' do
      before do
        sign_in(user)
      end

      it 'renders forbidden page' do
        allow_any_instance_of(SessionlessAuthentication).to \
          receive(:sessionless_user?).and_return(true)

        get root_path

        expect(response).to have_gitlab_http_status(:forbidden)
      end
    end
  end

  describe 'GET #exists', :saas, :phone_verification_code_enabled do
    context 'when signed' do
      before do
        sign_in(user)
        create(:user, email: 'temp-email-for-oauth-u2@email.com', phone: full_phone_number)
      end

      context 'when phone is not encrypted in DB' do
        it 'returns JSON indicating the phone not exists' do
          get exists_phone_url, params: { phone: full_phone_number }

          expect(response).to have_gitlab_http_status(:ok)

          expected_json = Gitlab::Json.generate({ exists: false })
          expect(response.body).to eq(expected_json)
        end

        it 'not return 302 for welcome' do
          user.update(onboarding_in_progress: true)
          stub_application_setting(check_namespace_plan: true)

          get exists_phone_url, params: { phone: full_phone_number }
          expected_json = Gitlab::Json.generate({ exists: false })
          expect(response.body).to eq(expected_json)
        end
      end

      context 'when phone is encrypted in DB' do
        before do
          create(:user, email: 'temp-email-for-oautph-u3@email.com', phone: encrypted_phone)
        end

        it 'returns JSON indicating the phone exists' do
          get exists_phone_url, params: { phone: full_phone_number }

          expect(response).to have_gitlab_http_status(:ok)

          expected_json = Gitlab::Json.generate({ exists: true })
          expect(response.body).to eq(expected_json)
        end
      end
    end

    context 'when not signed in' do
      it 'returns json' do
        get exists_phone_url, params: { phone: full_phone_number }

        expect(response).to have_gitlab_http_status(:ok)
        expected_json = Gitlab::Json.generate({ exists: false })
        expect(response.body).to eq(expected_json)
      end
    end
  end

  describe 'Terms for oauth users', :saas, :phone_verification_code_enabled do
    before do
      stub_env('IN_MEMORY_APPLICATION_SETTINGS', 'false')
      sign_in(user)
    end

    shared_examples 'oauth user is true' do
      it 'shows terms checkbox' do
        get phone_url

        expect(response.body).to include('data-oauth-user="true"')
      end
    end

    shared_examples 'oauth user is false' do
      it 'does not show terms checkbox' do
        get phone_url

        expect(response.body).to include('data-oauth-user="false"')
      end
    end

    context 'when terms are enforced' do
      before do
        enforce_terms
      end

      context 'when user is not an oauth user' do
        it_behaves_like 'oauth user is false'
      end

      context 'when user is an oauth user' do
        let_it_be(:user) { create(:user, password_automatically_set: true) }

        it_behaves_like 'oauth user is true'
      end
    end

    context 'when terms are not enforced' do
      context 'when user is an oauth user' do
        let_it_be(:user) { create(:user, password_automatically_set: true) }

        it_behaves_like 'oauth user is false'
      end
    end
  end
end
