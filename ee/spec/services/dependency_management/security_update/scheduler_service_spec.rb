# frozen_string_literal: true

require 'spec_helper'

RSpec.describe DependencyManagement::SecurityUpdate::SchedulerService, feature_category: :dependency_management do
  let_it_be(:project) { create(:project, :repository) }

  def make_vuln(severity: :high, solution: 'Upgrade to version 7.0.0 or above.')
    create(:vulnerability, :detected, severity,
      project: project,
      report_type: :dependency_scanning,
      findings: [build(:vulnerabilities_finding, :identifier,
        project: project,
        report_type: :dependency_scanning,
        solution: solution,
        raw_metadata: '{}')])
  end

  def make_occurrence(component_name:, vulns:, package_manager: 'bundler', purl_type: 'gem')
    component = create(:sbom_component, purl_type: purl_type, name: component_name)
    component_version = create(:sbom_component_version, component: component, version: '6.0.0')

    create(:sbom_occurrence,
      project: project,
      package_manager: package_manager,
      component: component,
      component_version: component_version).tap do |o|
      vulns.each { |v| create(:sbom_occurrences_vulnerability, occurrence: o, vulnerability: v) }
      o.reload
    end
  end

  def stub_finders_by_severity(occurrences_by_severity = {}, package_manager = 'bundler')
    allow(DependencyManagement::SecurityUpdate::VulnerableSbomOccurrencesFinder)
      .to receive(:new)
      .and_return(
        instance_double(
          DependencyManagement::SecurityUpdate::VulnerableSbomOccurrencesFinder,
          execute_in_batches: nil
        )
      )

    %i[critical high medium low].each do |severity|
      finder = instance_double(DependencyManagement::SecurityUpdate::VulnerableSbomOccurrencesFinder)
      occurrences = occurrences_by_severity.fetch(severity, [])

      allow(DependencyManagement::SecurityUpdate::VulnerableSbomOccurrencesFinder)
        .to receive(:new)
        .with(project: project, package_manager: package_manager, severity_level: severity)
        .and_return(finder)

      allow(finder).to receive(:execute_in_batches) do |&block|
        block.call(occurrences) unless occurrences.empty?
      end
    end
  end

  def expect_ordered_finder_calls(severities, package_manager: 'bundler')
    severities.each do |severity|
      expect(DependencyManagement::SecurityUpdate::VulnerableSbomOccurrencesFinder)
        .to receive(:new)
        .with(project: project, package_manager: package_manager, severity_level: severity)
        .ordered
        .and_return(
          instance_double(
            DependencyManagement::SecurityUpdate::VulnerableSbomOccurrencesFinder,
            execute_in_batches: nil
          )
        )
    end
  end

  def expect_no_finder_calls(severities, package_manager: anything)
    severities.each do |severity|
      expect(DependencyManagement::SecurityUpdate::VulnerableSbomOccurrencesFinder)
        .not_to receive(:new)
        .with(project: project, package_manager: package_manager, severity_level: severity)
    end
  end

  describe '.execute' do
    before do
      stub_finders_by_severity
    end

    it 'calls execute on the new instance' do
      instance = described_class.new(project: project)

      allow(described_class).to receive(:new).with(project: project)
        .and_return(instance)
      expect(instance).to receive(:execute).and_call_original

      described_class.execute(project: project)
    end
  end

  describe '#execute' do
    subject(:execute) { described_class.new(project: project).execute }

    context 'when project is nil' do
      let(:project) { nil }

      it { is_expected.to be_nil }
    end

    context 'when project has vulnerable occurrences' do
      let_it_be_with_reload(:profile) do
        create(:security_scan_profile, :dependency_scanning_post_processing,
          namespace: project.namespace,
          projects: [project])
      end

      let!(:trigger) { create(:security_scan_profile_trigger, scan_profile: profile, trigger_type: trigger_type) }
      let(:trigger_type) { :sbom_ingested }
      let(:configuration) { {} }

      let(:critical_vuln)       { make_vuln(severity: :critical, solution: 'Upgrade to version 8.0.0 or above.') }
      let(:high_vuln)           { make_vuln(severity: :high,     solution: 'Upgrade to version 7.0.0 or above.') }
      let(:vuln_1)              { make_vuln(severity: :high,     solution: 'Upgrade to version 7.0.0 or above.') }
      let(:vuln_2)              { make_vuln(severity: :high,     solution: 'Upgrade to version 7.1.0 or above.') }
      let(:remediable_vuln)     { make_vuln(severity: :high,     solution: 'Upgrade to version 7.0.0 or above.') }
      let(:unsolved_vuln)       { make_vuln(severity: :high,     solution: nil) }
      let(:non_remediable_vuln) do
        make_vuln(severity: :high, solution: 'Unfortunately, there is no solution available yet.')
      end

      let(:single_vuln_occurrence)      { make_occurrence(component_name: 'rails', vulns: [critical_vuln]) }
      let(:mixed_severity_occurrence)   do
        make_occurrence(component_name: 'lodash',   vulns: [high_vuln, critical_vuln])
      end

      let(:same_severity_occurrence)    { make_occurrence(component_name: 'lodash',   vulns: [vuln_1, vuln_2]) }
      let(:unsolved_occurrence)         { make_occurrence(component_name: 'rails',    vulns: [unsolved_vuln]) }
      let(:non_remediable_occurrence)   { make_occurrence(component_name: 'rails',    vulns: [non_remediable_vuln]) }
      let(:second_occurrence)           do
        make_occurrence(component_name: 'nokogiri', vulns: [make_vuln(solution: 'Upgrade to latest version.')])
      end

      let(:mixed_remediable_occurrence) do
        make_occurrence(component_name: 'lodash', vulns: [remediable_vuln, non_remediable_vuln])
      end

      let(:update_service) { instance_double(DependencyManagement::SecurityUpdate::UpdateService) }

      def wrap_auto_remediation(config)
        { 'auto_remediation' => config }
      end

      before do
        stub_licensed_features(security_scan_profiles: true)
        profile.update!(configuration: wrap_auto_remediation(configuration))

        allow(DependencyManagement::SecurityUpdate::UpdateService)
          .to receive(:new).with(project: project).and_return(update_service)
      end

      context 'when occurrence can be remediated' do
        before do
          stub_finders_by_severity(critical: [single_vuln_occurrence])
        end

        it 'passes a Request with the correct vulnerability to UpdateService' do
          expect(update_service).to receive(:execute) do |request|
            expect(request).to be_a(DependencyManagement::SecurityUpdate::Request)
            expect(request.vulnerability).to eq(critical_vuln)
            expect(request.sbom_occurrence).to eq(single_vuln_occurrence)
            ServiceResponse.success
          end

          execute
        end

        it 'does not call UpdateService again when it fails' do
          allow(update_service).to receive(:execute).and_return(ServiceResponse.error(message: 'Failed'))

          profile.update!(configuration: wrap_auto_remediation('open_merge_requests_limit' => 1))
          stub_finders_by_severity(critical: [single_vuln_occurrence, second_occurrence])

          # The first call fails so the limit is never reached; both occurrences are attempted.
          # This confirms a failed response does not count toward the open MR limit.
          expect(update_service).to receive(:execute).twice

          execute
        end

        it 'tracks the trigger event when UpdateService succeeds' do
          allow(update_service).to receive(:execute).and_return(ServiceResponse.success)

          expect { execute }
            .to trigger_internal_events('trigger_dependency_management_auto_remediation_request')
            .with(
              project: project,
              additional_properties: { purl_type: 'gem' }
            )
        end

        it 'does not track the trigger event when UpdateService fails' do
          allow(update_service).to receive(:execute).and_return(ServiceResponse.error(message: 'Failed'))

          expect { execute }
            .not_to trigger_internal_events('trigger_dependency_management_auto_remediation_request')
        end
      end

      context 'when occurrence has multiple vulnerabilities' do
        context 'when all vulnerabilities are remediable' do
          before do
            stub_finders_by_severity(critical: [mixed_severity_occurrence])
          end

          it 'selects the highest severity vulnerability' do
            expect(update_service).to receive(:execute) do |request|
              expect(request.vulnerability).to eq(critical_vuln)
              ServiceResponse.success
            end

            execute
          end
        end

        context 'when vulnerabilities share the same severity' do
          before do
            stub_finders_by_severity(critical: [same_severity_occurrence])
          end

          it 'selects the vulnerability with the lower id as a tiebreaker' do
            expect(update_service).to receive(:execute) do |request|
              expect(request.vulnerability).to eq(vuln_1)
              ServiceResponse.success
            end

            execute
          end
        end

        context 'when some vulnerabilities are not remediable' do
          before do
            stub_finders_by_severity(critical: [mixed_remediable_occurrence])
          end

          it 'picks the remediable vulnerability' do
            expect(update_service).to receive(:execute) do |request|
              expect(request.vulnerability).to eq(remediable_vuln)
              ServiceResponse.success
            end

            execute
          end
        end
      end

      context 'when no vulnerability is remediable' do
        shared_examples 'skips the occurrence' do
          it 'does not call UpdateService' do
            expect(update_service).not_to receive(:execute)

            execute
          end
        end

        context 'when the solution is blank' do
          before do
            stub_finders_by_severity(critical: [unsolved_occurrence])
          end

          it_behaves_like 'skips the occurrence'
        end

        context 'when the solution indicates no fix is available' do
          before do
            stub_finders_by_severity(critical: [non_remediable_occurrence])
          end

          it_behaves_like 'skips the occurrence'
        end
      end

      context 'when the MR limit is reached before the next package manager' do
        let(:configuration) { { 'open_merge_requests_limit' => 0 } }

        before do
          stub_finders_by_severity
        end

        it 'stops iterating package managers' do
          expect(DependencyManagement::SecurityUpdate::VulnerableSbomOccurrencesFinder)
            .not_to receive(:new)

          execute
        end
      end

      context 'when the MR limit is reached between occurrences in the same batch' do
        let(:configuration) { { 'open_merge_requests_limit' => 1 } }

        before do
          stub_finders_by_severity(critical: [single_vuln_occurrence, second_occurrence])

          allow(update_service).to receive(:execute).and_return(ServiceResponse.success)
        end

        it 'does not process the second occurrence' do
          expect(update_service).to receive(:execute).once

          execute
        end
      end

      described_class.const_get(:SUPPORTED_PACKAGE_MANAGERS, false).each do |package_manager|
        context "when the remediable occurrence uses #{package_manager}" do
          let(:remediable_occurrence) do
            make_occurrence(
              component_name: 'log4j-core',
              vulns: [critical_vuln],
              package_manager: package_manager,
              purl_type: Sbom::PurlType::Converter.purl_type_for_pkg_manager(package_manager)
            )
          end

          before do
            stub_finders_by_severity({ critical: [remediable_occurrence] }, package_manager)
          end

          it 'schedules a remediation through UpdateService' do
            expect(update_service).to receive(:execute) do |request|
              expect(request.sbom_occurrence).to eq(remediable_occurrence)
              ServiceResponse.success
            end

            execute
          end
        end
      end

      context 'when iterating severity levels' do
        let(:configuration) { { 'severity_level' => 'low' } }

        before do
          stub_finders_by_severity
        end

        it 'queries finder in critical → high → medium → low order' do
          expect_ordered_finder_calls(%i[critical high medium low])

          execute
        end
      end

      context 'when attached remediation profile has custom configuration values' do
        context 'with open_merge_requests_limit set above the default constant' do
          let(:configuration) { { 'open_merge_requests_limit' => 5 } }
          let_it_be(:third_occurrence) do
            make_occurrence(component_name: 'sidekiq', vulns: [make_vuln(solution: 'Upgrade to 7.0.0.')])
          end

          let_it_be(:fourth_occurrence) do
            make_occurrence(component_name: 'puma', vulns: [make_vuln(solution: 'Upgrade to 6.0.0.')])
          end

          before do
            stub_finders_by_severity(
              critical: [single_vuln_occurrence, second_occurrence, third_occurrence, fourth_occurrence]
            )
            allow(update_service).to receive(:execute).and_return(ServiceResponse.success)
          end

          it 'uses the profile limit instead of the default constant' do
            expect(update_service).to receive(:execute).exactly(4).times

            execute
          end
        end

        context 'with open_merge_requests_limit set to 0' do
          let(:configuration) { { 'open_merge_requests_limit' => 0 } }

          before do
            stub_finders_by_severity(critical: [single_vuln_occurrence])
          end

          it 'does not schedule any remediations' do
            expect(update_service).not_to receive(:execute)

            execute
          end
        end

        context 'with severity_level set to critical' do
          let(:configuration) { { 'severity_level' => 'critical' } }

          before do
            stub_finders_by_severity
          end

          it 'only iterates the critical severity level' do
            described_class.const_get(:SUPPORTED_PACKAGE_MANAGERS, false).each do |package_manager|
              expect_ordered_finder_calls([:critical], package_manager: package_manager)
            end
            expect_no_finder_calls(%i[high medium low])

            execute
          end
        end

        context 'with severity_level set to medium' do
          let(:configuration) { { 'severity_level' => 'medium' } }

          before do
            stub_finders_by_severity
          end

          it 'iterates critical → high → medium only, skipping low' do
            expect_ordered_finder_calls(%i[critical high medium])
            expect_no_finder_calls([:low], package_manager: 'bundler')

            execute
          end
        end

        context 'with severity_level set outside the supported levels' do
          let(:configuration) { { 'severity_level' => 'info' } }

          before do
            stub_finders_by_severity
          end

          it 'falls back to all severity levels' do
            expect_ordered_finder_calls(%i[critical high medium low])

            execute
          end
        end

        context 'with an empty configuration' do
          let(:configuration) { {} }

          before do
            stub_finders_by_severity
          end

          it 'applies default high severity threshold' do
            expect_ordered_finder_calls(%i[critical high])
            expect_no_finder_calls(%i[medium low], package_manager: 'bundler')

            execute
          end
        end
      end

      context 'when no remediation profile is resolved' do
        before do
          stub_finders_by_severity(critical: [single_vuln_occurrence, second_occurrence])
          allow(update_service).to receive(:execute).and_return(ServiceResponse.success)
        end

        shared_examples 'does nothing' do
          it 'does not query the finder' do
            expect(DependencyManagement::SecurityUpdate::VulnerableSbomOccurrencesFinder)
              .not_to receive(:new)

            execute
          end

          it 'does not instantiate or execute UpdateService' do
            expect(DependencyManagement::SecurityUpdate::UpdateService).not_to receive(:new)
            expect(update_service).not_to receive(:execute)

            execute
          end
        end

        context 'when the security_remediation_profiles feature flag is disabled' do
          before do
            stub_feature_flags(security_remediation_profiles: false)
          end

          it_behaves_like 'does nothing'
        end

        context 'when the security_scan_profiles licensed feature is unavailable' do
          before do
            stub_licensed_features(security_scan_profiles: false)
          end

          it_behaves_like 'does nothing'
        end

        context 'when the trigger_type is not sbom_ingested' do
          let(:trigger_type) { :git_push_event }

          it_behaves_like 'does nothing'
        end

        context 'when no profile is attached to the project' do
          before do
            profile.projects.delete(project)
          end

          it_behaves_like 'does nothing'
        end
      end

      context 'when the project already has open auto-remediation merge requests' do
        let(:configuration) { { 'open_merge_requests_limit' => 3 } }

        let(:service_account) do
          create(:user, :service_account, name: DependencyManagement::ProvisionServiceAccountService::SERVICE_ACCOUNT_NAME)
        end

        def open_existing_remediation_mrs(count)
          project.add_member(service_account, :guest)
          allow(project).to receive(:dependency_management_service_account).and_return(service_account)

          count.times do |i|
            create(:merge_request, :opened,
              target_project: project, source_project: project, author: service_account,
              source_branch: "remediation-#{i}", target_branch: "main-#{i}",
              skip_branch_existence_check: true)
          end
        end

        before do
          allow(update_service).to receive(:execute).and_return(ServiceResponse.success)
        end

        context 'and the limit is already reached' do
          before do
            open_existing_remediation_mrs(3)
            stub_finders_by_severity(critical: [single_vuln_occurrence])
          end

          it 'does not schedule any new remediations' do
            expect(update_service).not_to receive(:execute)

            execute
          end
        end

        context 'and remaining slots are available' do
          before do
            open_existing_remediation_mrs(2)
            stub_finders_by_severity(critical: [single_vuln_occurrence, second_occurrence])
          end

          it 'schedules remediations only up to the remaining limit' do
            expect(update_service).to receive(:execute).once.and_return(ServiceResponse.success)

            execute
          end
        end
      end

      context 'when an open remediation MR already exists for the dependency branch' do
        let(:service_account) do
          create(:user, :service_account, name: DependencyManagement::ProvisionServiceAccountService::SERVICE_ACCOUNT_NAME)
        end

        before do
          project.add_member(service_account, :guest)
          allow(project).to receive(:dependency_management_service_account).and_return(service_account)
          allow(update_service).to receive(:execute).and_return(ServiceResponse.success)

          # single_vuln_occurrence is `rails` at 6.0.0 -> dependency-management/rails-6.x
          create(:merge_request, :opened,
            target_project: project, source_project: project, author: service_account,
            source_branch: 'dependency-management/rails-6.x', target_branch: 'main',
            skip_branch_existence_check: true)

          stub_finders_by_severity(critical: [single_vuln_occurrence, second_occurrence])
        end

        it 'skips the dependency with an open MR and schedules only the others' do
          expect(update_service).to receive(:execute).once do |request|
            expect(request.sbom_occurrence).to eq(second_occurrence)
            ServiceResponse.success
          end

          execute
        end

        context 'when every vulnerable dependency already has an open MR' do
          before do
            stub_finders_by_severity(critical: [single_vuln_occurrence])
          end

          it 'does not schedule any remediation' do
            expect(update_service).not_to receive(:execute)

            execute
          end
        end
      end

      context 'when a maintainer closed the remediation MR for a dependency branch' do
        let(:service_account) do
          create(:user, :service_account, name: DependencyManagement::ProvisionServiceAccountService::SERVICE_ACCOUNT_NAME)
        end

        let(:maintainer) { create(:user) }

        before do
          project.add_member(service_account, :guest)
          allow(project).to receive(:dependency_management_service_account).and_return(service_account)
          allow(update_service).to receive(:execute).and_return(ServiceResponse.success)

          # single_vuln_occurrence is `rails` at 6.0.0 -> dependency-management/rails-6.x
          create(:merge_request, :closed, :with_closed_by,
            target_project: project, source_project: project, author: service_account,
            source_branch: 'dependency-management/rails-6.x', target_branch: 'main',
            skip_branch_existence_check: true, closed_by: maintainer)

          stub_finders_by_severity(critical: [single_vuln_occurrence, second_occurrence])
        end

        context 'on a reschedule run (skip_dismissed_branches: true)' do
          it 'skips the dismissed dependency and schedules only the others' do
            expect(update_service).to receive(:execute).once do |request|
              expect(request.sbom_occurrence).to eq(second_occurrence)
              ServiceResponse.success
            end

            described_class.new(project: project, skip_dismissed_branches: true).execute
          end
        end

        context 'on an initial run (skip_dismissed_branches: false)' do
          it 'still schedules the dismissed dependency so resurfacing can be evaluated' do
            expect(update_service).to receive(:execute).twice.and_return(ServiceResponse.success)

            described_class.new(project: project).execute
          end
        end
      end
    end
  end
end
