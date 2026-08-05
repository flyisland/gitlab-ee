# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Organization cd_application', feature_category: :continuous_delivery do
  include GraphqlHelpers

  let_it_be(:organization) { create(:organization) }
  let_it_be(:other_organization) { create(:organization) }
  let_it_be(:application) { create(:cd_application, organization: organization) }
  let_it_be(:other_application) { create(:cd_application, organization: other_organization) }

  let_it_be(:service_a) { create(:cd_service, application: application) }
  let_it_be(:service_b) { create(:cd_service, application: application) }
  let_it_be(:organization_owner) { create(:organization_user, :owner, organization: organization).user }
  let_it_be(:organization_member) { create(:organization_user, organization: organization).user }
  let_it_be(:non_member) { create(:user) }

  let(:current_user) { organization_owner }
  let(:application_gid) { application.to_global_id.to_s }

  let(:query) do
    <<~QUERY
      query organizationCdApplication(
        $id: OrganizationsOrganizationID!,
        $applicationId: CdApplicationID!
      ) {
        organization(id: $id) {
          cdApplication(id: $applicationId) {
            id
            name
            description
            organization { id }
            createdAt
            updatedAt
            services {
              nodes {
                id
                name
                description
              }
            }
            environments {
              nodes {
                id
                name
              }
            }
            deployments {
              nodes {
                id
                state
              }
            }
            lastDeployedAt
            userPermissions {
              readCdApplication
              updateCdApplication
              createCdService
              updateCdService
              createCdVersionSet
              createCdRollout
              resolveCdRolloutGate
            }
          }
        }
      }
    QUERY
  end

  subject(:post_query) do
    post_graphql(
      query,
      current_user: current_user,
      variables: { id: organization.to_global_id.to_s, applicationId: application_gid }
    )
  end

  context 'when the user is an organization owner' do
    it 'returns the application with its details', :aggregate_failures do
      post_query

      expect(application_response).to a_graphql_entity_for(application, :name, :description)
      expect(application_response['organization']).to a_graphql_entity_for(organization)
      expect(application_response['createdAt']).to be_present
      expect(application_response['updatedAt']).to be_present
    end

    it 'returns the services belonging to the application' do
      post_query

      expect(application_response.dig('services', 'nodes')).to contain_exactly(
        a_graphql_entity_for(service_a, :name, :description),
        a_graphql_entity_for(service_b, :name, :description)
      )
    end

    it 'returns the distinct environments the application has rolled out to' do
      staging = create(:cd_environment, :staging, organization: organization)
      version_set = create(:cd_version_set, application: application)
      rollout = create(:cd_rollout, version_set: version_set, application: application)
      create(:cd_rollout_environment, rollout: rollout, environment: staging)

      post_query

      expect(application_response.dig('environments', 'nodes')).to contain_exactly(
        a_graphql_entity_for(staging, :name)
      )
    end

    context 'when the application belongs to a different organization' do
      let(:application_gid) { other_application.to_global_id.to_s }

      it 'returns nil' do
        post_query

        expect(application_response).to be_nil
      end
    end

    it 'returns the deployments actuated by the application and the last deployed timestamp' do
      environment = create(:cd_environment, organization: organization)
      version_set = create(:cd_version_set, application: application)
      rollout = create(:cd_rollout, version_set: version_set, application: application)
      rollout_environment = create(:cd_rollout_environment, rollout: rollout, environment: environment)
      deployment = create(:cd_deployment, service: service_a, rollout_environment: rollout_environment,
        state: :healthy, finished_at: 1.hour.ago)

      post_query

      expect(application_response.dig('deployments', 'nodes')).to contain_exactly(
        a_graphql_entity_for(deployment)
      )
      expect(Time.zone.parse(application_response['lastDeployedAt'])).to be_within(1.second).of(deployment.finished_at)
    end

    context 'when the application has no deployments' do
      it 'returns nil for lastDeployedAt' do
        post_query

        expect(application_response['lastDeployedAt']).to be_nil
      end
    end

    it 'returns the user permissions for the application' do
      post_query

      expect(application_response['userPermissions']).to eq(
        'readCdApplication' => true,
        'updateCdApplication' => true,
        'createCdService' => true,
        'updateCdService' => true,
        'createCdVersionSet' => true,
        'createCdRollout' => true,
        'resolveCdRolloutGate' => true
      )
    end

    it 'avoids N+1 queries when fetching the application environments' do
      version_set = create(:cd_version_set, application: application)
      rollout = create(:cd_rollout, version_set: version_set, application: application)
      create(:cd_rollout_environment, rollout: rollout,
        environment: create(:cd_environment, organization: organization))

      run_query = -> do
        post_graphql(query, current_user: current_user,
          variables: { id: organization.to_global_id.to_s, applicationId: application_gid })
      end
      run_query.call # warm caches

      control = ActiveRecord::QueryRecorder.new { run_query.call }

      create(:cd_rollout_environment, rollout: rollout,
        environment: create(:cd_environment, organization: organization))

      expect { run_query.call }.not_to exceed_query_limit(control)
    end

    it 'avoids N+1 queries when fetching the application deployments' do
      environment = create(:cd_environment, organization: organization)
      version_set = create(:cd_version_set, application: application)
      rollout = create(:cd_rollout, version_set: version_set, application: application)
      rollout_environment = create(:cd_rollout_environment, rollout: rollout, environment: environment)
      create(:cd_deployment, service: service_a, rollout_environment: rollout_environment)

      run_query = -> do
        post_graphql(query, current_user: current_user,
          variables: { id: organization.to_global_id.to_s, applicationId: application_gid })
      end
      run_query.call # warm caches

      control = ActiveRecord::QueryRecorder.new { run_query.call }

      create(:cd_deployment, service: service_b, rollout_environment: rollout_environment)

      expect { run_query.call }.not_to exceed_query_limit(control)
    end

    it_behaves_like 'authorizing granular token permissions for GraphQL',
      [:read_cd_application, :read_cd_service, :read_organization] do
      let(:user) { organization_owner }
      let(:boundary_object) { :instance }
      let(:request) do
        post_graphql(
          query,
          variables: { id: organization.to_global_id.to_s, applicationId: application.to_global_id.to_s },
          token: { personal_access_token: pat }
        )
      end
    end
  end

  context 'when the user is a non-owner organization member' do
    let(:current_user) { organization_member }

    it 'does not return the application' do
      post_query

      expect(application_response).to be_nil
    end
  end

  context 'when the user is not a member of the organization' do
    let(:current_user) { non_member }

    it 'does not return the application' do
      post_query

      expect(application_response).to be_nil
    end
  end

  context 'when the ai_native_deploy feature flag is disabled' do
    before do
      stub_feature_flags(ai_native_deploy: false)
    end

    it 'does not return the application' do
      post_query

      expect(application_response).to be_nil
    end
  end

  def application_response
    graphql_dig_at(graphql_data, :organization, :cd_application)
  end
end
