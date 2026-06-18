# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Types::Ai::DuoWorkflows::SessionArtifactType, feature_category: :duo_agent_platform do
  it 'has the expected fields' do
    expected_fields = %i[id workflow_definition web_path audit_events_count project workflow_created_at]
    expect(described_class).to have_graphql_fields(*expected_fields)
  end

  it 'exposes id as non-null GraphQL ID' do
    expect(described_class.fields['id'].type.to_type_signature).to eq('ID!')
  end

  it 'exposes workflowDefinition as non-null String' do
    expect(described_class.fields['workflowDefinition'].type.to_type_signature).to eq('String!')
  end

  it 'exposes workflowCreatedAt as non-null Time' do
    expect(described_class.fields['workflowCreatedAt'].type.to_type_signature).to eq('Time!')
  end

  it 'exposes auditEventsCount as non-null Int' do
    expect(described_class.fields['auditEventsCount'].type.to_type_signature).to eq('Int!')
  end

  it 'exposes webPath as nullable String' do
    expect(described_class.fields['webPath'].type.to_type_signature).to eq('String')
  end

  describe '#id' do
    it 'returns the workflow_id as a Workflow GID' do
      artifact = instance_double(
        ::Ai::DuoWorkflows::SessionArtifact,
        workflow_id: 42
      )
      type_instance = described_class.send(:new, artifact, {})
      expected_gid = ::Gitlab::GlobalId.build(model_name: 'Ai::DuoWorkflows::Workflow', id: 42).to_s

      expect(type_instance.id).to eq(expected_gid)
    end
  end

  describe '#audit_events_count' do
    let_it_be(:workflow) { create(:duo_workflows_workflow) }
    let_it_be(:artifact) { create(:duo_workflow_session_artifact, workflow: workflow) }

    subject(:type_instance) { described_class.send(:new, artifact, {}) }

    context 'when ClickHouse is not enabled for analytics' do
      before do
        allow(::Gitlab::ClickHouse).to receive(:globally_enabled_for_analytics?).and_return(false)
        allow(::AuditEvents::AiAuditEvent)
          .to receive(:counts_for_workflows)
          .and_return({ workflow.id => 3 })
      end

      it 'queries PostgreSQL' do
        expect(type_instance.audit_events_count.sync).to eq(3)
        expect(::AuditEvents::AiAuditEvent).to have_received(:counts_for_workflows).with([workflow.id],
          min_created_at: anything)
      end
    end

    context 'when ClickHouse is enabled for analytics' do
      before do
        allow(::Gitlab::ClickHouse).to receive(:globally_enabled_for_analytics?).and_return(true)
        allow(::AuditEvents::AiAuditEvents::ClickHouseFinder)
          .to receive(:counts_for_workflows)
          .and_return({ workflow.id => 5 })
      end

      it 'queries ClickHouse' do
        expect(type_instance.audit_events_count.sync).to eq(5)
        expect(::AuditEvents::AiAuditEvents::ClickHouseFinder)
          .to have_received(:counts_for_workflows)
          .with([workflow.id], min_created_at: anything)
      end
    end
  end
end
