# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Create a continuous deployment application', feature_category: :continuous_delivery do
  include GraphqlHelpers

  let_it_be(:group) { create(:group) }
  let_it_be(:maintainer) { create(:user, maintainer_of: group) }
  let_it_be(:developer) { create(:user, developer_of: group) }

  let(:current_user) { maintainer }
  let(:group_path) { group.full_path }
  let(:input) { { group_path: group_path, name: 'app-1', description: 'My app' } }
  let(:mutation) { graphql_mutation(:cd_application_create, input) }
  let(:mutation_response) { graphql_mutation_response(:cd_application_create) }

  context 'when the user is a maintainer' do
    it 'creates the application' do
      expect { post_graphql_mutation(mutation, current_user: current_user) }
        .to change { ::Cd::Application.count }.by(1)

      expect(mutation_response['errors']).to be_empty
      expect(mutation_response['application']).to include(
        'name' => 'app-1',
        'description' => 'My app'
      )
    end

    it_behaves_like 'authorizing granular token permissions for GraphQL', :create_cd_application do
      let(:user) { current_user }
      let(:boundary_object) { group }
      let(:mutation) { graphql_mutation(:cd_application_create, input, 'errors') }
      let(:request) { post_graphql_mutation(mutation, token: { personal_access_token: pat }) }
    end

    context 'when the name is already taken' do
      before do
        create(:cd_application, group: group, name: 'app-1')
      end

      it 'returns errors in the response' do
        expect { post_graphql_mutation(mutation, current_user: current_user) }
          .not_to change { ::Cd::Application.count }

        expect(mutation_response['application']).to be_nil
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

    it_behaves_like 'a mutation that returns a top-level access error'

    it 'does not create the application' do
      expect { post_graphql_mutation(mutation, current_user: current_user) }
        .not_to change { ::Cd::Application.count }
    end
  end

  context 'when the ai_native_deploy feature flag is disabled' do
    before do
      stub_feature_flags(ai_native_deploy: false)
    end

    it_behaves_like 'a mutation that returns a top-level access error'

    it 'does not create the application' do
      expect { post_graphql_mutation(mutation, current_user: current_user) }
        .not_to change { ::Cd::Application.count }
    end
  end

  context 'when creating at the organization level' do
    let_it_be(:organization) { create(:organization) }
    let_it_be(:organization_owner) { create(:organization_user, :owner, organization: organization).user }
    let_it_be(:organization_member) { create(:organization_user, organization: organization).user }

    let(:current_user) { organization_owner }
    let(:input) { { organization_id: organization.to_global_id.to_s, name: 'app-1', description: 'My app' } }

    it 'creates the application on the organization' do
      expect { post_graphql_mutation(mutation, current_user: current_user) }
        .to change { ::Cd::Application.count }.by(1)

      expect(mutation_response['errors']).to be_empty
      expect(::Cd::Application.last).to have_attributes(
        organization: organization,
        group: nil,
        name: 'app-1'
      )
    end

    it_behaves_like 'authorizing granular token permissions for GraphQL', :create_cd_application do
      let(:user) { current_user }
      let(:boundary_object) { :instance }
      let(:mutation) { graphql_mutation(:cd_application_create, input, 'errors') }
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

    let(:input) { super().merge(organization_id: organization.to_global_id.to_s) }

    it_behaves_like 'returns an exactly_one_of argument error'
  end

  context 'when neither group_path nor organization_id are provided' do
    let(:input) { { name: 'app-1' } }

    it_behaves_like 'returns an exactly_one_of argument error'
  end
end
