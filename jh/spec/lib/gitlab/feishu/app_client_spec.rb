# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Gitlab::Feishu::AppClient, feature_category: :integrations do
  let(:app) { Gitlab::Feishu::App }
  let(:url) { 'https://open.feishu.test/open-apis/im/v1/messages?receive_id_type=open_id' }
  let(:card) { { header: { title: { tag: 'plain_text', content: 'Review requested' } } } }
  let(:uuid) { 'notification-uuid' }
  let(:body) { { code: 0, data: { message_id: 'message-1' } } }
  let(:status) { 200 }
  let(:headers) { {} }

  subject(:send_card) { described_class.new.send_card('ou_user', card, uuid: uuid) }

  before do
    allow(app).to receive_messages(api_site: 'https://open.feishu.test', access_token: 'tenant-token')
    stub_request(:post, url).to_return(status: status, headers: headers, body: Gitlab::Json.generate(body))
  end

  it 'sends an interactive card to the open ID with a stable deduplication key' do
    request = stub_request(:post, url).with(
      headers: { 'Authorization' => 'Bearer tenant-token' },
      body: Gitlab::Json.generate(receive_id: 'ou_user', msg_type: 'interactive',
        content: Gitlab::Json.generate(card), uuid: uuid)
    ).to_return(status: 200, body: Gitlab::Json.generate(body))

    expect(send_card).to eq(body.deep_stringify_keys)
    expect(request).to have_been_requested.once
  end

  [1500, 1503, 5000, 230049].each do |code|
    context "with transient error #{code}" do
      let(:status) { 400 }
      let(:body) { { code: code, msg: 'tenant-token app-secret' } }

      it 'raises a retryable error without leaking provider text' do
        expect { send_card }.to raise_error(described_class::TransientError) { |error|
          expect(error.message).not_to include('tenant-token', 'app-secret')
        }
      end
    end
  end

  [99991403, 99991401, 230013, 230006, 230035, 230053, 99999999].each do |code|
    context "with permanent error #{code}" do
      let(:status) { 400 }
      let(:body) { { code: code, msg: 'tenant-token app-secret' } }

      it 'does not retry an unknown or permanent error' do
        expect { send_card }.to raise_error(described_class::PermanentError) { |error|
          expect(error.message).not_to include('tenant-token', 'app-secret')
        }
      end
    end
  end

  [408, 500, 502, 503].each do |code|
    context "with HTTP #{code}" do
      let(:status) { code }

      it 'raises a retryable error' do
        expect { send_card }.to raise_error(described_class::TransientError)
      end
    end
  end

  context 'when rate limited' do
    let(:status) { 429 }
    let(:body) { { code: 99991400, msg: 'tenant-token' } }

    it 'raises a retryable error without a delay by default' do
      expect { send_card }.to raise_error(Gitlab::Feishu::AppResponse::RateLimited) { |error|
        expect(error).to be_a(described_class::TransientError)
        expect(error.retry_after).to be_nil
        expect(error.message).not_to include('tenant-token')
      }
    end

    {
      { 'Retry-After' => '30' } => 30,
      { 'x-ogw-ratelimit-reset' => '7' } => 7,
      { 'Retry-After' => '0', 'x-ogw-ratelimit-reset' => '7' } => 7,
      { 'Retry-After' => 'soon' } => nil,
      { 'Retry-After' => '-5' } => nil,
      { 'Retry-After' => '86400' } => 1.hour.to_i
    }.each do |rate_limit_headers, delay|
      context "with #{rate_limit_headers}" do
        let(:headers) { rate_limit_headers }

        it "retries after #{delay.inspect} seconds" do
          expect { send_card }.to raise_error(Gitlab::Feishu::AppResponse::RateLimited) { |error|
            expect(error.retry_after).to eq(delay)
          }
        end
      end
    end

    [230020, 99991400].each do |code|
      context "with rate limit code #{code} and HTTP 400" do
        let(:status) { 400 }
        let(:body) { { code: code } }
        let(:headers) { { 'x-ogw-ratelimit-reset' => '3' } }

        it 'raises a retryable error with the advertised delay' do
          expect { send_card }.to raise_error(Gitlab::Feishu::AppResponse::RateLimited) { |error|
            expect(error.retry_after).to eq(3)
          }
        end
      end
    end
  end

  describe '#upload_image' do
    let(:image_url) { 'https://open.feishu.test/open-apis/im/v1/images' }
    let(:file_path) { Rails.root.join('jh/public/feishu-notification-icon.png') }

    subject(:upload_image) { described_class.new.upload_image(file_path) }

    it 'uploads the file as a message image' do
      request = stub_request(:post, image_url)
        .with(headers: { 'Authorization' => 'Bearer tenant-token' }) do |request|
          request.headers['Content-Type'].start_with?('multipart/form-data') &&
            request.body.include?('name="image_type"') && request.body.include?('message')
        end
        .to_return(status: 200, body: '{"code":0,"data":{"image_key":"img_v2_icon"}}')

      expect(upload_image).to eq('code' => 0, 'data' => { 'image_key' => 'img_v2_icon' })
      expect(request).to have_been_requested.once
    end

    it 'refreshes a rejected token once and uploads the file again' do
      allow(app).to receive(:access_token).and_return('tenant-token', 'new-token')
      expect(app).to receive(:invalidate_access_token).once
      stub_request(:post, image_url).to_return(status: 400, body: '{"code":99991663}')
      request = stub_request(:post, image_url).with(headers: { 'Authorization' => 'Bearer new-token' })
        .with { |request| request.body.include?('feishu-notification-icon.png') }
        .to_return(status: 200, body: '{"code":0,"data":{"image_key":"img_v2_icon"}}')

      expect(upload_image.dig('data', 'image_key')).to eq('img_v2_icon')
      expect(request).to have_been_requested.once
    end
  end

  context 'when the access token expires' do
    let(:body) { { code: 99991663 } }

    it 'refreshes once and repeats the same message UUID' do
      allow(app).to receive(:access_token).and_return('tenant-token', 'new-token')
      expect(app).to receive(:invalidate_access_token).once
      request = stub_request(:post, url).with(headers: { 'Authorization' => 'Bearer new-token' })
        .to_return(status: 200, body: '{"code":0}')

      expect(send_card).to eq('code' => 0)
      expect(request).to have_been_requested.once
    end

    it 'stops immediate retries after one refresh' do
      expect(app).to receive(:invalidate_access_token).once

      expect { send_card }.to raise_error(described_class::TransientError)
      expect(a_request(:post, url)).to have_been_made.twice
    end
  end

  [{}, [], { code: '0' }, { code: nil }].each do |invalid_body|
    context "with malformed response #{invalid_body.inspect}" do
      let(:body) { invalid_body }

      it 'fails closed' do
        expect { send_card }.to raise_error(described_class::PermanentError)
      end
    end
  end

  it 'classifies malformed JSON as transient' do
    stub_request(:post, url).to_return(status: 200, body: '<html>upstream error</html>')

    expect { send_card }.to raise_error(described_class::TransientError)
  end

  it 'classifies blocked URLs as permanent' do
    allow(Gitlab::HTTP).to receive(:post).and_raise(Gitlab::HTTP::BlockedUrlError)

    expect { send_card }.to raise_error(described_class::PermanentError)
  end

  it 'classifies timeouts as transient' do
    stub_request(:post, url).to_timeout

    expect { send_card }.to raise_error(described_class::TransientError)
  end
end
