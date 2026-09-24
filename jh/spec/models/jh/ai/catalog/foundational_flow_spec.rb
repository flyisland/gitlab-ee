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
end
