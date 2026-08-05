# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'aiToolRules query', feature_category: :ai_agents do
  include GraphqlHelpers

  let_it_be(:group) { create(:group) }
  let_it_be(:owner) { create(:user, owner_of: group) }

  let(:current_user) { owner }

  let(:query) do
    <<~QUERY
      query aiToolRules($fullPath: ID!) {
        aiToolRules(fullPath: $fullPath) {
          nodes {
            id
            name
            webAccess
            localAccess
          }
        }
      }
    QUERY
  end

  subject(:post_query) do
    post_graphql(query, current_user: current_user, variables: { fullPath: group.full_path })
  end

  it 'returns the tool rules for the namespace' do
    post_query

    nodes = graphql_data_at(:ai_tool_rules, :nodes)
    expect(nodes).to be_present
    expect(nodes.first).to include('id', 'name', 'webAccess', 'localAccess')
  end

  # The field-level `authorize_granular_token` directive enforces the read scope; an unauthorized
  # token nulls the whole `aiToolRules` field (nodes are boundary-less hashes, nothing to redact
  # per-node), so the standard shared example applies, not the "skipped child type" variant.
  it_behaves_like 'authorizing granular token permissions for GraphQL', :read_ai_tool_rule do
    let(:user) { owner }
    let(:boundary_object) { group }
    let(:request) do
      post_graphql(query, variables: { fullPath: group.full_path }, token: { personal_access_token: pat })
    end
  end
end
