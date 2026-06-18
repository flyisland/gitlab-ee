# frozen_string_literal: true

require 'spec_helper'

RSpec.describe EE::Projects::DuoAgentsPlatformHelper, feature_category: :duo_agent_platform do
  include Rails.application.routes.url_helpers
  include Devise::Test::ControllerHelpers

  let_it_be(:group) { build_stubbed(:group, name: 'Test Group') }
  let_it_be(:project) { build_stubbed(:project, name: 'Test Project', group: group) }
  let_it_be(:user) { build_stubbed(:user) }

  shared_examples 'returns duo settings data for group admin' do
    before do
      allow(Ability).to receive(:allowed?).with(user, :admin_group, group).and_return(true)
    end

    it 'returns duo_settings_path and duo_settings_root_ancestor_name' do
      expect(helper_data).to include(
        duo_settings_path: group.duo_settings_path,
        duo_settings_root_ancestor_name: "Test Group"
      )
    end
  end

  before do
    helper.instance_variable_set(:@project, project)
    allow(ProductAnalyticsHelpers).to receive(:ai_impact_dashboard_globally_available?).and_return(true)
    allow(helper).to receive(:current_user).and_return(user)

    allow(group).to receive_messages(
      duo_custom_agents_enabled: true,
      duo_custom_flows_enabled: true,
      duo_external_agents_enabled: true
    )
  end

  describe '#duo_agents_platform_data' do
    subject(:helper_data) { helper.duo_agents_platform_data(project) }

    before do
      allow(helper).to receive(:project_automate_path).with(project).and_return('/test-project/-/automate')
      allow(helper).to receive(:project_analytics_dashboards_path)
                         .with(project, vueroute: 'duo_and_sdlc_trends')
                         .and_return('/test-project/-/analytics/dashboards/duo_and_sdlc_trends')

      # Mock TanukiBot to return credits available by default
      allow_next_instance_of(::Gitlab::Llm::TanukiBot) do |instance|
        allow(instance).to receive(:credits_available?).and_return(true)
      end

      allow(::Ai::Catalog).to receive(:user_can_access_experimental_and_beta_features?).with(user).and_return(true)
    end

    it 'returns the expected data hash' do
      expected_data = {
        agents_platform_base_route: '/test-project/-/automate',
        root_group_id: project.root_namespace.id,
        project_path: project.full_path,
        project_id: project.id,
        explore_ai_catalog_agents_path: '/explore/ai-catalog/agents',
        explore_ai_catalog_flows_path: '/explore/ai-catalog/flows',
        ai_impact_dashboard_enabled: 'true',
        credits_available: 'true',
        instance_beta_features_enabled: 'true',
        ai_impact_dashboard_path: '/test-project/-/analytics/dashboards/duo_and_sdlc_trends',
        duo_custom_agents_enabled: 'true',
        duo_custom_flows_enabled: 'true',
        duo_external_agents_enabled: 'true',
        duo_settings_path: nil,
        duo_settings_root_ancestor_name: "Test Group"
      }

      expect(helper_data).to eq(expected_data)
    end

    it_behaves_like 'returns duo settings data for group admin'

    context 'when beta features are disabled' do
      before do
        allow(::Ai::Catalog).to receive(:user_can_access_experimental_and_beta_features?).with(user).and_return(false)
      end

      it 'returns instance_beta_features_enabled as false' do
        expect(helper_data).to include(instance_beta_features_enabled: 'false')
      end
    end

    context 'when project is personal' do
      let_it_be(:project) { build_stubbed(:project, :in_user_namespace) }

      it 'returns root_group_id as nil and correct duo settings fields' do
        expect(helper_data).to include(
          root_group_id: nil,
          project_id: project.id,
          project_path: project.full_path,
          duo_settings_path: nil,
          duo_settings_root_ancestor_name: project.root_ancestor.name
        )
      end
    end

    context 'when AI impact dashboard is not available' do
      before do
        allow(ProductAnalyticsHelpers).to receive(:ai_impact_dashboard_globally_available?).and_return(false)
      end

      it 'returns ai_impact_dashboard_enabled as false and ai_impact_dashboard_path as nil' do
        expect(helper_data).to include(
          ai_impact_dashboard_enabled: 'false',
          ai_impact_dashboard_path: nil
        )
      end
    end
  end

  describe '#duo_agents_group_data' do
    subject(:helper_data) { helper.duo_agents_group_data(group) }

    before do
      allow(helper).to receive(:group_automate_path).with(group).and_return('/test-group/-/automate')
      allow(helper).to receive(:group_analytics_dashboards_path)
                         .with(group, vueroute: 'duo_and_sdlc_trends')
                         .and_return('/groups/test_group/-/analytics/dashboards/duo_and_sdlc_trends')

      # Mock TanukiBot to return credits available by default
      allow_next_instance_of(::Gitlab::Llm::TanukiBot) do |instance|
        allow(instance).to receive(:credits_available?).and_return(true)
      end

      allow(::Ai::Catalog).to receive(:user_can_access_experimental_and_beta_features?).with(user).and_return(true)
    end

    it 'returns the expected data hash' do
      expected_data = {
        agents_platform_base_route: '/test-group/-/automate',
        group_path: group.full_path,
        group_id: group.id,
        explore_ai_catalog_agents_path: '/explore/ai-catalog/agents',
        explore_ai_catalog_flows_path: '/explore/ai-catalog/flows',
        ai_impact_dashboard_enabled: 'true',
        credits_available: 'true',
        instance_beta_features_enabled: 'true',
        ai_impact_dashboard_path: '/groups/test_group/-/analytics/dashboards/duo_and_sdlc_trends',
        duo_custom_agents_enabled: 'true',
        duo_custom_flows_enabled: 'true',
        duo_external_agents_enabled: 'true',
        duo_settings_path: nil,
        duo_settings_root_ancestor_name: "Test Group"
      }

      expect(helper_data).to eq(expected_data)
    end

    it_behaves_like 'returns duo settings data for group admin'

    context 'when beta features are disabled' do
      before do
        allow(::Ai::Catalog).to receive(:user_can_access_experimental_and_beta_features?).with(user).and_return(false)
      end

      it 'returns instance_beta_features_enabled as false' do
        expect(helper_data).to include(instance_beta_features_enabled: 'false')
      end
    end

    context 'when AI impact dashboard is not available' do
      before do
        allow(ProductAnalyticsHelpers).to receive(:ai_impact_dashboard_globally_available?).and_return(false)
      end

      it 'returns ai_impact_dashboard_enabled as false and ai_impact_dashboard_path as nil' do
        expect(helper_data).to include(
          ai_impact_dashboard_enabled: 'false',
          ai_impact_dashboard_path: nil
        )
      end
    end
  end

  describe '#credits_available?' do
    context 'when container is a Project' do
      it 'returns true when TanukiBot has credits available' do
        allow_next_instance_of(::Gitlab::Llm::TanukiBot) do |instance|
          allow(instance).to receive(:credits_available?).and_return(true)
        end

        expect(helper.send(:credits_available?, project)).to be true
      end

      it 'returns false when TanukiBot has no credits available' do
        allow_next_instance_of(::Gitlab::Llm::TanukiBot) do |instance|
          allow(instance).to receive(:credits_available?).and_return(false)
        end

        expect(helper.send(:credits_available?, project)).to be false
      end
    end

    context 'when container is a Group' do
      it 'returns true when TanukiBot has credits available' do
        allow_next_instance_of(::Gitlab::Llm::TanukiBot) do |instance|
          allow(instance).to receive(:credits_available?).and_return(true)
        end

        expect(helper.send(:credits_available?, group)).to be true
      end

      it 'returns false when TanukiBot has no credits available' do
        allow_next_instance_of(::Gitlab::Llm::TanukiBot) do |instance|
          allow(instance).to receive(:credits_available?).and_return(false)
        end

        expect(helper.send(:credits_available?, group)).to be false
      end
    end
  end
end
