# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Organization cd_environments', feature_category: :continuous_delivery do
  include GraphqlHelpers

  let_it_be(:organization) { create(:organization) }
  let_it_be(:other_organization) { create(:organization) }
  let_it_be(:org_environment) { create(:cd_environment, :production, organization: organization) }
  let_it_be(:org_staging_environment) { create(:cd_environment, :staging, organization: organization) }
  let_it_be(:other_org_environment) { create(:cd_environment, organization: other_organization) }
  let_it_be(:organization_owner) { create(:organization_user, :owner, organization: organization).user }
  let_it_be(:organization_member) { create(:organization_user, organization: organization).user }
  let_it_be(:non_member) { create(:user) }

  let(:current_user) { organization_owner }
  let(:tier) { nil }

  let(:query) do
    <<~QUERY
      query organizationCdEnvironments($id: OrganizationsOrganizationID!, $tier: CdEnvironmentTier) {
        organization(id: $id) {
          id
          cdEnvironments(tier: $tier) {
            nodes {
              id
              name
              organization { id }
            }
          }
        }
      }
    QUERY
  end

  subject(:post_query) do
    post_graphql(query, current_user: current_user,
      variables: { id: organization.to_global_id.to_s, tier: tier })
  end

  context 'when the user is an organization owner' do
    it 'returns environments attached to the organization' do
      post_query

      expect(environments_response).to contain_exactly(
        a_graphql_entity_for(org_environment, :name),
        a_graphql_entity_for(org_staging_environment, :name)
      )
    end

    it 'exposes the parent organization for each environment' do
      post_query

      org_env_response = environments_response.find { |env| env['name'] == org_environment.name }

      expect(org_env_response).to include('organization' => a_graphql_entity_for(organization))
    end

    context 'when filtering by tier' do
      let(:tier) { 'PRODUCTION' }

      it 'returns only environments matching the tier' do
        post_query

        expect(environments_response).to contain_exactly(
          a_graphql_entity_for(org_environment, :name)
        )
      end
    end

    context 'when filtering by a tier with no matching environments' do
      let(:tier) { 'DEVELOPMENT' }

      it 'returns an empty list' do
        post_query

        expect(environments_response).to be_empty
      end
    end

    it_behaves_like 'authorizing granular token permissions for GraphQL', [:read_cd_environment, :read_organization] do
      let_it_be(:granular_organization) { create(:organization) }
      let_it_be(:granular_environment) do
        create(:cd_environment, organization: granular_organization)
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
