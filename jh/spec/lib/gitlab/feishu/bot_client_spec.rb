# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Gitlab::Feishu::BotClient, feature_category: :duo_agent_platform do
  let(:api) { 'https://open.feishu.cn/open-apis' }
  let(:client) { described_class.new }

  before do
    allow(::Gitlab::Feishu::BotApp).to receive(:access_token).and_return('tenant-token')
  end

  def respond(body, status: 200)
    { status: status, body: Gitlab::Json.generate(body) }
  end

  describe '#bot_open_id' do
    it "reads the robot's open_id from the top-level bot object" do
      stub_request(:get, "#{api}/bot/v3/info")
        .with(headers: { 'Authorization' => 'Bearer tenant-token' })
        .to_return(respond({ code: 0, msg: 'ok', bot: { open_id: 'ou_bot', app_name: 'GitLab' } }))

      expect(client.bot_open_id).to eq('ou_bot')
    end
  end

  describe '#reply' do
    it 'replies to the message with the content as a JSON string and the deduplication uuid' do
      request = stub_request(:post, "#{api}/im/v1/messages/om_1/reply")
        .with(body: { msg_type: 'post', content: '{"zh_cn":{}}', uuid: 'duo-reply-om_1' })
        .to_return(respond({ code: 0, data: { message_id: 'om_2' } }))

      client.reply('om_1', msg_type: 'post', content: { zh_cn: {} }, uuid: 'duo-reply-om_1')

      expect(request).to have_been_requested
    end

    it 'retries once with a fresh token when Feishu rejects the cached one', :aggregate_failures do
      stub_request(:post, "#{api}/im/v1/messages/om_1/reply")
        .to_return(respond({ code: 99991663 }, status: 400), respond({ code: 0, data: {} }))

      expect(::Gitlab::Feishu::BotApp).to receive(:invalidate_access_token).once

      client.reply('om_1', msg_type: 'text', content: {}, uuid: 'u')
    end

    it 'raises a permanent error for a recalled message' do
      stub_request(:post, "#{api}/im/v1/messages/om_1/reply").to_return(respond({ code: 230011 }, status: 400))

      expect { client.reply('om_1', msg_type: 'text', content: {}, uuid: 'u') }
        .to raise_error(described_class::PermanentError)
    end
  end

  describe '#create_card' do
    it 'creates a card entity from card JSON and returns its id' do
      card = { schema: '2.0', body: { elements: [] } }
      stub_request(:post, "#{api}/cardkit/v1/cards")
        .with(body: { type: 'card_json', data: Gitlab::Json.generate(card) })
        .to_return(respond({ code: 0, data: { card_id: 'card_1' } }))

      expect(client.create_card(card)).to eq('card_1')
    end

    it 'raises when Feishu returns no card id' do
      stub_request(:post, "#{api}/cardkit/v1/cards").to_return(respond({ code: 0, data: {} }))

      expect { client.create_card({}) }.to raise_error(described_class::PermanentError)
    end
  end

  describe '#stream_card_text' do
    let(:url) { "#{api}/cardkit/v1/cards/card_1/elements/duo_content/content" }

    it 'sends the full text with its sequence' do
      request = stub_request(:put, url).with(body: { content: 'hello', sequence: 3 }).to_return(respond({ code: 0 }))

      client.stream_card_text('card_1', 'duo_content', 'hello', sequence: 3)

      expect(request).to have_been_requested
    end

    [200850, 300309].each do |code|
      it "tells a closed stream (#{code}) apart from other refusals" do
        stub_request(:put, url).to_return(respond({ code: code }, status: 400))

        expect { client.stream_card_text('card_1', 'duo_content', 'hello', sequence: 1) }
          .to raise_error(described_class::StreamingClosedError)
      end
    end

    it 'raises a plain permanent error for an out-of-order sequence' do
      stub_request(:put, url).to_return(respond({ code: 300317 }, status: 400))

      expect { client.stream_card_text('card_1', 'duo_content', 'hello', sequence: 1) }
        .to raise_error(described_class::PermanentError) { |error|
          expect(error).not_to be_a(described_class::StreamingClosedError)
        }
    end
  end

  describe '#update_card' do
    it 'replaces the card with card JSON and its sequence' do
      card = { schema: '2.0' }
      request = stub_request(:put, "#{api}/cardkit/v1/cards/card_1")
        .with(body: { card: { type: 'card_json', data: Gitlab::Json.generate(card) }, sequence: 4 })
        .to_return(respond({ code: 0 }))

      client.update_card('card_1', card, sequence: 4)

      expect(request).to have_been_requested
    end
  end

  it 'raises a transient error when Feishu cannot be reached' do
    stub_request(:get, "#{api}/bot/v3/info").to_raise(Errno::ECONNREFUSED)

    expect { client.bot_open_id }.to raise_error(described_class::TransientError)
  end
end
