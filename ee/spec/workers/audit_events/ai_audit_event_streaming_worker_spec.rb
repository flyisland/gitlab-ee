# frozen_string_literal: true

require 'spec_helper'

RSpec.describe AuditEvents::AiAuditEventStreamingWorker, feature_category: :audit_events do
  let_it_be(:project) { create(:project) }
  let_it_be(:ai_audit_event) { create(:audit_events_ai_audit_event, target_project: project) }

  let(:worker) { described_class.new }
  let(:payload) { ai_audit_event.streaming_json }

  describe '#perform' do
    subject(:perform) { worker.perform(payload) }

    it 'delegates to ExternalDestinationStreamer with the rebuilt event' do
      expect_next_instance_of(::AuditEvents::ExternalDestinationStreamer,
        ai_audit_event.event_name, kind_of(::AuditEvents::AiAuditEvent)) do |streamer|
        expect(streamer).to receive(:stream_to_destinations)
      end

      perform
    end

    it 'rebuilds the AI audit event with the streamed columns' do
      received_event = nil
      allow(::AuditEvents::ExternalDestinationStreamer).to receive(:new) do |_event_name, event|
        received_event = event
        instance_double(::AuditEvents::ExternalDestinationStreamer, stream_to_destinations: nil)
      end

      perform

      expect(received_event).to be_a(::AuditEvents::AiAuditEvent)
      expect(received_event.cloud_event_id).to eq(ai_audit_event.cloud_event_id)
      expect(received_event.event_name).to eq(ai_audit_event.event_name)
      expect(received_event.project_id).to eq(ai_audit_event.project_id)
    end

    context 'when SilentMode is enabled' do
      before do
        allow(::Gitlab::SilentMode).to receive(:enabled?).and_return(true)
      end

      it 'does not call the external destination streamer' do
        expect(::AuditEvents::ExternalDestinationStreamer).not_to receive(:new)

        perform
      end
    end

    context 'when the payload is invalid JSON' do
      let(:payload) { 'not-json' }

      it 'tracks the exception and does not raise' do
        expect(::Gitlab::ErrorTracking).to receive(:track_exception).with(kind_of(JSON::ParserError))
        expect(::AuditEvents::ExternalDestinationStreamer).not_to receive(:new)

        expect { perform }.not_to raise_error
      end
    end

    context 'when the payload contains a root_group_entity_id' do
      let_it_be(:root_group) { create(:group) }
      let(:payload) do
        ::Gitlab::Json.safe_parse(ai_audit_event.streaming_json)
          .merge('root_group_entity_id' => root_group.id)
          .to_json
      end

      it 'preserves root_group_entity_id on the rebuilt event' do
        received_event = nil
        allow(::AuditEvents::ExternalDestinationStreamer).to receive(:new) do |_event_name, event|
          received_event = event
          instance_double(::AuditEvents::ExternalDestinationStreamer, stream_to_destinations: nil)
        end

        perform

        expect(received_event.root_group_entity_id).to eq(root_group.id)
      end
    end
  end
end
