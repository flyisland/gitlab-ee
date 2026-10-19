# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Namespace do
  describe '#actual_size_limit', :saas do
    let_it_be(:namespace) { create(:namespace) }
    let_it_be(:ultimate_limits) { create(:plan_limits, plan: create(:ultimate_plan), repository_size: 100) }
    let_it_be(:ultimate_namespace) { create(:namespace_with_plan, plan: :ultimate_plan) }

    before do
      allow(::Gitlab).to receive(:jh?).and_return(true)
    end

    it 'returns the actual size limit' do
      expect(ultimate_namespace.actual_size_limit).to eq(100)
      expect(namespace.actual_size_limit).to eq(::Gitlab::CurrentSettings.repository_size_limit)
    end
  end

  describe '#team_plan?', :saas do
    let(:group_with_team_plan) { create(:group) }
    let(:group_without_team_plan) { create(:group) }

    before do
      create(:gitlab_subscription, :team, namespace: group_with_team_plan)
    end

    it 'returns true for team plan' do
      expect(group_with_team_plan.team_plan?).to be_truthy
      expect(group_without_team_plan.team_plan?).to be_falsey
    end
  end

  describe '#actual_plan_without_generate_subscription' do
    let(:namespace) { create(:namespace) }
    let!(:ultimate_plan) { create(:ultimate_plan) }

    context 'when namespace does not have a subscription associated' do
      it 'returns default plan' do
        expect(namespace.actual_plan_without_generate_subscription).to eq(Plan.default)

        expect(namespace.gitlab_subscription).to be_nil
      end
    end

    context 'when running on Gitlab.com' do
      before do
        allow(Gitlab).to receive(:com?).and_return(true)
      end

      context 'for personal namespaces' do
        context 'when namespace has a subscription associated' do
          before do
            create(:gitlab_subscription, namespace: namespace, hosted_plan: ultimate_plan)
          end

          it 'returns the plan from the subscription' do
            expect(namespace.actual_plan_without_generate_subscription).to eq(ultimate_plan)
            expect(namespace.gitlab_subscription).to be_present
          end
        end

        context 'when namespace does not have a subscription associated' do
          it 'returns free plan without generates a subscription' do
            expect(namespace.actual_plan_without_generate_subscription).to eq(Plan.free)
            expect(namespace.gitlab_subscription).not_to be_present
          end
        end
      end

      context 'for groups' do
        context 'when the group is a subgroup with a parent' do
          let(:parent) { create(:group) }
          let(:subgroup) { create(:group, parent: parent) }

          context 'when parent group has a subscription associated' do
            before do
              create(:gitlab_subscription, namespace: parent, hosted_plan: ultimate_plan)
            end

            it 'returns the plan from the subscription' do
              expect(subgroup.actual_plan).to eq(ultimate_plan)
              expect(subgroup.gitlab_subscription).not_to be_present
            end
          end
        end
      end
    end
  end
end
