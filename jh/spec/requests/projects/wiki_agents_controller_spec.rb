# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Projects::WikiAgentsController, feature_category: :duo_agent_platform do
  let_it_be_with_reload(:group) { create(:group) }
  let_it_be(:project) { create(:project, :with_duo_features_enabled, group: group) }
  let_it_be(:developer) { create(:user, developer_of: project) }
  let_it_be(:reporter) { create(:user, reporter_of: project) }
  let_it_be(:admin) { create(:admin) }
  let_it_be(:service_account) { create(:service_account, provisioned_by_group: group) }
  let_it_be(:wiki_agent) do
    create(
      :ai_catalog_third_party_flow,
      :with_released_version,
      name: JH::Ai::Catalog::WikiAgentFlowTriggerFinder::AGENT_NAME,
      organization: project.organization,
      verification_level: :gitlab_maintained,
      visibility: :public
    )
  end

  let_it_be(:parent_consumer) do
    create(
      :ai_catalog_item_consumer,
      item: wiki_agent,
      group: group,
      service_account: service_account
    )
  end

  let_it_be(:consumer) do
    create(
      :ai_catalog_item_consumer,
      item: wiki_agent,
      project: project,
      parent_item_consumer: parent_consumer
    )
  end

  let_it_be(:flow_trigger) do
    create(
      :ai_flow_trigger,
      :for_catalog_consumer,
      project: project,
      ai_catalog_item_consumer: consumer
    )
  end

  let(:current_user) { developer }
  let(:workflow) { build_stubbed(:duo_workflows_workflow, project: project, user: current_user) }
  let(:workload) { instance_double(Ci::Workloads::Workload, latest_workflow: workflow) }
  let(:service_response) { ServiceResponse.success(payload: workload) }
  let(:run_service) { instance_double(Ai::FlowTriggers::RunService, execute: service_response) }

  subject(:run_wiki_agent) { post project_wiki_agent_path(project) }

  before_all do
    group.namespace_settings.update!(duo_external_agents_enabled: true)
  end

  before do
    sign_in(current_user) if current_user

    allow(::Ai::DuoWorkflow).to receive(:duo_agent_platform_available?).and_return(true)
    allow(::Gitlab::Llm::StageCheck).to receive(:available?).and_return(true)
    allow(current_user).to receive(:allowed_to_use?).and_return(true) if current_user
    allow(Ai::FlowTriggers::RunService).to receive(:new).and_return(run_service)
  end

  it 'starts Wiki Agent and redirects to its session without a toast', :aggregate_failures do
    run_wiki_agent

    expect(Ai::FlowTriggers::RunService).to have_received(:new).with(
      project: project,
      flow_trigger: flow_trigger,
      current_user: current_user
    )
    expect(run_service).to have_received(:execute).with(input: '', event: :manual)
    expect(response).to redirect_to(workflow.web_url)
    expect(response).to have_gitlab_http_status(:see_other)
    expect(flash).to be_empty
  end

  context 'when workload creation fails' do
    let(:service_response) { ServiceResponse.error(message: 'workload failed') }

    it 'redirects back to the project with a generic error', :aggregate_failures do
      run_wiki_agent

      expect(response).to redirect_to(project_path(project))
      expect(response).to have_gitlab_http_status(:see_other)
      expect(flash[:alert]).to eq(s_('AiPowered|An error occurred. Please try again.'))
    end
  end

  context 'when Wiki Agent is unavailable' do
    let(:finder) do
      instance_double(JH::Ai::Catalog::WikiAgentFlowTriggerFinder, execute: Ai::FlowTrigger.none)
    end

    before do
      allow(JH::Ai::Catalog::WikiAgentFlowTriggerFinder).to receive(:new).with(project).and_return(finder)
    end

    it 'returns not found without starting a flow' do
      run_wiki_agent

      expect(response).to have_gitlab_http_status(:not_found)
      expect(Ai::FlowTriggers::RunService).not_to have_received(:new)
    end
  end

  context 'when the user cannot trigger an AI flow' do
    let(:current_user) { reporter }

    it 'returns not found without starting a flow' do
      run_wiki_agent

      expect(response).to have_gitlab_http_status(:not_found)
      expect(Ai::FlowTriggers::RunService).not_to have_received(:new)
    end
  end

  context 'when the user cannot create a wiki' do
    let(:project) { create(:project, :with_duo_features_enabled, group: group, developers: developer) }
    let(:wiki_disabled_consumer) do
      create(
        :ai_catalog_item_consumer,
        item: wiki_agent,
        project: project,
        parent_item_consumer: parent_consumer
      )
    end

    let(:wiki_disabled_flow_trigger) do
      create(
        :ai_flow_trigger,
        :for_catalog_consumer,
        project: project,
        ai_catalog_item_consumer: wiki_disabled_consumer
      )
    end

    before do
      wiki_disabled_flow_trigger
      project.project_feature.update!(wiki_access_level: ProjectFeature::DISABLED)
    end

    it 'returns not found without starting a flow' do
      run_wiki_agent

      expect(response).to have_gitlab_http_status(:not_found)
      expect(Ai::FlowTriggers::RunService).not_to have_received(:new)
    end
  end

  context 'when the user cannot execute the external agent' do
    before do
      allow(::Gitlab::Llm::StageCheck).to receive(:available?)
        .with(project, :ai_catalog_third_party_flows).and_return(false)
    end

    it 'returns not found without starting a flow' do
      run_wiki_agent

      expect(response).to have_gitlab_http_status(:not_found)
      expect(Ai::FlowTriggers::RunService).not_to have_received(:new)
    end
  end

  context 'when the user is anonymous' do
    let(:current_user) { nil }

    it 'redirects to sign in without starting a flow' do
      run_wiki_agent

      expect(response).to redirect_to(new_user_session_path)
      expect(Ai::FlowTriggers::RunService).not_to have_received(:new)
    end
  end

  context 'when the user is an administrator', :enable_admin_mode do
    let(:current_user) { admin }

    it 'starts Wiki Agent' do
      run_wiki_agent

      expect(response).to redirect_to(workflow.web_url)
    end
  end
end
