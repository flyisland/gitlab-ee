# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Resolvers::Security::PolicyTestRunsResolver, feature_category: :security_policy_management do
  include GraphqlHelpers

  let_it_be(:project) { create(:project) }
  let_it_be(:policy_management_project) { create(:project) }
  let_it_be(:user) { create(:user) }

  let_it_be(:policy_configuration) do
    create(
      :security_orchestration_policy_configuration,
      security_policy_management_project: policy_management_project,
      project: project
    )
  end

  let_it_be(:security_policy) do
    create(:security_policy, :pipeline_execution_schedule_policy,
      name: 'test-policy',
      security_orchestration_policy_configuration: policy_configuration)
  end

  let(:policy_hash) do
    {
      policy_index: 0,
      type: 'pipeline_execution_schedule_policy'
    }
  end

  let(:ctx) { { current_user: user, security_policy_parent: project } }

  subject(:resolve_test_runs) { resolve(described_class, obj: policy_hash, ctx: ctx) }

  describe '#resolve' do
    context 'when policy type is not pipeline_execution_schedule_policy' do
      let(:policy_hash) do
        {
          policy_index: 0,
          type: 'scan_execution_policy'
        }
      end

      it 'returns empty results' do
        expect(resolve_test_runs.items).to be_empty
      end
    end

    context 'when policy_index is nil' do
      let(:policy_hash) do
        {
          policy_index: nil,
          type: 'pipeline_execution_schedule_policy'
        }
      end

      it 'returns empty results' do
        expect(resolve_test_runs.items).to be_empty
      end
    end

    context 'when security_policy_parent is not set in context' do
      let(:ctx) { { current_user: user } }

      it 'returns empty results' do
        expect(resolve_test_runs.items).to be_empty
      end
    end

    context 'when there is no policy configuration for the parent' do
      let_it_be(:other_project) { create(:project) }
      let(:ctx) { { current_user: user, security_policy_parent: other_project } }

      it 'returns empty results' do
        expect(resolve_test_runs.items).to be_empty
      end
    end

    context 'when the security policy is not found' do
      let(:policy_hash) do
        {
          policy_index: 999,
          type: 'pipeline_execution_schedule_policy'
        }
      end

      it 'returns empty results' do
        expect(resolve_test_runs.items).to be_empty
      end
    end
  end
end
