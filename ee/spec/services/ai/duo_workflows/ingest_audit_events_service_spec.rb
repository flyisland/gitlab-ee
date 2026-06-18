# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Ai::DuoWorkflows::IngestAuditEventsService, feature_category: :audit_events do
  let_it_be(:user) { create(:user) }
  let_it_be(:project) { create(:project) }
  let_it_be(:workflow) { create(:duo_workflows_workflow, user: user, project: project) }

  let(:event_id_one) { SecureRandom.uuid }
  let(:event_id_two) { SecureRandom.uuid }
  let(:event_time_one) { DateTime.parse('2026-01-01T00:00:00Z') }
  let(:event_time_two) { DateTime.parse('2026-01-01T00:00:01Z') }

  let(:events) do
    [
      {
        id: event_id_one,
        type: 'ai_llm_input_sent',
        source: '/duo_workflow_service',
        time: event_time_one,
        data: { model: 'claude-3' }
      },
      {
        id: event_id_two,
        type: 'ai_llm_response_received',
        source: '/duo_workflow_service',
        time: event_time_two,
        data: {}
      }
    ]
  end

  subject(:service) do
    described_class.new(
      workflow: workflow,
      events: events,
      current_user: user
    )
  end

  describe '#execute' do
    context 'when ingesting events' do
      it 'enqueues ProcessAuditEventsWorker with the built event attributes' do
        expect(::Ai::DuoWorkflows::ProcessAuditEventsWorker)
          .to receive(:perform_async)
          .with(array_including(
            hash_including('cloud_event_id' => event_id_one, 'event_name' => 'ai_llm_input_sent'),
            hash_including('cloud_event_id' => event_id_two, 'event_name' => 'ai_llm_response_received')
          ))

        service.execute
      end

      it 'returns success with the event count without waiting for processing' do
        allow(::Ai::DuoWorkflows::ProcessAuditEventsWorker).to receive(:perform_async)

        result = service.execute

        expect(result).to be_success
        expect(result.payload).to eq({ status: 'accepted', count: 2 })
      end

      it 'does not perform any storage or logging synchronously' do
        expect(::AuditEvents::AiAuditEvent).not_to receive(:bulk_insert!)
        expect(ClickHouse::WriteBuffer).not_to receive(:add)
        expect(::AuditEvents::AiAuditEvents::Streamer).not_to receive(:stream)
        expect(Gitlab::AuditJsonLogger).not_to receive(:build)

        allow(::Ai::DuoWorkflows::ProcessAuditEventsWorker).to receive(:perform_async)

        service.execute
      end

      it 'skips events without an id' do
        events << { type: 'ai_tool_invoked', source: '/duo_workflow_service', time: event_time_one, data: {} }

        expect(::Ai::DuoWorkflows::ProcessAuditEventsWorker)
          .to receive(:perform_async).with(array_including(have_attributes(size: 2).or(be_a(Hash))))

        result = service.execute

        expect(result.payload[:count]).to eq(2)
      end

      it 'skips events with blank type' do
        events << { id: SecureRandom.uuid, type: '', source: '/duo_workflow_service', time: event_time_one }

        allow(::Ai::DuoWorkflows::ProcessAuditEventsWorker).to receive(:perform_async)

        result = service.execute

        expect(result.payload[:count]).to eq(2)
      end

      it 'skips events missing time rather than fabricating a timestamp' do
        events << { id: SecureRandom.uuid, type: 'ai_tool_invoked', source: '/duo_workflow_service', data: {} }

        allow(::Ai::DuoWorkflows::ProcessAuditEventsWorker).to receive(:perform_async)

        result = service.execute

        expect(result.payload[:count]).to eq(2)
      end

      it 'does not enqueue the worker when no events pass validation' do
        events.clear

        expect(::Ai::DuoWorkflows::ProcessAuditEventsWorker).not_to receive(:perform_async)

        service.execute
      end

      context 'when events is nil' do
        subject(:service) do
          described_class.new(
            workflow: workflow,
            events: nil,
            current_user: user
          )
        end

        it 'returns success with count 0 without raising' do
          result = service.execute

          expect(result).to be_success
          expect(result.payload).to eq({ status: 'accepted', count: 0 })
        end
      end

      context 'when batch exceeds max size' do
        let(:events) do
          Array.new(501) do
            { id: SecureRandom.uuid, type: 'ai_llm_input_sent', source: '/', time: event_time_one }
          end
        end

        it 'returns an error without enqueuing' do
          expect(::Ai::DuoWorkflows::ProcessAuditEventsWorker).not_to receive(:perform_async)

          result = service.execute

          expect(result).to be_error
          expect(result.reason).to eq(:bad_request)
        end
      end

      context 'when an event has an unknown type name' do
        let(:events) do
          [
            {
              id: SecureRandom.uuid,
              type: 'ai_llm_input_sent',
              source: '/duo_workflow_service',
              time: event_time_one,
              data: {}
            },
            {
              id: SecureRandom.uuid,
              type: 'totally_made_up_event',
              source: '/duo_workflow_service',
              time: event_time_two,
              data: {}
            }
          ]
        end

        it 'enqueues only the known event and reports the dropped type' do
          enqueued_attrs = nil
          allow(::Ai::DuoWorkflows::ProcessAuditEventsWorker)
            .to receive(:perform_async) { |attrs| enqueued_attrs = attrs }

          result = service.execute

          expect(result).to be_success
          expect(result.payload).to eq({
            status: 'accepted',
            count: 1,
            dropped_unknown_event_types: ['totally_made_up_event']
          })
          expect(enqueued_attrs.size).to eq(1)
          expect(enqueued_attrs.first['event_name']).to eq('ai_llm_input_sent')
        end

        it 'reports every unknown name once, sorted, in the response payload' do
          events << {
            id: SecureRandom.uuid,
            type: 'another_bogus_type',
            source: '/duo_workflow_service',
            time: event_time_two,
            data: {}
          }

          # Same unknown name twice should be deduplicated in the response
          events << {
            id: SecureRandom.uuid,
            type: 'totally_made_up_event',
            source: '/duo_workflow_service',
            time: event_time_two,
            data: {}
          }

          allow(::Ai::DuoWorkflows::ProcessAuditEventsWorker).to receive(:perform_async)

          result = service.execute

          expect(result).to be_success
          expect(result.payload[:dropped_unknown_event_types]).to eq(
            %w[another_bogus_type totally_made_up_event]
          )
        end
      end

      context 'when every name in the batch is in the allowlist' do
        it 'accepts every name listed in AuditEvents::AiAuditEvent::ALLOWED_EVENT_NAMES' do
          batch = ::AuditEvents::AiAuditEvent::ALLOWED_EVENT_NAMES.each_with_index.map do |name, idx|
            {
              id: SecureRandom.uuid,
              type: name,
              source: '/duo_workflow_service',
              time: event_time_one + idx.seconds,
              data: {}
            }
          end

          allow(::Ai::DuoWorkflows::ProcessAuditEventsWorker).to receive(:perform_async)

          result = described_class.new(
            workflow: workflow, events: batch, current_user: user
          ).execute

          expect(result).to be_success
          expect(result.payload[:count]).to eq(batch.size)
        end
      end
    end
  end
end
