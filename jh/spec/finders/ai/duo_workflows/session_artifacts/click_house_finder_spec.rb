# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Ai::DuoWorkflows::SessionArtifacts::ClickHouseFinder, feature_category: :duo_agent_platform do
  let_it_be(:group) { create(:group) }

  it 'excludes private Slack, DingTalk and Feishu conversations', :aggregate_failures do
    query = described_class.new(namespace: group).execute.to_sql

    expect(query).to match(/not\(`[^`]+`\.`messaging_adapter`\s+IN\s+\('slack', 'dingtalk', 'feishu'\)\)/i)
    expect(query).not_to include('gitlab_duo_note')
  end
end
