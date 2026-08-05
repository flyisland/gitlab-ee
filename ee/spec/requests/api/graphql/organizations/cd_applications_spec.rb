# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Organization cd_applications', feature_category: :continuous_delivery do
  include GraphqlHelpers

  let_it_be(:organization) { create(:organization) }
  let_it_be(:other_organization) { create(:organization) }
  let_it_be(:org_application) { create(:cd_application, organization: organization) }
  let_it_be(:other_org_application) { create(:cd_application, organization: other_organization) }
  let_it_be(:org_application_service_a) { create(:cd_service, application: org_application) }
  let_it_be(:org_application_service_b) { create(:cd_service, application: org_application) }
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
              organization { id }
              services {
                nodes {
                  id
                  name
                  description
                }
              }
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
    it 'returns applications attached to the organization' do
      post_query

      expect(applications_response).to contain_exactly(
        a_graphql_entity_for(org_application, :name)
      )
    end

    it 'exposes the parent organization for each application' do
      post_query

      org_app_response = applications_response.find { |app| app['name'] == org_application.name }

      expect(org_app_response).to include('organization' => a_graphql_entity_for(organization))
    end

    it 'returns services belonging to the application' do
      post_query

      org_app_response = applications_response.find { |app| app['name'] == org_application.name }

      expect(org_app_response['services']['nodes']).to contain_exactly(
        a_graphql_entity_for(org_application_service_a, :name, :description),
        a_graphql_entity_for(org_application_service_b, :name, :description)
      )
    end

    it 'avoids N+1 queries when fetching services across applications' do
      run_query = -> do
        post_graphql(query, current_user: current_user,
          variables: { id: organization.to_global_id.to_s })
      end

      run_query.call # warm caches

      control = ActiveRecord::QueryRecorder.new { run_query.call }

      extra_application = create(:cd_application, organization: organization)
      create(:cd_service, application: extra_application)

      expect { run_query.call }.not_to exceed_query_limit(control)
    end

    it_behaves_like 'authorizing granular token permissions for GraphQL', [:read_cd_application, :read_organization] do
      let_it_be(:granular_organization) { create(:organization) }
      let_it_be(:granular_application) do
        create(:cd_application, organization: granular_organization)
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

  describe 'health rollup' do
    let(:query) do
      <<~QUERY
        query organizationCdApplications($id: OrganizationsOrganizationID!) {
          organization(id: $id) {
            cdApplications { nodes { name health } }
          }
        }
      QUERY
    end

    def health_response
      org_app = applications_response.find { |app| app['name'] == org_application.name }
      org_app['health']
    end

    it 'returns the worst health observed across the application services' do
      environment = create(:cd_environment, organization: organization)
      other_environment = create(:cd_environment, organization: organization)
      create(:cd_service_environment_health,
        service: org_application_service_a, environment: environment, health: :healthy)
      create(:cd_service_environment_health,
        service: org_application_service_b, environment: other_environment, health: :degraded)

      post_query

      expect(health_response).to eq('DEGRADED')
    end

    it 'returns null when no health has been reported' do
      post_query

      expect(health_response).to be_nil
    end

    it 'avoids N+1 queries when resolving health across applications' do
      run_query = -> do
        post_graphql(query, current_user: current_user,
          variables: { id: organization.to_global_id.to_s })
      end

      run_query.call # warm caches

      control = ActiveRecord::QueryRecorder.new { run_query.call }

      extra_application = create(:cd_application, organization: organization)
      extra_service = create(:cd_service, application: extra_application)
      create(:cd_service_environment_health,
        service: extra_service, environment: create(:cd_environment, organization: organization), health: :failed)

      expect { run_query.call }.not_to exceed_query_limit(control)
    end
  end

  describe 'searching by name or description' do
    let_it_be(:payments_application) do
      create(:cd_application, organization: organization, name: 'payments-platform',
        description: 'Billing system')
    end

    let(:query) do
      <<~QUERY
        query organizationCdApplications($id: OrganizationsOrganizationID!, $search: String) {
          organization(id: $id) {
            cdApplications(search: $search) { nodes { name } }
          }
        }
      QUERY
    end

    subject(:post_query) do
      post_graphql(query, current_user: current_user,
        variables: { id: organization.to_global_id.to_s, search: search })
    end

    def application_names
      applications_response.pluck('name')
    end

    context 'when the term matches a name' do
      let(:search) { 'payments' }

      it 'returns only matching applications' do
        post_query

        expect(application_names).to contain_exactly(payments_application.name)
      end
    end

    context 'when the term matches a description' do
      let(:search) { 'billing' }

      it 'returns only matching applications' do
        post_query

        expect(application_names).to contain_exactly(payments_application.name)
      end
    end

    it 'does not add queries per matching application (no N+1)' do
      run_query = -> do
        post_graphql(query, current_user: current_user,
          variables: { id: organization.to_global_id.to_s, search: 'app' })
      end

      run_query.call # warm caches

      control = ActiveRecord::QueryRecorder.new { run_query.call }

      create(:cd_application, organization: organization, name: 'another-app', description: 'app')

      expect { run_query.call }.not_to exceed_query_limit(control)
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
