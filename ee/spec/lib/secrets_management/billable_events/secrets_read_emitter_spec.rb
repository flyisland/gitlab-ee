# frozen_string_literal: true

require 'spec_helper'

RSpec.describe SecretsManagement::BillableEvents::SecretsReadEmitter, feature_category: :secrets_management do
  let_it_be(:project) { create(:project) }
  let_it_be(:group) { create(:group) }
  let_it_be(:user) { create(:user) }

  let(:audit_log) { SecretsManagement::AuditLog.new(payload_json) }
  let(:parsed_payload) { Gitlab::Json.safe_parse(payload_json) }
  let(:openbao_request_id) { parsed_payload.dig('request', 'id') }
  let(:openbao_entity_id) { parsed_payload.dig('auth', 'entity_id') }
  let(:expected_timestamp) { Time.zone.parse('2026-01-26T17:51:15.111915Z') }

  before do
    stub_feature_flags(secrets_manager_emit_secret_read_events: true)
    allow(::CloudConnector).to receive(:gitlab_realm).and_return(::CloudConnector::GITLAB_REALM_SAAS)
    allow(::Gitlab::BillingEvents::Client).to receive(:track_billing_event)
  end

  describe '.emit!' do
    context 'with a successful KV data read on a project mount' do
      let(:payload_json) { kv_data_read_success_payload }

      it 'tracks a secrets_read billing event scoped to the project namespace' do
        described_class.emit!(audit_log)

        expect(::Gitlab::BillingEvents::Client).to have_received(:track_billing_event).with(
          event_type: 'secrets_read',
          category: described_class.name,
          unit_of_measure: 'request',
          quantity: 1,
          namespace: project.namespace,
          project: project,
          user: user,
          idempotency_key: "secrets_read:#{openbao_request_id}",
          timestamp: expected_timestamp,
          metadata: hash_including(
            mount_type: 'kv',
            audit_request_id: openbao_request_id,
            openbao_entity_id: openbao_entity_id
          )
        )
      end
    end

    context 'with a successful KV data read on a group mount' do
      let(:payload_json) { kv_data_read_group_secret_success_payload }

      it 'tracks a secrets_read billing event scoped to the group, without a project' do
        described_class.emit!(audit_log)

        expect(::Gitlab::BillingEvents::Client).to have_received(:track_billing_event).with(
          event_type: 'secrets_read',
          category: described_class.name,
          unit_of_measure: 'request',
          quantity: 1,
          namespace: group,
          project: nil,
          user: user,
          idempotency_key: "secrets_read:#{openbao_request_id}",
          timestamp: expected_timestamp,
          metadata: hash_including(
            mount_type: 'kv',
            audit_request_id: openbao_request_id,
            openbao_entity_id: openbao_entity_id
          )
        )
      end
    end

    context 'with a permission-denied read' do
      let(:payload_json) { kv_read_permission_denied_payload }

      it 'does not track a billing event' do
        described_class.emit!(audit_log)

        expect(::Gitlab::BillingEvents::Client).not_to have_received(:track_billing_event)
      end
    end

    context 'when the feature flag is disabled' do
      let(:payload_json) { kv_data_read_success_payload }

      before do
        stub_feature_flags(secrets_manager_emit_secret_read_events: false)
      end

      it 'does not track a billing event' do
        described_class.emit!(audit_log)

        expect(::Gitlab::BillingEvents::Client).not_to have_received(:track_billing_event)
      end
    end

    context 'on Self-Managed / Dedicated' do
      let(:payload_json) { kv_data_read_success_payload }

      before do
        allow(::CloudConnector).to receive(:gitlab_realm).and_return(::CloudConnector::GITLAB_REALM_SELF_MANAGED)
      end

      it 'does not track a billing event (SaaS-only)' do
        described_class.emit!(audit_log)

        expect(::Gitlab::BillingEvents::Client).not_to have_received(:track_billing_event)
      end
    end

    context 'with a request-type audit log (pre-operation entry)' do
      let(:payload_json) do
        json = Gitlab::Json.safe_parse(kv_data_read_success_payload)
        json['type'] = 'request'
        json.to_json
      end

      it 'does not track a billing event, mirroring AuditLog#ignore_log? defense in depth' do
        described_class.emit!(audit_log)

        expect(::Gitlab::BillingEvents::Client).not_to have_received(:track_billing_event)
      end
    end

    context 'with a non-read event (create)' do
      let(:payload_json) do
        json = Gitlab::Json.safe_parse(kv_data_read_success_payload)
        json['request']['operation'] = 'create'
        json.to_json
      end

      it 'does not track a billing event' do
        described_class.emit!(audit_log)

        expect(::Gitlab::BillingEvents::Client).not_to have_received(:track_billing_event)
      end
    end

    context 'when tracking raises' do
      let(:payload_json) { kv_data_read_success_payload }

      before do
        allow(::Gitlab::BillingEvents::Client).to receive(:track_billing_event).and_raise(StandardError, 'boom')
      end

      it 'swallows the exception and tracks it' do
        expect(::Gitlab::ErrorTracking).to receive(:track_exception).with(
          instance_of(StandardError),
          hash_including(:audit_log_event_type)
        )

        expect { described_class.emit!(audit_log) }.not_to raise_error
      end
    end
  end

  def kv_data_read_success_payload
    json = File.read(Rails.root.join('ee/spec/fixtures/secrets_manager/audit_log_kv_data_read_success.json'))
    parsed = Gitlab::Json.safe_parse(json)
    parsed['auth']['metadata']['project_id'] = project.id.to_s
    parsed['auth']['metadata']['namespace_id'] = project.namespace.id.to_s
    parsed['auth']['metadata']['user_id'] = user.id.to_s
    parsed['request']['namespace']['path'] = "user_#{user.id}/project_#{project.id}/"
    parsed.to_json
  end

  def kv_read_permission_denied_payload
    File.read(Rails.root.join('ee/spec/fixtures/secrets_manager/audit_log_kv_read_permission_denied.json'))
  end

  def kv_data_read_group_secret_success_payload
    fixture_path = 'ee/spec/fixtures/secrets_manager/audit_log_kv_data_read_group_secret_success.json'
    json = File.read(Rails.root.join(fixture_path))
    parsed = Gitlab::Json.safe_parse(json)
    parsed['auth']['metadata']['namespace_id'] = group.id.to_s
    parsed['auth']['metadata']['group_id'] = group.id.to_s
    parsed['auth']['metadata']['user_id'] = user.id.to_s
    parsed['request']['namespace']['path'] = "group_#{group.id}/group_#{group.id}/"
    parsed['request']['mount_point'] = "group_#{group.id}/group_#{group.id}/secrets/kv/"
    parsed['response']['mount_point'] = "group_#{group.id}/group_#{group.id}/secrets/kv/"
    parsed.to_json
  end
end
