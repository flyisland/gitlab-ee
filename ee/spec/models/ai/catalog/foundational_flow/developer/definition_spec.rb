# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Ai::Catalog::FoundationalFlow::Developer::Definition, feature_category: :duo_agent_platform do
  subject(:flow) { Ai::Catalog::FoundationalFlow.developer_v1 }

  let(:project) { build_stubbed(:project) }
  let_it_be(:user) { create(:user) }

  it 'grants the privileges its flow config needs, including run_command', :aggregate_failures do
    expect(flow.agent_privileges).to eq([
      ::Ai::DuoWorkflows::Workflow::AgentPrivileges::READ_WRITE_FILES,
      ::Ai::DuoWorkflows::Workflow::AgentPrivileges::READ_ONLY_GITLAB,
      ::Ai::DuoWorkflows::Workflow::AgentPrivileges::READ_WRITE_GITLAB,
      ::Ai::DuoWorkflows::Workflow::AgentPrivileges::RUN_COMMANDS,
      ::Ai::DuoWorkflows::Workflow::AgentPrivileges::USE_GIT
    ])
  end

  describe 'resolve_flow_version_for' do
    subject(:resolved) { flow.resolve_flow_version_for(container: project, user: user) }

    it 'returns the flow own reference and version' do
      expect(resolved).to eq(
        flow_config_id: 'developer',
        flow_config_schema_version: 'v1',
        flow_version: '^3.0.0'
      )
    end

    context 'when duo_developer_orbit is enabled and the orbit killswitch is on' do
      before do
        stub_feature_flags(duo_developer_orbit: user)
        user.user_preference.update!(orbit_settings: { 'enabled' => true })
      end

      it 'returns the flow own reference and version' do
        expect(resolved).to eq(
          flow_config_id: 'developer',
          flow_config_schema_version: 'v1',
          flow_version: '^3.0.0'
        )
      end
    end
  end
end
