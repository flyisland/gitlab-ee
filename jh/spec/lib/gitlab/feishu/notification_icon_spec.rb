# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Gitlab::Feishu::NotificationIcon, :use_clean_rails_memory_store_caching, feature_category: :integrations do
  let(:app) { Gitlab::Feishu::App }
  let(:url) { 'https://open.feishu.test/open-apis/im/v1/images' }

  subject(:image_key) { described_class.image_key(app: app) }

  before do
    allow(app).to receive_messages(api_site: 'https://open.feishu.test', app_id: 'cli_app', access_token: 'token')
  end

  it 'uploads the instance icon once and reuses its key', :aggregate_failures do
    request = stub_request(:post, url)
      .with(headers: { 'Authorization' => 'Bearer token' }) do |request|
        request.headers['Content-Type'].start_with?('multipart/form-data') &&
          request.body.include?('name="image_type"') && request.body.include?('feishu-notification-icon.png')
      end
      .to_return(status: 200, body: '{"code":0,"data":{"image_key":"img_v2_icon"}}')

    expect(image_key).to eq('img_v2_icon')
    expect(described_class.image_key(app: app)).to eq('img_v2_icon')
    expect(request).to have_been_requested.once
  end

  it 'uploads again for a different app' do
    stub_request(:post, url).to_return(status: 200, body: '{"code":0,"data":{"image_key":"img_v2_icon"}}')
    image_key
    allow(app).to receive(:app_id).and_return('other_app')

    described_class.image_key(app: app)

    expect(a_request(:post, url)).to have_been_made.twice
  end

  context 'when the upload is refused' do
    before do
      stub_request(:post, url).to_return(status: 400, body: '{"code":99991672,"msg":"token app-secret"}')
    end

    it 'sends without an icon and waits before uploading again', :aggregate_failures do
      expect(Gitlab::AppLogger).to receive(:warn).once.with(hash_including(
        message: 'Could not upload the Feishu notification icon',
        Labkit::Fields::ERROR_MESSAGE => 'Feishu refused the request: code=99991672'
      ))

      expect(image_key).to be_nil
      expect(described_class.image_key(app: app)).to be_nil
      expect(a_request(:post, url)).to have_been_made.once
    end
  end

  it 'treats a response without an image key as a failed upload' do
    stub_request(:post, url).to_return(status: 200, body: '{"code":0,"data":"img_v2_icon"}')

    expect(image_key).to be_nil
  end
end
