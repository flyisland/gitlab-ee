# frozen_string_literal: true

require 'spec_helper'

RSpec.describe API::Users, :with_current_organization, feature_category: :api do
  let(:user_phone_api_path) { "/users/#{user_id}/phone" }
  let(:phone) { "+8615612341234" }
  let(:encrypted_phone) { ::Gitlab::CryptoHelper.aes256_gcm_encrypt(phone) }
  let!(:admin) { create(:admin, :with_namespace) }
  let!(:user) { create(:user, :with_namespace, phone: encrypted_phone) }
  let(:user_id) { user.id }

  before do
    stub_application_setting(admin_mode: false)
  end

  describe 'GET /users/:id/phone' do
    context 'when it is not COM' do
      it 'returns a :not_found error' do
        get api(user_phone_api_path, admin)

        expect(response).to have_gitlab_http_status(:not_found)
      end
    end

    context 'when it is COM', :saas do
      context 'when current user is not admin' do
        it 'returns an authentication error' do
          get api(user_phone_api_path)
          expect(response).to have_gitlab_http_status(:unauthorized)

          get api(user_phone_api_path, user)
          expect(response).to have_gitlab_http_status(:forbidden)
        end
      end

      context 'when current user is admin' do
        it 'returns user phone' do
          get api(user_phone_api_path, admin)

          expect(response).to have_gitlab_http_status(:ok)
          expect(json_response['phone']).to eq(phone)
        end

        context "when user's phone is blank" do
          let(:user) { create(:user) }

          it 'returns nil' do
            get api(user_phone_api_path, admin)

            expect(response).to have_gitlab_http_status(:ok)
            expect(json_response['phone']).to be_nil
          end
        end
      end
    end
  end

  describe 'PUT /users/:id/phone' do
    let(:new_phone) { "+8615612341111" }

    context 'when it is not COM' do
      it 'returns a :not_found error' do
        put api(user_phone_api_path, admin), params: { phone: new_phone }

        expect(response).to have_gitlab_http_status(:not_found)
      end
    end

    context 'when it is COM', :saas do
      context 'when current user is not admin' do
        it 'returns an authentication error' do
          put api(user_phone_api_path), params: { phone: new_phone }
          expect(response).to have_gitlab_http_status(:unauthorized)

          put api(user_phone_api_path, user), params: { phone: new_phone }
          expect(response).to have_gitlab_http_status(:forbidden)
        end
      end

      context 'when current user is admin' do
        it 'returns user phone' do
          put api(user_phone_api_path, admin), params: { phone: new_phone }

          expect(response).to have_gitlab_http_status(:ok)
          expect(json_response['phone']).to eq(new_phone)
        end
      end

      context 'when the phone number is duplicated' do
        let(:user_id) { admin.id }

        it 'returns an authentication error' do
          put api(user_phone_api_path, admin), params: { phone: phone }

          expect(response).to have_gitlab_http_status(:conflict)
          expect(json_response['message']).to eq('Phone has already been taken')
        end
      end

      context 'when the phone number is invalid' do
        let(:user_id) { admin.id }
        let(:phone) { '+861851626123x' }

        it 'returns a validation error' do
          put api(user_phone_api_path, admin), params: { phone: phone }

          expect(response).to have_gitlab_http_status(:bad_request)
          expect(json_response['error']).to eq('phone Invalid Phone Number')
        end
      end

      context 'when updating user failed' do
        before do
          expect_next_instance_of(Users::UpdateService) do |service|
            allow(service).to receive(:execute).and_return({ message: 'failed', status: :error })
          end
        end

        it 'returns a validation error' do
          put api(user_phone_api_path, admin), params: { phone: new_phone }

          expect(response).to have_gitlab_http_status(:bad_request)
          expect(json_response['message']).to eq('400 Bad Request')
        end
      end
    end
  end

  describe 'GET /user' do
    context 'as a regular user', :saas do
      it 'returns the phone of the user' do
        get api("/user", user)

        expect(json_response).to have_key('phone')
        expect(json_response['phone']).to eq(phone)
      end

      context "when user's phone is blank" do
        let(:user) { create(:user, :with_namespace) }

        it 'returns nil' do
          get api("/user", user)

          expect(json_response).to have_key('phone')
          expect(json_response['phone']).to be_nil
        end
      end
    end
  end

  describe 'GET /users/' do
    context 'as an admin' do
      it 'does not contain phone field' do
        get api("/users", admin), params: { username: user.username }

        expect(response).to have_gitlab_http_status(:success)
        expect(json_response.first).not_to have_key('phone')
      end
    end

    context 'when it is SaaS', :saas do
      context 'when unauthenticated' do
        it "does not contain phone field" do
          get api("/users"), params: { username: user.username }

          expect(json_response.first).not_to have_key('phone')
        end
      end

      context 'when authenticated' do
        context 'as a regular user' do
          it 'does not contain phone field' do
            get api("/users", user), params: { username: user.username }

            expect(json_response.first).to have_key('username')
            expect(json_response.first).not_to have_key('phone')
          end
        end

        context 'as an admin' do
          it 'contains the phone of users' do
            get api("/users", admin), params: { username: user.username }

            expect(response).to have_gitlab_http_status(:success)
            expect(json_response.first).to have_key('phone')
          end
        end
      end
    end
  end

  describe 'POST /users' do
    context 'with optional attributes' do
      let(:default_preferred_language) { 'zh_CN' }

      before do
        stub_feature_flags(qa_enforce_locale_to_en: false)
        stub_application_setting(default_preferred_language: default_preferred_language)
      end

      context 'without preferred_language' do
        it 'creates user with default_preferred_language' do
          attributes = attributes_for(:user)
          attributes.delete(:preferred_language)
          post api('/users', admin), params: attributes

          expect(response).to have_gitlab_http_status(:created)
          expect(json_response['preferred_language']).to eq(default_preferred_language)
        end
      end

      context 'with preferred_language' do
        context 'with valid specified preferred_language' do
          let(:specified_preferred_language) { 'fr' }

          it 'creates user' do
            attributes = attributes_for(:user).merge(preferred_language: specified_preferred_language)
            post api('/users', admin), params: attributes

            expect(response).to have_gitlab_http_status(:created)
            expect(json_response['preferred_language']).to eq(specified_preferred_language)
          end
        end

        context 'with invalid preferred_language' do
          let(:invalid_preferred_language) { 'xxx' }

          it 'returns the error message' do
            attributes = attributes_for(:user).merge(preferred_language: invalid_preferred_language)
            post api('/users', admin), params: attributes

            expect(response).to have_gitlab_http_status(:bad_request)
            expect(json_response.dig('message', 'preferred_language')).to include _('is not included in the list')
          end
        end
      end
    end
  end
end
