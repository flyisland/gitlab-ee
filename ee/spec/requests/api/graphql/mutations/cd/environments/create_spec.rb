# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Create a continuous deployment environment', feature_category: :continuous_delivery do
  include GraphqlHelpers

  let_it_be(:group) { create(:group) }
  let_it_be(:project) { create(:project, group: group) }
  let_it_be(:cluster_agent) { create(:cluster_agent, project: project) }
  let_it_be(:maintainer) { create(:user, maintainer_of: group) }
  let_it_be(:developer) { create(:user, developer_of: group) }
  let_it_be(:reporter) { create(:user, reporter_of: group) }

  let(:current_user) { maintainer }
  let(:group_path) { group.full_path }
  let(:input) do
    {
      group_path: group_path,
      name: 'env-1',
      description: 'My environment',
      cluster_agent_id: cluster_agent.to_global_id.to_s
    }
  end

  let(:mutation) { graphql_mutation(:cd_environment_create, input) }
  let(:mutation_response) { graphql_mutation_response(:cd_environment_create) }

  before_all do
    create(:agent_user_access_project_authorization, agent: cluster_agent, project: cluster_agent.project)
    cluster_agent.project.add_developer(maintainer)
    cluster_agent.project.add_developer(developer)
    cluster_agent.project.add_developer(reporter)
  end

  shared_examples 'rejects the mutation' do
    it_behaves_like 'a mutation that returns a top-level access error'

    it 'does not create the environment' do
      expect { post_graphql_mutation(mutation, current_user: current_user) }
        .not_to change { ::Cd::Environment.count }
    end
  end

  context 'when the user is a maintainer' do
    it 'creates the environment' do
      expect { post_graphql_mutation(mutation, current_user: current_user) }
        .to change { ::Cd::Environment.count }.by(1)

      expect(mutation_response['errors']).to be_empty
      expect(mutation_response['environment']).to include(
        'name' => 'env-1',
        'description' => 'My environment'
      )
    end

    it_behaves_like 'authorizing granular token permissions for GraphQL', :create_cd_environment do
      let(:user) { current_user }
      let(:boundary_object) { group }
      let(:mutation) { graphql_mutation(:cd_environment_create, input, 'errors') }
      let(:request) { post_graphql_mutation(mutation, token: { personal_access_token: pat }) }
    end

    context 'when the name is already taken' do
      before do
        create(:cd_environment, group: group, name: 'env-1')
      end

      it 'returns errors in the response' do
        expect { post_graphql_mutation(mutation, current_user: current_user) }
          .not_to change { ::Cd::Environment.count }

        expect(mutation_response['environment']).to be_nil
        expect(mutation_response['errors']).to include(a_string_matching(/Name has already been taken/))
      end
    end

    context 'when the group does not exist' do
      let(:group_path) { 'non-existent-group' }

      it_behaves_like 'a mutation that returns a top-level access error'
    end
  end

  context 'when the user is a developer' do
    let(:current_user) { developer }

    it_behaves_like 'rejects the mutation'
  end

  context 'when the user is a reporter' do
    let(:current_user) { reporter }

    it_behaves_like 'rejects the mutation'
  end

  context 'when the ai_native_deploy feature flag is disabled' do
    before do
      stub_feature_flags(ai_native_deploy: false)
    end

    it_behaves_like 'rejects the mutation'
  end

  context 'when the user cannot read the cluster agent' do
    let_it_be(:other_cluster_agent) { create(:cluster_agent) }

    let(:input) { super().merge(cluster_agent_id: other_cluster_agent.to_global_id.to_s) }

    it_behaves_like 'rejects the mutation'
  end

  context 'when creating at the organization level' do
    let_it_be(:organization) { create(:organization) }
    let_it_be(:organization_group) { create(:group, organization: organization) }
    let_it_be(:organization_project) { create(:project, group: organization_group) }
    let_it_be(:organization_cluster_agent) { create(:cluster_agent, project: organization_project) }
    let_it_be(:organization_owner) { create(:organization_user, :owner, organization: organization).user }
    let_it_be(:organization_member) { create(:organization_user, organization: organization).user }

    let(:current_user) { organization_owner }
    let(:input) do
      {
        organization_id: organization.to_global_id.to_s,
        name: 'env-1',
        description: 'My environment',
        cluster_agent_id: organization_cluster_agent.to_global_id.to_s
      }
    end

    before_all do
      organization_project.add_developer(organization_owner)
      organization_project.add_developer(organization_member)
    end

    it 'creates the environment on the organization' do
      expect { post_graphql_mutation(mutation, current_user: current_user) }
        .to change { ::Cd::Environment.count }.by(1)

      expect(mutation_response['errors']).to be_empty
      expect(::Cd::Environment.last).to have_attributes(
        organization: organization,
        group: nil,
        name: 'env-1'
      )
    end

    it_behaves_like 'authorizing granular token permissions for GraphQL', :create_cd_environment do
      let(:user) { current_user }
      let(:boundary_object) { :instance }
      let(:mutation) { graphql_mutation(:cd_environment_create, input, 'errors') }
      let(:request) { post_graphql_mutation(mutation, token: { personal_access_token: pat }) }
    end

    context 'when the user is an organization member' do
      let(:current_user) { organization_member }

      it_behaves_like 'a mutation that returns a top-level access error'
    end

    context 'when the user is not a member of the organization' do
      let(:current_user) { create(:user) }

      it_behaves_like 'a mutation that returns a top-level access error'
    end
  end

  shared_examples 'returns an exactly_one_of argument error' do
    it 'returns an argument error' do
      post_graphql_mutation(mutation, current_user: current_user)

      expect_graphql_errors_to_include(/One and only one of \[groupPath, organizationId\] arguments is required\./)
    end
  end

  context 'when both group_path and organization_id are provided' do
    let_it_be(:organization) { create(:organization) }

    let(:input) do
      super().merge(organization_id: organization.to_global_id.to_s)
    end

    it_behaves_like 'returns an exactly_one_of argument error'
  end

  context 'when neither group_path nor organization_id are provided' do
    let(:input) do
      {
        name: 'env-1',
        cluster_agent_id: cluster_agent.to_global_id.to_s
      }
    end

    it_behaves_like 'returns an exactly_one_of argument error'
  end
end
