# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Security::MergeRequestApprovalPolicies::LicenseExpressionChecker,
  feature_category: :security_policy_management do
  let_it_be(:project) { create(:project) }
  let_it_be(:target_branch_report) { create(:ci_reports_license_scanning_report) }
  let_it_be(:pipeline_report) { create(:ci_reports_license_scanning_report) }

  let(:approval_policy_source) do
    Security::ApprovalPolicySource.new(
      project: project,
      action_idx: 0,
      scan_result_policy_read: scan_result_policy_read,
      approval_policy_rule: nil
    )
  end

  let(:service) do
    described_class.new(project, pipeline_report, target_branch_report, approval_policy_source)
  end

  subject(:denied_licenses_with_dependencies) { service.denied_licenses_with_dependencies }

  context 'without package exceptions' do
    include_context 'for denied_licenses_checker without package exceptions'

    with_them do
      let(:target_branch_report) { build(:ci_reports_license_scanning_report) }
      let(:pipeline_report) { build(:ci_reports_license_scanning_report) }

      let(:license_states) { states }
      let(:licenses) { { policy_state.to_sym => [{ name: policy_license }] } }

      let(:scan_result_policy_read) do
        create(:scan_result_policy_read,
          project: project,
          license_states: license_states,
          licenses: licenses
        )
      end

      before do
        target_branch_licenses.each do |spdx_id, display_name, dependency_name|
          target_branch_report.add_license(id: spdx_id, name: display_name).add_dependency(name: dependency_name)
        end

        pipeline_branch_licenses.each do |spdx_id, display_name, dependency_name|
          pipeline_report.add_license(id: spdx_id, name: display_name).add_dependency(name: dependency_name)
        end
      end

      # The shared context includes allowlist rows (policy_state: :allowed) which
      # LicenseExpressionChecker does not support in iteration 1 (denylist only).
      it 'returns denied_licenses_with_dependencies' do
        next if policy_state == :allowed

        is_expected.to eq(violated_licenses)
      end
    end
  end

  shared_examples 'with license operator expressions' do |operator|
    include_context "for license_expression_checker #{operator} operator"

    with_them do
      let(:target_branch_report) { build(:ci_reports_license_scanning_report) }
      let(:pipeline_report) { build(:ci_reports_license_scanning_report) }

      let(:license_states) { states }
      let(:licenses) { { denied: policy_denied_names.map { |name| { name: name } } } }

      let(:scan_result_policy_read) do
        create(:scan_result_policy_read,
          project: project,
          license_states: license_states,
          licenses: licenses
        )
      end

      before do
        target_branch_licenses.each do |spdx_id, display_name, dependency_name|
          target_branch_report.add_license(id: spdx_id, name: display_name).add_dependency(name: dependency_name)
        end

        pipeline_branch_licenses.each do |spdx_id, display_name, dependency_name|
          pipeline_report.add_license(id: spdx_id, name: display_name).add_dependency(name: dependency_name)
        end
      end

      it 'returns denied_licenses_with_dependencies' do
        is_expected.to eq(violated_licenses)
      end
    end
  end

  context 'with AND operator expressions' do
    it_behaves_like 'with license operator expressions', 'AND'
  end

  context 'with OR operator expressions' do
    it_behaves_like 'with license operator expressions', 'OR'
  end

  context 'with WITH operator expressions' do
    it_behaves_like 'with license operator expressions', 'WITH'
  end

  context 'with PLUS operator expressions' do
    it_behaves_like 'with license operator expressions', 'PLUS'
  end

  context 'with LicenseRef expressions' do
    it_behaves_like 'with license operator expressions', 'LicenseRef'
  end

  context 'when the SPDX catalogue maps IDs to display names' do
    let(:pipeline_report) { create(:ci_reports_license_scanning_report) }
    let(:target_branch_report) { create(:ci_reports_license_scanning_report) }

    let(:scan_result_policy_read) do
      create(:scan_result_policy_read,
        project: project,
        license_states: ['newly_detected'],
        licenses: { denied: [{ name: 'MIT License' }] }
      )
    end

    before do
      allow(Gitlab::SPDX::Catalogue).to receive(:latest_active_licenses).and_return(
        [
          instance_double(Gitlab::SPDX::License, id: 'MIT', name: 'MIT License'),
          instance_double(Gitlab::SPDX::License, id: 'Apache-2.0', name: 'Apache License 2.0')
        ]
      )
    end

    context 'when the report contains a plain "MIT" SPDX ID' do
      before do
        pipeline_report.add_license(id: 'MIT', name: 'MIT').add_dependency(name: 'mit-lib')
      end

      it 'resolves "MIT" to "MIT License" and flags a violation' do
        expect(denied_licenses_with_dependencies).to eq({ 'MIT' => ['mit-lib'] })
      end
    end

    context 'when the report contains an identifier not in the SPDX catalogue' do
      before do
        pipeline_report.add_license(id: 'LicenseRef-Custom', name: 'LicenseRef-Custom')
                       .add_dependency(name: 'custom-lib')
      end

      it 'keeps the identifier as-is and does not flag a violation' do
        expect(denied_licenses_with_dependencies).to be_blank
      end
    end

    context 'when the policy name matches the raw SPDX ID but not the resolved display name' do
      let(:pipeline_report) { create(:ci_reports_license_scanning_report) }
      let(:target_branch_report) { create(:ci_reports_license_scanning_report) }

      let(:scan_result_policy_read) do
        create(:scan_result_policy_read,
          project: project,
          license_states: ['newly_detected'],
          licenses: { denied: [{ name: 'MIT' }] }
        )
      end

      before do
        pipeline_report.add_license(id: 'MIT', name: 'MIT').add_dependency(name: 'mit-lib')
      end

      it 'does not produce a false-positive violation via policy_plus_covers_report_base?' do
        expect(denied_licenses_with_dependencies).to be_blank
      end
    end
  end

  context 'when approval_policy_source is nil' do
    let(:service) do
      described_class.new(project, pipeline_report, target_branch_report, nil)
    end

    it 'returns no denied licenses' do
      expect(denied_licenses_with_dependencies).to be_blank
    end
  end

  context 'when the policy has no denied licenses' do
    let(:scan_result_policy_read) do
      create(:scan_result_policy_read,
        project: project,
        license_states: ['detected'],
        licenses: {}
      )
    end

    it 'returns no denied licenses' do
      expect(denied_licenses_with_dependencies).to be_blank
    end
  end
end
