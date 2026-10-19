# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Gitlab::Chat::Responder::Feishu, feature_category: :integrations do
  let(:chat_name) { create(:chat_name, chat_id: 'U123') }

  let(:receive_id) { "receive_id" }
  let(:pipeline) do
    pipeline = create(:ci_pipeline)

    pipeline.create_chat_data!(
      response_url: 'http://example.com',
      project_id: pipeline.project_id,
      chat_name_id: chat_name.id
    )
    pipeline.variables.create!(
      [{ key: 'CHAT_INPUT', value: "CHAT_INPUT" },
        { key: 'CHAT_CHANNEL', value: receive_id },
        { key: 'CHAT_USER_ID', value: chat_name.chat_id }]
    )

    pipeline
  end

  let(:build) { create(:ci_build, pipeline: pipeline) }
  let(:responder) { described_class.new(build) }

  before do
    stub_application_setting(
      feishu_integration_enabled: true,
      feishu_app_key: "feishu_app_key",
      feishu_app_secret: "feishu_app_secret"
    )
  end

  describe '#send_response' do
    let(:http_client) { instance_double(Gitlab::Feishu::Client) }
    let(:message_title) { "message_title" }
    let(:message_content) { "message_content" }

    before do
      allow(Gitlab::Feishu::Client).to receive(:build).and_return(http_client)
    end

    it 'sends a response back to Feishu' do
      expect(http_client).to receive(:send_message).with(
        /(#{receive_id}).+(#{message_title}).+(#{message_content})/,
        type: nil
      )
      responder.send_response(message_title, message_content)
    end
  end

  describe '#success' do
    it 'returns the output for a successful build' do
      expect(responder).to receive(:send_response).with(
        "ChatOps job finished",
        /successfully/
      )

      responder.success('_output')
    end
  end

  describe '#failure' do
    it 'returns the output for a failed build' do
      expect(responder).to receive(:send_response).with(
        "ChatOps job failed",
        /failed/
      )

      responder.failure
    end
  end

  describe '#scheduled_output' do
    it 'returns the output for a scheduled build' do
      output = responder.scheduled_output

      expect(output).to include(type: :markdown, content: /Your ChatOps job \[#\d+\]\(.+\) has been created!/)
    end
  end
end
