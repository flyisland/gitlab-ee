# frozen_string_literal: true

require "spec_helper"

# rubocop:disable RSpec/SpecFilePathFormat -- JSON-RPC has single path for method invocation
RSpec.describe API::Mcp, 'Call tool request', feature_category: :mcp_server do
  let_it_be(:user) { create(:user) }
  let_it_be(:access_token) { create(:oauth_access_token, user: user, scopes: [:mcp]) }
  let_it_be(:consumer_group) { create(:group) }
  let_it_be(:flow_project) { create(:project, group: consumer_group) }
  let_it_be(:flow) { create(:ai_catalog_flow, :public, project: flow_project) }

  let_it_be_with_reload(:execution_project) do
    create(:project, :repository, group: consumer_group, developers: user)
  end

  let_it_be(:group_consumer) { create(:ai_catalog_item_consumer, item: flow, group: consumer_group) }

  let_it_be(:project_consumer) do
    create(:ai_catalog_item_consumer, item: flow, project: execution_project,
      parent_item_consumer: group_consumer)
  end

  let(:params) do
    { jsonrpc: '2.0', method: 'tools/call', params: tool_params, id: '1' }
  end

  before_all do
    consumer_group.add_developer(user)
    execution_project.update!(duo_features_enabled: true, duo_remote_flows_enabled: true)
    flow_project.update!(duo_features_enabled: true)
  end

  before do
    stub_application_setting(instance_level_ai_beta_features_enabled: true)
    allow(::Gitlab::Llm::StageCheck).to receive(:available?).and_call_original
    allow(::Gitlab::Llm::StageCheck).to receive(:available?).with(flow_project, :ai_catalog).and_return(true)
    allow(::Gitlab::Llm::StageCheck).to receive(:available?).with(execution_project, :ai_catalog).and_return(true)
    allow(::Gitlab::Llm::StageCheck).to receive(:available?).with(execution_project, :duo_workflow).and_return(true)
  end

  describe '#start_duo_session' do
    let(:tool_params) do
      {
        name: 'start_duo_session',
        arguments: {
          project_id: execution_project.id.to_s,
          ai_catalog_item_consumer_id: project_consumer.id,
          goal: 'Fix the flaky spec'
        }
      }
    end

    let(:workflow) { build(:duo_workflows_workflow, user: user, project: execution_project) }

    let(:execute_service) do
      instance_double(::Ai::Catalog::Flows::ExecuteService,
        execute: ServiceResponse.success(payload: { workflow: workflow, workload_id: 124 }))
    end

    it 'forces start_workflow, which the model never sends', :aggregate_failures do
      expect(::Ai::Catalog::Flows::ExecuteService).to receive(:new).with(
        project: execution_project,
        current_user: user,
        params: hash_including(execute_workflow: true)
      ).and_return(execute_service)

      post api('/mcp', user, oauth_access_token: access_token), params: params, as: :json

      expect(response).to have_gitlab_http_status(:ok)
      expect(json_response.dig('result', 'isError')).to be(false)
    end

    # The path is the only reliable signal: the MCP handler re-dispatches with the original
    # env, so PATH_INFO still points at /api/v4/mcp when the route runs.
    it 'marks the session as started over MCP' do
      expect(::Ai::Catalog::Flows::ExecuteService).to receive(:new).with(
        project: execution_project,
        current_user: user,
        params: hash_including(source_type: :mcp)
      ).and_return(execute_service)

      post api('/mcp', user, oauth_access_token: access_token), params: params, as: :json

      expect(response).to have_gitlab_http_status(:ok)
    end

    it 'returns the session identifiers and a poll hint, not the raw workflow entity' do
      allow(::Ai::Catalog::Flows::ExecuteService).to receive(:new).and_return(execute_service)

      post api('/mcp', user, oauth_access_token: access_token), params: params, as: :json

      content = json_response.dig('result', 'structuredContent')
      expect(content.keys).to match_array(%w[workflow_id status workload_id poll_after_seconds web_url])
      expect(content['workload_id']).to eq(124)
      expect(content['web_url']).to eq(workflow.web_url)
      expect(json_response.dig('result', 'content', 0, 'text')).to include('get_duo_session')
    end

    context 'when the caller is not allowed to run the flow' do
      let_it_be(:outsider) { create(:user) }
      let_it_be(:outsider_token) { create(:oauth_access_token, user: outsider, scopes: [:mcp]) }

      it 'does not start a session' do
        expect(::Ai::Catalog::Flows::ExecuteService).not_to receive(:new)

        post api('/mcp', outsider, oauth_access_token: outsider_token), params: params, as: :json

        expect(json_response.dig('result', 'isError')).to be(true)
      end
    end

    context 'when the caller has read access but cannot run flows' do
      let_it_be(:reporter) { create(:user, reporter_of: execution_project) }
      let_it_be(:reporter_token) { create(:oauth_access_token, user: reporter, scopes: [:mcp]) }

      it 'refuses without creating a session, and names the role the caller needs', :aggregate_failures do
        expect(::Ai::Catalog::ExecuteWorkflowService).not_to receive(:new)
        expect(::Ci::Workloads::RunWorkloadService).not_to receive(:new)

        expect do
          post api('/mcp', reporter, oauth_access_token: reporter_token), params: params, as: :json
        end.to not_change { ::Ai::DuoWorkflows::Workflow.count }.and not_change { ::Ci::Pipeline.count }

        expect(json_response.dig('result', 'isError')).to be(true)
        expect(json_response.dig('result', 'content', 0, 'text'))
          .to include('Developer role', 'No session was started')
      end
    end

    context 'when a GitLab flow is named instead of a catalog consumer' do
      let_it_be(:session) { create(:duo_workflows_workflow, user: user, project: execution_project) }

      let(:tool_params) do
        {
          name: 'start_duo_session',
          arguments: {
            project_id: execution_project.id.to_s,
            flow: 'developer/v1',
            goal: 'Fix the flaky spec'
          }
        }
      end

      before do
        stub_feature_flags(enforce_composite_identity_for_api_started_workflows: false)

        allow_next_instance_of(::Ai::DuoWorkflows::WorkflowContextGenerationService) do |service|
          allow(service).to receive(:generate_workflow_token)
            .and_return(ServiceResponse.success(payload: { token: 'workflow-token' }))
        end

        allow(::Ai::DuoWorkflows::StartWorkflowService).to receive(:new).and_return(
          instance_double(::Ai::DuoWorkflows::StartWorkflowService,
            execute: ServiceResponse.success(payload: { workload_id: 124 }))
        )
      end

      it 'marks the session as started over MCP' do
        expect(::Ai::DuoWorkflows::CreateWorkflowService).to receive(:new)
          .with(hash_including(params: hash_including(source_type: :mcp)))
          .and_return(
            instance_double(::Ai::DuoWorkflows::CreateWorkflowService,
              execute: ServiceResponse.success(payload: { workflow: session }))
          )

        post api('/mcp', user, oauth_access_token: access_token), params: params, as: :json

        expect(response).to have_gitlab_http_status(:ok)
        expect(json_response.dig('result', 'isError')).to be(false)
      end
    end

    context 'when the catalog consumer runs fix_pipeline' do
      let_it_be(:fix_pipeline_item) do
        create(:ai_catalog_item, :flow, :public, foundational_flow_reference: 'fix_pipeline/v1')
      end

      let_it_be(:fix_pipeline_consumer) do
        create(:ai_catalog_item_consumer, item: fix_pipeline_item, project: execution_project,
          parent_item_consumer: create(:ai_catalog_item_consumer, item: fix_pipeline_item, group: consumer_group))
      end

      let_it_be(:failing_merge_request) do
        create(:merge_request, source_project: execution_project, target_project: execution_project,
          source_branch: 'feature', target_branch: 'master')
      end

      let_it_be(:failed_pipeline) do
        create(:ci_pipeline, :failed, project: execution_project, ref: 'feature',
          sha: failing_merge_request.diff_head_sha)
      end

      let(:goal) { Gitlab::UrlBuilder.build(failed_pipeline) }
      let(:tool_params) do
        {
          name: 'start_duo_session',
          arguments: {
            project_id: execution_project.id.to_s, ai_catalog_item_consumer_id: fix_pipeline_consumer.id, goal: goal
          }
        }
      end

      it 'starts it on the branch of the pipeline in the goal, with the merge request it belongs to' do
        expect(::Ai::Catalog::Flows::ExecuteService).to receive(:new).with(
          project: execution_project,
          current_user: user,
          params: hash_including(
            source_branch: 'feature',
            additional_context: array_including(
              hash_including('Category' => 'merge_request',
                'Content' => a_string_including("merge_requests/#{failing_merge_request.iid}"))
            )
          )
        ).and_return(execute_service)

        post api('/mcp', user, oauth_access_token: access_token), params: params, as: :json

        expect(json_response.dig('result', 'isError')).to be(false)
      end

      context 'when the goal is not a pipeline in the project' do
        let(:goal) { 'Fix the pipeline' }

        it 'refuses without starting a session, and says what the goal must be', :aggregate_failures do
          expect(::Ai::Catalog::Flows::ExecuteService).not_to receive(:new)

          expect do
            post api('/mcp', user, oauth_access_token: access_token), params: params, as: :json
          end.to not_change { ::Ai::DuoWorkflows::Workflow.count }

          expect(json_response.dig('result', 'isError')).to be(true)
          expect(json_response.dig('result', 'content', 0, 'text'))
            .to include('fix_pipeline/v1 fixes a pipeline', execution_project.full_path)
        end
      end
    end
  end
end
# rubocop:enable RSpec/SpecFilePathFormat
