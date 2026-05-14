# frozen_string_literal: true

require 'spec_helper'

RSpec.describe ProjectsFinder, feature_category: :groups_and_projects do
  using RSpec::Parameterized::TableSyntax

  describe '#execute', :saas do
    let_it_be(:user) { create(:user) }
    let_it_be(:ultimate_project) { create_project(:ultimate_plan) }
    let_it_be(:ultimate_project2) { create_project(:ultimate_plan) }
    let_it_be(:premium_project) { create_project(:premium_plan) }
    let_it_be(:no_plan_project) { create_project(nil) }

    let(:current_user) { user }
    let(:project_ids_relation) { nil }
    let(:finder) { described_class.new(current_user:, params:, project_ids_relation:) }

    subject { finder.execute }

    describe 'filter by plans' do
      let(:params) { { plans: plans } }

      context 'with ultimate plan' do
        let(:plans) { ['ultimate'] }

        it { is_expected.to contain_exactly(ultimate_project, ultimate_project2) }
      end

      context 'with multiple plans' do
        let(:plans) { %w[ultimate premium] }

        it { is_expected.to contain_exactly(ultimate_project, ultimate_project2, premium_project) }
      end

      context 'with other plans' do
        let(:plans) { ['bronze'] }

        it { is_expected.to be_empty }
      end

      context 'without plans' do
        let(:plans) { nil }

        it { is_expected.to contain_exactly(ultimate_project, ultimate_project2, premium_project, no_plan_project) }
      end

      context 'with empty plans' do
        let(:plans) { [] }

        it { is_expected.to contain_exactly(ultimate_project, ultimate_project2, premium_project, no_plan_project) }
      end
    end

    it_behaves_like 'projects finder with SAML session filtering' do
      let(:finder) { described_class.new(current_user: current_user, params: params) }
    end

    context 'filter by hidden' do
      let_it_be(:hidden_project) { create(:project, :public, :hidden) }

      context 'when include hidden is true' do
        let_it_be(:params) { { include_hidden: true } }

        it do
          is_expected.to contain_exactly(ultimate_project, ultimate_project2, premium_project, no_plan_project,
            hidden_project)
        end
      end

      context 'when include hidden is false' do
        let_it_be(:params) { { include_hidden: false } }

        it { is_expected.to contain_exactly(ultimate_project, ultimate_project2, premium_project, no_plan_project) }
      end
    end

    context 'filter by feature available' do
      let_it_be(:private_premium_project) { create_project(:premium_plan, :private) }

      before do
        private_premium_project.add_owner(user)
      end

      context 'when feature_available filter is used' do
        # `product_analytics` is a feature available in Ultimate tier only
        let_it_be(:params) { { feature_available: 'product_analytics' } }

        it do
          is_expected.to contain_exactly(
            ultimate_project,
            ultimate_project2,
            premium_project,
            no_plan_project
          )
        end
      end

      context 'when feature_available filter is not used' do
        let_it_be(:params) { {} }

        it do
          is_expected.to contain_exactly(
            ultimate_project,
            ultimate_project2,
            premium_project,
            no_plan_project,
            private_premium_project
          )
        end
      end
    end

    context 'when filtering by duo_licensed_feature' do
      let_it_be_with_reload(:ns_ultimate) { create(:group_with_plan, plan: :ultimate_plan) }
      let_it_be_with_reload(:ns_premium) { create(:group_with_plan, plan: :premium_plan) }
      let_it_be_with_reload(:ns_free) { create(:group_with_plan, plan: :free_plan) }

      let_it_be_with_reload(:p_ultimate_duo_on) { create(:project, namespace: ns_ultimate) }
      let_it_be_with_reload(:p_ultimate_duo_off) { create(:project, namespace: ns_ultimate) }
      let_it_be_with_reload(:p_premium_duo_on) { create(:project, namespace: ns_premium) }
      let_it_be_with_reload(:p_free_duo_on) { create(:project, namespace: ns_free) }
      let_it_be_with_reload(:p_free_duo_off) { create(:project, namespace: ns_free) }

      let(:params) { { duo_licensed_feature: :agentic_chat } }

      before_all do
        [p_ultimate_duo_on, p_premium_duo_on, p_free_duo_on].each do |p|
          p.project_setting.update!(duo_features_enabled: true)
        end

        [p_ultimate_duo_off, p_free_duo_off].each do |p|
          p.project_setting.update!(duo_features_enabled: false)
        end

        [ns_ultimate, ns_free].each { |ns| ns.add_maintainer(user) }

        ns_premium.add_developer(user)
      end

      context 'when duo_licensed_feature param is blank' do
        let(:params) { { duo_licensed_feature: nil } }

        it 'returns all visible projects without duo filtering' do
          is_expected.to include(p_ultimate_duo_on, p_ultimate_duo_off, p_premium_duo_on, p_free_duo_on, p_free_duo_off)
        end
      end

      context 'when current_user is nil' do
        let(:current_user) { nil }

        it 'returns no projects' do
          is_expected.to be_empty
        end
      end

      context 'when current_user is an admin', :enable_admin_mode do
        let(:current_user) { create(:admin) }

        it 'returns all eligible projects for duo_licensed_feature' do
          is_expected.to include(p_ultimate_duo_on, p_premium_duo_on)
        end
      end

      context 'when current_user is an auditor' do
        let(:current_user) { create(:user, :auditor) }

        it 'returns all eligible projects for duo_licensed_feature' do
          is_expected.to include(p_ultimate_duo_on, p_premium_duo_on)
        end
      end

      context 'when feature is plan-based' do
        let(:params) { { duo_licensed_feature: :ai_features } }

        it 'returns eligible projects under namespaces with qualifying plans' do
          is_expected.to contain_exactly(p_ultimate_duo_on)
        end
      end

      context 'when feature is credits-eligible' do
        let_it_be(:credits_purchase) do
          create(:gitlab_subscription_add_on_purchase, :gitlab_credits, namespace: ns_free)
        end

        it 'includes projects under namespaces with purchased credits' do
          is_expected.to contain_exactly(p_ultimate_duo_on, p_free_duo_on)
        end

        context 'when filter_projects_by_duo_licensed_feature flag is disabled' do
          before do
            stub_feature_flags(filter_projects_by_duo_licensed_feature: false)
          end

          it 'excludes credits and filters by plan eligibility only' do
            is_expected.to contain_exactly(p_ultimate_duo_on)
          end
        end
      end

      context 'on Self-Managed' do
        before do
          stub_saas_features(gitlab_duo_saas_only: false)
        end

        context 'when feature is not available via instance license' do
          before do
            stub_licensed_features(agentic_chat: false)
          end

          it 'returns no projects' do
            is_expected.to be_empty
          end
        end

        context 'when feature is available via instance license' do
          before do
            stub_licensed_features(agentic_chat: true)
          end

          it 'returns all eligible projects for duo_licensed_feature' do
            is_expected.to contain_exactly(p_ultimate_duo_on, p_free_duo_on)
          end
        end
      end
    end

    context 'when filtering by with_duo_eligible' do
      let_it_be(:params) { { with_duo_eligible: true } }

      let_it_be_with_reload(:ns_gold) { create(:group) }
      let_it_be_with_reload(:ns_ultimate) { create(:group) }
      let_it_be_with_reload(:ns_trial) { create(:group) }
      let_it_be_with_reload(:ns_trial_paid) { create(:group) }
      let_it_be_with_reload(:ns_premium) { create(:group) }
      let_it_be_with_reload(:ns_oss) { create(:group) }
      let_it_be_with_reload(:ns_free) { create(:group) }

      let_it_be_with_reload(:p_gold) { create(:project, namespace: ns_gold) }
      let_it_be_with_reload(:p_ultimate) { create(:project, namespace: ns_ultimate) }
      let_it_be_with_reload(:p_trial) { create(:project, namespace: ns_trial) }
      let_it_be_with_reload(:p_trial_paid) { create(:project, namespace: ns_trial_paid) }
      let_it_be_with_reload(:p_premium) { create(:project, namespace: ns_premium) }
      let_it_be_with_reload(:p_oss) { create(:project, namespace: ns_oss) }
      let_it_be_with_reload(:p_free) { create(:project, namespace: ns_free) }

      before_all do
        [p_gold, p_ultimate, p_trial, p_trial_paid, p_premium, p_oss, p_free].each do |p|
          p.project_setting.update!(duo_features_enabled: true)
        end

        gold_plan = create(:gold_plan)
        ultimate_plan = create(:ultimate_plan)
        trial_plan = create(:ultimate_trial_plan)
        trial_paid_plan = create(:ultimate_trial_paid_customer_plan)
        premium_plan = create(:premium_plan)
        oss_plan = create(:opensource_plan)
        free_plan = create(:free_plan)

        create(:gitlab_subscription, namespace: ns_gold, hosted_plan: gold_plan)
        create(:gitlab_subscription, namespace: ns_ultimate, hosted_plan: ultimate_plan)
        create(:gitlab_subscription, namespace: ns_trial, hosted_plan: trial_plan)
        create(:gitlab_subscription, namespace: ns_trial_paid, hosted_plan: trial_paid_plan)
        create(:gitlab_subscription, namespace: ns_premium, hosted_plan: premium_plan)
        create(:gitlab_subscription, namespace: ns_oss, hosted_plan: oss_plan)
        create(:gitlab_subscription, namespace: ns_free, hosted_plan: free_plan)

        [ns_gold, ns_ultimate, ns_trial, ns_trial_paid, ns_premium, ns_oss, ns_free].each do |ns|
          ns.add_developer(user)
        end
      end

      it 'returns only projects under eligible plans and with duo toggles enabled' do
        is_expected.to contain_exactly(
          p_gold,
          p_ultimate,
          p_trial,
          p_trial_paid,
          p_premium,
          p_oss
        )
      end

      context 'when a project disables duo features locally' do
        before do
          p_ultimate.project_setting.update!(duo_features_enabled: false)
        end

        it 'excludes that project even if the namespace plan is eligible' do
          is_expected.to contain_exactly(p_gold, p_trial, p_trial_paid, p_premium, p_oss)
        end
      end

      context 'when `semantic_code_search_saas_ga` FF is disabled' do
        before do
          stub_feature_flags(semantic_code_search_saas_ga: false)
        end

        it 'does not return any projects' do
          is_expected.to be_empty
        end

        context 'when namespace settings have experiment_features_enabled=true' do
          before do
            [ns_gold, ns_ultimate, ns_trial, ns_trial_paid, ns_premium, ns_oss, ns_free].each do |ns|
              ns.namespace_settings.update!(experiment_features_enabled: true)
            end
          end

          it 'returns projects under eligible plans and with duo toggles enabled' do
            is_expected.to contain_exactly(
              p_gold,
              p_ultimate,
              p_trial,
              p_trial_paid,
              p_premium,
              p_oss
            )
          end
        end
      end
    end

    private

    def create_project(plan, visibility = :public)
      create(:project, visibility, namespace: create(:group_with_plan, plan: plan))
    end
  end
end
