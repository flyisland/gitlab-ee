# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Types::Ai::DuoWorkflows::WorkflowSourceTypeEnum, feature_category: :duo_agent_platform do
  let(:context) { GraphQL::Query::NullContext.instance }

  it 'includes the JH chat surfaces in the workflow source type enum', :aggregate_failures do
    expect(described_class.coerce_input('DINGTALK', context)).to eq('dingtalk')
    expect(described_class.coerce_result('dingtalk', context)).to eq('DINGTALK')
    expect(described_class.coerce_input('FEISHU', context)).to eq('feishu')
    expect(described_class.coerce_result('feishu', context)).to eq('FEISHU')
  end
end
