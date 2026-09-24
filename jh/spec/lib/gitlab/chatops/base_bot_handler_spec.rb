# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Gitlab::Chatops::BaseBotHandler do
  subject do
    klass = Class.new(described_class)
    klass.new(anything, anything)
  end

  context "when not implement interface methods" do
    let(:interface_methods) do
      %i[
        process_url_verification!
        process_repeat_event!
        valid_message?
        send_bind_link_message
        responder
        command_message
        chat_name
        integration
        setting_enabled?
        group_message?
        formatter_class
        feature_name
        platform_name
      ]
    end

    it "raise NotImplementedError" do
      interface_methods.each do |method|
        expect { subject.send(method) }.to raise_error(NotImplementedError)
      end
    end
  end
end
