# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Resolvers::Ai::DuoWorkflows::GroupSessionArtifactsResolver, feature_category: :duo_agent_platform do
  include GraphqlHelpers

  let_it_be(:group) { create(:group) }
  let(:args) { {} }
  let_it_be(:owner) { create(:user) }

  # Access is gated on :read_agent_artifacts, a custom ability granted via
  # member roles (requires the custom_roles license).
  let_it_be(:owner_role) { create(:member_role, :guest, :read_agent_artifacts, namespace: group) }
  let_it_be(:owner_membership) do
    create(:group_member, :guest, member_role: owner_role, user: owner, group: group)
  end

  before do
    stub_licensed_features(
      custom_roles: true,
      project_level_compliance_dashboard: true,
      group_level_compliance_dashboard: true
    )
    stub_feature_flags(agent_artifacts_page: true)
    allow(::Gitlab::ClickHouse).to receive(:globally_enabled_for_analytics?).and_return(false)
  end

  subject(:resolve_artifacts) do
    resolve(described_class, obj: group, args: args, ctx: { current_user: owner })
  end

  describe '#resolve' do
    context 'when the feature flag is disabled' do
      before do
        stub_feature_flags(agent_artifacts_page: false)
      end

      it 'returns an empty relation' do
        expect(resolve_artifacts).to be_empty
      end
    end

    context 'when ClickHouse is not enabled for analytics' do
      context 'with no filter arguments' do
        it 'does not raise an error' do
          expect { resolve_artifacts }.not_to raise_error
        end
      end

      context 'with filter arguments' do
        let(:args) { { workflow_definition: 'chat' } }

        it 'returns an ArgumentError' do
          expect(resolve_artifacts).to be_a(Gitlab::Graphql::Errors::ArgumentError)
          expect(resolve_artifacts.message).to match(/requires ClickHouse to be enabled/)
        end
      end

      context 'with negated filter arguments' do
        let(:args) { { not: { workflow_definition: 'chat' } } }

        it 'returns an ArgumentError' do
          expect(resolve_artifacts).to be_a(Gitlab::Graphql::Errors::ArgumentError)
          expect(resolve_artifacts.message).to match(/requires ClickHouse to be enabled/)
        end
      end
    end

    context 'when ClickHouse is enabled for analytics' do
      before do
        allow(::Gitlab::ClickHouse).to receive(:globally_enabled_for_analytics?).and_return(true)
      end

      context 'with filter arguments' do
        let(:args) { { workflow_definition: 'chat' } }

        it 'does not raise an error' do
          expect { resolve_artifacts }.not_to raise_error
        end
      end

      context 'when workflowCreatedAfter is later than workflowCreatedBefore' do
        let(:args) { { workflow_created_after: 1.day.ago, workflow_created_before: 2.days.ago } }

        it 'returns an ArgumentError' do
          expect(resolve_artifacts).to be_a(Gitlab::Graphql::Errors::ArgumentError)
          expect(resolve_artifacts.message).to include('workflowCreatedAfter must be before workflowCreatedBefore')
        end
      end

      context 'when workflowCreatedAfter is before workflowCreatedBefore' do
        let(:args) { { workflow_created_after: 2.days.ago, workflow_created_before: 1.day.ago } }

        it 'does not raise an error' do
          expect(resolve_artifacts).not_to be_a(Gitlab::Graphql::Errors::ArgumentError)
        end
      end
    end
  end
end
