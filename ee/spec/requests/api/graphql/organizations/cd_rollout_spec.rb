# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Organization cd_rollout', feature_category: :continuous_delivery do
  include GraphqlHelpers

  let_it_be(:organization) { create(:organization) }
  let_it_be(:other_organization) { create(:organization) }
  let_it_be(:application) { create(:cd_application, organization: organization) }
  let_it_be(:other_org_application) { create(:cd_application, organization: other_organization) }
  let_it_be(:version_set) { create(:cd_version_set, application: application) }
  let_it_be(:other_org_version_set) { create(:cd_version_set, application: other_org_application) }
  let_it_be(:rollout) { create(:cd_rollout, version_set: version_set, application: application) }
  let_it_be(:other_org_rollout) do
    create(:cd_rollout, version_set: other_org_version_set, application: other_org_application)
  end

  let_it_be(:environment) { create(:cd_environment, organization: organization) }
  let_it_be(:rollout_environment) do
    create(:cd_rollout_environment, rollout: rollout, environment: environment)
  end

  let_it_be(:rollout_transition) { create(:cd_rollout_transition, rollout: rollout) }

  let_it_be(:organization_owner) { create(:organization_user, :owner, organization: organization).user }
  let_it_be(:organization_member) { create(:organization_user, organization: organization).user }
  let_it_be(:non_member) { create(:user) }

  let(:current_user) { organization_owner }
  let(:rollout_gid) { rollout.to_global_id.to_s }

  let(:query) do
    <<~QUERY
      query organizationCdRollout(
        $id: OrganizationsOrganizationID!,
        $rolloutId: CdRolloutID!
      ) {
        organization(id: $id) {
          cdRollout(id: $rolloutId) {
            id
            state
            workflowRef
            startedAt
            finishedAt
            createdAt
            updatedAt
            application { id name }
            versionSet { id name }
            rolloutEnvironments {
              nodes {
                id
                position
                state
                environment { id }
              }
            }
            rolloutTransitions {
              nodes {
                id
                event
              }
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
      variables: { id: organization.to_global_id.to_s, rolloutId: rollout_gid }
    )
  end

  context 'when the user is an organization owner' do
    it 'returns the rollout with its details', :aggregate_failures do
      post_query

      expect(rollout_response).to a_graphql_entity_for(rollout, :workflow_ref)
      expect(rollout_response['state']).to eq('PENDING')
      expect(rollout_response['application']).to a_graphql_entity_for(application, :name)
      expect(rollout_response['versionSet']).to a_graphql_entity_for(version_set, :name)
      expect(rollout_response['createdAt']).to be_present
      expect(rollout_response['updatedAt']).to be_present
    end

    it 'returns the rollout environments belonging to the rollout' do
      post_query

      expect(rollout_response.dig('rolloutEnvironments', 'nodes')).to contain_exactly(
        a_graphql_entity_for(rollout_environment, :position)
      )
    end

    it 'returns the rollout transitions belonging to the rollout' do
      post_query

      expect(rollout_response.dig('rolloutTransitions', 'nodes')).to contain_exactly(
        a_graphql_entity_for(rollout_transition)
      )
    end

    context 'when the rollout belongs to a different organization' do
      let(:rollout_gid) { other_org_rollout.to_global_id.to_s }

      it 'returns nil' do
        post_query

        expect(rollout_response).to be_nil
      end
    end

    it 'avoids N+1 queries when fetching the rollout with its associations' do
      run_query = -> do
        post_graphql(query, current_user: current_user,
          variables: { id: organization.to_global_id.to_s, rolloutId: rollout_gid })
      end

      run_query.call # warm caches

      control = ActiveRecord::QueryRecorder.new { run_query.call }

      create(:cd_rollout_environment,
        rollout: rollout,
        environment: create(:cd_environment, organization: organization),
        position: rollout_environment.position + 1)
      create(:cd_rollout_transition, rollout: rollout)

      expect { run_query.call }.not_to exceed_query_limit(control)
    end

    it_behaves_like 'authorizing granular token permissions for GraphQL',
      [:read_cd_rollout, :read_cd_application, :read_cd_version_set, :read_cd_environment, :read_organization] do
      let(:user) { organization_owner }
      let(:boundary_object) { :instance }
      let(:request) do
        post_graphql(
          query,
          variables: { id: organization.to_global_id.to_s, rolloutId: rollout.to_global_id.to_s },
          token: { personal_access_token: pat }
        )
      end
    end
  end

  context 'when the user is a non-owner organization member' do
    let(:current_user) { organization_member }

    it 'does not return the rollout' do
      post_query

      expect(rollout_response).to be_nil
    end
  end

  context 'when the user is not a member of the organization' do
    let(:current_user) { non_member }

    it 'does not return the rollout' do
      post_query

      expect(rollout_response).to be_nil
    end
  end

  context 'when the request is unauthenticated' do
    let(:current_user) { nil }

    it 'does not return the rollout' do
      post_query

      expect(rollout_response).to be_nil
    end
  end

  context 'when the ai_native_deploy feature flag is disabled' do
    before do
      stub_feature_flags(ai_native_deploy: false)
    end

    it 'does not return the rollout' do
      post_query

      expect(rollout_response).to be_nil
    end
  end

  def rollout_response
    graphql_dig_at(graphql_data, :organization, :cd_rollout)
  end
end
