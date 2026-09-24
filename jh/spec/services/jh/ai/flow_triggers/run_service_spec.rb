# frozen_string_literal: true

require 'spec_helper'

RSpec.describe ::Ai::FlowTriggers::RunService, feature_category: :duo_agent_platform do
  let_it_be(:group) { create(:group) }
  let_it_be(:project) { create(:project, :small_repo, group: group) }
  let_it_be(:current_user) { create(:user, maintainer_of: project) }
  let_it_be(:service_account) { create(:service_account, maintainer_of: project) }
  let_it_be(:resource) { create(:issue, project: project) }
  let_it_be(:flow_trigger) do
    create(:ai_flow_trigger, project: project, user: service_account, config_path: '.gitlab/duo/flow.yml')
  end

  let(:params) { { input: 'test input', event: :assign } }
  let(:inject_gateway_token) { true }
  let(:flow_definition) do
    {
      'image' => 'ruby:3.0',
      'commands' => ['echo "Hello World"'],
      'injectGatewayToken' => inject_gateway_token
    }.to_yaml
  end

  let(:service) do
    described_class.new(project: project, current_user: current_user, resource: resource, flow_trigger: flow_trigger)
  end

  before do
    project.project_setting.update!(duo_features_enabled: true, duo_remote_flows_enabled: true)
    allow(project.repository).to receive(:blob_data_at).and_return(nil)
    allow(project.repository).to receive(:blob_data_at)
      .with(project.default_branch, flow_trigger.config_path).and_return(flow_definition)
    allow(::Gitlab::Llm::StageCheck).to receive(:available?).and_return(true)
    allow(::Ability).to receive(:allowed?).and_return(true)
    allow(current_user).to receive(:allowed_to_use?).and_return(true)
    allow(::Gitlab::Llm::Chain::Utils::ChatAuthorizer).to receive(:resource).and_return(
      instance_double(::Gitlab::Llm::Utils::Authorizer::Response, allowed?: true)
    )
    allow_next_instance_of(::Ai::UsageQuotaService) do |quota_service|
      allow(quota_service).to receive(:execute).and_return(ServiceResponse.success)
    end
    allow_next_instance_of(::Ai::ThirdPartyAgents::TokenService) do |token_service|
      allow(token_service).to receive(:direct_access_token).and_return(
        ServiceResponse.success(payload: { token: 'gateway-token', headers: { 'Content-Type' => 'application/json' } })
      )
    end
    allow(::Ai::ModelSelection::ModelDefinitions).to receive(:fetch).and_return(
      ::Ai::ModelSelection::ModelDefinitions.new(ServiceResponse.success(payload: nil))
    )
  end

  describe '#execute' do
    context 'with an external agent that opts into the project image' do
      let(:flow_definition) { YAML.safe_load(super()).merge('useAgentConfigImage' => true).to_yaml }
      let(:agent_config) { { 'image' => 'registry.example.com/wiki-agent:1.0' }.to_yaml }
      let(:catalog_item) do
        create(:ai_catalog_third_party_flow, :public, project: project,
          latest_version: create(:ai_catalog_item_version, :for_third_party_flow,
            definition: YAML.safe_load(flow_definition)))
      end

      let(:flow_trigger) do
        parent = build(:ai_catalog_item_consumer, :for_third_party_flow,
          item: catalog_item, service_account: service_account, group: group)
        consumer = create(:ai_catalog_item_consumer, :child_item_consumer,
          item: catalog_item, project: project, parent_item_consumer: parent, pinned_version_prefix: nil)

        create(:ai_flow_trigger, :for_catalog_consumer, project: project, ai_catalog_item_consumer: consumer)
      end

      before do
        allow(project.repository).to receive(:blob_data_at)
          .with(project.default_branch, ::Gitlab::DuoAgentPlatform::Config::CONFIG_FILE_NAME).and_return(agent_config)
      end

      shared_examples 'uses the expected agent image' do
        it 'selects the workload image without changing the stored agent definition', :aggregate_failures do
          expect(::Ci::Workloads::RunWorkloadService).to receive(:new).and_wrap_original do |original, kwargs|
            expect(kwargs[:workload_definition].image).to eq(expected_image)
            expect(kwargs[:workload_definition].commands).to eq(['echo "Hello World"'])
            original.call(**kwargs)
          end

          expect(service.execute(params)).to be_success
          expect(catalog_item.latest_version.reload.definition).to eq(YAML.safe_load(flow_definition))
        end
      end

      context 'when the project config specifies an image' do
        let(:expected_image) { 'registry.example.com/wiki-agent:1.0' }

        it_behaves_like 'uses the expected agent image'
      end

      context 'when a candidate agent configuration uses an image' do
        let(:expected_image) { 'registry.example.com/wiki-agent:candidate' }

        before do
          allow(project.repository).to receive(:blob_data_at)
            .with(project.default_branch, ::Gitlab::DuoAgentPlatform::Config::CANDIDATE_CONFIG_FILE_NAME)
            .and_return({ 'image' => expected_image }.to_yaml)
        end

        it_behaves_like 'uses the expected agent image'
      end

      context 'when the project config is absent' do
        let(:agent_config) { nil }
        let(:expected_image) { 'ruby:3.0' }

        it_behaves_like 'uses the expected agent image'
      end

      context 'when the project config does not specify an image' do
        let(:agent_config) { { 'setup_script' => 'echo setup' }.to_yaml }
        let(:expected_image) { 'ruby:3.0' }

        it_behaves_like 'uses the expected agent image'
      end

      context 'when the project config is empty' do
        let(:agent_config) { '' }
        let(:expected_image) { 'ruby:3.0' }

        it_behaves_like 'uses the expected agent image'
      end

      context 'when the project config has an invalid image type' do
        let(:agent_config) { { 'image' => ['invalid'] }.to_yaml }

        it 'reports the invalid config without starting a workload', :aggregate_failures do
          expect(::Ci::Workloads::RunWorkloadService).not_to receive(:new)

          response = service.execute(params)

          expect(response).to be_error
          expect(response.message).to include('Invalid config file .gitlab/duo/agent-config.yml', 'image')
        end
      end

      shared_examples 'does not read the project config' do
        it 'skips loading the project config' do
          expect(::Gitlab::DuoAgentPlatform::Config).not_to receive(:new)

          expect(service.execute(params)).to be_success
        end
      end

      context 'when the option is false' do
        let(:flow_definition) { YAML.safe_load(super()).merge('useAgentConfigImage' => false).to_yaml }
        let(:expected_image) { 'ruby:3.0' }

        it_behaves_like 'uses the expected agent image'
        it_behaves_like 'does not read the project config'
      end

      context 'when the option is absent' do
        let(:flow_definition) { YAML.safe_load(super()).except('useAgentConfigImage').to_yaml }
        let(:expected_image) { 'ruby:3.0' }

        it_behaves_like 'uses the expected agent image'
        it_behaves_like 'does not read the project config'
      end
    end

    context 'with an AI Gateway token' do
      before do
        stub_env('DEVELOPMENT_AI_GATEWAY_URL', nil)
        stub_application_setting(ai_gateway_url: nil)
        allow(::CloudConnector::Config).to receive(:base_url).and_return('https://cloud.jihulab.com')
      end

      shared_examples 'injects the gateway URL' do
        it 'provides the OpenAI-compatible endpoint without requiring CI/CD variables' do
          expect(::Ci::Workloads::RunWorkloadService).to receive(:new).and_wrap_original do |original, kwargs|
            expect(kwargs[:workload_definition].variables[:AI_GATEWAY_BASE_URL]).to eq(expected_url)
            expect(kwargs[:ci_variables_included]).to eq([])
            original.call(**kwargs)
          end

          expect(service.execute(params)).to be_success
        end
      end

      context 'with the cloud gateway' do
        let(:expected_url) { 'https://cloud.jihulab.com/ai/v1/proxy/openai/v1' }

        it_behaves_like 'injects the gateway URL'
      end

      context 'with a development gateway' do
        let(:expected_url) { 'http://localhost:5001/v1/proxy/openai/v1' }

        before do
          stub_env('DEVELOPMENT_AI_GATEWAY_URL', 'http://localhost:5001/')
        end

        it_behaves_like 'injects the gateway URL'
      end

      context 'with a self-hosted gateway' do
        let(:expected_url) { 'https://gateway.example.com/v1/proxy/openai/v1' }

        before do
          stub_application_setting(ai_gateway_url: 'https://gateway.example.com/')
          stub_env('DEVELOPMENT_AI_GATEWAY_URL', 'http://localhost:5001')
        end

        it_behaves_like 'injects the gateway URL'
      end
    end

    context 'with an Agents and flows model selection' do
      let(:selected_model_ref) { 'claude_sonnet_4_20250514' }

      shared_examples 'passes the configured model to the workload' do
        it 'adds the model reference without changing the agent configuration', :aggregate_failures do
          expect(::Ai::ModelSelection::ModelDefinitions).not_to receive(:fetch)
          expect(::Ci::Workloads::RunWorkloadService).to receive(:new).and_wrap_original do |original, kwargs|
            workload_definition = kwargs[:workload_definition]
            expect(workload_definition.image).to eq('ruby:3.0')
            expect(workload_definition.commands).to eq(['echo "Hello World"'])
            expect(workload_definition.variables).to include(
              AI_FLOW_MODEL_REF: selected_model_ref,
              AI_FLOW_AI_GATEWAY_TOKEN: 'gateway-token',
              AI_FLOW_AI_GATEWAY_HEADERS: 'Content-Type: application/json'
            )
            original.call(**kwargs)
          end

          expect(service.execute(params)).to be_success
        end
      end

      context 'on SaaS', :saas_gitlab_com_subscriptions do
        let!(:feature_setting) do
          create(:ai_namespace_feature_setting, namespace: group, feature: :duo_agent_platform,
            offered_model_ref: selected_model_ref)
        end

        it_behaves_like 'passes the configured model to the workload'
      end

      context 'on a cloud-connected self-managed instance' do
        let(:selected_model_ref) { 'claude-3-7-sonnet-20250219' }

        let!(:feature_setting) do
          create(:instance_model_selection_feature_setting, feature: :duo_agent_platform,
            offered_model_ref: selected_model_ref)
        end

        it_behaves_like 'passes the configured model to the workload'
      end

      context 'when using the GitLab default model' do
        let(:definitions) do
          {
            'unit_primitives' => [
              { 'feature_setting' => 'duo_agent_platform', 'default_model' => selected_model_ref },
              { 'feature_setting' => 'duo_agent_platform_agentic_chat', 'default_model' => 'different_model' }
            ]
          }
        end

        before do
          allow(::Ai::ModelSelection::ModelDefinitions).to receive(:fetch).with(current_user).and_return(
            ::Ai::ModelSelection::ModelDefinitions.new(ServiceResponse.success(payload: definitions))
          )
        end

        it 'resolves the current platform default instead of leaving the choice to the image' do
          expect(::Ci::Workloads::RunWorkloadService).to receive(:new).and_wrap_original do |original, kwargs|
            expect(kwargs[:workload_definition].variables[:AI_FLOW_MODEL_REF]).to eq(selected_model_ref)
            original.call(**kwargs)
          end

          expect(service.execute(params)).to be_success
        end

        context 'when model definitions are unavailable' do
          let(:definitions) { nil }

          it 'preserves existing external agents without injecting an empty reference' do
            expect(::Ci::Workloads::RunWorkloadService).to receive(:new).and_wrap_original do |original, kwargs|
              expect(kwargs[:workload_definition].variables).not_to have_key(:AI_FLOW_MODEL_REF)
              original.call(**kwargs)
            end

            expect(service.execute(params)).to be_success
          end
        end

        context 'on SaaS', :saas_gitlab_com_subscriptions do
          it 'passes the platform default for the project namespace' do
            expect(::Ci::Workloads::RunWorkloadService).to receive(:new).and_wrap_original do |original, kwargs|
              expect(kwargs[:workload_definition].variables[:AI_FLOW_MODEL_REF]).to eq(selected_model_ref)
              original.call(**kwargs)
            end

            expect(service.execute(params)).to be_success
          end
        end
      end

      context 'when there is no GitLab-managed model setting' do
        let(:setting) { nil }

        before do
          allow_next_instance_of(::Ai::FeatureSettingSelectionService) do |selection|
            allow(selection).to receive(:execute).and_return(ServiceResponse.success(payload: setting))
          end
        end

        shared_examples 'does not select a GitLab-managed model' do
          it 'preserves the external agent model configuration' do
            expect(::Ai::ModelSelection::ModelDefinitions).not_to receive(:fetch)
            expect(::Ci::Workloads::RunWorkloadService).to receive(:new).and_wrap_original do |original, kwargs|
              expect(kwargs[:workload_definition].variables).not_to have_key(:AI_FLOW_MODEL_REF)
              original.call(**kwargs)
            end

            expect(service.execute(params)).to be_success
          end
        end

        it_behaves_like 'does not select a GitLab-managed model'

        context 'when the feature is disabled' do
          let(:setting) { build_stubbed(:ai_feature_setting, feature: :duo_agent_platform, provider: :disabled) }

          it_behaves_like 'does not select a GitLab-managed model'
        end

        context 'when using a self-hosted model' do
          let(:setting) { build_stubbed(:ai_feature_setting, feature: :duo_agent_platform) }

          it_behaves_like 'does not select a GitLab-managed model'
        end
      end

      context 'when model selection cannot be resolved' do
        before do
          allow_next_instance_of(::Ai::FeatureSettingSelectionService) do |selection|
            allow(selection).to receive(:execute).and_return(ServiceResponse.error(message: 'Unavailable'))
          end
        end

        it 'does not inject a model reference' do
          expect(::Ci::Workloads::RunWorkloadService).to receive(:new).and_wrap_original do |original, kwargs|
            expect(kwargs[:workload_definition].variables).not_to have_key(:AI_FLOW_MODEL_REF)
            original.call(**kwargs)
          end

          expect(service.execute(params)).to be_success
        end
      end
    end

    context 'when injectGatewayToken is false' do
      let(:inject_gateway_token) { false }

      it 'does not resolve or inject a GitLab model or gateway URL' do
        expect(::Ai::FeatureSettingSelectionService).not_to receive(:new)
        expect(::Gitlab::AiGateway).not_to receive(:url)
        expect(::Ci::Workloads::RunWorkloadService).to receive(:new).and_wrap_original do |original, kwargs|
          expect(kwargs[:workload_definition].variables).not_to have_key(:AI_FLOW_MODEL_REF)
          expect(kwargs[:workload_definition].variables).not_to have_key(:AI_GATEWAY_BASE_URL)
          original.call(**kwargs)
        end

        expect(service.execute(params)).to be_success
      end
    end
  end
end
