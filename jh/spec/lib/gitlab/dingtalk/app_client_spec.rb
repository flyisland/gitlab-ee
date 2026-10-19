# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Gitlab::Dingtalk::AppClient, feature_category: :integrations do
  let(:app) { class_double(Gitlab::Dingtalk::App, access_token: 'token', agent_id: '123') }
  let(:client) { described_class.new(app: app) }
  let(:card) { { title: 'Title', markdown: 'Text', single_title: 'View', single_url: 'https://example.com' } }

  def send_card
    client.send_card('staff-123', card)
  end

  def response(body, status: 200)
    stub_request(:post, described_class::ENDPOINT).with(query: { access_token: 'token' })
      .to_return(status: status, body: body.to_json)
  end

  it 'sends an action card to only the corporate userid' do
    request = response({ errcode: 0, task_id: 123 })
      .with(body: {
        agent_id: 123, userid_list: 'staff-123', to_all_user: false,
        msg: { msgtype: 'action_card', action_card: card }
      }.to_json)

    send_card

    expect(request).to have_been_requested.once
  end

  it 'refreshes a rejected token once' do
    response({ errcode: 40014 })
    expect(app).to receive(:invalidate_access_token).once

    expect { send_card }.to raise_error(described_class::TransientError, /kept rejecting/)
  end

  [-1].each do |code|
    it "retries known transient error #{code}" do
      response({ errcode: code })

      expect { send_card }.to raise_error(described_class::TransientError)
    end
  end

  [90002, 90018, 90006, 40003, 999_999, nil, '0'].each do |code|
    it "does not retry rate limits, unknown errors or invalid code #{code.inspect}" do
      response({ errcode: code, errmsg: 'secret token-value' })

      expect { send_card }.to raise_error(described_class::PermanentError, 'DingTalk refused the request')
    end
  end

  [408, 500, 502, 503].each do |status|
    it "retries HTTP #{status}" do
      response({}, status: status)

      expect { send_card }.to raise_error(described_class::TransientError)
    end
  end

  [400, 401, 403, 429].each do |status|
    it "does not retry HTTP #{status}" do
      response({}, status: status)

      expect { send_card }.to raise_error(described_class::PermanentError)
    end
  end

  it 'rejects multiple recipients' do
    expect { client.send_card('staff-123,other', card) }.to raise_error(ArgumentError)
  end

  it 'retries malformed responses' do
    stub_request(:post, described_class::ENDPOINT).with(query: { access_token: 'token' })
      .to_return(body: '<html>gateway</html>')

    expect { send_card }.to raise_error(described_class::TransientError)
  end

  it 'redacts network exceptions and their causes' do
    allow(Gitlab::HTTP).to receive(:post).and_raise(Net::ReadTimeout, 'secret token-value')

    expect { send_card }.to raise_error(described_class::TransientError) do |error|
      expect(error.message).not_to include('token-value')
      expect(error.cause).to be_nil
    end
  end
end
