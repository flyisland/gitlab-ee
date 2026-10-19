# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Querying AI governance sessions for a group', :click_house, feature_category: :compliance_management do
  include GraphqlHelpers
  include Ai::Governance::SessionClickHouseHelpers

  let_it_be(:group) { create(:group) }
  let_it_be(:subgroup) { create(:group, parent: group) }
  let_it_be(:project) { create(:project, group: group) }
  let_it_be(:owner) { create(:user) }
  let_it_be(:non_member) { create(:user) }
  let_it_be(:reference_time) { Time.current.change(usec: 0) }

  # aiGovernanceSessions requires :read_agent_artifacts, a custom ability granted via member roles.
  let_it_be(:member_role) { create(:member_role, :guest, :read_agent_artifacts, namespace: group) }
  let_it_be(:membership) { create(:group_member, :guest, member_role: member_role, user: owner, group: group) }

  let(:project_duo_session) do
    ai_governance_session_row(id: 1, namespace: project.project_namespace, project: project, user: owner,
      flow_type: 'chat', session_started_at: reference_time - 3.hours)
  end

  let(:namespace_duo_session) do
    ai_governance_session_row(id: 2, namespace: subgroup, user: owner, flow_type: 'agentic_chat',
      session_started_at: reference_time - 2.hours)
  end

  let(:external_session) do
    ai_governance_session_row(id: 3, namespace: group, user: owner, source: :claude_code_glab,
      flow_type: 'claude_code', agent_type: 'claude-code', session_started_at: reference_time - 1.hour)
  end

  let(:current_user) { owner }
  let(:arguments) { 'first: 10' }
  let(:query) do
    <<~GRAPHQL
      query {
        group(fullPath: "#{group.full_path}") {
          aiGovernanceSessions(#{arguments}) {
            count
            nodes {
              id
              sessionId
              flowType
              agentType
              source
              sessionStartedAt
              webPath
              downloadPath
              project { id fullPath }
              triggeredBy { id username }
            }
            pageInfo { hasNextPage hasPreviousPage startCursor endCursor }
          }
        }
      }
    GRAPHQL
  end

  def sessions
    graphql_data.dig('group', 'aiGovernanceSessions')
  end

  def node_ids
    sessions['nodes'].pluck('id')
  end

  def gid(row)
    ::Gitlab::GlobalId.build(model_name: 'Ai::Governance::Session', id: row[:id]).to_s
  end

  def audit_event_row(created_at:, workflow_id: 0, ai_governance_session_id: 0)
    {
      id: SecureRandom.uuid,
      event_name: 'run_tool',
      created_at: created_at,
      author_id: owner.id,
      project_id: project.id,
      workflow_id: workflow_id,
      ai_governance_session_id: ai_governance_session_id,
      traversal_path: project.project_namespace.traversal_path(with_organization: true)
    }
  end

  before do
    stub_licensed_features(
      custom_roles: true,
      project_level_compliance_dashboard: true,
      group_level_compliance_dashboard: true
    )
    allow(::Gitlab::ClickHouse).to receive(:globally_enabled_for_analytics?).and_return(true)

    insert_ai_governance_sessions(project_duo_session, namespace_duo_session, external_session)
  end

  it 'returns the sessions of the group and its descendants, newest first', :aggregate_failures do
    post_graphql(query, current_user: current_user)

    expect(graphql_errors).to be_nil
    expect(sessions['count']).to eq(3)
    expect(node_ids).to eq([external_session, namespace_duo_session, project_duo_session].map { |s| gid(s) })
  end

  it 'returns the field values of each source', :aggregate_failures do
    post_graphql(query, current_user: current_user)

    external, namespace_duo, project_duo = sessions['nodes']

    expect(external).to include(
      'sessionId' => external_session[:external_xid],
      'flowType' => 'claude_code',
      'agentType' => 'claude-code',
      'source' => 'CLAUDE_CODE_GLAB',
      'webPath' => nil,
      'downloadPath' => nil,
      'project' => nil,
      'triggeredBy' => { 'id' => global_id_of(owner).to_s, 'username' => owner.username }
    )
    expect(namespace_duo).to include(
      'sessionId' => namespace_duo_session[:workflow_id].to_s,
      'source' => 'GITLAB_DUO',
      'webPath' => nil,
      'downloadPath' => download_group_security_agent_artifact_path(subgroup, namespace_duo_session[:workflow_id]),
      'project' => nil
    )
    expect(project_duo).to include(
      'source' => 'GITLAB_DUO',
      'sessionStartedAt' => project_duo_session[:session_started_at].iso8601,
      'webPath' => project_automate_agent_session_path(project, project_duo_session[:workflow_id]),
      'downloadPath' => download_project_security_agent_artifact_path(project, project_duo_session[:workflow_id]),
      'project' => { 'id' => global_id_of(project).to_s, 'fullPath' => project.full_path }
    )
  end

  context 'with filters' do
    let(:arguments) do
      %(first: 10, agentClass: INTERNAL_DAP, not: { flowType: "chat" }, triggeredByUserId: "#{global_id_of(owner)}")
    end

    it 'applies them', :aggregate_failures do
      post_graphql(query, current_user: current_user)

      expect(graphql_errors).to be_nil
      expect(node_ids).to eq([gid(namespace_duo_session)])
    end
  end

  context 'with an invalid session start range' do
    let(:arguments) do
      %(first: 10, sessionStartedAfter: "#{reference_time.iso8601}",
        sessionStartedBefore: "#{(reference_time - 1.hour).iso8601}")
    end

    it 'returns an error' do
      post_graphql(query, current_user: current_user)

      expect_graphql_errors_to_include('sessionStartedAfter must not be after sessionStartedBefore')
    end
  end

  context 'with pagination' do
    let(:arguments) { 'first: 2' }

    it 'pages through the sessions in order', :aggregate_failures do
      post_graphql(query, current_user: current_user)

      expect(node_ids).to eq([gid(external_session), gid(namespace_duo_session)])
      expect(sessions['pageInfo']['hasNextPage']).to be(true)

      end_cursor = sessions['pageInfo']['endCursor']
      post_graphql(query.sub('first: 2', %(first: 2, after: "#{end_cursor}")), current_user: current_user)

      expect(node_ids).to eq([gid(project_duo_session)])
      expect(sessions['pageInfo']).to include('hasNextPage' => false, 'hasPreviousPage' => true)
    end
  end

  context 'when the user cannot read agent artifacts' do
    let(:current_user) { non_member }

    it 'returns null' do
      post_graphql(query, current_user: current_user)

      expect(graphql_data.dig('group', 'aiGovernanceSessions')).to be_nil
    end
  end

  context 'when the feature flag is disabled' do
    before do
      stub_feature_flags(ai_governance_sessions_api: false)
    end

    it 'returns no sessions', :aggregate_failures do
      post_graphql(query, current_user: current_user)

      expect(graphql_errors).to be_nil
      expect(sessions['nodes']).to be_empty
    end
  end

  context 'when ClickHouse is not enabled for analytics' do
    before do
      allow(::Gitlab::ClickHouse).to receive(:globally_enabled_for_analytics?).and_return(false)
    end

    it 'returns no sessions', :aggregate_failures do
      post_graphql(query, current_user: current_user)

      expect(graphql_errors).to be_nil
      expect(sessions['count']).to eq(0)
      expect(sessions['nodes']).to be_empty
    end
  end

  # Extra sessions reuse existing projects: each distinct project adds ProjectType's own
  # read_project authorization queries, which are not an N+1 of this field.
  it 'avoids N+1 queries when loading projects, groups and users' do
    post_graphql(query, current_user: current_user)
    control = ActiveRecord::QueryRecorder.new { post_graphql(query, current_user: current_user) }

    insert_ai_governance_sessions(
      ai_governance_session_row(id: 4, namespace: project.project_namespace, project: project, user: create(:user),
        session_started_at: reference_time - 4.hours),
      ai_governance_session_row(id: 5, namespace: subgroup, user: create(:user),
        session_started_at: reference_time - 5.hours),
      ai_governance_session_row(id: 6, namespace: group, user: create(:user), source: :claude_code_compliance_api,
        session_started_at: reference_time - 6.hours)
    )

    expect { post_graphql(query, current_user: current_user) }.not_to exceed_query_limit(control)
  end

  describe 'auditEvents' do
    let_it_be(:workflow) { create(:duo_workflows_workflow, project: project, user: owner) }
    let_it_be(:other_workflow) { create(:duo_workflows_workflow, project: project, user: owner) }

    let(:project_duo_session) do
      ai_governance_session_row(id: 1, namespace: project.project_namespace, project: project, user: owner,
        flow_type: 'chat', session_started_at: reference_time - 3.hours).merge(workflow_id: workflow.id)
    end

    let(:duo_event) do
      audit_event_row(workflow_id: workflow.id, created_at: project_duo_session[:session_started_at] + 1.minute)
    end

    let(:external_event) do
      audit_event_row(ai_governance_session_id: external_session[:id],
        created_at: external_session[:session_started_at] + 1.minute)
    end

    let(:events) do
      [
        duo_event,
        external_event,
        audit_event_row(ai_governance_session_id: external_session[:id],
          created_at: external_session[:session_started_at] - 1.day - 1.minute),
        audit_event_row(ai_governance_session_id: non_existing_record_id,
          created_at: external_session[:session_started_at] + 1.minute),
        audit_event_row(workflow_id: other_workflow.id, created_at: project_duo_session[:session_started_at] + 1.minute)
      ]
    end

    let(:session) { project_duo_session }
    let(:arguments) { %(id: "#{gid(session)}") }
    let(:query) do
      <<~GRAPHQL
        query {
          group(fullPath: "#{group.full_path}") {
            aiGovernanceSessions(#{arguments}) {
              nodes {
                id
                auditEvents { nodes { id eventName workflowId sessionId } }
              }
            }
          }
        }
      GRAPHQL
    end

    def audit_events_of(node)
      node.dig('auditEvents', 'nodes')
    end

    before do
      clickhouse_fixture(:ai_audit_events, events)
    end

    context 'for a GitLab Duo session' do
      it 'returns the events of its workflow', :aggregate_failures do
        post_graphql(query, current_user: current_user)

        expect(graphql_errors).to be_nil
        expect(sessions['nodes'].pluck('id')).to eq([gid(session)])
        expect(audit_events_of(sessions['nodes'].first)).to contain_exactly(
          { 'id' => duo_event[:id], 'eventName' => 'run_tool', 'workflowId' => workflow.id.to_s, 'sessionId' => nil }
        )
      end

      context 'when the workflow is a private messaging session' do
        let_it_be(:workflow) do
          create(:duo_workflows_workflow, project: project, user: owner,
            messaging_callback_context: { 'adapter' => 'slack' })
        end

        it 'returns no events', :aggregate_failures do
          post_graphql(query, current_user: current_user)

          expect(graphql_errors).to be_nil
          expect(audit_events_of(sessions['nodes'].first)).to be_empty
        end
      end
    end

    context 'for an external session' do
      let(:session) { external_session }

      it 'returns its events, excluding those over a day before the session start', :aggregate_failures do
        post_graphql(query, current_user: current_user)

        expect(graphql_errors).to be_nil
        expect(sessions['nodes'].pluck('id')).to eq([gid(session)])
        expect(audit_events_of(sessions['nodes'].first)).to contain_exactly(
          { 'id' => external_event[:id], 'eventName' => 'run_tool', 'workflowId' => nil, 'sessionId' => gid(session) }
        )
      end

      context 'when an event predates the session start by a few minutes' do
        let(:skewed_event) do
          audit_event_row(ai_governance_session_id: external_session[:id],
            created_at: external_session[:session_started_at] - 5.minutes)
        end

        let(:events) { super() + [skewed_event] }

        it 'returns it, allowing for client clock skew' do
          post_graphql(query, current_user: current_user)

          expect(audit_events_of(sessions['nodes'].first).pluck('id'))
            .to contain_exactly(external_event[:id], skewed_event[:id])
        end
      end
    end

    context 'when requested for more than one session' do
      let(:arguments) { 'first: 2' }

      it 'returns the events of the first session and an error for the others', :aggregate_failures do
        post_graphql(query, current_user: current_user)

        expect_graphql_errors_to_include(
          [/"auditEvents" field can be requested only for 1 AiGovernanceSession\(s\) at a time./]
        )
        expect(audit_events_of(sessions['nodes'].first).pluck('id')).to contain_exactly(external_event[:id])
        expect(sessions['nodes'].second['auditEvents']).to be_nil
      end
    end

    context 'when requested with first: 1' do
      let(:arguments) { 'first: 1' }

      it 'returns the events of the session', :aggregate_failures do
        post_graphql(query, current_user: current_user)

        expect(graphql_errors).to be_nil
        expect(audit_events_of(sessions['nodes'].first).pluck('id')).to contain_exactly(external_event[:id])
      end
    end
  end

  describe 'auditEventsCount' do
    let(:duo_session_without_workflow) do
      ai_governance_session_row(id: 4, namespace: subgroup, user: owner,
        session_started_at: reference_time - 4.hours).merge(workflow_id: nil)
    end

    let(:duplicated_duo_event) do
      audit_event_row(workflow_id: project_duo_session[:workflow_id],
        created_at: project_duo_session[:session_started_at] + 1.minute)
    end

    let(:query) do
      <<~GRAPHQL
        query {
          group(fullPath: "#{group.full_path}") {
            aiGovernanceSessions(first: 10) {
              nodes { id auditEventsCount }
            }
          }
        }
      GRAPHQL
    end

    def counts_by_session
      sessions['nodes'].to_h { |node| node.values_at('id', 'auditEventsCount') }
    end

    before do
      insert_ai_governance_sessions(duo_session_without_workflow)

      clickhouse_fixture(:ai_audit_events, [
        duplicated_duo_event,
        duplicated_duo_event,
        audit_event_row(workflow_id: project_duo_session[:workflow_id],
          created_at: project_duo_session[:session_started_at] + 2.minutes),
        audit_event_row(ai_governance_session_id: external_session[:id],
          created_at: external_session[:session_started_at] + 1.minute),
        audit_event_row(ai_governance_session_id: external_session[:id],
          created_at: external_session[:session_started_at] - 1.day - 1.minute),
        # Shares its number with the external session's ID, but belongs to a workflow.
        audit_event_row(workflow_id: external_session[:id],
          created_at: external_session[:session_started_at] + 1.minute)
      ])
    end

    it 'counts the events of each session with one query per session kind', :aggregate_failures do
      expect(::AuditEvents::AiAuditEvents::ClickHouseFinder).to receive(:counts_for_workflows).once.and_call_original
      expect(::AuditEvents::AiAuditEvents::ClickHouseFinder).to receive(:counts_for_sessions).once.and_call_original

      post_graphql(query, current_user: current_user)

      expect(graphql_errors).to be_nil
      expect(counts_by_session).to eq(
        gid(external_session) => 1,
        gid(namespace_duo_session) => 0,
        gid(project_duo_session) => 2,
        gid(duo_session_without_workflow) => 0
      )
    end
  end
end
