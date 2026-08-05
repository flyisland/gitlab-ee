# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Ai::DuoAgentPlatform::AccessPolicy, feature_category: :duo_agent_platform do
  let_it_be(:developer) { create(:user) }
  let_it_be(:reporter) { create(:user) }
  let_it_be(:non_member) { create(:user) }

  # `read_duo_agent_platform` is granted through roles (e.g. Developer) in
  # config/authz/roles. This concern prevents it unless the Duo Agent Platform is
  # enabled for the namespace AND the user is entitled (evaluated as if already
  # verified, so the identity verification gate doesn't block page access). These
  # examples hold the permission via a Developer membership and toggle each input.
  shared_examples 'gating read_duo_agent_platform on agent platform availability' do
    subject(:can_read) { policy_for(current_user).allowed?(:read_duo_agent_platform) }

    let(:current_user) { developer }
    let(:entitled) { true }

    before do
      allow(::Ai::DuoWorkflow).to receive(:duo_agent_platform_available?).with(container).and_return(dap_available)
      allow(container).to receive(:duo_features_enabled).and_return(duo_features_enabled)
      allow(::Gitlab::Llm::StageCheck).to receive(:available?)
        .with(container, :duo_workflow).and_return(stage_check_ready)
      allow(current_user).to receive(:allowed_to_use?)
        .with(:duo_agent_platform, root_namespace: container.root_ancestor, skip_identity_verification: true)
        .and_return(entitled)
    end

    context 'when the agent platform is enabled and the user is entitled' do
      let(:dap_available) { true }
      let(:duo_features_enabled) { true }
      let(:stage_check_ready) { true }

      it { is_expected.to be(true) }

      context 'and the user has no role granting the permission' do
        let(:current_user) { non_member }

        it { is_expected.to be(false) }
      end

      context 'and the user is a Reporter (a role below Developer)' do
        let(:current_user) { reporter }

        it { is_expected.to be(false) }
      end

      context 'and the user is not entitled to the agent platform' do
        let(:entitled) { false }

        it { is_expected.to be(false) }
      end
    end

    context 'when the agent platform is not available for the namespace' do
      let(:dap_available) { false }
      let(:duo_features_enabled) { true }
      let(:stage_check_ready) { true }

      it { is_expected.to be(false) }
    end

    context 'when Duo features are disabled' do
      let(:dap_available) { true }
      let(:duo_features_enabled) { false }
      let(:stage_check_ready) { true }

      it { is_expected.to be(false) }
    end

    context 'when the Duo Workflow stage check is unavailable' do
      let(:dap_available) { true }
      let(:duo_features_enabled) { true }
      let(:stage_check_ready) { false }

      it { is_expected.to be(false) }
    end
  end

  context 'for a project' do
    let_it_be(:container) { create(:project, group: create(:group), developers: developer, reporters: reporter) }

    def policy_for(user)
      ProjectPolicy.new(user, container)
    end

    it_behaves_like 'gating read_duo_agent_platform on agent platform availability'
  end

  context 'for a group' do
    let_it_be(:container) { create(:group, developers: developer, reporters: reporter) }

    def policy_for(user)
      GroupPolicy.new(user, container)
    end

    it_behaves_like 'gating read_duo_agent_platform on agent platform availability'
  end
end
