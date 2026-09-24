# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Gitlab::Chat::Responder::Dingtalk, feature_category: :integrations do
  let(:chat_name) { create(:chat_name, chat_id: 'U123') }

  let(:pipeline) do
    pipeline = create(:ci_pipeline)

    pipeline.create_chat_data!(
      response_url: 'http://example.com',
      project_id: pipeline.project_id,
      chat_name_id: chat_name.id
    )

    pipeline
  end

  let(:build) { create(:ci_build, pipeline: pipeline) }
  let(:responder) { described_class.new(build) }

  before do
    stub_application_setting(
      dingtalk_integration_enabled: true,
      dingtalk_corpid: "dingtalk_corpid",
      dingtalk_app_key: "dingtalk_app_key",
      dingtalk_app_secret: "dingtalk_app_secret"
    )
  end

  describe '#send_response' do
    it 'sends a response back to Dingtalk' do
      body = { msgtype: :markdown, markdown: Gitlab::Json.generate({ title: "ChatOps job finished" }) }

      expect(Gitlab::HTTP).to receive(:post).with(
        pipeline.chat_data.response_url,
        { headers: { Accept: 'application/json', 'Content-Type': 'application/json' },
          body: Gitlab::Json.generate(body) }
      )

      responder.send_response(body)
    end
  end

  describe '#success' do
    it 'returns the output for a successful build' do
      expect(responder).to receive(:send_response).with(
        hash_including(
          msgtype: :markdown,
          markdown: a_string_including('ChatOps job finished')
        ))

      responder.success('hello')
    end

    it 'does not send a response if the output is empty' do
      expect(responder).not_to receive(:send_response)

      responder.success('')
    end
  end

  describe '#failure' do
    it 'returns the output for a failed build' do
      expect(responder).to receive(:send_response).with(
        hash_including(
          msgtype: :markdown,
          markdown: a_string_including('ChatOps job failed')
        ))

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
