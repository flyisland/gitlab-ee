# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Ai::Messaging::AdapterRegistry, feature_category: :duo_agent_platform do
  it 'resolves the JH chat adapters by their keys', :aggregate_failures do
    expect(described_class['dingtalk']).to eq(::Ai::Messaging::Adapters::Dingtalk)
    expect(described_class['feishu']).to eq(::Ai::Messaging::Adapters::Feishu)
  end

  it 'keeps the upstream adapters registered' do
    expect(described_class['slack']).to eq(::Ai::Messaging::Adapters::Slack)
    expect(described_class['gitlab_duo_note']).to eq(::Ai::Messaging::Adapters::GitlabDuoNote)
    expect(described_class['webhook']).to eq(::Ai::Messaging::Adapters::Webhook)
  end

  it 'includes the JH chat adapters in the private-to-invoker keys' do
    expect(described_class.private_to_invoker_keys).to include('dingtalk', 'feishu')
  end
end
