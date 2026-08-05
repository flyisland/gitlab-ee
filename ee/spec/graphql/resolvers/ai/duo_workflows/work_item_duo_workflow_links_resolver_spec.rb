# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Resolvers::Ai::DuoWorkflows::WorkItemDuoWorkflowLinksResolver, feature_category: :duo_agent_platform do
  include GraphqlHelpers

  it 'returns a WorkflowWorkItemLink connection' do
    expect(described_class.type).to eq(Types::Ai::DuoWorkflows::WorkflowWorkItemLinkType.connection_type)
  end

  it 'has expected arguments' do
    expect(described_class.arguments.keys).to contain_exactly('linkType')
  end

  it 'resolves the duo_workflow_links association' do
    expect(described_class.links_association).to eq(:duo_workflow_links)
  end
end
