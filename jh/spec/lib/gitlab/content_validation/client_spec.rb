# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Gitlab::ContentValidation::Client do
  let(:endpoint) { Gitlab::CurrentSettings.current_application_settings.content_validation_endpoint_url }
  let(:client) { described_class.new }

  describe '#valid?' do
    let(:url) { "#{endpoint}/api/content_validation/validate" }

    context 'with invalid content' do
      before do
        stub_content_validation_request(false)
      end

      it "with sensitive word" do
        expect(client.valid?("sensitive")).to be false
      end
    end

    context 'with valid content' do
      before do
        stub_content_validation_request(true)
      end

      it 'with insensitive word' do
        expect(client.valid?("gitlab")).to be true
      end
    end

    context 'when client request is timeout' do
      it do
        WebMock.stub_request(:post, url).to_timeout
        expect(client.valid?("gitlab")).to be true
      end
    end

    context 'when client request raises an error' do
      it do
        WebMock.stub_request(:post, url).to_raise(StandardError)
        expect(client.valid?("gitlab")).to be true
      end
    end

    context 'when client is disalbed' do
      it do
        WebMock.disable_net_connect!
        expect(client.valid?("gitlab")).to be true
        WebMock.enable_net_connect!
      end
    end
  end

  describe "#blob_validate" do
    before do
      stub_content_validation_settings
      WebMock.stub_request(:post, "#{endpoint}/api/content_validation/blob_validate")
        .to_return(
          status: 200,
          body: ::Gitlab::Json.dump({ 'code' => 200 }),
          headers: { "Content-Type" => "application/json" }
        )
    end

    it "ok" do
      response = client.blob_validate({ user_id: 1, content_type: "text", text: "xxx", commit_sha: "xxx" })
      expect(response.parsed_response).to eq({ 'code' => 200 })
    end
  end

  describe "#user_complaint" do
    before do
      stub_content_validation_settings
      WebMock.stub_request(:post, "#{endpoint}/api/content_validation/complaint")
        .to_return(
          status: 200,
          body: ::Gitlab::Json.dump({ 'code' => 200 }),
          headers: { "Content-Type" => "application/json" }
        )
    end

    it "ok" do
      response = client.user_complaint({ user_id: 1, content_blocked_state_id: 1, description: "xxx" })
      expect(response.parsed_response).to eq({ 'code' => 200 })
    end
  end

  describe "#pre_check" do
    before do
      stub_content_validation_settings
      WebMock.stub_request(:post, "#{endpoint}/api/content_validation/pre_check")
        .to_return(
          status: 200,
          body: ::Gitlab::Json.dump({ 'code' => 200, 'skip_validate' => false }),
          headers: { "Content-Type" => "application/json" }
        )
    end

    it "ok" do
      response = client.pre_check({ project_full_path: "project_full_path" })
      expect(response.parsed_response).to eq({ 'code' => 200, 'skip_validate' => false })
    end
  end
end
