# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Organization cd_applications', feature_category: :continuous_delivery do
  include GraphqlHelpers

  let_it_be(:organization) { create(:organization) }
  let_it_be(:other_organization) { create(:organization) }
  let_it_be(:group) { create(:group, organization: organization) }
  let_it_be(:other_org_group) { create(:group, organization: other_organization) }
  let_it_be(:org_application) { create(:cd_application, :for_organization, organization: organization) }
  let_it_be(:group_application) { create(:cd_application, group: group) }
  let_it_be(:other_org_application) { create(:cd_application, :for_organization, organization: other_organization) }
  let_it_be(:other_group_application) { create(:cd_application, group: other_org_group) }
  let_it_be(:organization_owner) { create(:organization_user, :owner, organization: organization).user }
  let_it_be(:organization_member) { create(:organization_user, organization: organization).user }
  let_it_be(:non_member) { create(:user) }

  let(:current_user) { organization_owner }

  let(:query) do
    <<~QUERY
      query organizationCdApplications($id: OrganizationsOrganizationID!) {
        organization(id: $id) {
          id
          cdApplications {
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
    it 'returns applications attached to the org and its groups' do
      post_query

      expect(applications_response).to contain_exactly(
        a_graphql_entity_for(org_application, :name),
        a_graphql_entity_for(group_application, :name)
      )
    end

    it 'exposes the parent group or organization for each application' do
      post_query

      org_app_response = applications_response.find { |app| app['name'] == org_application.name }
      group_app_response = applications_response.find { |app| app['name'] == group_application.name }

      expect(org_app_response).to include(
        'group' => nil,
        'organization' => a_graphql_entity_for(organization)
      )
      expect(group_app_response).to include(
        'group' => a_graphql_entity_for(group),
        'organization' => a_graphql_entity_for(organization)
      )
    end

    it_behaves_like 'authorizing granular token permissions for GraphQL', [:read_cd_application, :read_organization] do
      let_it_be(:granular_organization) { create(:organization) }
      let_it_be(:granular_application) do
        create(:cd_application, :for_organization, organization: granular_organization)
      end

      let(:user) { create(:organization_user, :owner, organization: granular_organization).user }
      let(:boundary_object) { :instance }
      let(:query) do
        <<~QUERY
          query organizationCdApplications($id: OrganizationsOrganizationID!) {
            organization(id: $id) {
              cdApplications { nodes { name } }
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

    it 'does not return the applications' do
      post_query

      expect(applications_response).to be_nil
    end
  end

  context 'when the user is not a member of the organization' do
    let(:current_user) { non_member }

    it 'does not return the applications' do
      post_query

      expect(applications_response).to be_nil
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
    graphql_dig_at(graphql_data, :organization, :cd_applications, :nodes)
  end
end
