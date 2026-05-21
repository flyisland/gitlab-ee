# frozen_string_literal: true

require 'spec_helper'

RSpec.describe DependencyManagement::SecurityUpdate::SchedulerService, feature_category: :dependency_management do
  let_it_be(:project) { create(:project, :repository) }
  let_it_be(:sbom_component) { create(:sbom_component, purl_type: 'gem', name: 'rails') }

  let(:sbom_occurrence) do
    create(:sbom_occurrence,
      project: project,
      package_manager: 'bundler',
      component: sbom_component
    ).tap { |o| o.component_version&.update!(version: '6.0.0') }
  end

  let(:vulnerability) do
    create(:vulnerability,
      :with_finding,
      :detected,
      project: project,
      report_type: :dependency_scanning
    )
  end

  let(:finding) { vulnerability.finding }

  let(:solution) { 'Upgrade to version 7.0.0 or above.' }

  # Stubs each severity level's finder with its own double, yielding the given
  # occurrences only for severities present in the hash. Severities omitted from
  # the hash (or mapped to an empty array) produce no results.
  def stub_finders_by_severity(occurrences_by_severity = {})
    %i[critical high medium low].each do |severity|
      finder = instance_double(DependencyManagement::SecurityUpdate::VulnerableSbomOccurrencesFinder)
      occurrences = occurrences_by_severity.fetch(severity, [])

      allow(DependencyManagement::SecurityUpdate::VulnerableSbomOccurrencesFinder)
        .to receive(:new)
        .with(project: project, package_manager: 'bundler', severity_level: severity)
        .and_return(finder)

      allow(finder).to receive(:execute_in_batches) do |&block|
        block.call(occurrences) unless occurrences.empty?
      end
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
      before do
        finding.update!(solution: solution, raw_metadata: '{}')
        create(:sbom_occurrences_vulnerability, occurrence: sbom_occurrence, vulnerability: vulnerability)
        sbom_occurrence.reload

        allow(DependencyManagement::SecurityUpdate::UpdateService)
          .to receive(:new).with(project: project).and_return(update_service)
      end

      let(:update_service) { instance_double(DependencyManagement::SecurityUpdate::UpdateService) }

      context 'when occurrence can be remediated' do
        before do
          stub_finders_by_severity(critical: [sbom_occurrence])
        end

        it 'passes a Request with the correct vulnerability to UpdateService' do
          expect(update_service).to receive(:execute) do |request|
            expect(request).to be_a(DependencyManagement::SecurityUpdate::Request)
            expect(request.vulnerability).to eq(vulnerability)
            expect(request.sbom_occurrence).to eq(sbom_occurrence)
            ServiceResponse.success
          end

          execute
        end

        it 'calls UpdateService once per vulnerability' do
          expect(update_service).to receive(:execute).once.and_return(ServiceResponse.success)

          execute
        end

        it 'increments remediation_count on success' do
          allow(update_service).to receive(:execute).and_return(ServiceResponse.success)

          service = described_class.new(project: project)
          expect { service.execute }.to change { service.send(:remediation_count) }.from(0).to(1)
        end

        it 'does not increment remediation_count on failure' do
          allow(update_service).to receive(:execute).and_return(ServiceResponse.error(message: 'Failed'))

          service = described_class.new(project: project)
          expect { service.execute }.not_to change { service.send(:remediation_count) }
        end
      end

      context 'when occurrence has multiple vulnerabilities' do
        let(:vulnerability2) do
          create(:vulnerability, :with_finding, :detected, project: project, report_type: :dependency_scanning)
        end

        before do
          vulnerability2.finding.update!(solution: 'Upgrade to version 8.0.0 or above.', raw_metadata: '{}')
          create(:sbom_occurrences_vulnerability, occurrence: sbom_occurrence, vulnerability: vulnerability2)
          sbom_occurrence.reload

          stub_finders_by_severity(critical: [sbom_occurrence])
        end

        it 'calls UpdateService once per vulnerability' do
          expect(update_service).to receive(:execute).twice.and_return(ServiceResponse.success)

          execute
        end
      end

      context 'when occurrence has no solution' do
        let(:solution) { nil }

        before do
          stub_finders_by_severity(critical: [sbom_occurrence])
        end

        it 'does not call UpdateService' do
          expect(update_service).not_to receive(:execute)
          execute
        end
      end

      context 'when occurrence solution indicates no fix is available' do
        let(:solution) { 'Unfortunately, there is no solution available yet.' }

        before do
          stub_finders_by_severity(critical: [sbom_occurrence])
        end

        it 'does not call UpdateService' do
          expect(update_service).not_to receive(:execute)
          execute
        end
      end

      context 'when the MR limit is reached mid-vulnerability on a single occurrence' do
        let(:filling_occurrences) do
          %w[nokogiri puma].map do |name|
            component = create(:sbom_component, purl_type: 'gem', name: name)

            create(:sbom_occurrence, project: project, package_manager: 'bundler', component: component).tap do |o|
              vuln = create(:vulnerability, :with_finding, :detected,
                project: project, report_type: :dependency_scanning)

              vuln.finding.update!(solution: 'Upgrade to latest version.', raw_metadata: '{}')

              create(:sbom_occurrences_vulnerability, occurrence: o, vulnerability: vuln)

              o.reload
            end
          end
        end

        let(:vulnerability2) do
          create(:vulnerability, :with_finding, :detected,
            project: project, report_type: :dependency_scanning)
        end

        before do
          vulnerability2.finding.update!(solution: 'Upgrade to version 8.0.0 or above.', raw_metadata: '{}')
          create(:sbom_occurrences_vulnerability, occurrence: sbom_occurrence, vulnerability: vulnerability2)
          sbom_occurrence.reload

          stub_finders_by_severity(critical: [*filling_occurrences, sbom_occurrence])
          allow(update_service).to receive(:execute).and_return(ServiceResponse.success)
        end

        it 'stops scheduling mid-occurrence once the limit is hit' do
          expect(update_service).to receive(:execute).exactly(3).times.and_return(ServiceResponse.success)

          execute
        end
      end

      context 'when the MR limit is reached before the next package manager' do
        before do
          stub_finders_by_severity
        end

        it 'stops iterating package managers' do
          service = described_class.new(project: project)
          allow(service).to receive(:merge_request_limit_reached?).and_return(true)

          expect(DependencyManagement::SecurityUpdate::VulnerableSbomOccurrencesFinder)
            .not_to receive(:new)

          service.execute
        end
      end

      context 'when the MR limit is reached between occurrences in the same batch' do
        let(:occurrence2) do
          component2 = create(:sbom_component, purl_type: 'gem', name: 'nokogiri')

          create(:sbom_occurrence, project: project, package_manager: 'bundler', component: component2).tap do |o|
            vuln = create(:vulnerability, :with_finding, :detected,
              project: project, report_type: :dependency_scanning)

            vuln.finding.update!(solution: 'Upgrade to latest version.', raw_metadata: '{}')
            create(:sbom_occurrences_vulnerability, occurrence: o, vulnerability: vuln)

            o.reload
          end
        end

        before do
          stub_const("#{described_class}::MAX_OPEN_MERGE_REQUEST_LIMIT", 1)
          stub_finders_by_severity(critical: [sbom_occurrence, occurrence2])

          allow(update_service).to receive(:execute).and_return(ServiceResponse.success)
        end

        it 'does not process the second occurrence' do
          expect(update_service).to receive(:execute).once

          execute
        end
      end

      context 'when iterating severity levels' do
        before do
          stub_finders_by_severity
        end

        it 'queries finder in critical → high → medium → low order' do
          %i[critical high medium low].each do |severity|
            expect(DependencyManagement::SecurityUpdate::VulnerableSbomOccurrencesFinder)
              .to receive(:new)
              .with(project: project, package_manager: 'bundler', severity_level: severity)
              .ordered
              .and_return(
                instance_double(
                  DependencyManagement::SecurityUpdate::VulnerableSbomOccurrencesFinder,
                  execute_in_batches: nil
                )
              )
          end

          execute
        end
      end
    end
  end

  describe '#remediable?' do
    let(:service) { described_class.new(project: project) }

    subject(:remediable) { service.send(:remediable?, vulnerability) }

    context 'when solution is present and actionable' do
      before do
        allow(vulnerability).to receive(:solution).and_return('Upgrade to version 7.0.0 or above.')
      end

      it { is_expected.to be true }
    end

    context 'when solution is blank' do
      before do
        allow(vulnerability).to receive(:solution).and_return('')
      end

      it { is_expected.to be false }
    end

    context 'when solution matches the "no fix available" template' do
      before do
        allow(vulnerability).to receive(:solution).and_return('Unfortunately, there is no solution available yet.')
      end

      it { is_expected.to be false }
    end
  end

  describe 'remediation limit behavior' do
    let(:service_account) do
      create(:user, :service_account, name: DependencyManagement::ProvisionServiceAccountService::SERVICE_ACCOUNT_NAME)
    end

    let(:update_service) { instance_double(DependencyManagement::SecurityUpdate::UpdateService) }

    before do
      project.add_member(service_account, :guest)
      allow(project).to receive(:dependency_management_service_account).and_return(service_account)
      allow(DependencyManagement::SecurityUpdate::UpdateService)
        .to receive(:new).with(project: project).and_return(update_service)
    end

    context 'when scheduler has hit the remediation limit' do
      let_it_be(:filling_occurrences) do
        %w[rails_limit puma_limit nokogiri_limit].map do |name|
          component = create(:sbom_component, purl_type: 'gem', name: name)

          create(:sbom_occurrence, project: project, package_manager: 'bundler', component: component).tap do |o|
            vuln = create(:vulnerability, :with_finding, :detected,
              project: project, report_type: :dependency_scanning)

            vuln.finding.update!(solution: 'Upgrade to latest version.', raw_metadata: '{}')

            create(:sbom_occurrences_vulnerability, occurrence: o, vulnerability: vuln)

            o.reload
          end
        end
      end

      before do
        # Create 3 open merge requests from the service account to hit the limit
        filling_occurrences.each_with_index do |_occurrence, index|
          create(:merge_request, :opened,
            target_project: project,
            source_project: project,
            author: service_account,
            source_branch: "remediation-#{index}",
            target_branch: "main-#{index}",
            skip_branch_existence_check: true)
        end

        stub_finders_by_severity(critical: filling_occurrences)
        allow(update_service).to receive(:execute).and_return(ServiceResponse.success)
      end

      it 'does not schedule any new remediations' do
        expect(update_service).not_to receive(:execute)

        described_class.new(project: project).execute
      end
    end

    context 'when scheduler has 2 open remediations and can schedule 1 more' do
      let_it_be(:existing_occurrences) do
        %w[rails_two puma_two].map do |name|
          component = create(:sbom_component, purl_type: 'gem', name: name)

          create(:sbom_occurrence, project: project, package_manager: 'bundler', component: component).tap do |o|
            vuln = create(:vulnerability, :with_finding, :detected,
              project: project, report_type: :dependency_scanning)

            vuln.finding.update!(solution: 'Upgrade to latest version.', raw_metadata: '{}')

            create(:sbom_occurrences_vulnerability, occurrence: o, vulnerability: vuln)

            o.reload
          end
        end
      end

      let_it_be(:new_occurrence) do
        component = create(:sbom_component, purl_type: 'gem', name: 'nokogiri_two')

        create(:sbom_occurrence, project: project, package_manager: 'bundler', component: component).tap do |o|
          vuln = create(:vulnerability, :with_finding, :detected,
            project: project, report_type: :dependency_scanning)

          vuln.finding.update!(solution: 'Upgrade to latest version.', raw_metadata: '{}')

          create(:sbom_occurrences_vulnerability, occurrence: o, vulnerability: vuln)

          o.reload
        end
      end

      before do
        # Create 2 open merge requests from the service account
        existing_occurrences.each_with_index do |_occurrence, index|
          create(:merge_request, :opened,
            target_project: project,
            source_project: project,
            author: service_account,
            source_branch: "remediation-existing-#{index}",
            target_branch: "main-existing-#{index}",
            skip_branch_existence_check: true)
        end

        stub_finders_by_severity(critical: [*existing_occurrences, new_occurrence])
        allow(update_service).to receive(:execute).and_return(ServiceResponse.success)
      end

      it 'schedules exactly one more remediation' do
        expect(update_service).to receive(:execute).once.and_return(ServiceResponse.success)

        described_class.new(project: project).execute
      end
    end
  end
end
