# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Captcha', feature_category: :system_access do
  include GraphqlHelpers

  let(:rand_str) { '@EcF' }
  let(:ticket) { 't03Z2y17' }
  let(:captcha_response) { Base64.encode64(Gitlab::Json.generate({ rand_str: rand_str, ticket: ticket })) }
  let(:spam_log_id) { 40 }
  let(:headers) { { 'x-gitlab-captcha-response': captcha_response, 'x-gitlab-spam-log-id': spam_log_id } }

  let_it_be(:user) { create(:user) }

  before(:all) do
    Recaptcha.configuration.skip_verify_env.delete('test')
  end

  after(:all) do
    # Avoid test ordering issue and ensure `verify_recaptcha` returns true
    break if Recaptcha.configuration.skip_verify_env.include?('test')

    Recaptcha.configuration.skip_verify_env << 'test'
  end

  describe 'creating snippet' do
    let(:mutation) do
      'mutation create_snippet { createSnippet(input: { ' \
        'title: "Title", blobActions: [{action: create, ' \
        'filePath: "BlobPath", content: "BlobContent"}], ' \
        'visibilityLevel: public}){ errors } }'
    end

    context 'when it is JH COM', :with_current_organization do
      before do
        allow(Gitlab).to receive_messages(com?: true, jh?: true)
      end

      context 'with captcha enabled' do
        before do
          stub_application_setting(recaptcha_enabled: true)
          allow(Gitlab::CurrentSettings).to receive(:recaptcha_enabled?).and_return(true)
        end

        context 'when captcha is solved' do
          context 'when use geetest_captcha' do
            before do
              stub_request(:post, "#{JH::Captcha::Geetest.api_server}/validate?captcha_id=")
                .to_return(status: 200,
                  body: '{"result": "success"}')
            end

            it 'passes the captcha' do
              post_graphql(mutation, current_user: user, headers: headers)

              expect(json_response['errors']).to be_nil
            end
          end

          context 'when use tencent_captcha' do
            before do
              stub_feature_flags(geetest_captcha: false)
              expect(::JH::Captcha::TencentCloud).to receive(:verify!).with(ticket, anything, rand_str).and_return(true)
            end

            it 'passes the captcha' do
              post_graphql(mutation, current_user: user, headers: headers)

              expect(json_response['errors']).to be_nil
            end
          end
        end

        context 'when captcha is not solved' do
          context 'when use geetest captcha' do
            before do
              stub_request(:post, "#{JH::Captcha::Geetest.api_server}/validate?captcha_id=")
                .to_return(status: 200,
                  body: '{"result": "fail"}')
            end

            it 'returns captcha is required' do
              expect_next_instance_of(Spam::SpamVerdictService) do |verdict_service|
                expect(verdict_service).to receive(:execute).and_return(Spam::SpamConstants::CONDITIONAL_ALLOW)
              end
              expect_next_instance_of(Snippet) do |instance|
                expect(instance).to receive(:check_for_spam?).and_return(true)
              end
              post_graphql(mutation, current_user: user, headers: headers)
              expect(json_response.dig('errors', 0, 'message'))
                .to eq(Mutations::SpamProtection::NEEDS_CAPTCHA_RESPONSE_MESSAGE)
            end
          end

          context 'when use tencent captcha' do
            before do
              stub_feature_flags(geetest_captcha: false)
            end

            it 'returns captcha is required' do
              expect(::JH::Captcha::TencentCloud).to receive(:verify!).with(ticket, anything,
                rand_str).and_return(false)
              expect_next_instance_of(Spam::SpamVerdictService) do |verdict_service|
                expect(verdict_service).to receive(:execute).and_return(Spam::SpamConstants::CONDITIONAL_ALLOW)
              end
              expect_next_instance_of(Snippet) do |instance|
                expect(instance).to receive(:check_for_spam?).and_return(true)
              end
              post_graphql(mutation, current_user: user, headers: headers)

              expect(json_response.dig('errors', 0, 'message'))
                .to eq(Mutations::SpamProtection::NEEDS_CAPTCHA_RESPONSE_MESSAGE)
            end
          end
        end
      end
    end
  end
end
