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
    context 'when feature flag is disabled' do
      before do
        stub_feature_flags(duo_workflow_audit_events: false)
      end

      it 'returns success with count 0 without writing' do
        expect(ClickHouse::WriteBuffer).not_to receive(:add)
        expect { service.execute }.not_to change { ::AuditEvents::AiAuditEvent.count }
        expect(service.execute.payload).to eq({ status: 'accepted', count: 0 })
      end
    end

    context 'when feature flag is enabled' do
      before do
        stub_feature_flags(duo_workflow_audit_events: true)
      end

      context 'when ClickHouse is globally enabled for analytics' do
        before do
          allow(Gitlab::ClickHouse).to receive(:globally_enabled_for_analytics?).and_return(true)
        end

        it 'buffers records to ClickHouse and does not insert into Postgres' do
          expect(ClickHouse::WriteBuffer).to receive(:add).with('ai_audit_events', anything).twice
          expect { service.execute }.not_to change { ::AuditEvents::AiAuditEvent.count }
        end

        it 'returns success with the event count' do
          allow(ClickHouse::WriteBuffer).to receive(:add)
          result = service.execute
          expect(result).to be_success
          expect(result.payload).to eq({ status: 'accepted', count: 2 })
        end
      end

      context 'when ClickHouse is not globally enabled for analytics' do
        before do
          allow(Gitlab::ClickHouse).to receive(:globally_enabled_for_analytics?).and_return(false)
        end

        it 'persists records to Postgres and does not buffer to ClickHouse' do
          expect(ClickHouse::WriteBuffer).not_to receive(:add)
          expect { service.execute }.to change { ::AuditEvents::AiAuditEvent.count }.by(2)

          persisted = ::AuditEvents::AiAuditEvent.where(cloud_event_id: [event_id_one, event_id_two])
          expect(persisted.pluck(:cloud_event_id)).to contain_exactly(event_id_one, event_id_two)
          expect(persisted.pluck(:event_name))
            .to contain_exactly('ai_llm_input_sent', 'ai_llm_response_received')
          expect(persisted.pluck(:project_id).uniq).to eq([project.id])
          # Project-scoped workflows leave namespace_id nil to satisfy the
          # num_nonnulls(namespace_id, project_id) = 1 table constraint.
          expect(persisted.pluck(:namespace_id).uniq).to eq([nil])
          expect(persisted.pluck(:workflow_id).uniq).to eq([workflow.id])
          expect(persisted.pluck(:author_id).uniq).to eq([user.id])
          expect(persisted.pluck(:created_at)).to contain_exactly(event_time_one, event_time_two)
        end

        it 'deduplicates retried batches via the unique index' do
          service.execute
          expect do
            described_class.new(
              workflow: workflow,
              events: events,
              current_user: user
            ).execute
          end.not_to change { ::AuditEvents::AiAuditEvent.count }
        end
      end

      context 'with a group-scoped workflow' do
        let_it_be(:group) { create(:group) }
        let_it_be(:group_workflow) { create(:duo_workflows_workflow, user: user, namespace: group, project: nil) }

        subject(:service) do
          described_class.new(
            workflow: group_workflow,
            events: events,
            current_user: user
          )
        end

        before do
          allow(Gitlab::ClickHouse).to receive(:globally_enabled_for_analytics?).and_return(false)
        end

        it 'stores namespace_id and leaves project_id nil' do
          service.execute

          persisted = ::AuditEvents::AiAuditEvent.where(cloud_event_id: [event_id_one, event_id_two])
          expect(persisted.pluck(:project_id).uniq).to eq([nil])
          expect(persisted.pluck(:namespace_id).uniq).to eq([group.id])
        end
      end

      it 'skips events without an id' do
        events << { type: 'ai_tool_invoked', source: '/duo_workflow_service', time: event_time_one, data: {} }
        allow(ClickHouse::WriteBuffer).to receive(:add)
        result = service.execute
        expect(result.payload[:count]).to eq(2)
      end

      it 'skips events with blank type' do
        events << {
          id: SecureRandom.uuid, type: '', source: '/duo_workflow_service', time: event_time_one
        }
        allow(ClickHouse::WriteBuffer).to receive(:add)
        result = service.execute
        expect(result.payload[:count]).to eq(2)
      end

      it 'skips events missing time rather than fabricating a timestamp' do
        events << { id: SecureRandom.uuid, type: 'ai_tool_invoked', source: '/duo_workflow_service', data: {} }
        allow(ClickHouse::WriteBuffer).to receive(:add)
        result = service.execute
        expect(result.payload[:count]).to eq(2)
      end

      it 'logs events to the audit JSON log' do
        allow(ClickHouse::WriteBuffer).to receive(:add)
        logger = instance_double(Gitlab::AuditJsonLogger)
        allow(Gitlab::AuditJsonLogger).to receive(:build).and_return(logger)
        expect(logger).to receive(:info).with(hash_including(cloud_event_id: event_id_one)).ordered
        expect(logger).to receive(:info).with(hash_including(cloud_event_id: event_id_two)).ordered
        service.execute
      end

      context 'when streaming to external destinations' do
        before do
          allow(Gitlab::ClickHouse).to receive(:globally_enabled_for_analytics?).and_return(false)
        end

        it 'invokes the streamer for every built audit event' do
          expect(::AuditEvents::AiAuditEvents::Streamer)
            .to receive(:stream).with(kind_of(::AuditEvents::AiAuditEvent)).twice

          service.execute
        end

        it 'does not invoke the streamer for events dropped by the allowlist' do
          events << {
            id: SecureRandom.uuid,
            type: 'totally_made_up_event',
            source: '/duo_workflow_service',
            time: event_time_two,
            data: {}
          }

          expect(::AuditEvents::AiAuditEvents::Streamer)
            .to receive(:stream).with(kind_of(::AuditEvents::AiAuditEvent)).twice

          service.execute
        end

        it 'does not invoke the streamer when no events pass validation' do
          events.clear

          expect(::AuditEvents::AiAuditEvents::Streamer).not_to receive(:stream)

          service.execute
        end
      end

      context 'when an event payload includes ip_address' do
        let(:user_ip) { '203.0.113.42' }
        let(:events) do
          [
            {
              id: event_id_one,
              type: 'ai_llm_input_sent',
              source: '/duo_workflow_service',
              time: event_time_one,
              data: { ip_address: user_ip, model: 'claude-3' }
            }
          ]
        end

        before do
          allow(Gitlab::ClickHouse).to receive(:globally_enabled_for_analytics?).and_return(false)
        end

        it 'persists the ip_address from the CloudEvent payload' do
          service.execute

          persisted = ::AuditEvents::AiAuditEvent.find_by(cloud_event_id: event_id_one)
          expect(persisted.ip_address.to_s).to eq(user_ip)
        end
      end

      context 'when an event payload omits ip_address' do
        before do
          allow(Gitlab::ClickHouse).to receive(:globally_enabled_for_analytics?).and_return(false)
        end

        it 'persists nil for ip_address' do
          service.execute

          persisted = ::AuditEvents::AiAuditEvent.where(cloud_event_id: [event_id_one, event_id_two])
          expect(persisted.pluck(:ip_address).uniq).to eq([nil])
        end
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

        it 'returns an error' do
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

        it 'drops the unknown event and persists the known ones' do
          allow(Gitlab::ClickHouse).to receive(:globally_enabled_for_analytics?).and_return(false)

          result = nil
          expect { result = service.execute }.to change { ::AuditEvents::AiAuditEvent.count }.by(1)

          expect(result).to be_success
          expect(result.payload).to eq({
            status: 'accepted',
            count: 1,
            dropped_unknown_event_types: ['totally_made_up_event']
          })
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

          allow(ClickHouse::WriteBuffer).to receive(:add)

          result = service.execute
          expect(result).to be_success
          expect(result.payload[:dropped_unknown_event_types]).to eq(
            %w[another_bogus_type totally_made_up_event]
          )
        end
      end

      context 'when every name in the batch is in the allowlist' do
        it 'accepts every name listed in AuditEvents::AiAuditEvent::ALLOWED_EVENT_NAMES' do
          allow(Gitlab::ClickHouse).to receive(:globally_enabled_for_analytics?).and_return(false)

          batch = ::AuditEvents::AiAuditEvent::ALLOWED_EVENT_NAMES.each_with_index.map do |name, idx|
            {
              id: SecureRandom.uuid,
              type: name,
              source: '/duo_workflow_service',
              time: event_time_one + idx.seconds,
              data: {}
            }
          end

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
