# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Ai::DuoWorkflows::WorkflowWorkflowPolicy, feature_category: :duo_agent_platform do
  subject(:policy) { described_class.new(build_stubbed(:user), link) }

  let_it_be(:link) { build_stubbed(:duo_workflows_workflow_workflow) }

  it { is_expected.to delegate_to(Ai::DuoWorkflows::WorkflowPolicy) }

  it 'delegates to the session, not the linked workflow' do
    expect(policy.delegated_policies.values.map(&:subject)).to contain_exactly(link.workflow)
  end
end
