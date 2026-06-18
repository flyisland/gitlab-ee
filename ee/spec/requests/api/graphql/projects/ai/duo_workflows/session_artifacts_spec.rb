# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Querying session artifacts for a project', feature_category: :duo_agent_platform do
  include GraphqlHelpers

  let_it_be(:group) { create(:group) }
  let_it_be(:project) { create(:project, group: group) }
  let_it_be(:sibling_project) { create(:project, group: group) }
  let_it_be(:owner) { create(:user) }
  let_it_be(:non_member) { create(:user) }

  let_it_be(:workflow1) { create(:duo_workflows_workflow, project: project, user: owner) }
  let_it_be(:workflow2) { create(:duo_workflows_workflow, project: project, user: owner) }
  let_it_be(:sibling_workflow) { create(:duo_workflows_workflow, project: sibling_project, user: owner) }
  let_it_be(:namespace_workflow) { create(:duo_workflows_workflow, project: nil, namespace: group, user: owner) }

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

  let_it_be(:sibling_artifact) do
    create(:duo_workflow_session_artifact,
      workflow: sibling_workflow,
      workflow_definition: 'software_development',
      workflow_updated_at: 30.minutes.ago)
  end

  let_it_be(:namespace_artifact) do
    create(:duo_workflow_session_artifact, :with_namespace,
      workflow: namespace_workflow, namespace: group)
  end

  let_it_be(:current_user) { owner }
  let(:query) do
    <<~GRAPHQL
      query {
        project(fullPath: "#{project.full_path}") {
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

  before_all { project.add_owner(owner) }

  subject(:session_artifacts) do
    graphql_data.dig('project', 'duoWorkflowSessionArtifacts')
  end

  before do
    stub_licensed_features(project_level_compliance_dashboard: true)
    # Force the PostgreSQL finder path so we assert project_namespace scoping on PG.
    allow(::Gitlab::ClickHouse).to receive(:globally_enabled_for_analytics?).and_return(false)
  end

  context 'when the user is an authorized project owner' do
    it 'returns only the project artifacts, excluding siblings and group-namespace artifacts',
      :aggregate_failures do
      post_graphql(query, current_user: current_user)

      expect(response).to have_gitlab_http_status(:success)
      expect(graphql_errors).to be_nil

      ids = session_artifacts['nodes'].pluck('id')
      expect(session_artifacts['count']).to eq(2)
      expect(ids).to contain_exactly(workflow1.to_global_id.to_s, workflow2.to_global_id.to_s)
      expect(ids).not_to include(sibling_workflow.to_global_id.to_s)
      expect(ids).not_to include(namespace_workflow.to_global_id.to_s)
    end

    it 'returns artifacts ordered most recently updated first' do
      post_graphql(query, current_user: current_user)

      ids = session_artifacts['nodes'].pluck('id')
      expect(ids).to eq([workflow2.to_global_id.to_s, workflow1.to_global_id.to_s])
    end
  end

  context 'when querying with the group-only projectPath filter argument' do
    let(:query) do
      <<~GRAPHQL
        query {
          project(fullPath: "#{project.full_path}") {
            duoWorkflowSessionArtifacts(first: 10, projectPath: "#{project.full_path}") {
              count
            }
          }
        }
      GRAPHQL
    end

    it 'rejects the argument, since the project field is already project-scoped' do
      post_graphql(query, current_user: current_user)

      expect(graphql_errors).to be_present
      expect(graphql_errors.first['message']).to include("doesn't accept argument 'projectPath'")
    end
  end

  context 'when the user is not a member of the project' do
    let(:current_user) { non_member }

    it 'returns null for the field' do
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
end
