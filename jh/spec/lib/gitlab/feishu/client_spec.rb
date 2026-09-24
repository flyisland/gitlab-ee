# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Gitlab::Feishu::Client do
  subject { described_class.build }

  let(:feishu_token) { 'feishu_token' }

  before do
    stub_application_setting(
      feishu_integration_enabled: true,
      feishu_app_key: "feishu_app_key",
      feishu_app_secret: "feishu_app_secret"
    )
  end

  describe "#send_message" do
    context 'for success' do
      before do
        stub_request(:post, ::Gitlab::Feishu::Client::ACCESS_TOKEN_ENDPOINT)
          .with(
            body: "{\"app_id\":\"feishu_app_key\",\"app_secret\":\"feishu_app_secret\"}",
            headers: {
              'Content-Type' => 'application/json; charset=utf-8'
            })
          .to_return(status: 200,
            body: Gitlab::Json.generate({ tenant_access_token: feishu_token, expire: '1000', code: 0 }),
            headers: {})
      end

      it 'send to group' do
        body = { text: 'body' }
        stub_request(:post, "#{::Gitlab::Feishu::Client::MESSAGE_ENDPOINT}?receive_id_type=chat_id")
          .with(
            body: Gitlab::Json.generate(body),
            headers: {
              'Content-Type' => 'application/json; charset=utf-8',
              'Authorization' => "Bearer #{feishu_token}"
            })
          .to_return(status: 200,
            body: Gitlab::Json.generate({ code: 0 }),
            headers: {})
        expect(subject.send_message(Gitlab::Json.generate(body), type: :group)).not_to be_nil
      end
    end

    context 'for failure' do
      it 'not send message if no token' do
        stub_request(:post, ::Gitlab::Feishu::Client::ACCESS_TOKEN_ENDPOINT)
          .with(
            body: "{\"app_id\":\"feishu_app_key\",\"app_secret\":\"feishu_app_secret\"}",
            headers: {
              'Content-Type' => 'application/json; charset=utf-8'
            })
          .to_return(status: 200, body: Gitlab::Json.generate({ code: 500, msg: 'error' }), headers: {})

        expect(subject.send_message('body', type: :group)).to be_nil

        expect(a_request(:post, "#{::Gitlab::Feishu::Client::MESSAGE_ENDPOINT}?receive_id_type=chat_id"))
          .not_to have_been_made
      end
    end
  end

  describe "#groups_contains_bot" do
    before do
      stub_request(:post, ::Gitlab::Feishu::Client::ACCESS_TOKEN_ENDPOINT)
        .with(
          body: "{\"app_id\":\"feishu_app_key\",\"app_secret\":\"feishu_app_secret\"}",
          headers: {
            'Content-Type' => 'application/json; charset=utf-8'
          })
        .to_return(status: 200,
          body: Gitlab::Json.generate({ tenant_access_token: feishu_token, expire: '1000', code: 0 }),
          headers: {})
    end

    context 'for success' do
      it 'get groups with name and chat_id' do
        stub_request(:get, "#{::Gitlab::Feishu::Client::QUERY_BOT_ENDPOINT}?page_size=100")
          .with(
            headers: {
              'Content-Type' => 'application/json; charset=utf-8',
              'Authorization' => "Bearer #{feishu_token}"
            })
          .to_return(
            status: 200,
            body: Gitlab::Json.generate({
              'code' => 0,
              'data' => { 'items' => [
                { 'name' => 'group1', 'chat_id' => 'chat_id1' },
                { 'name' => 'group2', 'chat_id' => 'chat_id2' }
              ] }
            }), headers: {})

        expect(subject.groups_contains_bot).to eq({ 'group1' => 'chat_id1', 'group2' => 'chat_id2' })
      end
    end

    context 'for failure' do
      it 'get nil when error happen' do
        stub_request(:get, "#{::Gitlab::Feishu::Client::QUERY_BOT_ENDPOINT}?page_size=100")
          .with(
            headers: {
              'Content-Type' => 'application/json; charset=utf-8',
              'Authorization' => "Bearer #{feishu_token}"
            })
          .to_return(status: 500, body: Gitlab::Json.generate({ 'code' => 1 }), headers: {})

        expect(subject.groups_contains_bot).to be_nil
      end
    end
  end
end
