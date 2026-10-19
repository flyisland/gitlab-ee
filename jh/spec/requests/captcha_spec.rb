# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Captcha', :with_current_organization, feature_category: :system_access do
  let(:password) { User.random_password }
  let(:user) { create :user, password: password }
  let(:rand_str) { '@EcF' }
  let(:ticket) { 't03Z2y17' }
  let(:captcha_response) { Base64.encode64(Gitlab::Json.generate({ rand_str: rand_str, ticket: ticket })) }
  let(:spam_log_id) { 40 }

  before(:all) do
    Recaptcha.configuration.skip_verify_env.delete('test')
  end

  after(:all) do
    # Avoid test ordering issue and ensure `verify_recaptcha` returns true
    break if Recaptcha.configuration.skip_verify_env.include?('test')

    Recaptcha.configuration.skip_verify_env << 'test'
  end

  describe 'signing in' do
    let(:params) do
      {
      jh_captcha_response: captcha_response,
      user: {
        login: user.email,
        password: password,
        remember_me: 0
      }
    }
    end

    context 'when captcha is enabled' do
      before do
        allow_next_instance_of(SessionsController) do |instance|
          allow(instance).to receive_messages(captcha_enabled?: true, captcha_on_login_required?: true)
          allow(Gitlab::Recaptcha).to receive(:load_configurations!).at_least(:once).and_return(true)
        end
      end

      context 'when it is COM', :saas do
        context 'when use tencent captcha' do
          before do
            stub_feature_flags(geetest_captcha: false)
          end

          context 'when captcha is solved' do
            before do
              solve_captcha_succeeded
            end

            it 'signs in sucessfully' do
              post user_session_path, params: params
              expect(response).to redirect_to root_path
            end
          end

          context 'when captcha is not solved' do
            before do
              solve_captcha_failed
            end

            it 'signs in failed' do
              post user_session_path, params: params

              expect(flash[:alert]).to include _('There was an error with the ' \
                'reCAPTCHA. Please solve the reCAPTCHA again.')
              expect(response).to have_gitlab_http_status(:ok)
            end
          end
        end

        context 'when use geetest captcha' do
          context 'when captcha is solved' do
            before do
              solve_captcha_succeeded
            end

            it 'signs in sucessfully' do
              post user_session_path, params: params
              expect(response).to redirect_to root_path
            end
          end

          context 'when captcha is not solved' do
            before do
              solve_captcha_failed
            end

            it 'signs in failed' do
              post user_session_path, params: params

              expect(flash[:alert]).to include _('There was an error with the ' \
                'reCAPTCHA. Please solve the reCAPTCHA again.')
              expect(response).to have_gitlab_http_status(:ok)
            end
          end
        end
      end
    end
  end

  describe 'reseting password' do
    let(:params) do
      {
        jh_captcha_response: captcha_response,
        user: {
          email: user.email
        }
      }
    end

    context 'when captcha is enabled' do
      before do
        stub_application_setting(recaptcha_enabled: true)
      end

      context 'when it is COM', :saas do
        context 'when captcha is solved' do
          before do
            solve_captcha_succeeded
          end

          it 'returns password reset message' do
            post user_password_path, params: params

            expect(response).to redirect_to(new_user_session_path)
            expect(flash[:notice]).to include _('If your email address ' \
              'exists in our database, you will receive a password recovery ' \
              'link at your email address in a few minutes.')
          end
        end

        context 'when captcha is not solved' do
          before do
            solve_captcha_failed
          end

          it 'returns that captcha is not solved' do
            post user_password_path, params: params

            expect(response).to have_http_status(:ok)
            expect(flash[:alert]).to include _('There was an error with the ' \
              'reCAPTCHA. Please solve the reCAPTCHA again.')
          end
        end
      end
    end
  end

  describe 'resending confirmation' do
    let(:params) do
      {
        jh_captcha_response: captcha_response,
        user: {
          email: user.email
        }
      }
    end

    context 'when captcha is enabled' do
      before do
        stub_application_setting(recaptcha_enabled: true)
        stub_feature_flags(identity_verification: false)
      end

      context 'when it is COM', :saas do
        context 'when use geetest captcha' do
          context 'when captcha is solved' do
            before do
              solve_captcha_succeeded
            end

            it 'returns password reset message' do
              post user_confirmation_path, params: params

              expect(response).to redirect_to(users_almost_there_path)
            end
          end

          context 'when captcha is not solved' do
            before do
              solve_captcha_failed
            end

            it 'returns that captcha is not solved' do
              post user_confirmation_path, params: params

              expect(response).to have_http_status(:ok)
              expect(flash[:alert]).to include _('There was an error with the ' \
                'reCAPTCHA. Please solve the reCAPTCHA again.')
            end
          end
        end

        context 'when use tencent captcha' do
          before do
            stub_feature_flags(geetest_captcha: false)
          end

          context 'when captcha is solved' do
            before do
              solve_captcha_succeeded
            end

            it 'returns password reset message' do
              post user_confirmation_path, params: params

              expect(response).to redirect_to(users_almost_there_path)
            end
          end

          context 'when captcha is not solved' do
            before do
              solve_captcha_failed
            end

            it 'returns that captcha is not solved' do
              post user_confirmation_path, params: params

              expect(response).to have_http_status(:ok)
              expect(flash[:alert]).to include _('There was an error with the ' \
                'reCAPTCHA. Please solve the reCAPTCHA again.')
            end
          end
        end
      end
    end
  end

  describe 'sending sms code' do
    let(:sms_code) { '123456' }
    let(:phone) { '15612341234' }
    let(:params) do
      {
        phone: phone,
        rand_str: rand_str,
        ticket: ticket
      }
    end

    context 'when captcha is enabled' do
      before do
        stub_application_setting(recaptcha_enabled: true)
      end

      context 'when it is COM', :saas do
        context 'when use geetest captcha' do
          context 'when captcha is solved' do
            before do
              allow(Recaptcha).to receive(:geetest_captcha_verify_via_api_call).and_return(true)
            end

            it 'sends sms code failed' do
              post verification_code_sms_path, params: params

              expected_json = Gitlab::Json.generate({ status: 'SENDING_CODE_ERROR' })
              expect(response).to have_http_status(:ok)
              expect(response.body).to eq(expected_json)
            end

            context 'with spam' do
              before do
                allow_next_instance_of(Phone::VerificationCode) do |instance|
                  allow(instance).to receive(:created_at).and_return Time.now
                end
              end

              it 'renders SENDING_LIMIT_RATE_ERROR' do
                post verification_code_sms_path, params: params

                expected_json = Gitlab::Json.generate({ status: 'SENDING_LIMIT_RATE_ERROR' })
                expect(response).to have_http_status(:ok)
                expect(response.body).to eq(expected_json)
              end
            end

            context 'with code send success' do
              before do
                allow(JH::Sms::TencentSms).to receive(:send_code).and_return('test')
                allow_next_instance_of(SmsController) do |instance|
                  expect(instance).to receive(:visitor_id_code).and_return 'test'
                end
              end

              it 'renders ok' do
                post verification_code_sms_path, params: params

                expected_json = Gitlab::Json.generate({ status: 'OK' })
                expect(response).to have_http_status(:ok)
                expect(response.body).to eq(expected_json)
              end

              context 'with invalid phone verification' do
                before do
                  allow_next_instance_of(Phone::VerificationCode) do |instance|
                    allow(instance).to receive(:valid?).and_return false
                  end
                end

                it 'renders error' do
                  post verification_code_sms_path, params: params

                  expected_json = Gitlab::Json.generate({ status: 'ERROR', message: 'Validation failed: ' })
                  expect(response).to have_http_status(:ok)
                  expect(response.body).to eq(expected_json)
                end
              end
            end
          end

          context 'when captcha is not solved' do
            before do
              allow(Recaptcha).to receive(:geetest_captcha_verify_via_api_call).and_return(false)
            end

            it 'returns RECAPTCHA_ERROR' do
              post verification_code_sms_path, params: params

              expected_json = Gitlab::Json.generate({ status: 'RECAPTCHA_ERROR' })
              expect(response).to have_http_status(:ok)
              expect(response.body).to eq(expected_json)
            end
          end
        end

        context 'when use tencent captcha' do
          before do
            stub_feature_flags(geetest_captcha: false)
          end

          context 'when captcha is solved' do
            before do
              tencent_captcha_succeeded
            end

            it 'sends sms code failed' do
              post verification_code_sms_path, params: params

              expected_json = Gitlab::Json.generate({ status: 'SENDING_CODE_ERROR' })
              expect(response).to have_http_status(:ok)
              expect(response.body).to eq(expected_json)
            end
          end

          context 'when captcha is not solved' do
            before do
              tencent_captcha_failed
            end

            it 'returns RECAPTCHA_ERROR' do
              post verification_code_sms_path, params: params

              expected_json = Gitlab::Json.generate({ status: 'RECAPTCHA_ERROR' })
              expect(response).to have_http_status(:ok)
              expect(response.body).to eq(expected_json)
            end
          end
        end
      end
    end
  end

  describe 'creating new issue' do
    let(:issue) { create(:issue) }
    let(:project) { issue.project }
    let(:user) { issue.author }
    let(:params) do
      {
        issue: {
          title: 'Title',
          description: 'Description'
        },
        spam_log_id: spam_log_id,
        jh_captcha_response: captcha_response
      }
    end

    before do
      login_as(user)
    end

    context 'when captcha is enabled' do
      before do
        allow(Gitlab::CurrentSettings).to receive(:recaptcha_enabled?).and_return(true)
      end

      context 'when it is COM', :saas do
        context 'when captcha is solved' do
          before do
            solve_captcha_succeeded
          end

          it 'creates issue sucessfully' do
            expect { post project_issues_path(project), params: params }
              .to change { Issue.count }.by(1)
            expect(response).to have_http_status(:found)
          end
        end

        context 'when captcha is not solved' do
          before do
            solve_captcha_failed

            expect_next_instance_of(Spam::SpamVerdictService) do |verdict_service|
              allow(verdict_service).to receive(:execute).and_return(Spam::SpamConstants::CONDITIONAL_ALLOW)
            end

            expect_next_instance_of(Issue) do |instance|
              allow(instance).to receive(:check_for_spam?).and_return(true)
            end
          end

          it 'creates issue failed' do
            expect { post project_issues_path(project), params: params }
              .not_to change { Issue.count }
            expect(response).to have_http_status(:unprocessable_entity)
          end
        end
      end
    end
  end

  def solve_captcha_failed
    if ::Feature.enabled?(:geetest_captcha)
      geetest_captcha_failed
    else
      tencent_captcha_failed
    end
  end

  def solve_captcha_succeeded
    if ::Feature.enabled?(:geetest_captcha)
      geetest_captcha_succeeded
    else
      tencent_captcha_succeeded
    end
  end

  def tencent_captcha_failed
    allow(::JH::Captcha::TencentCloud).to receive(:verify!).with(ticket, anything, rand_str).and_return(false)
  end

  def geetest_captcha_failed
    stub_request(:post, "#{JH::Captcha::Geetest.api_server}/validate?captcha_id=")
      .to_return(status: 200, body: '{ "result": "fail"}')
  end

  def tencent_captcha_succeeded
    allow(::JH::Captcha::TencentCloud).to receive(:verify!).with(ticket, anything, rand_str).and_return(true)
  end

  def geetest_captcha_succeeded
    stub_request(:post, "#{JH::Captcha::Geetest.api_server}/validate?captcha_id=")
      .to_return(status: 200, body: '{ "result": "success"}')
  end
end
