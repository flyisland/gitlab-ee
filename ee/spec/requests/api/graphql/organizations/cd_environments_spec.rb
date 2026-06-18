# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Organization cd_environments', feature_category: :continuous_delivery do
  include GraphqlHelpers

  let_it_be(:organization) { create(:organization) }
  let_it_be(:other_organization) { create(:organization) }
  let_it_be(:group) { create(:group, organization: organization) }
  let_it_be(:other_org_group) { create(:group, organization: other_organization) }
  let_it_be(:org_environment) { create(:cd_environment, :for_organization, organization: organization) }
  let_it_be(:group_environment) { create(:cd_environment, group: group) }
  let_it_be(:other_org_environment) { create(:cd_environment, :for_organization, organization: other_organization) }
  let_it_be(:other_group_environment) { create(:cd_environment, group: other_org_group) }
  let_it_be(:organization_owner) { create(:organization_user, :owner, organization: organization).user }
  let_it_be(:organization_member) { create(:organization_user, organization: organization).user }
  let_it_be(:non_member) { create(:user) }

  let(:current_user) { organization_owner }

  let(:query) do
    <<~QUERY
      query organizationCdEnvironments($id: OrganizationsOrganizationID!) {
        organization(id: $id) {
          id
          cdEnvironments {
            nodes {
              id
              name
              group { id }
              organization { id }
            }
          }
        }
      }
    QUERY
  end

  subject(:post_query) do
    post_graphql(query, current_user: current_user, variables: { id: organization.to_global_id.to_s })
  end

  context 'when the user is an organization owner' do
    it 'returns environments attached to the org and its groups' do
      post_query

      expect(environments_response).to contain_exactly(
        a_graphql_entity_for(org_environment, :name),
        a_graphql_entity_for(group_environment, :name)
      )
    end

    it 'exposes the parent group or organization for each environment' do
      post_query

      org_env_response = environments_response.find { |env| env['name'] == org_environment.name }
      group_env_response = environments_response.find { |env| env['name'] == group_environment.name }

      expect(org_env_response).to include(
        'group' => nil,
        'organization' => a_graphql_entity_for(organization)
      )
      expect(group_env_response).to include(
        'group' => a_graphql_entity_for(group),
        'organization' => a_graphql_entity_for(organization)
      )
    end

    it_behaves_like 'authorizing granular token permissions for GraphQL', [:read_cd_environment, :read_organization] do
      let_it_be(:granular_organization) { create(:organization) }
      let_it_be(:granular_environment) do
        create(:cd_environment, :for_organization, organization: granular_organization)
      end

      let(:user) { create(:organization_user, :owner, organization: granular_organization).user }
      let(:boundary_object) { :instance }
      let(:query) do
        <<~QUERY
          query organizationCdEnvironments($id: OrganizationsOrganizationID!) {
            organization(id: $id) {
              cdEnvironments { nodes { name } }
            }
          }
        QUERY
      end

      let(:request) do
        post_graphql(query, variables: { id: granular_organization.to_global_id.to_s },
          token: { personal_access_token: pat })
      end
    end
  end

  context 'when the user is a non-owner organization member' do
    let(:current_user) { organization_member }

    it 'does not return the environments' do
      post_query

      expect(environments_response).to be_nil
    end
  end

  context 'when the user is not a member of the organization' do
    let(:current_user) { non_member }

    it 'does not return the environments' do
      post_query

      expect(environments_response).to be_nil
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
    graphql_dig_at(graphql_data, :organization, :cd_environments, :nodes)
  end
end
