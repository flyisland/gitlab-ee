# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Resolvers::ProjectsResolver, feature_category: :groups_and_projects do
  include GraphqlHelpers

  describe '#resolve' do
    subject { resolve(described_class, obj: nil, args: filters, ctx: { current_user: user }).items }

    let_it_be(:user) { create(:user) }
    let_it_be(:project) { create(:project, developers: user) }
    let_it_be(:marked_for_deletion_on) { Date.yesterday }
    let_it_be(:hidden_project) { create(:project, :hidden, developers: user) }

    let_it_be(:project_marked_for_deletion) do
      create(:project, marked_for_deletion_at: marked_for_deletion_on, developers: user)
    end

    let(:filters) { {} }

    before do
      ::Current.organization = project.organization
    end

    context 'when includeHidden filter is true' do
      let(:filters) { { include_hidden: true } }

      it do
        is_expected.to contain_exactly(project, hidden_project, project_marked_for_deletion)
      end
    end

    context 'when includeHidden filter is false' do
      let(:filters) { { include_hidden: false } }

      it { is_expected.to contain_exactly(project, project_marked_for_deletion) }
    end

    context 'when requesting duo_licensed_feature', :saas do
      let_it_be(:ns_ultimate) { create(:group_with_plan, plan: :ultimate_plan) }
      let_it_be(:p_ultimate_duo_on)  { create(:project, namespace: ns_ultimate) }
      let_it_be(:p_ultimate_duo_off) { create(:project, namespace: ns_ultimate) }

      let(:filters) { { duo_licensed_feature: 'ai_features' } }

      before_all do
        p_ultimate_duo_on.project_setting.update!(duo_features_enabled: true)
        p_ultimate_duo_off.project_setting.update!(duo_features_enabled: false)
        ns_ultimate.add_maintainer(user)
      end

      context 'when duo_features_enabled is true' do
        it { is_expected.to contain_exactly(p_ultimate_duo_on) }
      end

      context 'on Self-Managed' do
        before do
          stub_saas_features(gitlab_duo_saas_only: false)
        end

        context 'when feature is not available via instance license' do
          before do
            stub_licensed_features(ai_features: false)
          end

          it { is_expected.to be_empty }
        end

        context 'when feature is available via instance license' do
          before do
            stub_licensed_features(ai_features: true)
          end

          it { is_expected.to contain_exactly(p_ultimate_duo_on) }
        end
      end
    end

    context 'when requesting with_duo_eligible', :saas do
      let(:filters) { { with_duo_eligible: true } }

      it { is_expected.to be_empty }

      context 'with eligible ultimate project and namespace' do
        let!(:ns_ultimate) { create(:group_with_plan, plan: :ultimate_plan) }
        let!(:p_ultimate) { create(:project, namespace: ns_ultimate) }

        before do
          p_ultimate.project_setting.update!(duo_features_enabled: true)
          ns_ultimate.namespace_settings.update!(experiment_features_enabled: true)
          ns_ultimate.add_developer(user)
        end

        it { is_expected.to contain_exactly(p_ultimate) }
      end

      context 'with eligible premium project and namespace' do
        let!(:ns_premium) { create(:group_with_plan, plan: :premium_plan) }
        let!(:p_premium) { create(:project, namespace: ns_premium) }

        before do
          p_premium.project_setting.update!(duo_features_enabled: true)
          ns_premium.namespace_settings.update!(experiment_features_enabled: true)
          ns_premium.add_developer(user)
        end

        it { is_expected.to contain_exactly(p_premium) }
      end
    end
  end
end
