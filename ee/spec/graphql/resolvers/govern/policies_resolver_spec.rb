# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Resolvers::Govern::PoliciesResolver, :policy_store,
  feature_category: :security_policy_management do
  include GraphqlHelpers
  include_context 'with the policy store experiment active'

  let_it_be(:organization) { create(:organization) }
  let_it_be(:other_organization) { create(:organization) }
  let_it_be(:current_user) { create(:organization_user, :owner, organization: organization).user }

  let(:parent) { organization }
  let(:args) { {} }

  let!(:deployment_policy) do
    create_policy(organization_id: organization.id, name: 'Deployment policy', trigger_type: 'deployment_requested')
  end

  let!(:other_organization_policy) do
    create_policy(organization_id: other_organization.id, name: 'Other policy', trigger_type: 'deployment_requested')
  end

  before do
    opt_organization_into_policy_store!(organization)
  end

  subject(:result) { resolve(described_class, obj: parent, args: args, ctx: { current_user: current_user }) }

  it 'returns only the policies of the organization' do
    expect(result).to contain_exactly(deployment_policy)
  end

  context 'when the parent is a group' do
    let_it_be(:group) { create(:group) }

    let(:parent) { group }

    it { is_expected.to be_nil }
  end

  context 'with a trigger_type argument' do
    let(:args) { { trigger_type: 'deployment_requested' } }

    it 'returns the policies responding to the trigger' do
      expect(result).to contain_exactly(deployment_policy)
    end

    context 'with a trigger type REST rejects as invalid' do
      let(:args) { { trigger_type: 'unknown_trigger' } }

      # Deliberate divergence: REST returns 400 for unknown triggers, GraphQL keeps the
      # argument a String (the catalog is data) and returns an empty list instead.
      it { is_expected.to be_empty }
    end
  end

  context 'with an ids argument' do
    let!(:promoted_policy) do
      create_policy(organization_id: organization.id, name: 'Promoted policy', trigger_type: 'deployment_promoted')
    end

    let(:args) { { ids: [deployment_policy.id] } }

    it 'returns only the policies with those ids' do
      expect(result).to contain_exactly(deployment_policy)
    end

    context 'when combined with trigger_type' do
      let(:args) { { ids: [deployment_policy.id, promoted_policy.id], trigger_type: 'deployment_promoted' } }

      it 'returns only the policies matching both filters' do
        expect(result).to contain_exactly(promoted_policy)
      end
    end

    context 'with ids no policy has' do
      let(:args) { { ids: [non_existing_record_id] } }

      it { is_expected.to be_empty }
    end

    context 'when the user is not an organization owner and passes ids' do
      let_it_be(:current_user) { create(:user) }

      it { is_expected.to be_nil }
    end

    context 'when ids exceeds the port limit' do
      let(:args) { { ids: Array.new(Gitlab::PolicyStore::Ports::PolicyRepository::MAX_PER_PAGE + 1) { |index| index } } }

      # graphql-ruby catches a GraphQL::ExecutionError raised from #resolve and returns it
      # as the field's value rather than letting it propagate, so it is asserted here, not raised.
      it 'returns a GraphQL execution error naming the limit', :aggregate_failures do
        expect(result).to be_a(GraphQL::ExecutionError)
        expect(result.message).to match(/ids exceeds maximum/)
      end
    end
  end

  context 'when the user is not an organization owner' do
    let_it_be(:current_user) { create(:user) }

    it { is_expected.to be_nil }
  end

  context 'when the feature flag is disabled' do
    before do
      stub_feature_flags(security_policies_v2: false)
    end

    it { is_expected.to be_nil }
  end

  context 'when the experiment is disabled for the instance' do
    before do
      stub_application_setting(policy_store_experiment_enabled: false)
    end

    it { is_expected.to be_nil }
  end

  context 'when the license does not include security orchestration policies' do
    before do
      stub_licensed_features(security_orchestration_policies: false)
    end

    it { is_expected.to be_nil }
  end

  describe 'schema execution' do
    let_it_be(:organization_owner) { create(:organization_user, :owner, organization: organization).user }

    it 'resolves ids through the value object, which BaseObject#id cannot answer' do
      result = GitlabSchema.execute(
        "{ organization(id: \"#{organization.to_global_id}\") " \
          '{ policyStore { policies { id name triggerType } } } }',
        context: { current_user: organization_owner }
      ).to_h

      expect(result['errors']).to be_nil
      expect(result.dig('data', 'organization', 'policyStore', 'policies')).to contain_exactly(
        { 'id' => deployment_policy.id, 'name' => 'Deployment policy', 'triggerType' => 'deployment_requested' }
      )
    end
  end
end
