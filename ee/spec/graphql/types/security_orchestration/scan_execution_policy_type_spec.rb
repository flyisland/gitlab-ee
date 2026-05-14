# frozen_string_literal: true

require 'spec_helper'

RSpec.describe GitlabSchema.types['ScanExecutionPolicy'], feature_category: :security_policy_management do
  let(:fields) { %i[id policy_configuration_id description edit_path enabled name updated_at yaml policy_scope csp] }

  include_context 'with scan execution policy specific fields'

  it { expect(described_class).to have_graphql_fields(fields + type_specific_fields) }

  describe '#updated_at' do
    include GraphqlHelpers

    let(:policy_last_updated_at) { Time.current }
    let(:config) { instance_double(Security::OrchestrationPolicyConfiguration) }
    let(:policy_object) { { config: config } }

    before do
      allow(config).to receive(:policy_last_updated_at).and_return(policy_last_updated_at)
    end

    it 'resolves updated_at lazily from config' do
      result = resolve_field(:updated_at, policy_object, object_type: described_class)

      expect(result).to eq(policy_last_updated_at)
      expect(config).to have_received(:policy_last_updated_at)
    end

    context 'when config is nil' do
      let(:policy_object) { { config: nil } }

      it 'returns nil' do
        result = resolve_field(:updated_at, policy_object, object_type: described_class)

        expect(result).to be_nil
      end
    end
  end

  describe '#id' do
    include GraphqlHelpers

    let(:policy_name) { 'test-policy' }
    let(:policy_type) { 'scan_execution_policy' }
    let(:policy_index) { 0 }
    let(:policy_object) { { name: policy_name, type: policy_type, policy_index: policy_index, config: config } }

    context 'when security policy exists' do
      let_it_be(:security_policy) { create(:security_policy, :scan_execution_policy) }
      let(:config) { security_policy.security_orchestration_policy_configuration }
      let(:policy_name) { security_policy.name }
      let(:policy_index) { security_policy.policy_index }

      it 'returns the global ID of the security policy' do
        result = resolve_field(:id, policy_object, object_type: described_class)

        expect(result).to be_a(GraphQL::Execution::Lazy)
        expect(result.value).to eq(security_policy.to_global_id)
      end
    end

    context 'when security policy does not exist' do
      let_it_be(:config) { create(:security_orchestration_policy_configuration) }

      it 'returns nil' do
        result = resolve_field(:id, policy_object, object_type: described_class)

        expect(result).to be_a(GraphQL::Execution::Lazy)
        expect(result.value).to be_nil
      end
    end

    context 'when config is nil' do
      let(:policy_object) { { name: policy_name, type: policy_type, policy_index: policy_index, config: nil } }

      it 'returns nil' do
        result = resolve_field(:id, policy_object, object_type: described_class)

        expect(result).to be_nil
      end
    end
  end

  describe '#policy_configuration_id' do
    include GraphqlHelpers

    let_it_be(:config) { create(:security_orchestration_policy_configuration) }

    it 'returns the global ID of the policy configuration' do
      result = resolve_field(:policy_configuration_id, { config: config }, object_type: described_class)

      expect(result).to eq(config.to_global_id)
    end

    context 'when config is nil' do
      it 'returns nil' do
        result = resolve_field(:policy_configuration_id, { config: nil }, object_type: described_class)

        expect(result).to be_nil
      end
    end
  end
end
