# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Group policyStore policies', feature_category: :security_policy_management do
  include GraphqlHelpers
  include_context 'with policy store service authorization'
  include_context 'with policy store group containers'

  let_it_be(:group_developer) { create(:user, developer_of: group) }

  let_it_be(:policy) { create(:govern_policy, namespace: group) }
  let_it_be(:organization_policy) { create(:govern_policy, :without_namespace, organization: organization) }
  let_it_be(:other_group_policy) { create(:govern_policy, namespace: other_group) }

  let(:current_user) { group_owner }
  let(:arguments) { {} }

  let(:query) do
    <<~QUERY
      query groupPolicyStorePolicies($fullPath: ID!, $ids: [Int!]) {
        group(fullPath: $fullPath) {
          policyStore {
            policies(ids: $ids) {
              nodes { id name namespaceId }
            }
          }
        }
      }
    QUERY
  end

  subject(:request) do
    post_graphql(query, current_user: current_user, variables: { fullPath: group.full_path }.merge(arguments))
  end

  def policy_store
    graphql_data.dig('group', 'policyStore')
  end

  def policies
    policy_store&.dig('policies', 'nodes')
  end

  it "returns the group's own and inherited organization-wide policies, but not a sibling group's" do
    request

    expect(policies).to contain_exactly(
      { 'id' => policy.id, 'name' => policy.name, 'namespaceId' => group.id },
      { 'id' => organization_policy.id, 'name' => organization_policy.name, 'namespaceId' => nil }
    )
  end

  context 'with ids' do
    let(:arguments) { { ids: [policy.id, organization_policy.id, other_group_policy.id] } }

    it 'returns only the requested policies the group can read' do
      request

      expect(policies).to contain_exactly(
        a_hash_including('id' => policy.id), a_hash_including('id' => organization_policy.id)
      )
    end
  end

  context 'when the user is a group member without the owner role' do
    let(:current_user) { group_developer }

    it 'returns null policies while the catalogs stay reachable' do
      request

      expect(policy_store).to be_present
      expect(policy_store['policies']).to be_nil
      expect_graphql_errors_to_be_empty
    end
  end

  context 'when the user owns a sibling group in the same organization' do
    let(:current_user) { create(:user, owner_of: other_group) }

    it 'returns null policies' do
      request

      expect(policies).to be_nil
      expect_graphql_errors_to_be_empty
    end
  end

  describe 'granular token permissions' do
    let(:user) { create(:user, organization: organization, owner_of: group) }
    let(:request) do
      post_graphql(query, variables: { fullPath: group.full_path }, token: { personal_access_token: pat })
    end

    it_behaves_like 'authorizing granular token permissions for GraphQL', [:read_group, :read_govern_policy] do
      let(:boundary_object) { group }
    end

    def granular_token(boundary_object, permissions)
      assignables = permissions.map do |permission|
        ::Authz::PermissionGroups::Assignable.for_permission(permission).min_by(&:name).name
      end

      create(:granular_pat, user: user, boundary: ::Authz::Boundary.for(boundary_object), permissions: assignables.uniq)
    end

    context 'with a token scoped to the group' do
      let(:pat) { granular_token(group, [:read_group, :read_govern_policy]) }

      it "returns the group's own and inherited policies" do
        request

        expect(policies).to contain_exactly(
          a_hash_including('id' => policy.id), a_hash_including('id' => organization_policy.id)
        )
      end
    end

    context 'with a token scoped to the group that cannot read policies' do
      let(:pat) { granular_token(group, [:read_group]) }

      it 'returns null policies' do
        request

        expect(policy_store).to be_present
        expect(policy_store['policies']).to be_nil
      end
    end

    context 'with a token scoped to the instance' do
      let(:pat) { granular_token(:instance, [:read_group, :read_govern_policy]) }

      it 'returns null policies, because the group being read is the boundary' do
        request

        expect(policy_store['policies']).to be_nil
      end
    end
  end
end
