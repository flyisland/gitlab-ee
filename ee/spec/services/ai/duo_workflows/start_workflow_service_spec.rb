# frozen_string_literal: true

require 'spec_helper'

RSpec.describe ::Ai::DuoWorkflows::StartWorkflowService, :request_store, feature_category: :duo_agent_platform do
  let_it_be(:group) { create(:group) }
  let_it_be(:project) { create(:project, :repository, group: group) }
  let_it_be(:developer) { create(:user, developer_of: project) }
  let_it_be(:maintainer) { create(:user, maintainer_of: project) }
  let_it_be(:reporter) { create(:user, reporter_of: project) }
  let_it_be(:service_account) { create(:user, :service_account) }

  let(:image) { 'example.com/example-image:latest' }
  let(:duo_cli_version) { described_class::DUO_CLI_VERSION }
  let(:workflow) { create(:duo_workflows_workflow, user: maintainer, image: image, **container_params) }
  let(:container_params) { { project: project } }
  let(:duo_agent_platform_feature_setting) { nil }

  let(:params) do
    {
      goal: 'test-goal',
      workflow: workflow,
      workflow_oauth_token: 'test-oauth-token',
      workflow_service_token: 'test-service-token',
      workflow_metadata: { key: 'val' }.to_json,
      duo_agent_platform_feature_setting: duo_agent_platform_feature_setting,
      service_account: service_account
    }
  end

  before_all do
    project.add_member(service_account, Gitlab::Access::DEVELOPER)
  end

  shared_examples "success" do
    it 'creates a workload to execute workflow with the correct definition' do
      shadowed_project = project
      expect(Ci::Workloads::RunWorkloadService).to receive(:new).and_wrap_original do |method, **kwargs|
        project = kwargs[:project]
        workload_definition = kwargs[:workload_definition]
        expect(project).to eq(shadowed_project)
        expect(workload_definition.tags).to eq([::Ai::DuoWorkflows::Workflow::WORKLOAD_TAG])
        expect(kwargs[:duo_workflow_definition]).to eq(workflow.workflow_definition)
        method.call(**kwargs)
      end

      expect(execute).to be_success

      workload_id = execute.payload[:workload_id]
      expect(workload_id).not_to be_nil
      expect(workflow.workflows_workloads.first).to have_attributes(project_id: project.id,
        workload_id: workload_id)

      workload = Ci::Workloads::Workload.find_by_id([workload_id])
      expect(workload.branch_name).to start_with('refs/workloads/')
    end
  end

  shared_examples 'failure' do
    it 'does not create a workload to execute workflow' do
      expect(execute).to be_error
      expect(execute.reason).to eq(:feature_unavailable)
      expect(execute.message).to eq('Can not execute workflow in CI')
    end
  end

  shared_examples 'successful flow config' do
    let(:flow_config) do
      { 'version' => 'experimental', 'environment' => 'remote' }
    end

    let(:schema_version) { 'experimental' }

    context 'when flow_config is provided' do
      let(:params) do
        super().merge(
          flow_config: flow_config,
          flow_config_schema_version: schema_version
        )
      end

      it 'sets DUO_WORKFLOW_FLOW_CONFIG as JSON string and DUO_WORKFLOW_FLOW_CONFIG_SCHEMA_VERSION' do
        expect(Ci::Workloads::RunWorkloadService)
          .to receive(:new).and_wrap_original do |method, **kwargs|
          workload_definition = kwargs[:workload_definition]
          variables = workload_definition.variables

          expect(variables[:DUO_WORKFLOW_FLOW_CONFIG]).to eq(::Gitlab::Json.dump(flow_config))
          expect(variables[:DUO_WORKFLOW_FLOW_CONFIG_SCHEMA_VERSION]).to eq(schema_version)
          method.call(**kwargs)
        end

        expect(execute).to be_success
      end
    end

    context 'when flow_config is not provided' do
      it 'sets DUO_WORKFLOW_FLOW_CONFIG as empty string and DUO_WORKFLOW_FLOW_CONFIG_SCHEMA_VERSION as nil' do
        expect(Ci::Workloads::RunWorkloadService)
          .to receive(:new).and_wrap_original do |method, **kwargs|
          workload_definition = kwargs[:workload_definition]
          variables = workload_definition.variables

          expect(variables[:DUO_WORKFLOW_FLOW_CONFIG]).to be_nil
          expect(variables[:DUO_WORKFLOW_FLOW_CONFIG_SCHEMA_VERSION]).to be_nil
          method.call(**kwargs)
        end

        expect(execute).to be_success
      end
    end

    context 'when flow_config is not in Hash format' do
      let(:params) do
        super().merge(
          flow_config: "flow_config",
          flow_config_schema_version: schema_version
        )
      end

      it 'sets DUO_WORKFLOW_FLOW_CONFIG as nil' do
        expect(Ci::Workloads::RunWorkloadService)
          .to receive(:new).and_wrap_original do |method, **kwargs|
          workload_definition = kwargs[:workload_definition]
          variables = workload_definition.variables

          expect(variables[:DUO_WORKFLOW_FLOW_CONFIG]).to be_nil

          method.call(**kwargs)
        end

        expect(execute).to be_success
      end
    end
  end

  shared_examples 'additional context' do
    let(:additional_context) do
      [
        {
          Category: "agent_user_environment",
          Content: "some content",
          Metadata: "{}"
        }
      ]
    end

    def standard_context_content(parsed_context)
      context = parsed_context.find { |ctx| ctx["Category"] == "agent_platform_standard_context" }
      ::Gitlab::Json.parse(context["Content"]) if context
    end

    context 'when additional_context is provided' do
      let(:params) { super().merge(additional_context: additional_context) }

      it 'includes the original context' do
        expect(Ci::Workloads::RunWorkloadService)
          .to receive(:new).and_wrap_original do |method, **kwargs|
          workload_definition = kwargs[:workload_definition]
          variables = workload_definition.variables
          parsed_context = ::Gitlab::Json.parse(variables[:DUO_WORKFLOW_ADDITIONAL_CONTEXT_CONTENT])

          expect(parsed_context).to include(hash_including("Category" => "agent_user_environment"))
          method.call(**kwargs)
        end

        expect(execute).to be_success
      end

      it 'adds agent_platform_standard_context' do
        expect(Ci::Workloads::RunWorkloadService)
          .to receive(:new).and_wrap_original do |method, **kwargs|
          workload_definition = kwargs[:workload_definition]
          variables = workload_definition.variables
          parsed_context = ::Gitlab::Json.parse(variables[:DUO_WORKFLOW_ADDITIONAL_CONTEXT_CONTENT])
          standard_context = parsed_context.find { |ctx| ctx["Category"] == "agent_platform_standard_context" }

          expect(standard_context).to be_present
          method.call(**kwargs)
        end

        expect(execute).to be_success
      end
    end

    context 'when agent_platform_standard_context already exists' do
      let(:additional_context) do
        [
          {
            Category: "agent_user_environment",
            Content: "some content",
            Metadata: "{}"
          },
          {
            Category: "agent_platform_standard_context",
            Content: ::Gitlab::Json.dump({ "key" => "value" })
          }
        ]
      end

      let(:params) { super().merge(additional_context: additional_context) }

      it 'does not create a duplicate' do
        expect(Ci::Workloads::RunWorkloadService)
          .to receive(:new).and_wrap_original do |method, **kwargs|
          workload_definition = kwargs[:workload_definition]
          variables = workload_definition.variables
          parsed_context = ::Gitlab::Json.parse(variables[:DUO_WORKFLOW_ADDITIONAL_CONTEXT_CONTENT])
          standard_contexts = parsed_context.select { |ctx| ctx["Category"] == "agent_platform_standard_context" }

          expect(standard_contexts.size).to eq(1)
          method.call(**kwargs)
        end

        expect(execute).to be_success
      end

      it 'overrides the existing context' do
        expect(Ci::Workloads::RunWorkloadService)
          .to receive(:new).and_wrap_original do |method, **kwargs|
          workload_definition = kwargs[:workload_definition]
          variables = workload_definition.variables
          parsed_context = ::Gitlab::Json.parse(variables[:DUO_WORKFLOW_ADDITIONAL_CONTEXT_CONTENT])
          content = standard_context_content(parsed_context)

          expect(content).not_to eq({ "key" => "value" })
          expect(content.keys).to match_array(%w[workload_branch primary_branch session_owner_id])
          method.call(**kwargs)
        end

        expect(execute).to be_success
      end
    end

    context 'when source_branch exists' do
      let(:params) { super().merge(additional_context: additional_context, source_branch: 'feature-branch') }

      before do
        project.repository.create_branch('feature-branch', project.default_branch)
      end

      it 'uses source_branch as primary_branch' do
        expect(Ci::Workloads::RunWorkloadService)
          .to receive(:new).and_wrap_original do |method, **kwargs|
          workload_definition = kwargs[:workload_definition]
          variables = workload_definition.variables
          parsed_context = ::Gitlab::Json.parse(variables[:DUO_WORKFLOW_ADDITIONAL_CONTEXT_CONTENT])
          content = standard_context_content(parsed_context)

          expect(content["primary_branch"]).to eq('feature-branch')
          method.call(**kwargs)
        end

        expect(execute).to be_success
      end
    end

    context 'when source_branch does not exist' do
      let(:params) { super().merge(additional_context: additional_context, source_branch: 'non-existent-branch') }

      it 'falls back to default branch as primary_branch' do
        expect(Ci::Workloads::RunWorkloadService)
          .to receive(:new).and_wrap_original do |method, **kwargs|
          workload_definition = kwargs[:workload_definition]
          variables = workload_definition.variables
          parsed_context = ::Gitlab::Json.parse(variables[:DUO_WORKFLOW_ADDITIONAL_CONTEXT_CONTENT])
          content = standard_context_content(parsed_context)

          expect(content["primary_branch"]).to eq(project.default_branch_or_main)
          method.call(**kwargs)
        end

        expect(execute).to be_success
      end
    end

    context 'when additional_context is not provided' do
      it 'only includes agent_platform_standard_context' do
        expect(Ci::Workloads::RunWorkloadService)
          .to receive(:new).and_wrap_original do |method, **kwargs|
          workload_definition = kwargs[:workload_definition]
          variables = workload_definition.variables
          parsed_context = ::Gitlab::Json.parse(variables[:DUO_WORKFLOW_ADDITIONAL_CONTEXT_CONTENT])

          expect(parsed_context.size).to eq(1)
          expect(parsed_context.first["Category"]).to eq("agent_platform_standard_context")
          method.call(**kwargs)
        end

        expect(execute).to be_success
      end
    end
  end

  shared_context 'with Duo enabled' do
    before do
      allow(::Gitlab::Llm::StageCheck).to receive(:available?).with(project, :duo_workflow).and_return(true)
      allow(maintainer).to receive(:allowed_to_use?).and_return(true)
    end
  end

  subject(:execute) { described_class.new(workflow: workflow, params: params).execute }

  context 'with workflow enablement checks' do
    using RSpec::Parameterized::TableSyntax
    where(:duo_features_enabled, :duo_remote_flows_enabled, :current_user,
      :shared_examples) do
      true  | false | ref(:maintainer) | 'failure'
      true  | true  | ref(:maintainer) | 'success'
      true  | true  | ref(:reporter)   | 'failure'
      false | true  | ref(:developer)  | 'failure'
      false | false | ref(:developer)  | 'failure'
      true  | true  | ref(:maintainer) | 'successful flow config'
      true  | true  | ref(:developer) | 'additional context'
    end

    with_them do
      before do
        allow(::Gitlab::Llm::StageCheck).to receive(:available?).with(project, :duo_workflow).and_return(true)
        allow(current_user).to receive(:allowed_to_use?).and_return(true)
        project.project_setting.update!(duo_features_enabled: duo_features_enabled,
          duo_remote_flows_enabled: duo_remote_flows_enabled)
        workflow.update!(user: current_user)
      end

      include_examples params[:shared_examples]
    end
  end

  context 'when workflow is not project-level' do
    let(:container_params) { { namespace: group } }

    it 'returns an error' do
      expect(execute).to be_error
      expect(execute.reason).to eq(:unprocessable_entity)
      expect(execute.message).to eq('Only project-level workflow is supported')
    end
  end

  context 'when ci pipeline could not be created' do
    let(:pipeline) do
      instance_double(Ci::Pipeline, created_successfully?: false, full_error_messages: 'full error messages')
    end

    let(:service_response) { ServiceResponse.error(message: 'Error in creating pipeline', payload: pipeline) }

    before do
      allow(::Gitlab::Llm::StageCheck).to receive(:available?).with(project, :duo_workflow).and_return(true)
      # rubocop:disable RSpec/AnyInstanceOf -- not the next instance
      allow_any_instance_of(User).to receive_messages(allowed_to_use?: true, allowed_to_use_for_resource?: true)
      # rubocop:enable RSpec/AnyInstanceOf
      allow_next_instance_of(Ci::CreatePipelineService) do |instance|
        allow(instance).to receive(:execute).and_return(service_response)
      end
      project.project_setting.update!(duo_features_enabled: true, duo_remote_flows_enabled: true)
    end

    it 'does not start a pipeline to execute workflow' do
      expect(execute).to be_error
      expect(execute.reason).to eq(:workload_failure)
      expect(execute.message).to eq('Error in creating workload: full error messages')
    end
  end

  context 'when service_account is not provided' do
    include_context 'with Duo enabled'

    before do
      params.delete(:service_account)
    end

    it 'returns an error' do
      expect(execute).to be_error
      expect(execute.reason).to eq(:invalid_service_account)
      expect(execute.message).to include('Service account is required')
    end
  end

  context 'when service_account is set' do
    include_context 'with Duo enabled'

    it 'creates the workload as the service account' do
      expect(Ci::Workloads::RunWorkloadService)
        .to receive(:new).and_wrap_original do |method, **kwargs|
        expect(kwargs[:current_user]).to eq(service_account)
        method.call(**kwargs)
      end

      expect(execute).to be_success
    end
  end

  context 'with source_branch parameter' do
    before do
      allow(::Gitlab::Llm::StageCheck).to receive(:available?).with(project, :duo_workflow).and_return(true)
      # rubocop:disable RSpec/AnyInstanceOf -- not the next instance
      allow_any_instance_of(User).to receive_messages(allowed_to_use?: true, allowed_to_use_for_resource?: true)
      # rubocop:enable RSpec/AnyInstanceOf
      project.project_setting.update!(duo_features_enabled: true, duo_remote_flows_enabled: true)
    end

    it 'creates workload branch from source_branch and passes ref to RunWorkloadService when provided' do
      local_params = params.merge(source_branch: 'feature-branch')
      service = described_class.new(workflow: workflow, params: local_params)

      expect(::Ci::Workloads::WorkloadBranchService).to receive(:new).with(
        hash_including(source_branch: 'feature-branch')
      ).and_call_original

      expect(service.execute).to be_success
    end

    it 'passes nil when source_branch not provided' do
      expect(::Ci::Workloads::WorkloadBranchService).to receive(:new).with(
        hash_including(source_branch: nil)
      ).and_call_original

      expect(execute).to be_success
    end

    it 'returns error with reason when workload branch creation fails' do
      branch_error = ServiceResponse.error(message: 'Source ref not found', reason: :source_ref_not_found)
      allow_next_instance_of(::Ci::Workloads::WorkloadBranchService) do |service|
        allow(service).to receive(:execute).and_return(branch_error)
      end

      result = execute

      expect(result).to be_error
      expect(result.message).to eq('Source ref not found')
      expect(result.reason).to eq(:source_ref_not_found)
    end
  end

  context 'with custom image configuration' do
    let(:custom_image) { 'registry.gitlab.com/custom/image:v1.0' }
    let(:duo_config) { instance_double(::Gitlab::DuoAgentPlatform::Config) }

    before do
      allow(::Gitlab::Llm::StageCheck).to receive(:available?).with(project, :duo_workflow).and_return(true)
      allow(maintainer).to receive(:allowed_to_use?).and_return(true)
      project.project_setting.update!(duo_features_enabled: true, duo_remote_flows_enabled: true)
      allow(::Gitlab::DuoAgentPlatform::Config).to receive(:new).with(project).and_return(duo_config)
    end

    context 'when .gitlab/duo/agent-config.yml exists with valid configuration' do
      before do
        allow(duo_config).to receive_messages(
          config_present?: true,
          default_image: custom_image,
          setup_script: nil,
          cache_config: nil,
          network_policy: nil,
          valid_format?: true
        )
      end

      context 'when workflow has no image specified' do
        let(:image) { nil }

        it 'uses the configured image from .gitlab/duo/agent-config.yml' do
          expect(Ci::Workloads::RunWorkloadService)
            .to receive(:new).and_wrap_original do |method, **kwargs|
            workload_definition = kwargs[:workload_definition]
            expect(workload_definition.image).to eq(custom_image)
            method.call(**kwargs)
          end

          expect(execute).to be_success
        end
      end

      context 'when workflow already has an image specified' do
        let(:image) { 'workflow-specific-image:latest' }

        it 'prefers the workflow image over the configured image' do
          expect(Ci::Workloads::RunWorkloadService)
            .to receive(:new).and_wrap_original do |method, **kwargs|
            workload_definition = kwargs[:workload_definition]
            expect(workload_definition.image).to eq(image)
            method.call(**kwargs)
          end

          expect(execute).to be_success
        end
      end
    end

    context 'when .gitlab/duo/agent-config.yml exists but has no default_image' do
      before do
        allow(duo_config).to receive_messages(
          config_present?: true,
          default_image: nil,
          setup_script: nil,
          cache_config: nil,
          network_policy: nil,
          valid_format?: true
        )
      end

      let(:image) { nil }

      it 'falls back to the hardened image' do
        expect(Ci::Workloads::RunWorkloadService)
          .to receive(:new).and_wrap_original do |method, **kwargs|
          workload_definition = kwargs[:workload_definition]
          expect(workload_definition.image).to eq("registry.gitlab.com/#{described_class::HARDENED_IMAGE_PATH}")
          method.call(**kwargs)
        end

        expect(execute).to be_success
      end

      context 'when duo_workflow_use_hardened_image feature flag is disabled' do
        before do
          stub_feature_flags(duo_workflow_use_hardened_image: false)
        end

        it 'falls back to the default image' do
          expect(Ci::Workloads::RunWorkloadService)
            .to receive(:new).and_wrap_original do |method, **kwargs|
            workload_definition = kwargs[:workload_definition]
            expect(workload_definition.image).to eq("registry.gitlab.com/#{described_class::IMAGE_PATH}")
            method.call(**kwargs)
          end

          expect(execute).to be_success
        end
      end
    end
  end

  context 'when agent-config.yml is present but has invalid format' do
    let(:duo_config) { instance_double(::Gitlab::DuoAgentPlatform::Config) }
    let(:config_file) { ::Gitlab::DuoAgentPlatform::Config::CONFIG_FILE_NAME }

    before do
      allow(::Gitlab::Llm::StageCheck).to receive(:available?).with(project, :duo_workflow).and_return(true)
      allow(maintainer).to receive(:allowed_to_use?).and_return(true)
      project.project_setting.update!(duo_features_enabled: true, duo_remote_flows_enabled: true)
      allow(::Gitlab::DuoAgentPlatform::Config).to receive(:new).with(project).and_return(duo_config)
      allow(duo_config).to receive_messages(
        config_present?: true,
        valid_format?: false,
        validation_errors: ["object property at `/imgae` is a disallowed additional property"]
      )
    end

    it 'returns an error with the validation errors in the message' do
      expect(execute).to be_error
      expect(execute.reason).to eq(:unprocessable_entity)
      expect(execute.message).to eq(
        "Invalid config file #{config_file} -> " \
          "object property at `/imgae` is a disallowed additional property"
      )
    end
  end

  context 'with image priority' do
    let(:workflow_image) { 'workflow-image:latest' }
    let(:config_image) { 'config-image:latest' }
    let(:duo_config) { instance_double(::Gitlab::DuoAgentPlatform::Config) }

    before do
      allow(::Gitlab::Llm::StageCheck).to receive(:available?).with(project, :duo_workflow).and_return(true)
      allow(maintainer).to receive(:allowed_to_use?).and_return(true)
      project.project_setting.update!(duo_features_enabled: true, duo_remote_flows_enabled: true)
      allow(::Gitlab::DuoAgentPlatform::Config).to receive(:new).with(project).and_return(duo_config)
      allow(duo_config).to receive_messages(
        config_present?: true,
        default_image: config_image,
        setup_script: nil,
        cache_config: nil,
        network_policy: nil,
        valid_format?: true
      )
    end

    context 'when workflow image is present' do
      let(:image) { workflow_image }

      it 'uses the workflow image' do
        expect(Ci::Workloads::RunWorkloadService)
          .to receive(:new).and_wrap_original do |method, **kwargs|
          workload_definition = kwargs[:workload_definition]
          expect(workload_definition.image).to eq(workflow_image)
          method.call(**kwargs)
        end

        expect(execute).to be_success
      end
    end

    context 'when only config image is present' do
      let(:image) { nil }

      it 'uses the config image' do
        expect(Ci::Workloads::RunWorkloadService)
          .to receive(:new).and_wrap_original do |method, **kwargs|
          workload_definition = kwargs[:workload_definition]
          expect(workload_definition.image).to eq(config_image)
          method.call(**kwargs)
        end

        expect(execute).to be_success
      end
    end

    context 'when neither workflow nor config image are present' do
      let(:image) { nil }

      before do
        allow(duo_config).to receive_messages(
          default_image: nil,
          setup_script: nil,
          cache_config: nil,
          network_policy: nil
        )
      end

      it 'uses the hardened image' do
        expect(Ci::Workloads::RunWorkloadService)
          .to receive(:new).and_wrap_original do |method, **kwargs|
          workload_definition = kwargs[:workload_definition]
          expect(workload_definition.image).to eq("registry.gitlab.com/#{described_class::HARDENED_IMAGE_PATH}")
          method.call(**kwargs)
        end

        expect(execute).to be_success
      end

      context 'when duo_workflow_use_hardened_image feature flag is disabled' do
        before do
          stub_feature_flags(duo_workflow_use_hardened_image: false)
        end

        it 'uses the default image' do
          expect(Ci::Workloads::RunWorkloadService)
            .to receive(:new).and_wrap_original do |method, **kwargs|
            workload_definition = kwargs[:workload_definition]
            expect(workload_definition.image).to eq("registry.gitlab.com/#{described_class::IMAGE_PATH}")
            method.call(**kwargs)
          end

          expect(execute).to be_success
        end
      end
    end
  end

  describe 'flow versioning params' do
    let(:workflow) do
      create(:duo_workflows_workflow, user: maintainer, image: image, workflow_definition: 'developer/v1',
     **container_params)
    end

    before do
      allow(::Gitlab::Llm::StageCheck).to receive(:available?).with(project, :duo_workflow).and_return(true)
      allow(maintainer).to receive(:allowed_to_use?).and_return(true)
      project.project_setting.update!(duo_features_enabled: true, duo_remote_flows_enabled: true)
    end

    context 'when routing params differ from stable workflow_definition' do
      let(:params) do
        super().merge(
          flow_config_id: 'developer_unstable',
          flow_config_schema_version: 'experimental',
          flow_version: '1.0.0'
        )
      end

      it 'uses stable identity for RunWorkloadService and routing value for DUO_WORKFLOW_DEFINITION' do
        expect(Ci::Workloads::RunWorkloadService).to receive(:new).and_wrap_original do |method, **kwargs|
          expect(kwargs[:duo_workflow_definition]).to eq('developer/v1')
          variables = kwargs[:workload_definition].variables
          expect(variables[:DUO_WORKFLOW_DEFINITION]).to eq('developer_unstable/experimental')
          expect(variables[:DUO_WORKFLOW_FLOW_CONFIG_ID]).to eq('developer_unstable')
          expect(variables[:DUO_WORKFLOW_FLOW_CONFIG_SCHEMA_VERSION]).to eq('experimental')
          expect(variables[:DUO_WORKFLOW_FLOW_VERSION]).to eq('1.0.0')
          method.call(**kwargs)
        end

        expect(execute).to be_success
      end
    end
  end

  context 'for GITLAB_PROJECT_PATH' do
    before do
      allow(::Gitlab::Llm::StageCheck).to receive(:available?).with(project, :duo_workflow).and_return(true)
      allow(maintainer).to receive(:allowed_to_use?).and_return(true)
      project.project_setting.update!(duo_features_enabled: true, duo_remote_flows_enabled: true)
    end

    it 'sets it to project full path' do
      expect(Ci::Workloads::RunWorkloadService)
        .to receive(:new).and_wrap_original do |method, **kwargs|
        variables = kwargs[:workload_definition].variables
        expect(variables[:GITLAB_PROJECT_PATH]).to eq(project.full_path)
        method.call(**kwargs)
      end

      expect(execute).to be_success
    end
  end

  shared_examples 'sets AGENT_PLATFORM_MODEL_METADATA' do
    it 'sets the correct model metadata' do
      expect(Ci::Workloads::RunWorkloadService)
        .to receive(:new).and_wrap_original do |method, **kwargs|
        variables = kwargs[:workload_definition].variables
        expect(variables[:AGENT_PLATFORM_MODEL_METADATA]).to eq(expected_model_metadata)
        method.call(**kwargs)
      end

      expect(execute).to be_success
    end
  end

  context 'for AGENT_PLATFORM_MODEL_METADATA' do
    before do
      allow(::Gitlab::Llm::StageCheck).to receive(:available?).with(project, :duo_workflow).and_return(true)
      allow(maintainer).to receive(:allowed_to_use?).and_return(true)
      project.project_setting.update!(duo_features_enabled: true, duo_remote_flows_enabled: true)
    end

    context 'when self-hosted feature setting exists' do
      let(:expected_model_metadata) do
        {
          provider: 'openai',
          name: 'claude_3',
          endpoint: 'http://localhost:11434/v1',
          api_key: 'token',
          identifier: 'claude-3-7-sonnet-20250219'
        }.to_json
      end

      let_it_be(:model) do
        create(:ai_self_hosted_model, model: :claude_3, identifier: 'claude-3-7-sonnet-20250219')
      end

      let_it_be(:duo_agent_platform_feature_setting) do
        create(:ai_feature_setting, :duo_agent_platform, self_hosted_model: model)
      end

      it_behaves_like 'sets AGENT_PLATFORM_MODEL_METADATA'
    end

    context 'when instance level model selection exists' do
      let(:expected_model_metadata) do
        {
          provider: 'gitlab',
          feature_setting: 'duo_agent_platform',
          identifier: 'claude-3-7-sonnet-20250219'
        }.to_json
      end

      let_it_be(:duo_agent_platform_feature_setting) do
        create(:instance_model_selection_feature_setting, feature: :duo_agent_platform)
      end

      it_behaves_like 'sets AGENT_PLATFORM_MODEL_METADATA'
    end

    context 'when namespace level model selection exists', :saas do
      let(:expected_model_metadata) do
        {
          provider: 'gitlab',
          feature_setting: 'duo_agent_platform',
          identifier: 'claude_sonnet_3_7_20250219'
        }.to_json
      end

      let_it_be(:duo_agent_platform_feature_setting) do
        create(:ai_namespace_feature_setting,
          namespace: project.namespace,
          feature: :duo_agent_platform,
          offered_model_ref: "claude_sonnet_3_7_20250219")
      end

      it_behaves_like 'sets AGENT_PLATFORM_MODEL_METADATA'
    end

    context 'when no feature setting exists' do
      let(:expected_model_metadata) { nil }

      it_behaves_like 'sets AGENT_PLATFORM_MODEL_METADATA'
    end
  end

  shared_examples 'sets AGENT_PLATFORM_FEATURE_SETTING_NAME' do
    it 'sets the correct feature setting name' do
      expect(Ci::Workloads::RunWorkloadService)
        .to receive(:new).and_wrap_original do |method, **kwargs|
        variables = kwargs[:workload_definition].variables
        expect(variables[:AGENT_PLATFORM_FEATURE_SETTING_NAME]).to eq(expected_feature_setting_name)
        method.call(**kwargs)
      end

      expect(execute).to be_success
    end
  end

  context 'for AGENT_PLATFORM_FEATURE_SETTING_NAME' do
    before do
      allow(::Gitlab::Llm::StageCheck).to receive(:available?).with(project, :duo_workflow).and_return(true)
      allow(maintainer).to receive(:allowed_to_use?).and_return(true)
      project.project_setting.update!(duo_features_enabled: true, duo_remote_flows_enabled: true)
    end

    context 'when self-hosted feature setting exists' do
      let(:expected_feature_setting_name) { 'duo_agent_platform' }

      let_it_be(:model) do
        create(:ai_self_hosted_model, model: :claude_3, identifier: 'claude-3-7-sonnet-20250219')
      end

      let_it_be(:duo_agent_platform_feature_setting) do
        create(:ai_feature_setting, :duo_agent_platform, self_hosted_model: model)
      end

      it_behaves_like 'sets AGENT_PLATFORM_FEATURE_SETTING_NAME'
    end

    context 'when instance level model selection exists' do
      let(:expected_feature_setting_name) { 'duo_agent_platform' }

      let_it_be(:duo_agent_platform_feature_setting) do
        create(:instance_model_selection_feature_setting, feature: :duo_agent_platform)
      end

      it_behaves_like 'sets AGENT_PLATFORM_FEATURE_SETTING_NAME'
    end

    context 'when namespace level model selection exists', :saas do
      let(:expected_feature_setting_name) { 'duo_agent_platform' }

      let_it_be(:duo_agent_platform_feature_setting) do
        create(:ai_namespace_feature_setting,
          namespace: project.namespace,
          feature: :duo_agent_platform,
          offered_model_ref: "claude_sonnet_3_7_20250219")
      end

      it_behaves_like 'sets AGENT_PLATFORM_FEATURE_SETTING_NAME'
    end

    context 'when feature setting is for review_merge_request', :saas do
      let(:expected_feature_setting_name) { 'review_merge_request' }

      let_it_be(:review_merge_request_feature_setting) do
        create(:ai_namespace_feature_setting,
          namespace: project.namespace,
          feature: :review_merge_request,
          offered_model_ref: "claude_sonnet_3_7")
      end

      let(:duo_agent_platform_feature_setting) { review_merge_request_feature_setting }

      it_behaves_like 'sets AGENT_PLATFORM_FEATURE_SETTING_NAME'
    end

    context 'when no feature setting exists' do
      let(:expected_feature_setting_name) { 'duo_agent_platform' }

      it_behaves_like 'sets AGENT_PLATFORM_FEATURE_SETTING_NAME'
    end
  end

  context 'for LANGSMITH_TRACE' do
    before do
      allow(::Gitlab::Llm::StageCheck).to receive(:available?).with(project, :duo_workflow).and_return(true)
      allow(maintainer).to receive(:allowed_to_use?).and_return(true)
      project.project_setting.update!(duo_features_enabled: true, duo_remote_flows_enabled: true)
    end

    context 'when langsmith_trace param is present' do
      let(:params) { super().merge(langsmith_trace: 'trace-id-123') }

      it 'sets LANGSMITH_TRACE variable' do
        expect(Ci::Workloads::RunWorkloadService)
          .to receive(:new).and_wrap_original do |method, **kwargs|
          variables = kwargs[:workload_definition].variables
          expect(variables[:LANGSMITH_TRACE]).to eq('trace-id-123')
          method.call(**kwargs)
        end

        expect(execute).to be_success
      end
    end

    context 'when langsmith_trace param is not present' do
      it 'does not set LANGSMITH_TRACE variable' do
        expect(Ci::Workloads::RunWorkloadService)
          .to receive(:new).and_wrap_original do |method, **kwargs|
          variables = kwargs[:workload_definition].variables
          expect(variables).not_to have_key(:LANGSMITH_TRACE)
          method.call(**kwargs)
        end

        expect(execute).to be_success
      end
    end
  end

  shared_examples 'sets DUO_WORKFLOW_SERVICE_SERVER' do
    it 'sets the correct service server URL' do
      expect(Ci::Workloads::RunWorkloadService)
        .to receive(:new).and_wrap_original do |method, **kwargs|
        variables = kwargs[:workload_definition].variables
        expect(variables[:DUO_WORKFLOW_SERVICE_SERVER]).to eq(expected_service_server_url)
        method.call(**kwargs)
      end

      expect(execute).to be_success
    end
  end

  context 'for DUO_WORKFLOW_SERVICE_SERVER' do
    let(:cloud_connector_url) { 'cloud.staging.gitlab.com:443' }
    let(:self_hosted_url) { 'self-hosted-dap-service-url:50052' }

    before do
      allow(::Gitlab::Llm::StageCheck).to receive(:available?).with(project, :duo_workflow).and_return(true)
      allow(maintainer).to receive(:allowed_to_use?).and_return(true)
      project.project_setting.update!(duo_features_enabled: true, duo_remote_flows_enabled: true)
      allow(Gitlab::DuoWorkflow::Client).to receive_messages(self_hosted_url: self_hosted_url,
        cloud_connected_url: cloud_connector_url)
    end

    context 'when self-hosted feature setting exists' do
      let(:expected_service_server_url) { self_hosted_url }

      let_it_be(:model) do
        create(:ai_self_hosted_model, model: :claude_3, identifier: 'claude-3-7-sonnet-20250219')
      end

      let_it_be(:duo_agent_platform_feature_setting) do
        create(:ai_feature_setting, :duo_agent_platform, self_hosted_model: model)
      end

      it_behaves_like 'sets DUO_WORKFLOW_SERVICE_SERVER'
    end

    context 'when instance level model selection exists' do
      let(:expected_service_server_url) { cloud_connector_url }

      let_it_be(:duo_agent_platform_feature_setting) do
        create(:instance_model_selection_feature_setting, feature: :duo_agent_platform)
      end

      it_behaves_like 'sets DUO_WORKFLOW_SERVICE_SERVER'
    end

    context 'when namespace level model selection exists', :saas do
      let(:expected_service_server_url) { cloud_connector_url }

      let_it_be(:duo_agent_platform_feature_setting) do
        create(:ai_namespace_feature_setting,
          namespace: project.namespace,
          feature: :duo_agent_platform,
          offered_model_ref: "claude_sonnet_3_7_20250219")
      end

      it_behaves_like 'sets DUO_WORKFLOW_SERVICE_SERVER'
    end

    context 'when no feature setting exists' do
      let(:expected_service_server_url) { cloud_connector_url }

      it_behaves_like 'sets DUO_WORKFLOW_SERVICE_SERVER'
    end
  end

  context 'with setup_script configuration' do
    let(:duo_config) { instance_double(::Gitlab::DuoAgentPlatform::Config) }
    let(:sandbox) { instance_double(::Gitlab::DuoWorkflow::Sandbox) }
    let(:glab_setup) { instance_double(::Gitlab::DuoWorkflow::GlabSetup) }
    let(:orbit_local_setup) { instance_double(::Gitlab::DuoWorkflow::OrbitLocalSetup) }
    let(:sandbox_setup_commands) { ["mkdir -p #{::Gitlab::DuoWorkflow::Sandbox::SANDBOX_SYSTEM_DIR}"] }
    let(:setup_commands) { ['npm install', 'npm run build', 'npm test'] }
    let(:shared_main_commands) do
      [
        "git remote set-url origin " \
          '"$(echo "${DUO_WORKFLOW_GIT_HTTP_BASE_URL}" | ' \
          "sed 's|://|://oauth:'\"${GIT_PASSWORD}\"'@|')/${GITLAB_PROJECT_PATH}.git\"",
        %(echo $DUO_WORKFLOW_DEFINITION),
        %(echo $DUO_WORKFLOW_FLOW_CONFIG_ID),
        %(echo $DUO_WORKFLOW_FLOW_VERSION),
        %(echo $DUO_WORKFLOW_GOAL),
        %(echo $DUO_WORKFLOW_SOURCE_BRANCH),
        %(echo $DUO_WORKFLOW_FLOW_CONFIG),
        %(echo $DUO_WORKFLOW_FLOW_CONFIG_SCHEMA_VERSION),
        %(echo $DUO_WORKFLOW_ADDITIONAL_CONTEXT_CONTENT),
        %(echo Starting Workflow #{workflow.id})
      ]
    end

    let(:cli_install_commands) do
      cli_install_command = [
        "command -v duo > /dev/null 2>&1 && ",
        "echo \"duo-cli already present, skipping installation\" || ",
        "{ echo \"Installing @gitlab/duo-cli@#{duo_cli_version}...\" && ",
        "npm install -g @gitlab/duo-cli@#{duo_cli_version}; }"
      ].join

      [
        cli_install_command,
        %(ls -la $(npm root -g)/@gitlab/duo-cli || echo "GitLab Duo package not found"),
        %(export PATH="$(npm bin -g):$PATH"),
        %(which duo || echo "duo not in PATH")
      ]
    end

    let(:glab_setup_commands) do
      %w[
        __glab_install__
        __glab_path_export__
        __glab_which__
        __glab_version__
        __glab_config_mkdir__
        __glab_config_write__
        __glab_config_chmod__
      ]
    end

    let(:sandbox_env_vars) do
      {
        NPM_CONFIG_CACHE: "/tmp/.npm-cache",
        GITLAB_LSP_STORAGE_DIR: "/tmp"
      }
    end

    let(:wrapped_commands) do
      [
        %(if which srt > /dev/null; then),
        %(  echo "SRT found, creating config..."),
        %(  srt --settings /tmp/srt-settings.json #{duo_cli_command}),
        %(fi)
      ]
    end

    let(:duo_cli_command) { %(duo run --existing-session-id #{workflow.id} --connection-type websocket) }

    def binary_install_commands
      [
        a_string_including(
          "command -v duo",
          described_class::DUO_CLI_REGISTRY_BASE_URL,
          described_class::DUO_CLI_PROJECT_ID,
          "/packages/generic/duo-cli/#{duo_cli_version}",
          "curl -fsSL",
          described_class::DUO_CLI_INSTALL_DIR,
          "chmod +x",
          "Unsupported architecture",
          "} || exit 1"
        ),
        %(which duo || echo "duo not in PATH"),
        %(duo --version || echo "duo version check failed")
      ]
    end

    before do
      stub_feature_flags(duo_agent_platform_executor_binary: false)
      allow(::Gitlab::Llm::StageCheck).to receive(:available?).with(project, :duo_workflow).and_return(true)
      allow(maintainer).to receive(:allowed_to_use?).and_return(true)
      project.project_setting.update!(duo_features_enabled: true, duo_remote_flows_enabled: true)
      allow(::Gitlab::DuoAgentPlatform::Config).to receive(:new).with(project).and_return(duo_config)
      allow(duo_config).to receive_messages(
        config_present?: true,
        default_image: nil,
        cache_config: nil
      )
      allow(::Gitlab::DuoWorkflow::Sandbox).to receive(:new).and_return(sandbox)
      allow(sandbox).to receive_messages(
        setup_sandbox_commands: sandbox_setup_commands,
        environment_variables: sandbox_env_vars
      )
      allow(sandbox).to receive(:wrap_command).with(duo_cli_command).and_return(wrapped_commands)
      allow(::Gitlab::DuoWorkflow::GlabSetup).to receive(:new).and_return(glab_setup)
      allow(glab_setup).to receive(:commands).and_return(glab_setup_commands)
      allow(::Gitlab::DuoWorkflow::OrbitLocalSetup).to receive(:new).and_return(orbit_local_setup)
      allow(orbit_local_setup).to receive(:commands).and_return([])
    end

    context 'when setup_script is present' do
      before do
        allow(duo_config).to receive_messages(
          setup_script: setup_commands,
          valid_format?: true
        )
      end

      it 'prepends setup_script commands to the main commands' do
        allow(Ci::Workloads::RunWorkloadService).to receive(:new).and_call_original

        expect(execute).to be_success

        expect(Ci::Workloads::RunWorkloadService).to have_received(:new) do |workload_definition:, **_kwargs|
          expect(workload_definition.commands).to eq(sandbox_setup_commands + setup_commands + shared_main_commands +
                                                     cli_install_commands + glab_setup_commands + wrapped_commands)
        end

        expect(execute).to be_success
      end
    end

    context 'when setup_script is not present' do
      before do
        allow(duo_config).to receive_messages(setup_script: nil, valid_format?: true)
        allow(Ci::Workloads::RunWorkloadService).to receive(:new).and_call_original
      end

      it 'uses only the main commands' do
        expect(execute).to be_success

        expect(Ci::Workloads::RunWorkloadService).to have_received(:new) do |workload_definition:, **_kwargs|
          expect(workload_definition.commands).to eq(sandbox_setup_commands + shared_main_commands +
                                                     cli_install_commands + glab_setup_commands + wrapped_commands)
        end

        expect(execute).to be_success
      end
    end

    context 'when setup_script is empty array' do
      before do
        allow(duo_config).to receive_messages(setup_script: [], valid_format?: true)
      end

      it 'does not prepend any commands' do
        expect(Ci::Workloads::RunWorkloadService).to receive(:new) do |workload_definition:, **_kwargs|
          commands = workload_definition.commands

          # Should start with main commands
          expect(commands.first).to eq(shared_main_commands.first)
          expect(commands.size).to eq(shared_main_commands.size + cli_install_commands.size +
                                      glab_setup_commands.size + wrapped_commands.size)
        end.and_call_original

        expect(execute).to be_success
      end
    end

    context 'when setup_script has a single command' do
      before do
        allow(duo_config).to receive_messages(setup_script: ['bundle install'], valid_format?: true)
      end

      it 'prepends the single command' do
        expect(Ci::Workloads::RunWorkloadService).to receive(:new) do |workload_definition:, **_kwargs|
          commands = workload_definition.commands

          expect(commands[0]).to eq('bundle install')
          expect(commands[1]).to eq(shared_main_commands.first)
          expect(commands.size).to eq(1 + shared_main_commands.size + cli_install_commands.size +
                                      glab_setup_commands.size + wrapped_commands.size)
        end.and_call_original

        expect(execute).to be_success
      end
    end

    context 'with duo_agent_platform_executor_binary feature flag' do
      before do
        allow(duo_config).to receive_messages(setup_script: nil, valid_format?: true)
        allow(Ci::Workloads::RunWorkloadService).to receive(:new).and_call_original
      end

      context 'when duo_agent_platform_executor_binary is disabled' do
        it 'installs duo-cli via npm' do
          expect(execute).to be_success

          expect(Ci::Workloads::RunWorkloadService).to have_received(:new) do |workload_definition:, **_kwargs|
            commands = workload_definition.commands
            expect(commands).to include(a_string_including("npm install -g @gitlab/duo-cli@#{duo_cli_version}"))
            expect(commands).to include(a_string_including("npm root -g"))
            expect(commands).to include(a_string_including("npm bin -g"))
            expect(commands).not_to include(a_string_including("curl -fsSL"))
          end
        end

        it 'uses npm CLI install commands in the correct position' do
          expect(execute).to be_success

          expect(Ci::Workloads::RunWorkloadService).to have_received(:new) do |workload_definition:, **_kwargs|
            expect(workload_definition.commands).to eq(
              sandbox_setup_commands + shared_main_commands +
                cli_install_commands + glab_setup_commands + wrapped_commands
            )
          end
        end
      end

      context 'when duo_agent_platform_executor_binary is enabled' do
        before do
          stub_feature_flags(duo_agent_platform_executor_binary: true)
        end

        it 'installs duo-cli via binary download from the package registry', :aggregate_failures do
          expect(execute).to be_success

          expect(Ci::Workloads::RunWorkloadService).to have_received(:new) do |workload_definition:, **_kwargs|
            install_command = workload_definition.commands.find { |cmd| cmd.include?('curl -fsSL') }

            expect(install_command).to be_present
            expect(install_command).to include(described_class::DUO_CLI_REGISTRY_BASE_URL)
            expect(install_command).to include(described_class::DUO_CLI_PROJECT_ID)
            expect(install_command).to include("/packages/generic/duo-cli/#{duo_cli_version}")
            expect(install_command).to include(described_class::DUO_CLI_INSTALL_DIR)
            expect(install_command).to include("chmod +x")
            expect(install_command).to end_with("} || exit 1")
            expect(install_command).to include("uname -s")
            expect(install_command).to include("uname -m")
            expect(install_command).to include("x86_64|amd64")
            expect(install_command).to include("arm64|aarch64")
            expect(install_command).to include("Unsupported architecture")
            expect(workload_definition.commands).not_to include(a_string_including("npm install -g @gitlab/duo-cli"))
            expect(workload_definition.commands).not_to include(a_string_including("npm root -g"))
            expect(workload_definition.commands).not_to include(a_string_including("npm bin -g"))
            expect(workload_definition.commands).to include(%(duo --version || echo "duo version check failed"))
          end
        end

        it 'uses binary CLI install commands in the correct position' do
          expect(execute).to be_success

          expect(Ci::Workloads::RunWorkloadService).to have_received(:new) do |workload_definition:, **_kwargs|
            expect(workload_definition.commands).to match(
              sandbox_setup_commands + shared_main_commands +
                binary_install_commands + glab_setup_commands + wrapped_commands
            )
          end
        end
      end
    end

    context 'with sandbox integration' do
      before do
        allow(duo_config).to receive(:setup_script).and_return(nil)
      end

      shared_examples 'sandbox enabled behavior' do
        let(:duo_workflow_service_url) { 'https://duo-workflow-service.example.com:443' }

        let(:sandbox_env_vars) do
          {
            NPM_CONFIG_CACHE: "/tmp/.npm-cache",
            GITLAB_LSP_STORAGE_DIR: "/tmp"
          }
        end

        let(:duo_config) { ::Gitlab::DuoAgentPlatform::Config.new(project) }

        before do
          allow(Gitlab::DuoWorkflow::Client).to receive(:url_for).and_return(duo_workflow_service_url)
          allow(sandbox).to receive(:wrap_command).with(duo_cli_command).and_return(wrapped_commands)
          allow(sandbox).to receive(:environment_variables).and_return(sandbox_env_vars)
          expect_next_instance_of(::Ai::DuoWorkflows::StartWorkflowService) do |instance|
            allow(instance).to receive_messages(base_variables: { var1: 1 }, git_environment_variables: { var2: 1 },
              token_variables: { var3: 3 })
          end
        end

        it 'creates sandbox instance with correct parameters' do
          execute

          expect(::Gitlab::DuoWorkflow::Sandbox).to have_received(:new).with(
            current_user: maintainer,
            duo_workflow_service_url: duo_workflow_service_url,
            duo_config: duo_config,
            unmask_env_variables: [:var1, :var2, :var3]
          )
        end

        it 'wraps executor command with sandbox' do
          allow(Ci::Workloads::RunWorkloadService).to receive(:new).and_call_original

          expect(execute).to be_success

          expect(sandbox).to have_received(:wrap_command).with(duo_cli_command)
          expect(Ci::Workloads::RunWorkloadService).to have_received(:new) do |workload_definition:, **_kwargs|
            commands = workload_definition.commands
            expect(commands).to include(*wrapped_commands)
          end
        end

        it 'includes sandbox environment variables' do
          allow(Ci::Workloads::RunWorkloadService).to receive(:new).and_call_original

          expect(execute).to be_success

          expect(sandbox).to have_received(:environment_variables)
          expect(Ci::Workloads::RunWorkloadService).to have_received(:new) do |workload_definition:, **_kwargs|
            variables = workload_definition.variables
            expect(variables[:NPM_CONFIG_CACHE]).to eq("/tmp/.npm-cache")
            expect(variables[:GITLAB_LSP_STORAGE_DIR]).to eq("/tmp")
          end
        end

        it 'combines setup_sandbox_commands, setup_script, main commands, CLI install, and wrapped executor commands' do
          allow(duo_config).to receive(:setup_script).and_return(['npm install'])
          allow(Ci::Workloads::RunWorkloadService).to receive(:new).and_call_original

          expect(execute).to be_success

          # setup_sandbox_commands
          expect(Ci::Workloads::RunWorkloadService).to have_received(:new) do |workload_definition:, **_kwargs|
            commands = workload_definition.commands
            expect(commands[0]).to eq(sandbox_setup_commands[0])
            expect(commands[1]).to eq('npm install')
            expect(commands[2..11]).to eq(shared_main_commands)
            expect(commands[12..15]).to eq(cli_install_commands)
            expect(commands[16..22]).to eq(glab_setup_commands)
            expect(commands[23..]).to eq(wrapped_commands)
            expect(workload_definition.image).to eq(expected_image)
          end
        end

        it 'inserts orbit commands between glab setup and wrapped commands when orbit is enabled',
          :aggregate_failures do
          orbit_cmds = %w[__orbit_install__ __orbit_index__]
          allow(orbit_local_setup).to receive(:commands).and_return(orbit_cmds)
          allow(duo_config).to receive(:setup_script).and_return(['npm install'])
          allow(Ci::Workloads::RunWorkloadService).to receive(:new).and_call_original

          expect(execute).to be_success

          expect(Ci::Workloads::RunWorkloadService).to have_received(:new) do |workload_definition:, **_kwargs|
            commands = workload_definition.commands
            glab_end = commands.index(glab_setup_commands.last)
            orbit_start = commands.index(orbit_cmds.first)
            wrapped_start = commands.index(wrapped_commands.first)

            expect(orbit_start).to eq(glab_end + 1)
            expect(wrapped_start).to eq(orbit_start + orbit_cmds.size)
          end
        end
      end

      context 'when sandbox is enabled with no custom image' do
        let(:image) { nil }
        let(:expected_image) { "registry.gitlab.com/#{described_class::HARDENED_IMAGE_PATH}" }

        it_behaves_like 'sandbox enabled behavior'

        context 'when duo_workflow_use_hardened_image feature flag is disabled' do
          let(:expected_image) { "registry.gitlab.com/#{described_class::IMAGE_PATH}" }

          before do
            stub_feature_flags(duo_workflow_use_hardened_image: false)
          end

          it_behaves_like 'sandbox enabled behavior'
        end
      end

      context 'when sandbox is enabled with custom image' do
        let(:image) { "custom-image:latest" }
        let(:expected_image) { "custom-image:latest" }

        include_examples 'sandbox enabled behavior'
      end
    end

    context 'when orbit local setup is enabled' do
      let(:orbit_commands) { %w[__orbit_install__ __orbit_index__] }

      before do
        allow(duo_config).to receive_messages(setup_script: nil, valid_format?: true)
        allow(orbit_local_setup).to receive(:commands).and_return(orbit_commands)
        allow(Ci::Workloads::RunWorkloadService).to receive(:new).and_call_original
      end

      it 'includes orbit commands between glab setup and wrapped commands', :aggregate_failures do
        expect(execute).to be_success

        expect(Ci::Workloads::RunWorkloadService).to have_received(:new) do |workload_definition:, **_kwargs|
          commands = workload_definition.commands
          glab_end = commands.index(glab_setup_commands.last)
          orbit_start = commands.index(orbit_commands.first)
          wrapped_start = commands.index(wrapped_commands.first)

          expect(orbit_start).to eq(glab_end + 1)
          expect(wrapped_start).to eq(orbit_start + orbit_commands.size)
        end
      end
    end

    context 'when orbit local setup is disabled' do
      before do
        allow(duo_config).to receive_messages(setup_script: nil, valid_format?: true)
        allow(orbit_local_setup).to receive(:commands).and_return([])
        allow(Ci::Workloads::RunWorkloadService).to receive(:new).and_call_original
      end

      it 'does not include orbit commands' do
        expect(execute).to be_success

        expect(Ci::Workloads::RunWorkloadService).to have_received(:new) do |workload_definition:, **_kwargs|
          commands = workload_definition.commands
          expect(commands).not_to include('__orbit_install__')
        end
      end
    end
  end

  context 'with cache configuration' do
    let(:duo_config) { instance_double(::Gitlab::DuoAgentPlatform::Config) }

    before do
      allow(::Gitlab::Llm::StageCheck).to receive(:available?).with(project, :duo_workflow).and_return(true)
      allow(maintainer).to receive(:allowed_to_use?).and_return(true)
      project.project_setting.update!(duo_features_enabled: true, duo_remote_flows_enabled: true)
      allow(::Gitlab::DuoAgentPlatform::Config).to receive(:new).with(project).and_return(duo_config)
      allow(duo_config).to receive_messages(
        config_present?: true,
        default_image: nil,
        setup_script: nil,
        network_policy: nil
      )
    end

    context 'when cache config with file-based key is present' do
      let(:cache_config) do
        {
          'key' => { 'files' => ['package.json', 'package-lock.json'] },
          'paths' => ['node_modules', '.npm']
        }
      end

      before do
        allow(duo_config).to receive_messages(cache_config: cache_config, valid_format?: true)
      end

      it 'passes cache configuration to workload definition' do
        expect(Ci::Workloads::RunWorkloadService).to receive(:new) do |workload_definition:, **_kwargs|
          expect(workload_definition.cache).to eq(cache_config)
        end.and_call_original

        expect(execute).to be_success
      end
    end

    context 'when cache config with string key is present' do
      let(:cache_config) do
        {
          'key' => 'my-cache-key',
          'paths' => ['vendor/bundle']
        }
      end

      before do
        allow(duo_config).to receive_messages(cache_config: cache_config, valid_format?: true)
      end

      it 'passes cache configuration to workload definition' do
        expect(Ci::Workloads::RunWorkloadService).to receive(:new) do |workload_definition:, **_kwargs|
          expect(workload_definition.cache).to eq(cache_config)
        end.and_call_original

        expect(execute).to be_success
      end
    end

    context 'when cache config with file key and prefix is present' do
      let(:cache_config) do
        {
          'key' => {
            'files' => ['Gemfile.lock'],
            'prefix' => 'rspec'
          },
          'paths' => ['vendor/ruby']
        }
      end

      before do
        allow(duo_config).to receive_messages(cache_config: cache_config, valid_format?: true)
      end

      it 'passes cache configuration with prefix to workload definition' do
        expect(Ci::Workloads::RunWorkloadService).to receive(:new) do |workload_definition:, **_kwargs|
          expect(workload_definition.cache).to eq(cache_config)
        end.and_call_original

        expect(execute).to be_success
      end
    end

    context 'when cache config with only paths (no key) is present' do
      let(:cache_config) do
        {
          'paths' => ['node_modules']
        }
      end

      before do
        allow(duo_config).to receive_messages(cache_config: cache_config, valid_format?: true)
      end

      it 'passes cache configuration without key to workload definition' do
        expect(Ci::Workloads::RunWorkloadService).to receive(:new) do |workload_definition:, **_kwargs|
          expect(workload_definition.cache).to eq(cache_config)
        end.and_call_original

        expect(execute).to be_success
      end
    end

    context 'when cache config is not present' do
      before do
        allow(duo_config).to receive_messages(cache_config: nil, valid_format?: true)
      end

      it 'does not set cache on workload definition' do
        expect(Ci::Workloads::RunWorkloadService).to receive(:new) do |workload_definition:, **_kwargs|
          # Cache should not be set when config returns nil
          expect(workload_definition.cache).to be_nil
        end.and_call_original

        expect(execute).to be_success
      end
    end
  end

  context 'with both setup_script and cache configuration' do
    let(:duo_config) { instance_double(::Gitlab::DuoAgentPlatform::Config) }
    let(:setup_commands) { ['npm ci', 'npm test'] }
    let(:cache_config) do
      {
        'key' => {
          'files' => ['package.json'],
          'prefix' => 'test'
        },
        'paths' => ['node_modules']
      }
    end

    before do
      allow(::Gitlab::Llm::StageCheck).to receive(:available?).with(project, :duo_workflow).and_return(true)
      allow(maintainer).to receive(:allowed_to_use?).and_return(true)
      project.project_setting.update!(duo_features_enabled: true, duo_remote_flows_enabled: true)
      allow(::Gitlab::DuoAgentPlatform::Config).to receive(:new).with(project).and_return(duo_config)
      allow(duo_config).to receive_messages(
        config_present?: true,
        default_image: 'node:18',
        setup_script: setup_commands,
        cache_config: cache_config,
        network_policy: nil,
        valid_format?: true
      )
    end

    it 'includes both setup commands and cache configuration' do
      expect(Ci::Workloads::RunWorkloadService).to receive(:new) do |workload_definition:, **_kwargs|
        # Check setup commands are prepended
        commands = workload_definition.commands
        expect(commands[0]).to eq('npm ci')
        expect(commands[1]).to eq('npm test')
        expect(commands[2]).to eq('echo $DUO_WORKFLOW_DEFINITION')

        # Check cache is configured
        expect(workload_definition.cache).to eq(cache_config)

        # Check image is set
        expect(workload_definition.image).to eq('node:18')
      end.and_call_original

      expect(execute).to be_success
    end
  end

  context 'without agent configuration' do
    let(:duo_config) { instance_double(::Gitlab::DuoAgentPlatform::Config) }

    before do
      allow(::Gitlab::Llm::StageCheck).to receive(:available?).with(project, :duo_workflow).and_return(true)
      allow(maintainer).to receive(:allowed_to_use?).and_return(true)
      project.project_setting.update!(duo_features_enabled: true, duo_remote_flows_enabled: true)
      allow(::Gitlab::DuoAgentPlatform::Config).to receive(:new).with(project).and_return(duo_config)
      allow(duo_config).to receive_messages(
        config_present?: false,
        default_image: nil,
        setup_script: nil,
        cache_config: nil,
        network_policy: nil,
        valid_format?: false
      )
    end

    it 'uses defaults and does not set cache or setup commands' do
      expect(Ci::Workloads::RunWorkloadService).to receive(:new) do |workload_definition:, **_kwargs|
        # Should use default or workflow image
        expect(workload_definition.image).to eq(image)

        # Should not have setup commands prepended
        commands = workload_definition.commands
        expect(commands.first).to eq('echo $DUO_WORKFLOW_DEFINITION')
        expect(commands.size).to eq(8)

        # Should not have cache
        expect(workload_definition.cache).to be_nil
      end.and_call_original

      expect(execute).to be_success
    end
  end

  context 'with priority ordering for all features' do
    let(:duo_config) { instance_double(::Gitlab::DuoAgentPlatform::Config) }
    let(:workflow_image) { 'workflow-priority:latest' }
    let(:config_image) { 'config-priority:latest' }

    before do
      allow(::Gitlab::Llm::StageCheck).to receive(:available?).with(project, :duo_workflow).and_return(true)
      allow(maintainer).to receive(:allowed_to_use?).and_return(true)
      project.project_setting.update!(duo_features_enabled: true, duo_remote_flows_enabled: true)
      allow(::Gitlab::DuoAgentPlatform::Config).to receive(:new).with(project).and_return(duo_config)
    end

    context 'when workflow has image and config has all features' do
      let(:image) { workflow_image }

      before do
        allow(duo_config).to receive_messages(
          config_present?: true,
          default_image: config_image,
          setup_script: ['echo "from config"'],
          cache_config: { 'paths' => ['test'] },
          network_policy: {
            'allowed_domains' => ['*.gitlab.com'],
            'denied_domains' => ['example.gitlab.com']
          },
          valid_format?: true
        )
      end

      it 'uses workflow image but config setup_script and cache' do
        expect(Ci::Workloads::RunWorkloadService).to receive(:new) do |workload_definition:, **_kwargs|
          # Workflow image takes priority
          expect(workload_definition.image).to eq(workflow_image)

          # But setup_script from config is used
          expect(workload_definition.commands.first).to eq('echo "from config"')

          # And cache from config is used
          expect(workload_definition.cache).to eq({ 'paths' => ['test'] })
        end.and_call_original

        expect(execute).to be_success
      end
    end
  end

  describe 'LOG_LEVEL variable' do
    before do
      allow(::Gitlab::Llm::StageCheck).to receive(:available?).with(project, :duo_workflow).and_return(true)
      project.project_setting.update!(duo_features_enabled: true, duo_remote_flows_enabled: true)
      allow(maintainer).to receive(:allowed_to_use?).and_return(true)
    end

    it 'sets LOG_LEVEL to debug' do
      allow(Ci::Workloads::RunWorkloadService).to receive(:new).and_call_original

      expect(execute).to be_success

      expect(Ci::Workloads::RunWorkloadService).to have_received(:new) do |workload_definition:, **_kwargs|
        expect(workload_definition.variables[:LOG_LEVEL]).to eq('debug')
      end
    end
  end

  describe 'GLAB_CHECK_UPDATE variable' do
    before do
      allow(::Gitlab::Llm::StageCheck).to receive(:available?).with(project, :duo_workflow).and_return(true)
      project.project_setting.update!(duo_features_enabled: true, duo_remote_flows_enabled: true)
      allow(maintainer).to receive(:allowed_to_use?).and_return(true)
    end

    it "sets GLAB_CHECK_UPDATE to '0' to suppress glab's update nudge", :aggregate_failures do
      allow(Ci::Workloads::RunWorkloadService).to receive(:new).and_call_original

      expect(execute).to be_success

      expect(Ci::Workloads::RunWorkloadService).to have_received(:new) do |workload_definition:, **_kwargs|
        expect(workload_definition.variables[:GLAB_CHECK_UPDATE]).to eq('0')
      end
    end
  end

  describe 'git environment variables' do
    before do
      allow(::Gitlab::Llm::StageCheck).to receive(:available?).with(project, :duo_workflow).and_return(true)
      project.project_setting.update!(duo_features_enabled: true, duo_remote_flows_enabled: true)
      allow(maintainer).to receive(:allowed_to_use?).and_return(true)
      workflow.update!(user: maintainer)
    end

    it 'sets git security hardening variables' do
      expect(Ci::Workloads::RunWorkloadService)
        .to receive(:new).and_wrap_original do |method, **kwargs|
        variables = kwargs[:workload_definition].variables

        expect(variables[:GIT_TERMINAL_PROMPT]).to eq('0')
        expect(variables[:GIT_CONFIG_NOSYSTEM]).to eq('1')
        expect(variables[:GIT_CONFIG_GLOBAL]).to eq('/dev/null')
        method.call(**kwargs)
      end

      expect(execute).to be_success
    end

    it 'sets GIT_PASSWORD to the OAuth token' do
      expect(Ci::Workloads::RunWorkloadService)
        .to receive(:new).and_wrap_original do |method, **kwargs|
        variables = kwargs[:workload_definition].variables

        expect(variables[:GIT_PASSWORD]).to eq('test-oauth-token')
        method.call(**kwargs)
      end

      expect(execute).to be_success
    end

    it 'sets git config variables for safe directory and URL rewriting' do
      expect(Ci::Workloads::RunWorkloadService)
        .to receive(:new).and_wrap_original do |method, **kwargs|
        variables = kwargs[:workload_definition].variables

        expect(variables[:GIT_CONFIG_COUNT]).to eq('2')
        expect(variables[:GIT_CONFIG_KEY_0]).to eq('safe.directory')
        expect(variables[:GIT_CONFIG_VALUE_0]).to eq('/builds/*')
        expect(variables[:GIT_CONFIG_KEY_1]).to start_with('url.')
        expect(variables[:GIT_CONFIG_KEY_1]).to end_with('.insteadOf')
        expect(variables).not_to have_key(:GIT_CONFIG_KEY_2)
        method.call(**kwargs)
      end

      expect(execute).to be_success
    end

    context 'when workload user has commit_email' do
      before do
        allow(maintainer).to receive_messages(
          commit_email: 'commit@example.com'
        )
      end

      it 'uses the commit_email for GIT_COMMITTER_EMAIL' do
        expect(Ci::Workloads::RunWorkloadService)
          .to receive(:new).and_wrap_original do |method, **kwargs|
          variables = kwargs[:workload_definition].variables

          expect(variables[:GIT_COMMITTER_EMAIL]).to eq('commit@example.com')
          method.call(**kwargs)
        end

        expect(execute).to be_success
      end
    end

    context 'when workload user has no commit_email' do
      before do
        allow(maintainer).to receive_messages(
          commit_email: nil,
          email: "email@example.com"
        )
      end

      it 'uses the email for GIT_COMMITTER_EMAIL' do
        expect(Ci::Workloads::RunWorkloadService)
          .to receive(:new).and_wrap_original do |method, **kwargs|
          variables = kwargs[:workload_definition].variables

          expect(variables[:GIT_COMMITTER_EMAIL]).to eq('email@example.com')
          method.call(**kwargs)
        end

        expect(execute).to be_success
      end
    end

    context 'when workload user does not respond to commit_email_or_default' do
      before do
        allow(maintainer).to receive(:respond_to?).and_call_original
        allow(maintainer).to receive(:respond_to?).with(:commit_email_or_default).and_return(false)
      end

      it 'sets GIT_COMMITTER_EMAIL to empty string' do
        expect(Ci::Workloads::RunWorkloadService)
          .to receive(:new).and_wrap_original do |method, **kwargs|
          variables = kwargs[:workload_definition].variables

          expect(variables[:GIT_COMMITTER_EMAIL]).to eq("")
          method.call(**kwargs)
        end

        expect(execute).to be_success
      end
    end

    context 'when workload user has name' do
      before do
        allow(maintainer).to receive_messages(name: 'Some User')
      end

      it 'uses that name for GIT_COMMITTER_NAME' do
        expect(Ci::Workloads::RunWorkloadService)
          .to receive(:new).and_wrap_original do |method, **kwargs|
          variables = kwargs[:workload_definition].variables

          expect(variables[:GIT_COMMITTER_NAME]).to eq('Some User')
          method.call(**kwargs)
        end

        expect(execute).to be_success
      end
    end

    context 'when workload user does not respond to name' do
      before do
        allow(maintainer).to receive(:respond_to?).and_call_original
        allow(maintainer).to receive(:respond_to?).with(:name).and_return(false)
      end

      it 'sets GIT_COMMITTER_NAME to empty string' do
        expect(Ci::Workloads::RunWorkloadService)
          .to receive(:new).and_wrap_original do |method, **kwargs|
          variables = kwargs[:workload_definition].variables

          expect(variables[:GIT_COMMITTER_NAME]).to eq("")
          method.call(**kwargs)
        end

        expect(execute).to be_success
      end
    end
  end

  context 'when shallow_clone is not set', :aggregate_failures do
    include_context 'with Duo enabled'

    context 'when dap_git_tree_zero_option is enabled' do
      before do
        stub_feature_flags(dap_git_tree_zero_option: true)
      end

      it 'does not set GIT_DEPTH' do
        expect(Ci::Workloads::RunWorkloadService).to receive(:new).and_wrap_original do |method, **kwargs|
          variables = kwargs[:workload_definition].variables

          expect(variables).not_to have_key(:GIT_DEPTH)

          method.call(**kwargs)
        end

        expect(execute).to be_success
      end
    end

    context 'when dap_git_tree_zero_option is disabled' do
      before do
        stub_feature_flags(dap_git_tree_zero_option: false)
      end

      it 'sets GIT_DEPTH to 1' do
        expect(Ci::Workloads::RunWorkloadService).to receive(:new).and_wrap_original do |method, **kwargs|
          variables = kwargs[:workload_definition].variables

          expect(variables[:GIT_DEPTH]).to eq(1)

          method.call(**kwargs)
        end

        expect(execute).to be_success
      end
    end
  end

  context 'when shallow_clone is true', :aggregate_failures do
    include_context 'with Duo enabled'

    let(:params) do
      super().merge(shallow_clone: true)
    end

    it 'sets GIT_DEPTH to 1' do
      expect(Ci::Workloads::RunWorkloadService).to receive(:new).and_wrap_original do |method, **kwargs|
        workload_definition = kwargs[:workload_definition]
        variables = workload_definition.variables

        expect(variables[:GIT_DEPTH]).to eq(1)

        method.call(**kwargs)
      end

      expect(execute).to be_success
    end
  end

  context 'when shallow_clone is false', :aggregate_failures do
    include_context 'with Duo enabled'

    let(:params) do
      super().merge(shallow_clone: false)
    end

    it 'does not set GIT_DEPTH' do
      expect(Ci::Workloads::RunWorkloadService).to receive(:new).and_wrap_original do |method, **kwargs|
        workload_definition = kwargs[:workload_definition]
        variables = workload_definition.variables

        expect(variables).not_to have_key(:GIT_DEPTH)

        method.call(**kwargs)
      end

      expect(execute).to be_success
    end
  end

  context 'with Git LFS skip configuration', :aggregate_failures do
    include_context 'with Duo enabled'

    it 'sets GIT_LFS_SKIP_SMUDGE to skip LFS smudging during clone' do
      expect(Ci::Workloads::RunWorkloadService).to receive(:new).and_wrap_original do |method, **kwargs|
        workload_definition = kwargs[:workload_definition]
        variables = workload_definition.variables

        expect(variables[:GIT_LFS_SKIP_SMUDGE]).to eq(1)

        method.call(**kwargs)
      end

      expect(execute).to be_success
    end

    context 'when dap_git_tree_zero_option feature flag is disabled' do
      before do
        stub_feature_flags(dap_git_tree_zero_option: false)
      end

      it 'sets GIT_FETCH_EXTRA_FLAGS to --filter=blob:none' do
        expect(Ci::Workloads::RunWorkloadService).to receive(:new).and_wrap_original do |method, **kwargs|
          workload_definition = kwargs[:workload_definition]
          variables = workload_definition.variables

          expect(variables[:GIT_FETCH_EXTRA_FLAGS]).to eq('--filter=blob:none')

          method.call(**kwargs)
        end

        expect(execute).to be_success
      end
    end

    context 'when dap_git_tree_zero_option feature flag is enabled' do
      before do
        stub_feature_flags(dap_git_tree_zero_option: true)
      end

      it 'sets GIT_FETCH_EXTRA_FLAGS to --filter=tree:0' do
        expect(Ci::Workloads::RunWorkloadService).to receive(:new).and_wrap_original do |method, **kwargs|
          workload_definition = kwargs[:workload_definition]
          variables = workload_definition.variables

          expect(variables[:GIT_FETCH_EXTRA_FLAGS]).to eq('--filter=tree:0')

          method.call(**kwargs)
        end

        expect(execute).to be_success
      end
    end
  end

  context 'when workflows_workload join table fails to create' do
    include_context 'with Duo enabled'

    it 'returns an error' do
      invalid_instance = ::Ai::DuoWorkflows::WorkflowsWorkload.new
      invalid_instance.valid?
      # Nasty hack since there is no easy way to stub workflow.workflows_workloads.create
      expect_next_instance_of(::Ai::DuoWorkflows::WorkflowsWorkload) do |instance|
        allow(instance).to receive_messages(
          persisted?: false,
          errors: invalid_instance.errors
        )
      end
      result = execute
      expect(result).to be_error
      expect(result.reason).to eq(:workflow_workload_failure)
    end
  end

  describe 'DUO_WORKFLOW_GOAL' do
    before do
      stub_licensed_features(ai_workflows: true)
      allow(::Gitlab::Llm::StageCheck).to receive(:available?).with(project, :duo_workflow).and_return(true)
      allow(maintainer).to receive(:allowed_to_use?).and_return(true)
      project.project_setting.update!(duo_features_enabled: true, duo_remote_flows_enabled: true)
    end

    it 'sets DUO_WORKFLOW_GOAL to the goal param without modification' do
      expect(Ci::Workloads::RunWorkloadService)
        .to receive(:new).and_wrap_original do |method, **kwargs|
        variables = kwargs[:workload_definition].variables
        expect(variables[:DUO_WORKFLOW_GOAL]).to eq('test-goal')
        method.call(**kwargs)
      end

      expect(execute).to be_success
    end

    context 'when dap_session_tracking_enabled is true' do
      before do
        project.project_setting.update!(dap_session_tracking_enabled: true)
      end

      it 'still sets DUO_WORKFLOW_GOAL to the goal param without modification' do
        expect(Ci::Workloads::RunWorkloadService)
          .to receive(:new).and_wrap_original do |method, **kwargs|
          variables = kwargs[:workload_definition].variables
          expect(variables[:DUO_WORKFLOW_GOAL]).to eq('test-goal')
          method.call(**kwargs)
        end

        expect(execute).to be_success
      end
    end
  end

  describe 'git commit trailer hooks' do
    before do
      stub_licensed_features(ai_workflows: true)
      allow(::Gitlab::Llm::StageCheck).to receive(:available?).with(project, :duo_workflow).and_return(true)
      allow(maintainer).to receive(:allowed_to_use?).and_return(true)
      project.project_setting.update!(duo_features_enabled: true, duo_remote_flows_enabled: true)
    end

    context 'when dap_session_tracking_enabled is true' do
      before do
        project.project_setting.update!(dap_session_tracking_enabled: true)
      end

      it 'installs a commit-msg hook in GIT_HOOKS_DIR', :aggregate_failures do
        expect(Ci::Workloads::RunWorkloadService)
          .to receive(:new).and_wrap_original do |method, **kwargs|
          commands = kwargs[:workload_definition].commands
          hooks_dir = described_class::GIT_HOOKS_DIR

          expect(commands).to include("mkdir -p #{hooks_dir}")
          expect(commands).to include(a_string_matching(/commit-msg/))
          expect(commands).to include("chmod +x #{hooks_dir}/commit-msg")
          method.call(**kwargs)
        end

        expect(execute).to be_success
      end

      it 'writes a hook that appends the Duo session trailers via git interpret-trailers', :aggregate_failures do
        expect(Ci::Workloads::RunWorkloadService)
          .to receive(:new).and_wrap_original do |method, **kwargs|
          commands = kwargs[:workload_definition].commands
          hook_write_cmd = commands.find { |c| c.include?('commit-msg') && c.include?('printf') }
          failure_msg = "expected a printf command writing commit-msg hook, got: #{commands.inspect}"
          expect(hook_write_cmd).to be_present, failure_msg

          # The trailer values are double-shell-escaped: once as --trailer args,
          # then again when the whole hook script is embedded in the printf command.
          expect(hook_write_cmd).to include('interpret-trailers')
          expect(hook_write_cmd).to include('addIfDifferent')
          double_escaped_coauthor = Shellwords.escape(Shellwords.escape('Co-authored-by: GitLab Duo <duo@gitlab.com>'))
          expect(hook_write_cmd).to include(double_escaped_coauthor)
          expect(hook_write_cmd).to include(workflow.web_url)
          method.call(**kwargs)
        end

        expect(execute).to be_success
      end

      it 'sets core.hooksPath via GIT_CONFIG to point to GIT_HOOKS_DIR', :aggregate_failures do
        expect(Ci::Workloads::RunWorkloadService)
          .to receive(:new).and_wrap_original do |method, **kwargs|
          variables = kwargs[:workload_definition].variables
          hooks_dir = described_class::GIT_HOOKS_DIR

          expect(variables[:GIT_CONFIG_COUNT]).to eq('3')
          expect(variables[:GIT_CONFIG_KEY_2]).to eq('core.hooksPath')
          expect(variables[:GIT_CONFIG_VALUE_2]).to eq(hooks_dir)
          method.call(**kwargs)
        end

        expect(execute).to be_success
      end

      it 'places hook setup commands after sandbox setup and before setup_script commands', :aggregate_failures do
        expect(Ci::Workloads::RunWorkloadService)
          .to receive(:new).and_wrap_original do |method, **kwargs|
          commands = kwargs[:workload_definition].commands
          hooks_dir = described_class::GIT_HOOKS_DIR
          sandbox_cmd_idx = commands.index("mkdir -p #{::Gitlab::DuoWorkflow::Sandbox::SANDBOX_SYSTEM_DIR}")
          hook_mkdir_idx = commands.index("mkdir -p #{hooks_dir}")

          expect(sandbox_cmd_idx).not_to be_nil
          expect(hook_mkdir_idx).not_to be_nil
          expect(hook_mkdir_idx).to be > sandbox_cmd_idx
          method.call(**kwargs)
        end

        expect(execute).to be_success
      end
    end

    context 'when dap_session_tracking_enabled is false' do
      before do
        project.project_setting.update!(dap_session_tracking_enabled: false)
      end

      it 'does not install a commit-msg hook', :aggregate_failures do
        expect(Ci::Workloads::RunWorkloadService)
          .to receive(:new).and_wrap_original do |method, **kwargs|
          commands = kwargs[:workload_definition].commands
          hooks_dir = described_class::GIT_HOOKS_DIR

          expect(commands).not_to include("mkdir -p #{hooks_dir}")
          expect(commands).not_to include("chmod +x #{hooks_dir}/commit-msg")
          method.call(**kwargs)
        end

        expect(execute).to be_success
      end

      it 'does not set core.hooksPath in GIT_CONFIG', :aggregate_failures do
        expect(Ci::Workloads::RunWorkloadService)
          .to receive(:new).and_wrap_original do |method, **kwargs|
          variables = kwargs[:workload_definition].variables

          expect(variables[:GIT_CONFIG_COUNT]).to eq('2')
          expect(variables).not_to have_key(:GIT_CONFIG_KEY_2)
          method.call(**kwargs)
        end

        expect(execute).to be_success
      end
    end
  end

  describe 'DUO_SESSION_TRACKING_ENABLED variable' do
    using RSpec::Parameterized::TableSyntax

    where(:setting_value, :expected_env_value) do
      true  | 'true'
      false | 'false'
    end

    with_them do
      before do
        stub_licensed_features(ai_workflows: true)

        allow(::Gitlab::Llm::StageCheck).to receive(:available?).with(project, :duo_workflow).and_return(true)
        allow(maintainer).to receive(:allowed_to_use?).and_return(true)
        project.project_setting.update!(
          duo_features_enabled: true,
          duo_remote_flows_enabled: true,
          dap_session_tracking_enabled: setting_value
        )
      end

      it 'sets DUO_SESSION_TRACKING_ENABLED to the expected value' do
        expect(Ci::Workloads::RunWorkloadService)
          .to receive(:new).and_wrap_original do |method, **kwargs|
          variables = kwargs[:workload_definition].variables
          expect(variables[:DUO_SESSION_TRACKING_ENABLED]).to eq(expected_env_value)
          method.call(**kwargs)
        end

        expect(execute).to be_success
      end
    end
  end

  describe '#instance_image' do
    subject(:instance_image) { service.send(:instance_image) }

    let(:service) { described_class.new(workflow: workflow, params: params) }

    context 'when no setting is configured' do
      it 'returns the hardened image from registry.gitlab.com' do
        expect(instance_image).to eq(
          "registry.gitlab.com/#{described_class::HARDENED_IMAGE_PATH}"
        )
      end

      context 'when duo_workflow_use_hardened_image feature flag is disabled' do
        before do
          stub_feature_flags(duo_workflow_use_hardened_image: false)
        end

        it 'returns the default image from registry.gitlab.com' do
          expect(instance_image).to eq(
            "registry.gitlab.com/#{described_class::IMAGE_PATH}"
          )
        end
      end
    end

    context 'when duo_workflows_default_image_registry setting is configured' do
      before do
        stub_application_setting(duo_workflows_default_image_registry: 'instance-registry.example.com')
      end

      it 'uses the configured registry' do
        expect(instance_image).to eq(
          "instance-registry.example.com/#{described_class::HARDENED_IMAGE_PATH}"
        )
      end
    end

    context 'when registry includes port number' do
      before do
        stub_application_setting(duo_workflows_default_image_registry: 'registry.example.com:8080')
      end

      it 'preserves the port number in the image URL' do
        expect(instance_image).to eq(
          "registry.example.com:8080/#{described_class::HARDENED_IMAGE_PATH}"
        )
      end
    end

    context 'when registry is set to default value' do
      before do
        stub_application_setting(duo_workflows_default_image_registry: 'registry.gitlab.com')
      end

      it 'returns the hardened image from registry.gitlab.com' do
        expect(instance_image).to eq(
          "registry.gitlab.com/#{described_class::HARDENED_IMAGE_PATH}"
        )
      end
    end

    context 'when registry is set to empty string' do
      before do
        stub_application_setting(duo_workflows_default_image_registry: '')
      end

      it 'falls back to the default registry' do
        expect(instance_image).to eq("registry.gitlab.com/#{described_class::HARDENED_IMAGE_PATH}")
      end
    end

    context 'when registry already includes a path' do
      before do
        stub_application_setting(
          duo_workflows_default_image_registry: 'registry.example.com/my-org/my-image:v1.0'
        )
      end

      it 'uses the registry value as-is without appending IMAGE_PATH' do
        expect(instance_image).to eq('registry.example.com/my-org/my-image:v1.0')
      end
    end

    context 'when registry includes a path without a tag' do
      before do
        stub_application_setting(
          duo_workflows_default_image_registry: 'registry.example.com/my-org/my-image'
        )
      end

      it 'uses the registry value as-is without appending IMAGE_PATH' do
        expect(instance_image).to eq('registry.example.com/my-org/my-image')
      end
    end

    context 'when registry is only a hostname (no path)' do
      before do
        stub_application_setting(duo_workflows_default_image_registry: 'registry.example.com')
      end

      it 'appends the image path to the hostname' do
        expect(instance_image).to eq("registry.example.com/#{described_class::HARDENED_IMAGE_PATH}")
      end
    end
  end
end
