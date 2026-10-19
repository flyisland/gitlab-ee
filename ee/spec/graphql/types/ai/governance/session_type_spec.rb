# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Types::Ai::Governance::SessionType, feature_category: :compliance_management do
  include GraphqlHelpers

  specify { expect(described_class.graphql_name).to eq('AiGovernanceSession') }

  it 'has the expected fields' do
    expect(described_class).to have_graphql_fields(
      :id, :session_id, :flow_type, :agent_type, :source, :session_started_at, :web_path, :download_path, :project,
      :triggered_by, :audit_events, :audit_events_count
    )
  end

  it 'types the non-null fields', :aggregate_failures do
    expect(described_class.fields['id'].type.to_type_signature).to eq('AiGovernanceSessionID!')
    expect(described_class.fields['source'].type.to_type_signature).to eq('AiGovernanceSessionSource!')
    expect(described_class.fields['sessionStartedAt'].type.to_type_signature).to eq('Time!')
  end

  describe 'field resolution' do
    let_it_be(:project) { create(:project) }
    let_it_be(:user) { create(:user) }

    let(:duo_row) do
      { 'id' => 7, 'source' => 0, 'workflow_id' => 42, 'external_xid' => nil, 'project_id' => project.id,
        'namespace_id' => project.project_namespace_id, 'user_id' => user.id, 'flow_type' => 'chat',
        'agent_type' => nil, 'session_started_at' => '2026-07-01 10:00:00.000000' }
    end

    let(:external_row) do
      duo_row.merge('source' => 2, 'workflow_id' => nil, 'external_xid' => 'glab_123', 'agent_type' => 'claude-code')
    end

    it 'builds the global ID from the row id' do
      expect(resolve_field(:id, duo_row)).to eq(::Gitlab::GlobalId.build(model_name: 'Ai::Governance::Session', id: 7))
    end

    it 'maps the source value to its name', :aggregate_failures do
      expect(resolve_field(:source, duo_row)).to eq('gitlab_duo')
      expect(resolve_field(:source, external_row)).to eq('claude_code_glab')
    end

    it 'parses the session start time' do
      expect(resolve_field(:session_started_at, duo_row)).to eq(Time.utc(2026, 7, 1, 10))
    end

    it 'returns the workflow ID as the session ID for a GitLab Duo session' do
      expect(resolve_field(:session_id, duo_row)).to eq('42')
    end

    it 'returns the external ID as the session ID for a session from another source' do
      expect(resolve_field(:session_id, external_row)).to eq('glab_123')
    end

    it 'returns no audit events for a GitLab Duo session without a workflow' do
      expect(resolve_field(:audit_events, duo_row.merge('workflow_id' => nil)).items).to be_empty
    end

    it 'counts no audit events for a GitLab Duo session without a workflow' do
      expect(resolve_field(:audit_events_count, duo_row.merge('workflow_id' => nil))).to eq(0)
    end

    it 'looks up the audit events of a session from another source by session ID' do
      expect(::AuditEvents::AiAuditEvents::ClickHouseFinder).to receive(:new)
        .with(ai_governance_session_id: 7,
          created_after: Time.utc(2026, 7, 1, 10) - described_class::AUDIT_EVENTS_CLOCK_SKEW)
        .and_call_original

      resolve_field(:audit_events, external_row)
    end

    it 'returns no paths for a session from another source', :aggregate_failures do
      expect(resolve_field(:web_path, external_row)).to be_nil
      expect(resolve_field(:download_path, external_row)).to be_nil
    end
  end

  it 'exposes a countable connection' do
    expect(described_class.connection_type.fields.keys).to include('count')
  end
end
