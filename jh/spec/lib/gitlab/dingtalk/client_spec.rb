# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Gitlab::Dingtalk::Client do
  describe "#send_message" do
    subject { described_class.new({ corpid: 'corpid', app_secret: 'app_secret', app_key: 'app_key' }) }

    let(:dingtalk_token) { 'dingtalk_token' }

    context 'when success' do
      before do
        stub_request(:post, ::Gitlab::Dingtalk::Client::ACCESS_TOKEN_ENDPOINT)
          .with(
            body: "{\"appKey\":\"app_key\",\"appSecret\":\"app_secret\"}",
            headers: {
              'Content-Type' => 'application/json'
            })
          .to_return(status: 200, body: Gitlab::Json.generate({ accessToken: dingtalk_token,
                                                                expireIn: '1000' }), headers: {})
      end

      it 'send to user' do
        body = { text: 'body' }
        stub_request(:post, ::Gitlab::Dingtalk::Client::USER_MESSAGE_ENDPOINT)
          .with(
            body: Gitlab::Json.generate(body),
            headers: {
              'Content-Type' => 'application/json',
              'x-acs-dingtalk-access-token' => dingtalk_token
            })

        subject.send_message(Gitlab::Json.generate(body))
      end

      it 'send to group' do
        body = { text: 'body' }
        stub_request(:post, ::Gitlab::Dingtalk::Client::GROUP_MESSAGE_ENDPOINT)
          .with(
            body: Gitlab::Json.generate(body),
            headers: {
              'Content-Type' => 'application/json',
              'x-acs-dingtalk-access-token' => dingtalk_token
            })
        subject.send_message(Gitlab::Json.generate(body), type: :group)
      end
    end

    context 'when failure' do
      it 'not send message if no token' do
        stub_request(:post, ::Gitlab::Dingtalk::Client::ACCESS_TOKEN_ENDPOINT)
          .with(
            body: "{\"appKey\":\"app_key\",\"appSecret\":\"app_secret\"}",
            headers: {
              'Content-Type' => 'application/json'
            })
          .to_return(status: 500, body: 'error', headers: {})

        subject.send_message('body', type: :group)

        expect(a_request(:post, ::Gitlab::Dingtalk::Client::GROUP_MESSAGE_ENDPOINT)).not_to have_been_made
      end
    end
  end
end
