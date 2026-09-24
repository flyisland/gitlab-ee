# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Gitlab::ChatopsMessage::AlertMessage do
  subject { described_class.new(args) }

  let_it_be(:start_time) { Time.current }

  let(:alert) { create(:alert_management_alert, started_at: start_time) }

  let(:args) do
    {
      markdown: true,
      project_name: 'project_name',
      project_url: 'http://example.com'
    }.merge(Gitlab::DataBuilder::Alert.build(alert))
  end

  describe '#pretext' do
    it 'returns the correct message' do
      expect(subject.pretext).to eq("Alert firing in [#{args[:project_name]}](#{args[:project_url]})")
    end
  end

  describe '#attachments' do
    it 'returns an array of one' do
      expect(subject.attachments).to include(alert.title)
      expect(subject.attachments).to include("Severity: #{alert.severity.capitalize}")
      expect(subject.attachments).to include("Events: #{alert.events}")
      expect(subject.attachments).to include("Status: Triggered")
      start_time_str = "Start time: #{Time.zone.parse(start_time.to_s).strftime('%Y-%-m-%-d %T')}"
      expect(subject.attachments).to include(start_time_str)
    end
  end

  describe "#template_theme" do
    it 'return error theme' do
      expect(subject.template_theme).to eq Gitlab::ChatopsMessage::MessageHelper::MESSAGE_THEMES[:error]
    end
  end
end
