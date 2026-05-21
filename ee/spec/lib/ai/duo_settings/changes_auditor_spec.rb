# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Ai::DuoSettings::ChangesAuditor, feature_category: :ai_abstraction_layer do
  describe '#execute' do
    let_it_be(:user) { create(:user) }

    # Use `let` (not `let_it_be`) so each example gets a fresh record.
    # Reload after creation to clear previous_changes left by the factory insert.
    let(:ai_setting) { create(:ai_settings).tap(&:reload) }
    let(:auditor) { described_class.new(user, ai_setting) }

    before do
      stub_licensed_features(extended_audit_events: true, admin_audit_log: true)
    end

    context 'when a setting is changed' do
      before do
        ai_setting.update!(ai_gateway_url: "http://new-gateway:5052")
      end

      it 'creates an audit event' do
        expect(Gitlab::Audit::Auditor).to receive(:audit).with(
          {
            name: "ai_setting_updated",
            author: user,
            scope: be_an_instance_of(Gitlab::Audit::InstanceScope),
            target: ai_setting,
            message: "Changed ai_gateway_url from http://0.0.0.0:5052 to http://new-gateway:5052",
            additional_details: {
              change: "ai_gateway_url",
              from: "http://0.0.0.0:5052",
              target_details: "Ai gateway url",
              to: "http://new-gateway:5052"
            },
            target_details: "Ai gateway url"
          }
        ).and_call_original

        expect { auditor.execute }.to change { AuditEvent.count }.by(1)

        event = AuditEvent.last
        expect(event.details[:change]).to eq "ai_gateway_url"
        expect(event.details[:from]).to eq "http://0.0.0.0:5052"
        expect(event.details[:to]).to eq "http://new-gateway:5052"
      end
    end

    context 'when multiple settings are changed' do
      before do
        ai_setting.update!(ai_gateway_url: "http://new-gateway:5052", ai_gateway_timeout_seconds: 120)
      end

      it 'creates one audit event per changed column' do
        expect { auditor.execute }.to change { AuditEvent.count }.by(2)
      end
    end

    context 'when no settings are changed' do
      it 'does not create any audit events' do
        expect { auditor.execute }.not_to change { AuditEvent.count }
      end
    end

    context 'when model is blank' do
      let(:auditor) { described_class.new(user, nil) }

      it 'does not create any audit events' do
        expect { auditor.execute }.not_to change { AuditEvent.count }
      end
    end

    context 'when updated_at changes but no other columns change' do
      before do
        allow(ai_setting).to receive(:previous_changes)
          .and_return(ActiveSupport::HashWithIndifferentAccess.new("updated_at" => [1.minute.ago, Time.current]))
      end

      it 'does not create any audit events' do
        expect { auditor.execute }.not_to change { AuditEvent.count }
      end
    end

    context 'when a column not in AUDIT_EVENT_COLUMNS changes' do
      before do
        allow(ai_setting).to receive(:saved_change_to_attribute?).and_return(false)
        allow(ai_setting).to receive(:saved_change_to_attribute?)
          .with(:amazon_q_oauth_application_id).and_return(true)
      end

      it 'does not create any audit events' do
        expect { auditor.execute }.not_to change { AuditEvent.count }
      end
    end
  end
end
