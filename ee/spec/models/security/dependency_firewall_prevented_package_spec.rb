# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Security::DependencyFirewallPreventedPackage, feature_category: :dependency_firewall do
  let_it_be(:project) { create(:project) }

  around do |example|
    freeze_time { example.run }
  end

  describe 'associations' do
    it { is_expected.to belong_to(:project).required }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:identifier) }
    it { is_expected.to validate_length_of(:identifier).is_at_most(512) }
    it { is_expected.to validate_presence_of(:rule_type) }
    it { is_expected.to validate_presence_of(:first_seen_at) }

    it 'rejects a severity on a non-vulnerability rule type' do
      row = build(:dependency_firewall_prevented_package, project: project, rule_type: :license, severity: :high)

      expect(row).to be_invalid
      expect(row.errors[:severity]).to include('is only valid for vulnerability-family rule types')
    end

    it 'permits a severity on both vulnerability-family rule types', :aggregate_failures do
      expect(build(:dependency_firewall_prevented_package, :vulnerability, project: project)).to be_valid
      expect(build(:dependency_firewall_prevented_package, :risk_severity, project: project)).to be_valid
    end

    it 'permits a NULL severity on any rule type' do
      row = build(:dependency_firewall_prevented_package, project: project, rule_type: :vulnerability, severity: nil)

      expect(row).to be_valid
    end

    it 'rejects a row with neither prevention timestamp' do
      row = build(:dependency_firewall_prevented_package, project: project,
        last_blocked_at: nil, last_warned_at: nil)

      expect(row).to be_invalid
      expect(row.errors[:base]).to include('must set last_blocked_at or last_warned_at')
    end

    it 'permits a row with either prevention timestamp alone', :aggregate_failures do
      expect(build(:dependency_firewall_prevented_package, project: project, last_warned_at: nil)).to be_valid
      expect(build(:dependency_firewall_prevented_package, project: project,
        last_blocked_at: nil, last_warned_at: Time.current)).to be_valid
    end
  end

  describe 'enums' do
    # Pinned literals, not a comparison against the source constants: the migration hardcodes
    # rule_type IN (1, 4) in check_dep_fw_prevented_packages_severity_rule_type, so a renumbering
    # of either enum must fail here rather than silently diverge from the DB constraint.
    it 'pins the integers the severity CHECK constraint hardcodes' do
      expect(described_class.rule_types)
        .to eq('license' => 0, 'vulnerability' => 1, 'malicious' => 2, 'risk_severity' => 4)
    end

    it 'pins the canonical vulnerability severity integers' do
      expect(described_class.severities)
        .to eq('info' => 1, 'unknown' => 2, 'low' => 4, 'medium' => 5, 'high' => 6, 'critical' => 7)
    end
  end

  describe 'check_dep_fw_prevented_packages_severity_rule_type constraint' do
    def upsert_row(rule_type)
      described_class.bulk_upsert!([{
        project_id: project.id, rule_type: described_class.rule_types[rule_type],
        identifier: "pkg:npm/#{rule_type}@1", first_seen_at: Time.current, last_blocked_at: Time.current,
        last_warned_at: nil, severity: described_class.severities['high']
      }])
    end

    it 'accepts a severity-carrying row for each vulnerability-family rule type', :aggregate_failures do
      %w[vulnerability risk_severity].each do |rule_type|
        expect { upsert_row(rule_type) }.to change { described_class.count }.by(1)
      end
    end

    # One example per type: a constraint violation aborts the example's transaction, so a loop
    # inside one example would fail on PG::InFailedSqlTransaction for the second type.
    %w[license malicious].each do |rule_type|
      it "rejects a severity-carrying #{rule_type} row via bulk_upsert! (which bypasses model validation)" do
        expect { upsert_row(rule_type) }
          .to raise_error(ActiveRecord::StatementInvalid, /check_dep_fw_prevented_packages_severity_rule_type/)
      end
    end
  end

  describe 'check_59b3d4e571 identifier length constraint' do
    it 'rejects an over-limit identifier via bulk_upsert! rather than truncating it' do
      expect do
        described_class.bulk_upsert!([{
          project_id: project.id, rule_type: described_class.rule_types['license'],
          identifier: "pkg:npm/#{'a' * 512}@1", first_seen_at: Time.current, last_blocked_at: Time.current,
          last_warned_at: nil, severity: nil
        }])
      end.to raise_error(ActiveRecord::StatementInvalid, /check_59b3d4e571/)
    end
  end

  describe 'check_dep_fw_prevented_packages_timestamps constraint' do
    it 'rejects a row with neither timestamp, which both read scopes would exclude forever' do
      expect do
        described_class.bulk_upsert!([{
          project_id: project.id, rule_type: described_class.rule_types['license'],
          identifier: 'pkg:npm/a@1', first_seen_at: Time.current, last_blocked_at: nil,
          last_warned_at: nil, severity: nil
        }])
      end.to raise_error(ActiveRecord::StatementInvalid, /check_dep_fw_prevented_packages_timestamps/)
    end
  end

  describe 'scopes' do
    let_it_be(:other_project) { create(:project) }

    let_it_be(:blocked_recent) do
      create(:dependency_firewall_prevented_package, project: project, last_blocked_at: 1.day.ago)
    end

    let_it_be(:blocked_old) do
      create(:dependency_firewall_prevented_package, project: project,
        first_seen_at: 30.days.ago, last_blocked_at: 30.days.ago)
    end

    let_it_be(:warned_recent) do
      create(:dependency_firewall_prevented_package, :warned_only, project: project, last_warned_at: 1.day.ago)
    end

    let_it_be(:other_project_row) do
      create(:dependency_firewall_prevented_package, project: other_project, last_blocked_at: 1.day.ago)
    end

    let_it_be(:vulnerability_row) do
      create(:dependency_firewall_prevented_package, :vulnerability, project: project, last_blocked_at: 1.day.ago)
    end

    it '.for_rule_types accepts one type or a list', :aggregate_failures do
      expect(described_class.for_rule_types(:vulnerability)).to contain_exactly(vulnerability_row)
      expect(described_class.for_rule_types(%w[license vulnerability]))
        .to contain_exactly(blocked_recent, blocked_old, warned_recent, other_project_row, vulnerability_row)
    end

    it '.blocked_since keeps rows blocked in the window' do
      expect(described_class.blocked_since(7.days.ago))
        .to contain_exactly(blocked_recent, other_project_row, vulnerability_row)
    end

    describe '.warned_only_since' do
      it 'keeps rows warned in the window with no block at all' do
        expect(described_class.warned_only_since(7.days.ago)).to contain_exactly(warned_recent)
      end

      it 'keeps a row whose only block predates the window (warned since, blocked before)' do
        old_block_new_warn = create(:dependency_firewall_prevented_package, project: project,
          first_seen_at: 30.days.ago, last_blocked_at: 30.days.ago, last_warned_at: 1.day.ago)

        expect(described_class.warned_only_since(7.days.ago)).to contain_exactly(warned_recent, old_block_new_warn)
      end

      it 'excludes a row both warned and blocked in the window' do
        create(:dependency_firewall_prevented_package, project: project,
          last_blocked_at: 1.day.ago, last_warned_at: 1.day.ago)

        expect(described_class.warned_only_since(7.days.ago)).to contain_exactly(warned_recent)
      end
    end

    it '.for_projects limits to the given project ids' do
      expect(described_class.for_projects([other_project.id])).to contain_exactly(other_project_row)
    end

    it '.for_projects accepts a project relation and filters via WHERE EXISTS', :aggregate_failures do
      relation_scope = described_class.for_projects(Project.where(id: other_project.id))

      expect(relation_scope.to_sql).to include('EXISTS')
      expect(relation_scope).to contain_exactly(other_project_row)
    end
  end

  describe 'dashboard counts' do
    let_it_be(:other_project) { create(:project) }

    let(:projects) { [project.id, other_project.id] }
    let(:from) { 7.days.ago }
    let(:vulnerability_family) { %w[vulnerability risk_severity] }

    before_all do
      # Same purl blocked in two projects: one distinct package.
      create(:dependency_firewall_prevented_package, project: project,
        identifier: 'pkg:npm/lic-shared@1', last_blocked_at: 1.day.ago)
      create(:dependency_firewall_prevented_package, project: other_project,
        identifier: 'pkg:npm/lic-shared@1', last_blocked_at: 2.days.ago)
      create(:dependency_firewall_prevented_package, project: project,
        identifier: 'pkg:npm/lic-both@1', last_blocked_at: 1.day.ago, last_warned_at: 1.day.ago)
      create(:dependency_firewall_prevented_package, :warned_only, project: other_project,
        identifier: 'pkg:npm/lic-warned@1', last_warned_at: 1.day.ago)
      create(:dependency_firewall_prevented_package, project: project,
        identifier: 'pkg:npm/lic-rewarned@1', first_seen_at: 30.days.ago, last_blocked_at: 30.days.ago,
        last_warned_at: 1.day.ago)
      create(:dependency_firewall_prevented_package, project: project,
        identifier: 'pkg:npm/lic-old@1', first_seen_at: 30.days.ago, last_blocked_at: 30.days.ago)

      create(:dependency_firewall_prevented_package, :vulnerability, project: project,
        identifier: 'pkg:npm/vuln-a@1', severity: :high, last_blocked_at: 1.day.ago)
      create(:dependency_firewall_prevented_package, :risk_severity, project: other_project,
        identifier: 'pkg:npm/vuln-a@1', severity: :critical, last_blocked_at: 1.day.ago)
      create(:dependency_firewall_prevented_package, :vulnerability, project: other_project,
        identifier: 'pkg:npm/vuln-b@1', severity: nil, last_blocked_at: 1.day.ago)
      create(:dependency_firewall_prevented_package, :vulnerability, project: project,
        identifier: 'pkg:npm/vuln-c@1', severity: :unknown, last_blocked_at: 1.day.ago)
      create(:dependency_firewall_prevented_package, :vulnerability, project: project,
        identifier: 'pkg:npm/vuln-old@1', severity: :critical, first_seen_at: 30.days.ago,
        last_blocked_at: 30.days.ago)
    end

    # Byte-wise comparison speeds up the sort without changing the counts.
    it 'compares purls byte-wise in every dashboard count' do
      recorder = ActiveRecord::QueryRecorder.new do
        described_class.distinct_blocked_count(projects: projects, rule_types: :license, from: from)
        described_class.distinct_warned_only_count(projects: projects, rule_types: :license, from: from)
        described_class.blocked_count_by_max_severity(projects: projects, rule_types: vulnerability_family, from: from)
      end

      counts = recorder.log.select { |sql| sql.include?('FROM "dependency_firewall_prevented_packages"') }

      expect(counts.size).to eq(3)
      expect(counts).to all(include('"dependency_firewall_prevented_packages"."identifier" COLLATE "C"'))
    end

    describe '.distinct_blocked_count' do
      it 'counts each purl blocked in the window once across projects', :aggregate_failures do
        expect(described_class.distinct_blocked_count(projects: projects, rule_types: :license, from: from))
          .to eq(2)
        expect(described_class.distinct_blocked_count(projects: projects, rule_types: vulnerability_family,
          from: from)).to eq(3)
      end

      it 'scopes to the given projects, including a project relation', :aggregate_failures do
        expect(described_class.distinct_blocked_count(projects: [other_project.id], rule_types: :license,
          from: from)).to eq(1)
        expect(described_class.distinct_blocked_count(projects: Project.where(id: other_project.id),
          rule_types: :license, from: from)).to eq(1)
      end
    end

    describe '.distinct_warned_only_count' do
      it 'counts purls warned in the window and not blocked in it, including a block that predates it' do
        expect(described_class.distinct_warned_only_count(projects: projects, rule_types: :license, from: from))
          .to eq(2)
      end
    end

    describe '.blocked_count_by_max_severity' do
      it 'counts each purl once at its max severity, keeping NULL apart from unknown' do
        # Raw severity integers: the collector folds nil into 'unknown'.
        expect(described_class.blocked_count_by_max_severity(projects: projects, rule_types: vulnerability_family,
          from: from)).to eq(
            described_class.severities['critical'] => 1,
            described_class.severities['unknown'] => 1,
            nil => 1
          )
      end
    end
  end

  describe '.bulk_upsert!' do
    def row(
      rule_type: 'license', identifier: 'pkg:npm/a@1', first_seen_at: Time.current,
      last_blocked_at: Time.current, last_warned_at: nil, severity: nil)
      {
        project_id: project.id,
        rule_type: described_class.rule_types[rule_type],
        identifier: identifier,
        first_seen_at: first_seen_at,
        last_blocked_at: last_blocked_at,
        last_warned_at: last_warned_at,
        severity: severity && described_class.severities[severity]
      }
    end

    context 'with a value outside the enum maps' do
      it 'rejects an unmapped rule_type rather than inserting a row nothing can read' do
        expect { described_class.bulk_upsert!([row.merge(rule_type: 99)]) }
          .to raise_error(ArgumentError, "'99' is not a valid rule_type")
          .and not_change { described_class.count }
      end

      it 'rejects an unmapped severity' do
        expect { described_class.bulk_upsert!([row(rule_type: 'vulnerability').merge(severity: 99)]) }
          .to raise_error(ArgumentError, "'99' is not a valid severity")
          .and not_change { described_class.count }
      end

      it 'rejects an unmapped value in any row of the batch, writing none of them' do
        expect { described_class.bulk_upsert!([row, row(identifier: 'pkg:npm/b@1').merge(rule_type: 99)]) }
          .to raise_error(ArgumentError)
          .and not_change { described_class.count }
      end

      it 'permits a nil severity' do
        expect { described_class.bulk_upsert!([row.merge(severity: nil)]) }.to change { described_class.count }.by(1)
      end
    end

    # upsert_all applies the enum cast itself, so a caller passing names rather than integers
    # worked before the guard existed and has to keep working.
    context 'with enum keys rather than integers' do
      it 'accepts string keys and stores the mapped integers', :aggregate_failures do
        expect do
          described_class.bulk_upsert!([row.merge(rule_type: 'vulnerability', severity: 'high')])
        end.to change { described_class.count }.by(1)

        expect(described_class.last).to have_attributes(rule_type: 'vulnerability', severity: 'high')
      end

      it 'accepts symbol keys', :aggregate_failures do
        expect do
          described_class.bulk_upsert!([row.merge(rule_type: :vulnerability, severity: :high)])
        end.to change { described_class.count }.by(1)

        expect(described_class.last).to have_attributes(rule_type: 'vulnerability', severity: 'high')
      end

      it 'still rejects a name that is not in the map' do
        expect { described_class.bulk_upsert!([row.merge(rule_type: 'not_a_rule')]) }
          .to raise_error(ArgumentError, "'not_a_rule' is not a valid rule_type")
          .and not_change { described_class.count }
      end
    end

    it 'inserts a new ledger row', :aggregate_failures do
      expect { described_class.bulk_upsert!([row]) }.to change { described_class.count }.by(1)

      expect(described_class.last).to have_attributes(
        project_id: project.id,
        rule_type: 'license',
        identifier: 'pkg:npm/a@1',
        first_seen_at: be_like_time(Time.current),
        last_blocked_at: be_like_time(Time.current),
        last_warned_at: nil,
        severity: nil
      )
    end

    it 'advances timestamps on conflict, keeping min(first_seen) and max(blocked/warned)', :aggregate_failures do
      described_class.bulk_upsert!([
        row(first_seen_at: 3.days.ago, last_blocked_at: 3.days.ago, last_warned_at: 2.days.ago)
      ])
      # Out-of-order replay: an older first_seen with a newer block must merge, not overwrite.
      described_class.bulk_upsert!([
        row(first_seen_at: 5.days.ago, last_blocked_at: 1.day.ago, last_warned_at: 4.days.ago)
      ])

      expect(described_class.count).to eq(1)
      expect(described_class.last).to have_attributes(
        first_seen_at: be_like_time(5.days.ago),
        last_blocked_at: be_like_time(1.day.ago),
        last_warned_at: be_like_time(2.days.ago)
      )
    end

    it 'keeps the max severity on conflict (GREATEST ignores NULL)', :aggregate_failures do
      described_class.bulk_upsert!([row(rule_type: 'vulnerability', severity: 'critical')])
      described_class.bulk_upsert!([row(rule_type: 'vulnerability', severity: 'low')])

      expect(described_class.last.severity).to eq('critical')

      described_class.bulk_upsert!([row(rule_type: 'vulnerability', severity: nil)])

      expect(described_class.last.severity).to eq('critical')
    end

    it 'does not clear last_warned_at when a later block carries no warn' do
      described_class.bulk_upsert!([row(last_blocked_at: nil, last_warned_at: 2.days.ago)])
      described_class.bulk_upsert!([row(last_blocked_at: Time.current, last_warned_at: nil)])

      expect(described_class.last).to have_attributes(
        last_blocked_at: be_like_time(Time.current),
        last_warned_at: be_like_time(2.days.ago)
      )
    end

    it 'keeps separate rows per rule type for the same package' do
      described_class.bulk_upsert!([row(rule_type: 'license'), row(rule_type: 'malicious')])

      expect(described_class.count).to eq(2)
    end

    it 'keeps separate rows per identifier' do
      described_class.bulk_upsert!([row(identifier: 'pkg:npm/a@1'), row(identifier: 'pkg:npm/a@2')])

      expect(described_class.count).to eq(2)
    end

    it 'does nothing when given no rows' do
      expect { described_class.bulk_upsert!([]) }.not_to change { described_class.count }
    end
  end
end
