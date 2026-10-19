# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Namespaces::Storage::RepositoryLimit::Enforcement, feature_category: :consumables_cost_management do
  using RSpec::Parameterized::TableSyntax

  let(:namespace) { build_stubbed(:group, additional_purchased_storage_size: additional_purchased_storage_size) }
  let(:total_repository_size_excess) { 50.megabytes }
  let(:additional_purchased_storage_size) { 100 }
  let(:model) { described_class.new(namespace) }
  let(:root_namespace) { namespace }

  before do
    allow(root_namespace).to receive(:total_repository_size_excess).and_return(total_repository_size_excess)
  end

  # jh_disable_subject_to_high_limit value is false, copy from upstream
  describe '#subject_to_high_limit?', :saas do
    before do
      stub_feature_flags(jh_disable_subject_to_high_limit: false)
      namespace.actual_plan.actual_limits.update!(repository_size: 10)
    end

    where :plan_name, :is_subject_to_high_limit do
      :default_plan                      | false
      :free_plan                         | false
      :bronze_plan                       | true
      :silver_plan                       | true
      :premium_plan                      | true
      :gold_plan                         | true
      :ultimate_plan                     | true
      :ultimate_trial_plan               | false
      :ultimate_trial_paid_customer_plan | true
      :premium_trial_plan                | false
      :opensource_plan                   | true
    end

    with_them do
      let(:namespace) { create(:group_with_plan, plan: plan_name) }

      it { expect(model.subject_to_high_limit?).to be is_subject_to_high_limit }
    end
  end

  # jh_disable_subject_to_high_limit value is true
  describe '#subject_to_high_limit? with jh_disable_subject_to_high_limit opened', :saas do
    before do
      stub_feature_flags(jh_disable_subject_to_high_limit: true)
      namespace.actual_plan.actual_limits.update!(repository_size: 10)
    end

    where :plan_name, :is_subject_to_high_limit do
      :default_plan                      | false
      :free_plan                         | false
      :bronze_plan                       | false
      :silver_plan                       | false
      :premium_plan                      | false
      :gold_plan                         | false
      :ultimate_plan                     | false
      :ultimate_trial_plan               | false
      :ultimate_trial_paid_customer_plan | false
      :premium_trial_plan                | false
      :opensource_plan                   | false
    end

    with_them do
      let(:namespace) { create(:group_with_plan, plan: plan_name) }

      it { expect(model.subject_to_high_limit?).to be is_subject_to_high_limit }
    end
  end

  describe '#has_projects_over_high_limit_warning_threshold?', :saas do
    let_it_be_with_refind(:namespace) { create(:group_with_plan, plan: :ultimate_plan) }
    let_it_be_with_refind(:project) { create(:project, namespace: namespace) }

    let(:project_size) { 91.gigabytes }

    before do
      stub_feature_flags(jh_disable_subject_to_high_limit: false)
      namespace.update!(additional_purchased_storage_size: additional_purchased_storage_size)
      namespace.actual_plan.actual_limits.update!(repository_size: 100.gigabytes)
      project.statistics.update!(repository_size: project_size)
    end

    context 'with purchased storage and project usage combinations' do
      where :additional_purchased_storage_size, :total_repository_size_excess, :project_size, :is_over_threshold do
        100 | 50.megabytes  | 91.gigabytes  | false
        100 | 89.megabytes  | 91.gigabytes  | false
        100 | 50.megabytes  | 101.gigabytes | false
        100 | 90.megabytes  | 91.gigabytes  | false
        100 | 90.megabytes  | 80.gigabytes  | false
        100 | 90.megabytes  | 101.gigabytes | true
        100 | 100.megabytes | 91.gigabytes  | true
        100 | 0             | 91.gigabytes  | true
        0   | 0             | 91.gigabytes  | true
        0   | 1.megabyte    | 91.gigabytes  | true
      end

      with_them do
        it 'returns the expected boolean value' do
          expect(model.has_projects_over_high_limit_warning_threshold?).to be is_over_threshold
        end
      end
    end

    context 'when jh_disable_subject_to_high_limit is enabled' do
      let(:total_repository_size_excess) { 90.megabytes }

      before do
        stub_feature_flags(jh_disable_subject_to_high_limit: true)
      end

      it { expect(model.has_projects_over_high_limit_warning_threshold?).to be false }
    end

    context 'when group is not subject to high limit' do
      let_it_be_with_refind(:namespace) { create(:group_with_plan, plan: :free_plan) }
      let(:total_repository_size_excess) { 90.megabytes }

      it { expect(model.has_projects_over_high_limit_warning_threshold?).to be false }
    end
  end
end
