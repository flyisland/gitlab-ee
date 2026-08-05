# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Security::DependencyFirewallActivityStat, feature_category: :dependency_firewall do
  let_it_be(:project) { create(:project) }
  let_it_be(:rule) { create(:dependency_firewall_policy_rule) }

  around do |example|
    freeze_time { example.run }
  end

  describe 'associations' do
    it { is_expected.to belong_to(:dependency_firewall_policy_rule).optional }
    it { is_expected.to belong_to(:project).required }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:stat_time) }
    it { is_expected.to validate_presence_of(:outcome) }
    it { is_expected.to validate_numericality_of(:count).is_greater_than_or_equal_to(0) }

    it 'is invalid when an allowed row carries a rule_id' do
      stat = described_class.new(project: project, dependency_firewall_policy_rule: rule,
        outcome: :allowed, count: 1, stat_time: Time.current.beginning_of_hour)

      expect(stat).to be_invalid
      expect(stat.errors[:dependency_firewall_policy_rule_id]).to include('must be blank when outcome is allowed')
    end

    it 'is valid when a blocked row carries a rule_id' do
      stat = described_class.new(project: project, dependency_firewall_policy_rule: rule,
        outcome: :blocked, count: 1, stat_time: Time.current.beginning_of_hour)

      expect(stat).to be_valid
    end
  end

  describe 'factory' do
    it 'cannot be created with the default rule once the outcome is :allowed' do
      expect { create(:dependency_firewall_activity_stat, outcome: :allowed) }
        .to raise_error(ActiveRecord::RecordInvalid, /must be blank when outcome is allowed/)
    end

    it 'builds a valid rule-less allowed row via the :allowed trait' do
      stat = create(:dependency_firewall_activity_stat, :allowed)

      expect(stat).to have_attributes(outcome: 'allowed', dependency_firewall_policy_rule_id: nil)
    end
  end

  describe 'enums' do
    it { is_expected.to define_enum_for(:outcome).with_values(blocked: 0, warned: 1, allowed: 2).with_prefix }
  end

  describe 'check_allowed_outcome_has_null_rule constraint' do
    let(:hour) { Time.current.beginning_of_hour }

    it 'rejects an allowed row with a rule_id via increment! (which bypasses model validation)' do
      expect do
        described_class.increment!(project_id: project.id, rule_id: rule.id, outcome: :allowed)
      end.to raise_error(ActiveRecord::StatementInvalid, /check_allowed_outcome_has_null_rule/)
    end

    it 'permits an allowed row with a NULL rule_id' do
      expect do
        described_class.create!(project: project, dependency_firewall_policy_rule: nil,
          outcome: :allowed, count: 1, stat_time: hour)
      end.not_to raise_error
    end

    it 'permits a blocked or warned row that carries a rule_id' do
      expect do
        described_class.create!(project: project, dependency_firewall_policy_rule: rule,
          outcome: :blocked, count: 1, stat_time: hour)
      end.not_to raise_error
    end
  end

  describe 'scopes' do
    let_it_be(:other_project) { create(:project) }
    let_it_be(:other_rule) { create(:dependency_firewall_policy_rule) }

    let_it_be(:in_scope) do
      create(:dependency_firewall_activity_stat, dependency_firewall_policy_rule: rule, project: project,
        outcome: :blocked, stat_time: 1.hour.ago.beginning_of_hour)
    end

    let_it_be(:other_project_stat) do
      create(:dependency_firewall_activity_stat, dependency_firewall_policy_rule: rule, project: other_project,
        outcome: :blocked, stat_time: 1.hour.ago.beginning_of_hour)
    end

    let_it_be(:other_rule_stat) do
      create(:dependency_firewall_activity_stat, dependency_firewall_policy_rule: other_rule, project: project,
        outcome: :blocked, stat_time: 1.hour.ago.beginning_of_hour)
    end

    let_it_be(:old_stat) do
      create(:dependency_firewall_activity_stat, dependency_firewall_policy_rule: rule, project: project,
        outcome: :blocked, stat_time: 2.days.ago.beginning_of_hour)
    end

    it '.for_rules limits to the given rule ids' do
      expect(described_class.for_rules([rule.id])).to contain_exactly(in_scope, other_project_stat, old_stat)
    end

    it '.for_projects limits to the given project ids' do
      expect(described_class.for_projects([project.id])).to contain_exactly(in_scope, other_rule_stat, old_stat)
    end

    it '.for_projects accepts a project relation and filters via WHERE EXISTS', :aggregate_failures do
      relation_scope = described_class.for_projects(Project.where(id: project.id))

      expect(relation_scope.to_sql).to include('EXISTS')
      expect(relation_scope).to contain_exactly(in_scope, other_rule_stat, old_stat)
    end

    it '.in_time_range limits to rows whose stat_time falls in the range' do
      expect(described_class.in_time_range(6.hours.ago..Time.current))
        .to contain_exactly(in_scope, other_project_stat, other_rule_stat)
    end
  end

  describe '.increment!' do
    it 'creates a row with count 1 on first activity, bucketed to the hour', :aggregate_failures do
      expect do
        described_class.increment!(rule_id: rule.id, project_id: project.id, outcome: :blocked)
      end.to change { described_class.count }.by(1)

      expect(described_class.order(:id).last).to have_attributes(
        dependency_firewall_policy_rule_id: rule.id,
        project_id: project.id,
        outcome: 'blocked',
        count: 1,
        stat_time: be_like_time(Time.current.utc.beginning_of_hour)
      )
    end

    it 'increments the same hourly bucket atomically instead of inserting a new row', :aggregate_failures do
      3.times { described_class.increment!(rule_id: rule.id, project_id: project.id, outcome: :blocked) }

      expect(described_class.count).to eq(1)
      expect(described_class.order(:id).last.count).to eq(3)
    end

    it 'keeps separate buckets per outcome' do
      described_class.increment!(rule_id: rule.id, project_id: project.id, outcome: :blocked)
      described_class.increment!(rule_id: rule.id, project_id: project.id, outcome: :warned)

      expect(described_class.count).to eq(2)
    end

    it 'buckets activity in different hours into separate rows' do
      described_class.increment!(rule_id: rule.id, project_id: project.id, outcome: :blocked, time: 3.hours.ago)
      described_class.increment!(rule_id: rule.id, project_id: project.id, outcome: :blocked, time: Time.current)

      expect(described_class.count).to eq(2)
    end

    it 'counts allowed outcomes with no rule (NULL rule_id) into a single bucket', :aggregate_failures do
      2.times { described_class.increment!(project_id: project.id, outcome: :allowed) }

      expect(described_class.count).to eq(1)
      expect(described_class.order(:id).last).to have_attributes(
        dependency_firewall_policy_rule_id: nil,
        outcome: 'allowed',
        count: 2
      )
    end
  end

  describe '.outcome_totals' do
    before do
      create(:dependency_firewall_activity_stat, dependency_firewall_policy_rule: rule, project: project,
        outcome: :blocked, count: 4)
      create(:dependency_firewall_activity_stat, dependency_firewall_policy_rule: nil, project: project,
        outcome: :allowed, count: 96)
    end

    it 'returns group-level totals per outcome, including NULL-rule allowed rows' do
      totals = described_class.outcome_totals(
        project_ids: [project.id], time_range: 1.day.ago..Time.current
      )

      expect(totals).to eq(blocked: 4, warned: 0, allowed: 96)
    end

    it 'excludes activity from projects outside the requested set' do
      other_project = create(:project)
      create(:dependency_firewall_activity_stat, dependency_firewall_policy_rule: rule, project: other_project,
        outcome: :blocked, count: 50)

      totals = described_class.outcome_totals(
        project_ids: [project.id], time_range: 1.day.ago..Time.current
      )

      expect(totals).to eq(blocked: 4, warned: 0, allowed: 96)
    end

    it 'excludes activity outside the requested time window' do
      create(:dependency_firewall_activity_stat, dependency_firewall_policy_rule: rule, project: project,
        outcome: :blocked, count: 50, stat_time: 2.days.ago.beginning_of_hour)

      totals = described_class.outcome_totals(
        project_ids: [project.id], time_range: 6.hours.ago..Time.current
      )

      expect(totals).to eq(blocked: 4, warned: 0, allowed: 96)
    end
  end

  describe '.activity_counts_by_rule' do
    let_it_be(:other_rule) { create(:dependency_firewall_policy_rule) }

    before do
      create(:dependency_firewall_activity_stat, dependency_firewall_policy_rule: rule, project: project,
        outcome: :blocked, count: 5)
      create(:dependency_firewall_activity_stat, dependency_firewall_policy_rule: rule, project: project,
        outcome: :warned, count: 2)
    end

    subject(:counts) do
      described_class.activity_counts_by_rule(
        rule_ids: [rule.id, other_rule.id], project_ids: [project.id], time_range: 1.day.ago..Time.current
      )
    end

    it 'returns the blocked/warned hash per rule for rules with data' do
      expect(counts[rule.id]).to eq(blocked: 5, warned: 2)
    end

    it 'returns zeroed counts for a requested rule with no matching rows' do
      expect(counts[other_rule.id]).to eq(blocked: 0, warned: 0)
    end

    it 'excludes rows for rules outside the requested rule_ids' do
      unrequested_rule = create(:dependency_firewall_policy_rule)
      create(:dependency_firewall_activity_stat, dependency_firewall_policy_rule: unrequested_rule, project: project,
        outcome: :blocked, count: 99)

      expect(counts.keys).to contain_exactly(rule.id, other_rule.id)
    end

    it 'excludes rows from projects outside the requested set' do
      other_project = create(:project)
      create(:dependency_firewall_activity_stat, dependency_firewall_policy_rule: rule, project: other_project,
        outcome: :blocked, count: 50)

      expect(counts[rule.id]).to eq(blocked: 5, warned: 2)
    end

    it 'excludes rows outside the requested time window' do
      create(:dependency_firewall_activity_stat, dependency_firewall_policy_rule: rule, project: project,
        outcome: :blocked, count: 99, stat_time: 2.days.ago.beginning_of_hour)

      windowed = described_class.activity_counts_by_rule(
        rule_ids: [rule.id], project_ids: [project.id], time_range: 6.hours.ago..Time.current
      )

      expect(windowed[rule.id]).to eq(blocked: 5, warned: 2)
    end
  end
end
