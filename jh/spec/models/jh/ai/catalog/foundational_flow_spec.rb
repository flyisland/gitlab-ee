# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Ai::Catalog::FoundationalFlow, feature_category: :duo_agent_platform do
  let(:flow) { described_class['jh_advanced_code_review/v1'] }

  describe 'jh_advanced_code_review/v1' do
    it 'registers the JH flow with its review triggers and privileges', :aggregate_failures do
      expect(flow).to have_attributes(
        display_name: 'JH Advanced Code Review',
        description: 'Review merge requests with related Issue and Pipeline context.',
        feature_maturity: 'experimental',
        ai_feature: 'duo_agent_platform',
        suppress_mention_progress_note: true
      )
      expect(described_class.jh_advanced_code_review_v1).to eq(flow)
      expect(flow.triggers).to match_array([
        Ai::FlowTrigger::EVENT_TYPES[:assign_reviewer],
        Ai::FlowTrigger::EVENT_TYPES[:mention]
      ])
      expect(flow.agent_privileges).to match_array([
        Ai::DuoWorkflows::Workflow::AgentPrivileges::READ_WRITE_GITLAB,
        Ai::DuoWorkflows::Workflow::AgentPrivileges::RUN_COMMANDS,
        Ai::DuoWorkflows::Workflow::AgentPrivileges::USE_GIT
      ])
    end

    it 'resolves a merge request IID as the goal' do
      merge_request = build_stubbed(:merge_request, iid: 37)

      goal = flow.goal_templates.resolve(
        event_type: :assign_reviewer,
        resource: merge_request
      )

      expect(goal).to eq('37')
    end

    it 'rejects resources other than merge requests' do
      issue = build_stubbed(:issue)

      expect do
        flow.goal_templates.resolve(event_type: :mention, resource: issue)
      end.to raise_error(ArgumentError, 'resource must be a merge request')
    end
  end

  describe 'dingtalk_assistant/v1' do
    let(:flow) { described_class['dingtalk_assistant/v1'] }

    it 'registers the DingTalk assistant flow as a server-side capable flow', :aggregate_failures do
      expect(flow).to have_attributes(
        display_name: 'GitLab Duo for DingTalk',
        feature_maturity: 'experimental',
        feature_flag: 'jh_dingtalk_duo_chat',
        ai_feature: 'duo_agent_platform',
        environment: 'ambient',
        coding_environment: 'none'
      )
      expect(described_class.dingtalk_assistant_v1).to eq(flow)
      expect(flow.agent_privileges).to contain_exactly(
        Ai::DuoWorkflows::Workflow::AgentPrivileges::READ_ONLY_GITLAB,
        Ai::DuoWorkflows::Workflow::AgentPrivileges::READ_WRITE_GITLAB,
        Ai::DuoWorkflows::Workflow::AgentPrivileges::START_FLOWS
      )
    end

    it 'is only available to groups with the jh_dingtalk_duo_chat feature flag' do
      group = build_stubbed(:group)

      stub_feature_flags(jh_dingtalk_duo_chat: false)
      expect(flow.available_for?(group)).to be(false)

      stub_feature_flags(jh_dingtalk_duo_chat: group)
      expect(flow.available_for?(group)).to be(true)
    end

    it 'resolves to the JH-owned dingtalk_assistant flow config in the Duo Workflow Service' do
      expect(flow.resolve_flow_version_for(container: nil, user: nil)).to eq(
        flow_config_id: 'dingtalk_assistant',
        flow_config_schema_version: 'v1',
        flow_version: '^1.0.0'
      )
    end
  end

  describe 'feishu_assistant/v1' do
    let(:flow) { described_class['feishu_assistant/v1'] }

    it 'registers the Feishu assistant flow as a server-side capable flow', :aggregate_failures do
      expect(flow).to have_attributes(
        display_name: 'GitLab Duo for Feishu',
        feature_maturity: 'experimental',
        feature_flag: 'jh_feishu_duo_chat',
        ai_feature: 'duo_agent_platform',
        environment: 'ambient',
        coding_environment: 'none'
      )
      expect(described_class.feishu_assistant_v1).to eq(flow)
      expect(flow.agent_privileges).to contain_exactly(
        Ai::DuoWorkflows::Workflow::AgentPrivileges::READ_ONLY_GITLAB,
        Ai::DuoWorkflows::Workflow::AgentPrivileges::READ_WRITE_GITLAB,
        Ai::DuoWorkflows::Workflow::AgentPrivileges::START_FLOWS
      )
    end

    it 'is only available to groups with the jh_feishu_duo_chat feature flag' do
      group = build_stubbed(:group)

      stub_feature_flags(jh_feishu_duo_chat: false)
      expect(flow.available_for?(group)).to be(false)

      stub_feature_flags(jh_feishu_duo_chat: group)
      expect(flow.available_for?(group)).to be(true)
    end

    it 'resolves to the JH-owned feishu_assistant flow config in the Duo Workflow Service' do
      expect(flow.resolve_flow_version_for(container: nil, user: nil)).to eq(
        flow_config_id: 'feishu_assistant',
        flow_config_schema_version: 'v1',
        flow_version: '^1.0.0'
      )
    end
  end
end
