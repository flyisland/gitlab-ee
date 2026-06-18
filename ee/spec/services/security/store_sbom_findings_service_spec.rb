# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Security::StoreSbomFindingsService, feature_category: :dependency_management do
  let_it_be(:findings_partition_number, freeze: false) { Security::Finding.active_partition_number }
  let_it_be(:security_scan, freeze: false) do
    create(:security_scan, findings_partition_number: findings_partition_number)
  end

  let_it_be(:project, freeze: false) { security_scan.project }
  let_it_be(:scanner, freeze: false) { create(:vulnerabilities_scanner, project: project) }
  let_it_be(:security_finding_1, freeze: false) { build(:ci_reports_security_finding) }
  let_it_be(:security_finding_2, freeze: false) { build(:ci_reports_security_finding) }
  let_it_be(:security_finding_3, freeze: false) { build(:ci_reports_security_finding) }
  let_it_be(:security_finding_4, freeze: false) { build(:ci_reports_security_finding) }
  let_it_be(:deduplicated_finding_uuids, freeze: false) { [security_finding_1.uuid, security_finding_3.uuid] }
  let_it_be(:existing_uuids, freeze: false) { [] }
  let_it_be(:security_scanner, freeze: false) { build(:ci_reports_security_scanner) }
  let_it_be(:report, freeze: false) do
    build(
      :ci_reports_security_report,
      findings: [security_finding_1, security_finding_2, security_finding_3, security_finding_4],
      scanner: security_scanner
    )
  end

  describe '#execute' do
    before do
      security_finding_4.uuid = nil
    end

    let(:service_object) do
      described_class.new(security_scan, scanner, report, deduplicated_finding_uuids, existing_uuids)
    end

    subject(:store_findings) { service_object.execute }

    it 'creates the security finding entries in database' do
      store_findings

      expect(security_scan.findings.reload.as_json(only: [:partition_number, :uuid, :deduplicated]))
        .to match_array(
          [
            {
              "partition_number" => findings_partition_number,
              "uuid" => security_finding_1.uuid,
              "deduplicated" => true
            },
            {
              "partition_number" => findings_partition_number,
              "uuid" => security_finding_2.uuid,
              "deduplicated" => false
            },
            {
              "partition_number" => findings_partition_number,
              "uuid" => security_finding_3.uuid,
              "deduplicated" => true
            }
          ])
    end

    context 'with security findings uuids provided' do
      let_it_be(:existing_uuids, freeze: false) { [security_finding_1.uuid] }

      it 'skips the creation of the non unique security finding' do
        store_findings

        expect(security_scan.findings.reload.as_json(only: [:partition_number, :uuid, :deduplicated]))
          .to match_array(
            [
              {
                "partition_number" => findings_partition_number,
                "uuid" => security_finding_2.uuid,
                "deduplicated" => false
              },
              {
                "partition_number" => findings_partition_number,
                "uuid" => security_finding_3.uuid,
                "deduplicated" => true
              }
            ])
      end
    end
  end
end
