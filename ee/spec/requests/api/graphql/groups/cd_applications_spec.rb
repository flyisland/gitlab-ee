# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Group cd_applications', feature_category: :continuous_delivery do
  include GraphqlHelpers

  let_it_be(:group) { create(:group, :private) }
  let_it_be(:subgroup) { create(:group, :private, parent: group) }
  let_it_be(:application) { create(:cd_application, group: group) }
  let_it_be(:subgroup_application) { create(:cd_application, group: subgroup) }
  let_it_be(:maintainer) { create(:user, maintainer_of: group) }
  let_it_be(:developer) { create(:user, developer_of: group) }
  let_it_be(:non_member) { create(:user) }

  let(:current_user) { maintainer }

  let(:query) do
    <<~QUERY
      query groupCdApplications($groupPath: ID!) {
        group(fullPath: $groupPath) {
          id
          cdApplications {
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
    it 'returns applications from the group and its descendants' do
      post_query

      expect(applications_response).to contain_exactly(
        a_graphql_entity_for(application, :name, :description),
        a_graphql_entity_for(subgroup_application, :name, :description)
      )
    end

    it_behaves_like 'authorizing granular token permissions for GraphQL', :read_cd_application do
      let(:user) { current_user }
      let(:boundary_object) { group }
      let(:query) do
        <<~QUERY
          query groupCdApplications($groupPath: ID!) {
            group(fullPath: $groupPath) {
              cdApplications { nodes { name } }
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

    it 'does not return the applications' do
      post_query

      expect(applications_response).to be_empty
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

    it 'does not return the applications' do
      post_query

      expect(applications_response).to be_nil
    end
  end

  def applications_response
    graphql_dig_at(graphql_data, :group, :cd_applications, :nodes)
  end
end
