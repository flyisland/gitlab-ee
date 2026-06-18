# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Deployment, feature_category: :continuous_delivery do
  let_it_be(:user1) { create(:user) }
  let_it_be(:user2) { create(:user) }
  let_it_be(:project, freeze: false) { create(:project, :repository) }

  let_it_be(:environment) { create(:environment, project: project) }
  let_it_be_with_refind(:deployment) { create(:deployment, :blocked, project: project, environment: environment) }

  let_it_be(:group1, freeze: false) { create(:group, name: 'group1', maintainers: [user1]) }
  let_it_be(:group2, freeze: false) { create(:group, name: 'group2', maintainers: [user2]) }

  let_it_be(:approval_rule1, freeze: false) do
    create(:protected_environment_approval_rule, group: group1, required_approvals: 1)
  end

  let_it_be(:approval_rule2, freeze: false) do
    create(:protected_environment_approval_rule, group: group2, required_approvals: 1)
  end

  let!(:protected_environment) do
    create(:protected_environment, :maintainers_can_deploy, name: environment.name, project: project,
      approval_rules: [approval_rule1, approval_rule2])
  end

  it { is_expected.to have_many(:approvals) }
  it { is_expected.to delegate_method(:needs_approval?).to(:environment) }

  describe 'state machine' do
    context 'when transitioning to :running' do
      it 'calls the audit service' do
        service = instance_double(Environments::Deployments::AuditService)

        expect(Environments::Deployments::AuditService).to receive(:new).with(deployment).and_return(service)
        expect(service).to receive(:execute)

        deployment.run!
      end
    end
  end

  describe '#waiting_for_approval?' do
    subject { deployment.waiting_for_approval? }

    context 'when Protected Environments feature is available' do
      before do
        stub_licensed_features(protected_environments: true)
      end

      context 'when pending approval count is positive' do
        it { is_expected.to be(true) }
      end

      context 'when pending approval count is zero' do
        before do
          create(
            :deployment_approval,
            deployment: deployment,
            approval_rule_id: approval_rule1.id
          )
          create(
            :deployment_approval,
            deployment: deployment,
            approval_rule_id: approval_rule2.id
          )
        end

        it { is_expected.to be(false) }
      end
    end

    context 'when Protected Environments feature is not available' do
      before do
        stub_licensed_features(protected_environments: false)
      end

      it { is_expected.to be(false) }
    end
  end

  describe '#pending_approval_count' do
    context 'when Protected Environments feature is available' do
      before do
        stub_licensed_features(protected_environments: true)
        protected_environment
      end

      context 'with no approvals' do
        it 'returns the number of approvals required by the environment' do
          expect(deployment.pending_approval_count).to eq(2)
        end
      end

      context 'with some approvals' do
        before do
          create(
            :deployment_approval,
            deployment: deployment,
            approval_rule_id: approval_rule1.id
          )
        end

        it 'returns the number of pending approvals' do
          expect(deployment.pending_approval_count).to eq(1)
        end
      end

      # In this case we have 2 separate rules that need to be satisfied.
      # We want to make sure that we get enough approvals per rule, not just a
      # a sum of all approvals.
      context 'when sum is enough but not all rules are satisfied' do
        before do
          create(
            :deployment_approval,
            deployment: deployment,
            approval_rule_id: approval_rule1.id
          )

          create(
            :deployment_approval,
            deployment: deployment,
            approval_rule_id: approval_rule1.id
          )
        end

        it 'returns the number of pending approvals' do
          expect(deployment.pending_approval_count).to eq(1)
        end
      end

      context 'with all approvals satisfied' do
        let(:approval_rules) { [approval_rule1, app] }

        before do
          create(
            :deployment_approval,
            deployment: deployment,
            approval_rule_id: approval_rule1.id
          )
          create(
            :deployment_approval,
            deployment: deployment,
            approval_rule_id: approval_rule2.id
          )
        end

        it 'returns zero' do
          expect(deployment.pending_approval_count).to eq(0)
        end
      end

      context 'with a protected environment that does not require approval' do
        let(:protected_environment) do
          create(:protected_environment, name: environment.name, project: project)
        end

        let(:deployment) { create(:deployment, :success, project: project, environment: environment) }

        it 'returns zero' do
          expect(deployment.pending_approval_count).to eq(0)
        end
      end

      context 'when loading approval count' do
        before do
          deployment.environment.required_approval_count
          deployment.approvals.to_a
        end

        it 'does not perform an extra query when approvals are loaded', :request_store do
          expect { deployment.pending_approval_count }.not_to exceed_query_limit(0)
        end
      end
    end

    context 'when Protected Environments feature is not available' do
      before do
        stub_licensed_features(protected_environments: false)
      end

      it 'returns zero' do
        expect(deployment.pending_approval_count).to eq(0)
      end
    end
  end
end
