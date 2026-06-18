# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'AiDuoWorkflowCreate', feature_category: :duo_chat do
  include GraphqlHelpers

  let_it_be(:licensed_guest, freeze: false) { create(:user) }
  let_it_be(:unlicensed_guest, freeze: false) { create(:user) }
  let_it_be(:licensed_developer, freeze: false) { create(:user) }
  let_it_be(:group, freeze: false) do
    create(:group, guests: [licensed_guest, unlicensed_guest], developers: [licensed_developer])
  end

  let_it_be_with_reload(:project) { create(:project, group: group) }
  let_it_be(:other_project, freeze: false) { create(:project) }

  let_it_be(:add_on_purchase, freeze: false) do
    create(:gitlab_subscription_add_on_purchase, :duo_enterprise, :active, namespace: group)
  end

  let_it_be(:add_on_assignment, freeze: false) do
    create(:gitlab_subscription_user_add_on_assignment, user: licensed_guest, add_on_purchase: add_on_purchase)
    create(:gitlab_subscription_user_add_on_assignment, user: licensed_developer, add_on_purchase: add_on_purchase)
  end

  let_it_be(:agent, freeze: false) do
    create(:ai_catalog_agent, project: other_project, public: true)
  end

  let_it_be(:agent_version, freeze: false) do
    create(:ai_catalog_agent_version, item: agent)
  end

  let_it_be(:agent_consumer, freeze: false) do
    create(:ai_catalog_item_consumer, item: agent, project: project)
  end

  let_it_be(:issue, freeze: false) { create(:issue, project: project) }

  let_it_be(:merge_request, freeze: false) { create(:merge_request, source_project: project) }

  let(:current_user) { licensed_guest }
  let(:container) { project }
  let(:workflow_type) { "chat" }
  let(:input) do
    {
      goal: "Automate PR reviews",
      agent_privileges: [1, 2, 3],
      pre_approved_agent_privileges: [1],
      workflow_definition: workflow_type,
      allow_agent_to_request_user: true,
      environment: 'WEB',
      ai_catalog_item_version_id: agent_version.to_global_id,
      **container_input
    }
  end

  let(:container_input) { { project_id: project.to_global_id } }

  let(:mutation) do
    graphql_mutation(:ai_duo_workflow_create, input,
      <<-QL
        errors
        workflow {
          id
          projectId
          namespaceId
        }
      QL
    )
  end

  let(:mutation_response) { graphql_mutation_response(:ai_duo_workflow_create) }

  subject(:request) { post_graphql_mutation(mutation, current_user: current_user) }

  before do
    stub_licensed_features(ai_workflows: true, agentic_chat: true, ai_chat: true)
    project.root_ancestor.update!(experiment_features_enabled: true)
    allow_next_instance_of(Ai::UsageQuotaService) do |instance|
      allow(instance).to receive(:execute).and_return(
        ServiceResponse.success
      )
    end
  end

  context 'when container is a project', :saas do
    it 'creates a new workflow' do
      expect(::Ai::DuoWorkflows::CreateWorkflowService).to receive(:new).with(
        container: container,
        current_user: current_user,
        params: {
          goal: "Automate PR reviews",
          agent_privileges: [1, 2, 3],
          pre_approved_agent_privileges: [1],
          workflow_definition: workflow_type,
          allow_agent_to_request_user: true,
          environment: 'web',
          ai_catalog_item_version_id: agent_version.id
        }
      ).and_call_original

      post_graphql_mutation(mutation, current_user: current_user)

      expect(response).to have_gitlab_http_status(:success)

      workflow = ::Ai::DuoWorkflows::Workflow.last
      expect(mutation_response['workflow']['id']).to eq("gid://gitlab/Ai::DuoWorkflows::Workflow/#{workflow.id}")
      expect(mutation_response['workflow']['projectId']).to eq("gid://gitlab/Project/#{project.id}")
      expect(mutation_response['workflow']['namespaceId']).to be_nil
      expect(mutation_response['errors']).to be_empty
    end

    context 'with default workflow type' do
      let(:workflow_type) { 'default' }

      context 'when the user has guest access' do
        before do
          post_graphql_mutation(mutation, current_user: current_user)
        end

        include_examples 'a mutation that returns top-level errors',
          errors: ['forbidden to access duo workflow']
      end

      context 'when the user has at least developer access' do
        let(:current_user) { licensed_developer }

        it 'creates a new workflow' do
          expect(::Ai::DuoWorkflows::CreateWorkflowService).to receive(:new).with(
            container: container,
            current_user: current_user,
            params: {
              goal: "Automate PR reviews",
              agent_privileges: [1, 2, 3],
              pre_approved_agent_privileges: [1],
              workflow_definition: workflow_type,
              allow_agent_to_request_user: true,
              environment: 'web',
              ai_catalog_item_version_id: agent_version.id
            }
          ).and_call_original

          post_graphql_mutation(mutation, current_user: current_user)

          expect(response).to have_gitlab_http_status(:success)

          workflow = ::Ai::DuoWorkflows::Workflow.last
          expect(mutation_response['workflow']['id']).to eq("gid://gitlab/Ai::DuoWorkflows::Workflow/#{workflow.id}")
          expect(mutation_response['workflow']['projectId']).to eq("gid://gitlab/Project/#{project.id}")
          expect(mutation_response['workflow']['namespaceId']).to be_nil
          expect(mutation_response['errors']).to be_empty
        end
      end
    end
  end

  context 'when container is a namespace' do
    let(:container) { group }
    let(:current_user) { licensed_developer }
    let(:workflow_type) { 'default' }
    let(:container_input) { { namespace_id: group.to_global_id } }

    it 'creates a new workflow' do
      expect(::Ai::DuoWorkflows::CreateWorkflowService).to receive(:new).with(
        container: container,
        current_user: current_user,
        params: {
          goal: "Automate PR reviews",
          agent_privileges: [1, 2, 3],
          pre_approved_agent_privileges: [1],
          workflow_definition: workflow_type,
          allow_agent_to_request_user: true,
          environment: 'web',
          ai_catalog_item_version_id: agent_version.id
        }
      ).and_call_original

      post_graphql_mutation(mutation, current_user: current_user)

      expect(response).to have_gitlab_http_status(:success)

      if workflow_type == 'chat'
        workflow = ::Ai::DuoWorkflows::Workflow.last
        expect(mutation_response['workflow']['id']).to eq("gid://gitlab/Ai::DuoWorkflows::Workflow/#{workflow.id}")
        expect(mutation_response['workflow']['projectId']).to be_nil
        expect(mutation_response['workflow']['namespaceId']).to eq("gid://gitlab/Types::Namespace/#{group.id}")
        expect(mutation_response['errors']).to be_empty
      else
        # NOTE: Non-chat types do not support namespace-level workflow yet.
        # See https://gitlab.com/gitlab-org/gitlab/-/issues/554952.
        expect(graphql_errors.pluck('message')).to eq(['forbidden to access duo workflow'])
      end
    end
  end

  context 'with a public project', :saas do
    let_it_be(:container, freeze: false) do
      public_group = create(:group, :public)
      public_group.update!(experiment_features_enabled: true)
      create(:project, :public, group: public_group)
    end

    let(:container_input) { { project_id: container.to_global_id } }

    context 'when the user is licensed to use agentic chat' do
      it 'creates and returns a workflow' do
        post_graphql_mutation(mutation, current_user: current_user)

        expect(response).to have_gitlab_http_status(:success)
        expect(mutation_response['errors']).to be_empty

        workflow = ::Ai::DuoWorkflows::Workflow.last
        expect(mutation_response['workflow']).to match a_graphql_entity_for(workflow)
      end

      context 'when user cannot use agent version' do
        let(:agent) { create(:ai_catalog_agent, project: other_project) }
        let(:agent_version) { create(:ai_catalog_agent_version, item: agent) }

        include_examples 'a mutation that returns top-level errors',
          errors: ['User is not authorized to use agent catalog item.']
      end

      context 'when an agent version is not provided' do
        let(:input) { super().merge(ai_catalog_item_version_id: nil) }

        it 'creates and returns a workflow' do
          post_graphql_mutation(mutation, current_user: current_user)

          expect(response).to have_gitlab_http_status(:success)
          expect(mutation_response['errors']).to be_empty

          workflow = ::Ai::DuoWorkflows::Workflow.last
          expect(mutation_response['workflow']).to match a_graphql_entity_for(workflow)
        end
      end

      context 'when neither project_id nor namespace_id are specified' do
        let(:container_input) { {} }
        let(:current_user) { licensed_developer }

        it 'uses the default duo namespace from user preferences' do
          post_graphql_mutation(mutation, current_user: current_user)

          expect(response).to have_gitlab_http_status(:success)
          workflow = ::Ai::DuoWorkflows::Workflow.last
          expect(mutation_response['workflow']['id']).to eq("gid://gitlab/Ai::DuoWorkflows::Workflow/#{workflow.id}")
          expect(mutation_response['errors']).to be_empty
        end
      end
    end

    context 'when the user is not licensed to use the feature' do
      let(:current_user) { unlicensed_guest }

      before do
        post_graphql_mutation(mutation, current_user: current_user)
      end

      include_examples 'a mutation that returns top-level errors',
        errors: ['forbidden to access agentic chat']
    end
  end

  context 'when the service returns an error', :saas do
    it 'returns the error message' do
      service_result = ::ServiceResponse.error(
        message: 'Failed to create workflow',
        http_status: :error # rubocop: disable Gitlab/ServiceResponse -- requires refactoring in CreateWorkflowService
      )

      service = instance_double(::Ai::DuoWorkflows::CreateWorkflowService, execute: service_result)
      allow(::Ai::DuoWorkflows::CreateWorkflowService).to receive(:new).and_return(service)

      post_graphql_mutation(mutation, current_user: current_user)

      expect(response).to have_gitlab_http_status(:success)
      expect(mutation_response['workflow']).to be_nil
      expect(mutation_response['errors']).to eq(['Failed to create workflow'])
    end
  end

  context 'when the user is not authorized to use the feature', :saas do
    let(:current_user) { unlicensed_guest }

    where(:workflow_type) do
      %w[default unknown]
    end

    with_them do
      before do
        post_graphql_mutation(mutation, current_user: current_user)
      end

      include_examples 'a mutation that returns top-level errors',
        errors: ['forbidden to access duo workflow']
    end
  end

  context 'when a user is not authorized to use the agentic chat' do
    let(:current_user) { unlicensed_guest }

    before do
      post_graphql_mutation(mutation, current_user: current_user)
    end

    include_examples 'a mutation that returns top-level errors',
      errors: ['forbidden to access agentic chat']
  end

  context 'when both project_id and namespace_id are specified', :saas do
    let(:container_input) { { project_id: project.to_global_id, namespace_id: group.to_global_id } }

    it 'uses project_id and ignores namespace_id' do
      expect(::Ai::DuoWorkflows::CreateWorkflowService).to receive(:new).with(
        container: project,
        current_user: current_user,
        params: {
          goal: "Automate PR reviews",
          agent_privileges: [1, 2, 3],
          pre_approved_agent_privileges: [1],
          workflow_definition: workflow_type,
          allow_agent_to_request_user: true,
          environment: 'web',
          ai_catalog_item_version_id: agent_version.id
        }
      ).and_call_original

      post_graphql_mutation(mutation, current_user: current_user)

      expect(response).to have_gitlab_http_status(:success)

      workflow = ::Ai::DuoWorkflows::Workflow.last
      expect(mutation_response['workflow']['id']).to eq("gid://gitlab/Ai::DuoWorkflows::Workflow/#{workflow.id}")
      expect(mutation_response['workflow']['projectId']).to eq("gid://gitlab/Project/#{project.id}")
      expect(mutation_response['workflow']['namespaceId']).to be_nil
      expect(mutation_response['errors']).to be_empty
    end
  end

  context 'when issue_id and merge_request_id are not specified', :saas do
    let(:container_input) { { project_id: project.to_global_id, namespace_id: group.to_global_id } }

    it 'ignores issue_id and merge_request_id' do
      expect(::Ai::DuoWorkflows::CreateWorkflowService).to receive(:new).with(
        container: project,
        current_user: current_user,
        params: {
          goal: "Automate PR reviews",
          agent_privileges: [1, 2, 3],
          pre_approved_agent_privileges: [1],
          workflow_definition: workflow_type,
          allow_agent_to_request_user: true,
          environment: 'web',
          ai_catalog_item_version_id: agent_version.id
        }
      ).and_call_original

      post_graphql_mutation(mutation, current_user: current_user)

      expect(response).to have_gitlab_http_status(:success)

      workflow = ::Ai::DuoWorkflows::Workflow.last
      expect(mutation_response['workflow']['id']).to eq("gid://gitlab/Ai::DuoWorkflows::Workflow/#{workflow.id}")
      expect(mutation_response['workflow']['projectId']).to eq("gid://gitlab/Project/#{project.id}")
      expect(mutation_response['workflow']['issueId']).to be_nil
      expect(mutation_response['workflow']['mergeRequestId']).to be_nil
      expect(mutation_response['errors']).to be_empty
    end
  end

  context 'when issue_id is provided', :saas do
    let(:input) do
      super().merge(issue_id: issue.iid)
    end

    it 'creates a workflow associated with the issue' do
      expect(::Ai::DuoWorkflows::CreateWorkflowService).to receive(:new).with(
        container: container,
        current_user: current_user,
        params: {
          goal: "Automate PR reviews",
          agent_privileges: [1, 2, 3],
          pre_approved_agent_privileges: [1],
          workflow_definition: workflow_type,
          allow_agent_to_request_user: true,
          environment: 'web',
          ai_catalog_item_version_id: agent_version.id,
          issue_id: issue.iid
        }
      ).and_call_original

      post_graphql_mutation(mutation, current_user: current_user)

      expect(response).to have_gitlab_http_status(:success)

      workflow = ::Ai::DuoWorkflows::Workflow.last
      expect(workflow.issue).to eq(issue)
      expect(workflow.merge_request).to be_nil
      expect(mutation_response['errors']).to be_empty
    end
  end

  context 'when invalid issue_id is provided', :saas do
    let(:invalid_issue_iid) { 999999 }
    let(:input) do
      super().merge(issue_id: invalid_issue_iid)
    end

    it 'creates a workflow without issue association' do
      expect(::Ai::DuoWorkflows::CreateWorkflowService).to receive(:new).with(
        container: container,
        current_user: current_user,
        params: {
          goal: "Automate PR reviews",
          agent_privileges: [1, 2, 3],
          pre_approved_agent_privileges: [1],
          workflow_definition: workflow_type,
          allow_agent_to_request_user: true,
          environment: 'web',
          ai_catalog_item_version_id: agent_version.id,
          issue_id: invalid_issue_iid
        }
      ).and_call_original

      post_graphql_mutation(mutation, current_user: current_user)

      expect(response).to have_gitlab_http_status(:success)

      workflow = ::Ai::DuoWorkflows::Workflow.last
      expect(workflow.issue).to be_nil
      expect(mutation_response['errors']).to be_empty
    end
  end

  context 'when workflow_definition is a foundational flow', :saas do
    let_it_be(:flow_item, freeze: false) do
      create(:ai_catalog_item, :flow, :with_released_version, foundational_flow_reference: 'fix_pipeline/v1')
    end

    let_it_be(:group_consumer, freeze: false) do
      create(:ai_catalog_item_consumer,
        item: flow_item, group: group,
        service_account: create(:user, :service_account, provisioned_by_group: group))
    end

    let_it_be(:project_consumer, freeze: false) do
      create(:ai_catalog_item_consumer,
        item: flow_item, project: project, parent_item_consumer: group_consumer)
    end

    let_it_be(:enabled_flow, freeze: false) do
      create(:ai_catalog_enabled_foundational_flow, :for_project, project: project, catalog_item: flow_item)
    end

    let(:current_user) { licensed_developer }
    let(:workflow_type) { 'fix_pipeline/v1' }
    let(:input) { { goal: 'Fix the pipeline', workflow_definition: workflow_type, **container_input } }

    before_all do
      project.update!(duo_features_enabled: true, duo_remote_flows_enabled: true)
    end

    before do
      allow(::Gitlab::Llm::StageCheck).to receive(:available?).and_call_original
      allow(::Gitlab::Llm::StageCheck).to receive(:available?).with(project, :duo_workflow).and_return(true)
      allow(::Gitlab::Llm::StageCheck).to receive(:available?).with(project, :foundational_flows).and_return(true)
      allow(::Gitlab::Llm::StageCheck).to receive(:available?).with(project, :ai_catalog).and_return(true)
      allow(::Ai::Catalog::FoundationalFlow['fix_pipeline/v1']).to receive(:catalog_item).and_return(flow_item)
    end

    it 'creates the workflow when foundational flows are enabled' do
      post_graphql_mutation(mutation, current_user: current_user)

      expect(response).to have_gitlab_http_status(:success)
      expect(mutation_response['errors']).to be_empty
      expect(mutation_response['workflow']).to be_present
    end

    context 'when duo_foundational_flows_enabled is false' do
      before do
        project.update!(duo_foundational_flows_enabled: false)
      end

      it 'returns an error' do
        post_graphql_mutation(mutation, current_user: current_user)

        expect(mutation_response).to be_nil
        expect(graphql_errors).to be_present
      end
    end

    context 'when no consumer is configured' do
      let_it_be(:empty_project, freeze: false) do
        create(:project, :repository, group: group, developers: licensed_developer)
      end

      let(:container_input) { { project_id: empty_project.to_global_id } }

      before do
        empty_project.update!(duo_features_enabled: true, duo_remote_flows_enabled: true)
        allow(::Gitlab::Llm::StageCheck).to receive(:available?).with(empty_project, :duo_workflow).and_return(true)
        allow(::Gitlab::Llm::StageCheck).to receive(:available?)
          .with(empty_project, :foundational_flows).and_return(true)
        allow(::Gitlab::Llm::StageCheck).to receive(:available?).with(empty_project, :ai_catalog).and_return(true)
      end

      it 'returns an error' do
        post_graphql_mutation(mutation, current_user: current_user)

        expect(mutation_response).to be_nil
        expect(graphql_errors).to be_present
      end
    end

    context 'when flow is not in the allow list' do
      before do
        enabled_flow.destroy!
      end

      it 'returns an error' do
        post_graphql_mutation(mutation, current_user: current_user)

        expect(mutation_response).to be_nil
        expect(graphql_errors).to be_present
      end
    end

    context 'when foundational flow has no catalog_item' do
      before do
        allow(::Ai::Catalog::FoundationalFlow['fix_pipeline/v1']).to receive(:catalog_item).and_return(nil)
      end

      it 'skips authorization and creates the workflow' do
        post_graphql_mutation(mutation, current_user: current_user)

        expect(response).to have_gitlab_http_status(:success)
        expect(mutation_response['errors']).to be_empty
        expect(mutation_response['workflow']).to be_present
      end
    end
  end
end
