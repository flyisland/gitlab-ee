# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Gitlab::Feishu::Formatter do
  describe '#respond_notification' do
    subject { described_class.new(message: message) }

    let_it_be(:message_klass) { Struct.new(:template_theme, :pretext, :attachments) }

    context 'when format message with success theme' do
      let(:message) do
        message_klass
          .new(
            ::Gitlab::ChatopsMessage::MessageHelper::MESSAGE_THEMES[:success],
            'pretext',
            'attachments'
          )
      end

      it 'return feishu message' do
        expect(subject.respond_notification('feishu_chat_id'))
          .to eq(Gitlab::Json.generate({
                   receive_id: "feishu_chat_id",
                   content:
                     Gitlab::Json.generate({
                       "header" => { "title" => { "tag" => "markdown", "content" => "JiHu GitLab Notification" },
                                     "template" => "green" },
                       "elements" => [
                         { "tag" => "markdown", "content" => "pretext" },
                         { "tag" => "markdown", "content" => "attachments" }
                       ]
                     }),
                   msg_type: "interactive"
                 }))
      end
    end

    context 'when format message attachments only with error theme' do
      let(:message) do
        message_klass
          .new(
            ::Gitlab::ChatopsMessage::MessageHelper::MESSAGE_THEMES[:error],
            'pretext',
            ''
          )
      end

      it 'return feishu message' do
        expect(subject.respond_notification('feishu_chat_id'))
          .to eq(Gitlab::Json.generate({
                   receive_id: "feishu_chat_id",
                   content:
                     Gitlab::Json.generate({
                       "header" => { "title" => { "tag" => "markdown", "content" => "JiHu GitLab Notification" },
                                     "template" => "red" },
                       "elements" => [
                         { "tag" => "markdown", "content" => "pretext" }
                       ]
                     }),
                   msg_type: "interactive"
                 }))
      end
    end
  end
end
