# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Querying session artifacts for a group', feature_category: :duo_agent_platform do
  include GraphqlHelpers

  let_it_be(:group) { create(:group) }
  let_it_be(:project) { create(:project, group: group) }
  let_it_be(:owner) { create(:user) }
  let_it_be(:non_member) { create(:user) }
  let_it_be(:workflow1) { create(:duo_workflows_workflow, project: project, user: owner) }
  let_it_be(:workflow2) { create(:duo_workflows_workflow, project: project, user: owner) }

  let_it_be(:artifact1) do
    create(:duo_workflow_session_artifact,
      workflow: workflow1,
      workflow_definition: 'software_development',
      workflow_updated_at: 2.hours.ago)
  end

  let_it_be(:artifact2) do
    create(:duo_workflow_session_artifact,
      workflow: workflow2,
      workflow_definition: 'chat',
      workflow_updated_at: 1.hour.ago)
  end

  let(:current_user) { owner }
  let(:query) do
    <<~GRAPHQL
      query {
        group(fullPath: "#{group.full_path}") {
          duoWorkflowSessionArtifacts(first: 10) {
            count
            nodes {
              id
              workflowDefinition
              webPath
              auditEventsCount
              workflowCreatedAt
              project {
                id
                fullPath
              }
            }
            pageInfo {
              hasNextPage
              hasPreviousPage
              startCursor
              endCursor
            }
          }
        }
      }
    GRAPHQL
  end

  before_all { group.add_owner(owner) }

  subject(:session_artifacts) do
    graphql_data.dig('group', 'duoWorkflowSessionArtifacts')
  end

  before do
    stub_licensed_features(group_level_compliance_dashboard: true)
    stub_feature_flags(agent_artifacts_page: true)
  end

  it 'returns session artifacts for the group', :aggregate_failures do
    post_graphql(query, current_user: current_user)

    expect(response).to have_gitlab_http_status(:success)
    expect(graphql_errors).to be_nil
    expect(session_artifacts['count']).to eq(2)
  end

  it 'returns artifacts ordered most recently updated first' do
    post_graphql(query, current_user: current_user)

    ids = session_artifacts['nodes'].pluck('id')
    expect(ids).to eq([workflow2.to_global_id.to_s, workflow1.to_global_id.to_s])
  end

  it 'returns the correct field values for each node', :aggregate_failures do
    post_graphql(query, current_user: current_user)

    node = session_artifacts['nodes'].first
    expect(node['id']).to eq(workflow2.to_global_id.to_s)
    expect(node['workflowDefinition']).to eq('chat')
    expect(node['webPath']).to include(workflow2.id.to_s)
    expect(node['auditEventsCount']).to eq(0)
    expect(node['project']['fullPath']).to eq(project.full_path)
  end

  context 'when the user is not a member of the group' do
    let(:current_user) { non_member }

    it 'returns an empty list' do
      post_graphql(query, current_user: current_user)

      expect(session_artifacts).to be_nil
    end
  end

  context 'when the agent_artifacts_page feature flag is disabled' do
    before do
      stub_feature_flags(agent_artifacts_page: false)
    end

    it 'returns no artifacts', :aggregate_failures do
      post_graphql(query, current_user: current_user)

      expect(response).to have_gitlab_http_status(:success)
      expect(graphql_errors).to be_nil
      expect(session_artifacts['nodes']).to be_empty
      expect(session_artifacts['count']).to eq(0)
    end
  end

  context 'with pagination' do
    let(:query) do
      <<~GRAPHQL
        query {
          group(fullPath: "#{group.full_path}") {
            duoWorkflowSessionArtifacts(first: 1) {
              count
              nodes { id }
              pageInfo {
                hasNextPage
                endCursor
              }
            }
          }
        }
      GRAPHQL
    end

    it 'returns the first page with correct pagination info', :aggregate_failures do
      post_graphql(query, current_user: current_user)

      expect(session_artifacts['count']).to eq(2)
      expect(session_artifacts['nodes'].length).to eq(1)
      expect(session_artifacts['pageInfo']['hasNextPage']).to be(true)
      expect(session_artifacts['pageInfo']['endCursor']).to be_present
    end
  end

  context 'with auditEventsCount' do
    let_it_be(:audit_events) do
      create_list(:audit_events_ai_audit_event, 3,
        target_project: project, user: owner, workflow_id: workflow1.id)
    end

    it 'returns the correct audit event count per artifact', :aggregate_failures do
      post_graphql(query, current_user: current_user)

      node1 = session_artifacts['nodes'].find { |n| n['id'] == workflow1.to_global_id.to_s }
      node2 = session_artifacts['nodes'].find { |n| n['id'] == workflow2.to_global_id.to_s }

      expect(node1['auditEventsCount']).to eq(3)
      expect(node2['auditEventsCount']).to eq(0)
    end

    it 'avoids N+1 queries when loading audit event counts' do
      post_graphql(query, current_user: current_user)
      control = ActiveRecord::QueryRecorder.new { post_graphql(query, current_user: current_user) }

      extra_workflow = create(:duo_workflows_workflow, project: project, user: owner)
      create(:duo_workflow_session_artifact, workflow: extra_workflow,
        workflow_definition: 'chat', workflow_updated_at: 30.minutes.ago)

      expect { post_graphql(query, current_user: current_user) }
        .not_to exceed_query_limit(control)
    end
  end
end
