# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Resolvers::Ai::DuoWorkflows::WorkflowWorkItemLinksResolver, feature_category: :duo_agent_platform do
  include GraphqlHelpers

  it 'returns a WorkflowWorkItemLink connection' do
    expect(described_class.type).to eq(Types::Ai::DuoWorkflows::WorkflowWorkItemLinkType.connection_type)
  end

  it 'has expected arguments' do
    expect(described_class.arguments.keys).to contain_exactly('linkType')
  end

  it 'resolves the work_item_links association' do
    expect(described_class.links_association).to eq(:work_item_links)
  end
end
