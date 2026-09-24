# frozen_string_literal: true

require 'spec_helper'

RSpec.describe UsersController do
  include RandomNumberString

  let(:user) { create(:user, email: GpgHelpers::User1.emails[0]) }
  let(:phone) { "+8615688888888" }

  describe 'GET #email_exists' do
    let!(:user) { create :user }

    context 'when it is JH COM' do
      before do
        allow(::Gitlab).to receive_messages(jh?: true, com?: true)
      end

      context 'when querying with user email' do
        it 'returns email exists' do
          get user_email_exists_url user.email

          expect(response).to have_gitlab_http_status(:ok)

          expected_json = Gitlab::Json.generate({ exists: true })
          expect(response.body).to eq(expected_json)
        end
      end

      context 'when querying with non-existing email' do
        it 'returns email exists' do
          get user_email_exists_url 'non-existing'

          expect(response).to have_gitlab_http_status(:ok)

          expected_json = Gitlab::Json.generate({ exists: false })
          expect(response.body).to eq(expected_json)
        end
      end
    end

    context 'when it is not JH COM' do
      before do
        allow(::Gitlab).to receive(:com?).and_return(false)
        sign_in(user)
      end

      context 'when querying with user email' do
        it 'returns an error' do
          get user_email_exists_url user.email

          expect(response).to have_gitlab_http_status(:unauthorized)

          expected_json =
            Gitlab::Json.generate({ error: s_('JH|You must be authorized to access this path.') })
          expect(response.body).to eq(expected_json)
        end
      end
    end
  end

  describe 'POST #reset_password_token' do
    let(:sms_code) { random_number_string(6) }
    let(:visitor_id_code) { Random.bytes(16).unpack1("H*") }

    let!(:encrypted_phone) { Gitlab::CryptoHelper.aes256_gcm_encrypt(phone) }
    let!(:user) { create(:user, phone: encrypted_phone) }

    context 'when it is JH COM', :saas do
      before do
        allow_next_instance_of(described_class) do |instance|
          allow(instance).to receive(:visitor_id_code).and_return visitor_id_code
        end
      end

      context 'without sending code' do
        it 'shows nonexist error' do
          post '/users/reset_password_token', params: { phone: phone, verification_code: sms_code }

          expect(json_response["message"]).to eq s_('JH|RealName|Verification code is nonexist.')
        end
      end

      context 'with code sent' do
        before do
          phone_verification = Phone::VerificationCode.find_or_initialize_by(phone: encrypted_phone)

          phone_verification.assign_attributes(
            phone: encrypted_phone,
            visitor_id_code: visitor_id_code,
            code: sms_code,
            created_at: Time.zone.now)

          phone_verification.save!
        end

        context 'with wrong code' do
          it 'shows incorrect code error' do
            post '/users/reset_password_token', params: { phone: phone, verification_code: (sms_code.to_i + 1).to_s }

            expect(json_response["message"]).to eq s_('JH|RealName|Verification code is incorrect.')
          end
        end

        context 'with expired code' do
          it 'shows outdated code error' do
            travel 11.minutes do
              post '/users/reset_password_token', params: { phone: phone, verification_code: sms_code }

              expect(json_response["message"]).to eq s_('JH|RealName|Verification code is outdated.')
            end
          end
        end

        it 'passes the code verification then get token' do
          post '/users/reset_password_token', params: { phone: phone, verification_code: sms_code }

          expect(response).to have_http_status(:ok)
          resp = json_response
          expect(resp["message"]).to be_nil
          expect(resp).to have_key('token')
        end
      end
    end
  end
end
