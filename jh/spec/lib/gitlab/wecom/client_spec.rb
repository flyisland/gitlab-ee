# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Gitlab::Wecom::Client, feature_category: :api do
  subject { described_class.new }

  let(:channel_key) { '1ed13b8c-6bdf-45d0-a666-19de1c1e90b3' }
  let(:message_body) { Gitlab::Json.generate({ msgtype: 'markdown', markdown: { content: "西安今日天气：29度，大部分多云" } }) }

  describe "#send_message" do
    context 'for success' do
      before do
        stub_request(:post, "#{::Gitlab::Wecom::Client::MESSAGE_ENDPOINT}?key=#{channel_key}")
          .with({
            headers: { 'Content-Type' => 'application/json' },
            body: message_body
          })
          .to_return(
            status: 200,
            body: Gitlab::Json.generate({ errcode: 0, errmsg: 'ok' }),
            headers: {})
      end

      it 'sends to wecom api' do
        response = subject.send_message(message_body, channel_key)

        expect(a_request(:post, "#{::Gitlab::Wecom::Client::MESSAGE_ENDPOINT}?key=#{channel_key}")).to have_been_made

        expect(response).not_to be_nil
        expect(Gitlab::Json.parse(response.body)).to include(
          'errcode' => 0,
          'errmsg' => 'ok'
        )
      end
    end

    context 'for failure' do
      before do
        stub_request(:post, "#{::Gitlab::Wecom::Client::MESSAGE_ENDPOINT}?key=#{channel_key}")
          .with({
            headers: { 'Content-Type' => 'application/json' },
            body: message_body
          })
          .to_return(
            status: 200,
            body: Gitlab::Json.generate({ errcode: 40008, errmsg: 'invalid message type' }),
            headers: {})
      end

      it 'gets invaild response' do
        expect(subject.send_message(message_body, channel_key)).to be_nil
      end
    end
  end
end
