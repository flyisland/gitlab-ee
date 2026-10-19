# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Gitlab::Wecom::Formatter do
  describe '#respond_notification', feature_category: :api do
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

      it 'return wecom message' do
        expect(subject.respond_notification).to eq(Gitlab::Json.generate({
          msgtype: "markdown",
          markdown: {
            content: "# <font color=\"info\">JiHu GitLab Notification</font>\npretext\n> attachments"
          }
        }))
      end
    end

    context 'when format message with error theme' do
      let(:message) do
        message_klass
          .new(
            ::Gitlab::ChatopsMessage::MessageHelper::MESSAGE_THEMES[:error],
            'pretext',
            'attachments'
          )
      end

      it 'return wecom message' do
        expect(subject.respond_notification).to eq(Gitlab::Json.generate({
          msgtype: "markdown",
          markdown: {
            content: "# <font color=\"warning\">JiHu GitLab Notification</font>\npretext\n> attachments"
          }
        }))
      end
    end
  end
end
