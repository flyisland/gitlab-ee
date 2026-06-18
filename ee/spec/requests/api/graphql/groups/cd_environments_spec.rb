# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Group cd_environments', feature_category: :continuous_delivery do
  include GraphqlHelpers

  let_it_be(:group) { create(:group, :private) }
  let_it_be(:subgroup) { create(:group, :private, parent: group) }
  let_it_be(:environment) { create(:cd_environment, group: group) }
  let_it_be(:subgroup_environment) { create(:cd_environment, group: subgroup) }
  let_it_be(:maintainer) { create(:user, maintainer_of: group) }
  let_it_be(:developer) { create(:user, developer_of: group) }
  let_it_be(:non_member) { create(:user) }

  let(:current_user) { maintainer }

  let(:query) do
    <<~QUERY
      query groupCdEnvironments($groupPath: ID!) {
        group(fullPath: $groupPath) {
          id
          cdEnvironments {
            nodes {
              id
              name
              description
            }
          }
        }
      }
    QUERY
  end

  subject(:post_query) do
    post_graphql(query, current_user: current_user, variables: { groupPath: group.full_path })
  end

  context 'when the user is a maintainer' do
    it 'returns environments from the group and its descendants' do
      post_query

      expect(environments_response).to contain_exactly(
        a_graphql_entity_for(environment, :name, :description),
        a_graphql_entity_for(subgroup_environment, :name, :description)
      )
    end

    it_behaves_like 'authorizing granular token permissions for GraphQL', :read_cd_environment do
      let(:user) { current_user }
      let(:boundary_object) { group }
      let(:query) do
        <<~QUERY
          query groupCdEnvironments($groupPath: ID!) {
            group(fullPath: $groupPath) {
              cdEnvironments { nodes { name } }
            }
          }
        QUERY
      end

      let(:request) do
        post_graphql(query, variables: { groupPath: group.full_path }, token: { personal_access_token: pat })
      end
    end
  end

  context 'when the user is a developer' do
    let(:current_user) { developer }

    it 'does not return the environments' do
      post_query

      expect(environments_response).to be_nil
    end
  end

  context 'when the user is not a member of a private group' do
    let(:current_user) { non_member }

    it 'does not return the group' do
      post_query

      expect(graphql_data_at(:group)).to be_nil
    end
  end

  context 'when the ai_native_deploy feature flag is disabled' do
    before do
      stub_feature_flags(ai_native_deploy: false)
    end

    it 'does not return the environments' do
      post_query

      expect(environments_response).to be_nil
    end
  end

  def environments_response
    graphql_dig_at(graphql_data, :group, :cd_environments, :nodes)
  end
end
