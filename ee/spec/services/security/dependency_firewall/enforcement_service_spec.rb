# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Security::DependencyFirewall::EnforcementService, feature_category: :dependency_firewall do
  let_it_be(:project) { create(:project) }
  let_it_be(:current_user) { create(:user) }

  describe '.new' do
    it 'is private' do
      expect { described_class.new }.to raise_error(NoMethodError, /private method `new' called/)
    end
  end

  describe '.firewall_check' do
    let(:pkg_type) { 'npm' }
    let(:name) { 'lodash' }
    let(:version) { '4.17.21' }
    let(:operation) { described_class::PACKAGE_DOWNLOAD }

    subject(:firewall_check) do
      described_class.firewall_check(project: project, pkg_type: pkg_type, name: name, version: version,
        operation: operation, current_user: current_user)
    end

    context 'when project is nil' do
      let(:project) { nil }

      before do
        stub_feature_flags(dependency_firewall_phase1: true)
      end

      it 'raises ArgumentError' do
        expect { firewall_check }.to raise_error(ArgumentError, /DependencyFirewall: project is nil/)
      end
    end

    context 'when project is valid' do
      context 'when feature flag is disabled' do
        before do
          stub_feature_flags(dependency_firewall_phase1: false)
        end

        it 'returns success with allowed status' do
          expect(firewall_check).to be_success
          expect(firewall_check.payload[:status]).to eq(described_class::SUCCESS_ALLOWED)
        end
      end

      context 'when project is not licensed' do
        before do
          stub_feature_flags(dependency_firewall_phase1: true)
          allow(project).to receive(:licensed_feature_available?).with(:dependency_firewall).and_return(false)
        end

        it 'returns success with allowed status' do
          expect(firewall_check).to be_success
          expect(firewall_check.payload[:status]).to eq(described_class::SUCCESS_ALLOWED)
        end
      end

      context 'when project is licensed' do
        before do
          allow(project).to receive(:licensed_feature_available?).with(:dependency_firewall).and_return(true)
          allow_next_instance_of(Security::DependencyFirewall::CreateAuditEventsService) do |svc|
            allow(svc).to receive(:execute)
          end
        end

        context 'when pkg_type is blank' do
          where(:pkg_type) { [[''], [nil]] }

          with_them do
            it 'raises ArgumentError' do
              expect { firewall_check }.to raise_error(ArgumentError, /DependencyFirewall: pkg_type is blank/)
            end
          end
        end

        context 'when name is blank' do
          where(:name) { [[''], [nil]] }

          with_them do
            it 'raises ArgumentError' do
              expect { firewall_check }.to raise_error(ArgumentError, /DependencyFirewall: name is blank/)
            end
          end
        end

        context 'when version is nil (e.g. metadata package)' do
          let(:version) { nil }

          it 'allows the check to proceed' do
            expect(firewall_check).to be_success
            expect(firewall_check.payload[:status]).to eq(described_class::SUCCESS_ALLOWED)
          end
        end

        context 'when operation is invalid' do
          where(:operation) { [[999], [nil]] }

          with_them do
            it 'raises ArgumentError' do
              expect { firewall_check }.to raise_error(ArgumentError, /DependencyFirewall: operation/)
            end
          end
        end

        context 'when operation is valid' do
          where(:operation_type) do
            [
              [described_class::PACKAGE_DOWNLOAD],
              [described_class::PACKAGE_UPLOAD],
              [described_class::CONTAINER_PULL],
              [described_class::CONTAINER_PUSH],
              [described_class::PACKAGE_FORWARDED]
            ]
          end

          with_them do
            let(:operation) { operation_type }

            before do
              allow_next_instance_of(Security::DependencyFirewall::FetchPackageLicensesService) do |svc|
                allow(svc).to receive(:execute).and_return([{ name: 'MIT' }])
              end
            end

            it 'returns success with allowed status' do
              expect(firewall_check).to be_success
              expect(firewall_check.payload[:status]).to eq(described_class::SUCCESS_ALLOWED)
            end
          end

          context 'when tracking dependency firewall events' do
            let(:operation) { described_class::PACKAGE_DOWNLOAD }

            before do
              stub_feature_flags(dependency_firewall_phase1: true)
              allow_next_instance_of(Security::DependencyFirewall::FetchPackageLicensesService) do |svc|
                allow(svc).to receive(:execute).and_return([{ name: 'MIT' }])
              end
            end

            context 'when package is allowed (no policy match)' do
              before do
                allow_next_instance_of(Security::DependencyFirewall::PolicyEvaluator) do |ev|
                  allow(ev).to receive(:evaluate).and_return([])
                end
              end

              it 'tracks event with SUCCESS_ALLOWED outcome' do
                double = instance_double(Security::DependencyFirewall::CreateEventService, execute: nil)
                expect(Security::DependencyFirewall::CreateEventService).to receive(:new).with(
                  project, current_user,
                  hash_including(
                    outcome: described_class::SUCCESS_ALLOWED,
                    operation: described_class::PACKAGE_DOWNLOAD
                  )
                ).and_return(double)

                firewall_check
              end
            end

            context 'when package is blocked' do
              before do
                allow_next_instance_of(Security::DependencyFirewall::PolicyEvaluator) do |ev|
                  allow(ev).to receive(:evaluate).and_return([
                    { policy_name: 'Block Policy', action: :denied, reason: :evaluation }
                  ])
                end
              end

              it 'tracks event with SUCCESS_BLOCKED outcome' do
                double = instance_double(Security::DependencyFirewall::CreateEventService, execute: nil)
                expect(Security::DependencyFirewall::CreateEventService).to receive(:new).with(
                  project, current_user,
                  hash_including(outcome: described_class::SUCCESS_BLOCKED)
                ).and_return(double)

                firewall_check
              end
            end

            context 'when package is warned' do
              before do
                allow_next_instance_of(Security::DependencyFirewall::PolicyEvaluator) do |ev|
                  allow(ev).to receive(:evaluate).and_return([
                    { policy_name: 'Warn Policy', action: :warned, reason: :evaluation }
                  ])
                end
              end

              it 'tracks event with SUCCESS_WARNING outcome' do
                double = instance_double(Security::DependencyFirewall::CreateEventService, execute: nil)
                expect(Security::DependencyFirewall::CreateEventService).to receive(:new).with(
                  project, current_user,
                  hash_including(outcome: described_class::SUCCESS_WARNING)
                ).and_return(double)

                firewall_check
              end
            end

            context 'when no licenses are found for the package' do
              before do
                allow_next_instance_of(Security::DependencyFirewall::FetchPackageLicensesService) do |svc|
                  allow(svc).to receive(:execute).and_return([])
                end
                allow_next_instance_of(Security::DependencyFirewall::PolicyEvaluator) do |ev|
                  allow(ev).to receive(:evaluate).and_return([])
                end
              end

              it 'still invokes the evaluator and tracks SUCCESS_ALLOWED when it allows' do
                double = instance_double(Security::DependencyFirewall::CreateEventService, execute: nil)
                expect(Security::DependencyFirewall::CreateEventService).to receive(:new).with(
                  project, current_user,
                  hash_including(outcome: described_class::SUCCESS_ALLOWED)
                ).and_return(double)

                firewall_check
              end
            end

            context 'with a package operation' do
              it 'includes purl in event params' do
                allow_next_instance_of(Security::DependencyFirewall::PolicyEvaluator) do |ev|
                  allow(ev).to receive(:evaluate).and_return([])
                end

                double = instance_double(Security::DependencyFirewall::CreateEventService, execute: nil)
                expect(Security::DependencyFirewall::CreateEventService).to receive(:new).with(
                  project, current_user, hash_including(purl: "pkg:npm/lodash@4.17.21")
                ).and_return(double)

                firewall_check
              end
            end

            context 'when tracking the operation' do
              before do
                allow_next_instance_of(Security::DependencyFirewall::PolicyEvaluator) do |ev|
                  allow(ev).to receive(:evaluate).and_return([])
                end
              end

              context 'when the operation is a package forward' do
                let(:operation) { described_class::PACKAGE_FORWARDED }

                it 'tracks the event with the forwarded operation' do
                  double = instance_double(Security::DependencyFirewall::CreateEventService, execute: nil)
                  expect(Security::DependencyFirewall::CreateEventService).to receive(:new).with(
                    project, current_user, hash_including(operation: described_class::PACKAGE_FORWARDED)
                  ).and_return(double)

                  firewall_check
                end
              end

              context 'when the operation is not a package forward' do
                let(:operation) { described_class::PACKAGE_DOWNLOAD }

                it 'tracks the event with the package download operation' do
                  double = instance_double(Security::DependencyFirewall::CreateEventService, execute: nil)
                  expect(Security::DependencyFirewall::CreateEventService).to receive(:new).with(
                    project, current_user, hash_including(operation: described_class::PACKAGE_DOWNLOAD)
                  ).and_return(double)

                  firewall_check
                end
              end
            end

            context 'with a container operation' do
              let(:operation) { described_class::CONTAINER_PULL }
              let(:pkg_type) { 'docker' }
              let(:name) { 'cassandra' }
              let(:version) { 'sha256:244fd47e07d1004f0aed9c' }

              before do
                allow_next_instance_of(Security::DependencyFirewall::PolicyEvaluator) do |ev|
                  allow(ev).to receive(:evaluate).and_return([])
                end
              end

              it 'includes purl in event params' do
                double = instance_double(Security::DependencyFirewall::CreateEventService, execute: nil)
                expect(Security::DependencyFirewall::CreateEventService).to receive(:new).with(
                  project, current_user,
                  hash_including(purl: "pkg:docker/cassandra@sha256:244fd47e07d1004f0aed9c")
                ).and_return(double)

                firewall_check
              end
            end

            context 'when both denied and warned results are present' do
              before do
                allow_next_instance_of(Security::DependencyFirewall::PolicyEvaluator) do |ev|
                  allow(ev).to receive(:evaluate).and_return([
                    { policy_name: 'Warn Policy', action: :warned, reason: :evaluation },
                    { policy_name: 'Block Policy', action: :denied, reason: :evaluation }
                  ])
                end
              end

              it 'tracks SUCCESS_BLOCKED outcome (denied takes priority over warned)' do
                double = instance_double(Security::DependencyFirewall::CreateEventService, execute: nil)
                expect(Security::DependencyFirewall::CreateEventService).to receive(:new).with(
                  project, current_user, hash_including(outcome: described_class::SUCCESS_BLOCKED)
                ).and_return(double)

                firewall_check
              end
            end

            context 'when feature is disabled (project not licensed)' do
              before do
                allow(project).to receive(:licensed_feature_available?).with(:dependency_firewall).and_return(false)
              end

              it 'does not track any event' do
                expect(Security::DependencyFirewall::CreateEventService).not_to receive(:new)

                firewall_check
              end
            end
          end

          context 'when the package does not exist in the package metadata database' do
            let(:pkg_type) { 'maven' }
            let(:name) { 'unknown-lib' }
            let(:version) { '1.0.0' }
            let(:operation) { described_class::PACKAGE_DOWNLOAD }

            it 'returns allowed when licenses cannot be determined' do
              expect(firewall_check).to be_success
              expect(firewall_check.payload[:status]).to eq(described_class::SUCCESS_ALLOWED)
            end
          end

          context 'when the package exists in the package metadata database' do
            let(:operation) { described_class::PACKAGE_DOWNLOAD }

            where(:pkg_type, :name, :version) do
              [
                ['maven', 'trivial-lib', '1.0.0'],
                ['maven', 'commons-lang3', '3.12.0'],
                ['npm', 'lodash', '4.17.21']
              ]
            end

            with_them do
              before do
                create(:pm_package,
                  name: name,
                  purl_type: pkg_type,
                  other_licenses: [{ license_names: ['Apache-2.0'], versions: [version] }])
              end

              it 'succeeds after fetching license data' do
                expect(firewall_check).to be_success
                expect(firewall_check.payload[:status]).to eq(described_class::SUCCESS_ALLOWED)
              end
            end
          end

          context 'when vulnerabilities are fetched' do
            let(:operation) { described_class::PACKAGE_DOWNLOAD }
            let(:fetched_vulnerabilities) do
              [{ id: 'CVE-2099-0001', severity: 'high' }]
            end

            before do
              stub_feature_flags(dependency_firewall_phase1: true)
              allow_next_instance_of(::Security::DependencyFirewall::FetchPackageLicensesService) do |svc|
                allow(svc).to receive(:execute).and_return([])
              end
              allow_next_instance_of(::Security::DependencyFirewall::FetchPackageVulnerabilitiesService) do |svc|
                allow(svc).to receive(:execute).and_return(fetched_vulnerabilities)
              end
            end

            it 'forwards them to the PolicyEvaluator under :vulnerabilities' do
              expect_next_instance_of(::Security::DependencyFirewall::PolicyEvaluator) do |evaluator|
                expect(evaluator).to receive(:evaluate)
                  .with(name, hash_including(vulnerabilities: fetched_vulnerabilities))
                  .and_return([])
              end

              firewall_check
            end
          end

          context 'when both licenses and vulnerabilities are empty' do
            let(:operation) { described_class::PACKAGE_DOWNLOAD }

            before do
              stub_feature_flags(dependency_firewall_phase1: true)
              allow_next_instance_of(::Security::DependencyFirewall::FetchPackageLicensesService) do |svc|
                allow(svc).to receive(:execute).and_return([])
              end
              allow_next_instance_of(::Security::DependencyFirewall::FetchPackageVulnerabilitiesService) do |svc|
                allow(svc).to receive(:execute).and_return([])
              end
            end

            it 'still evaluates the policy and lets the evaluator decide the outcome', :aggregate_failures do
              expect_next_instance_of(::Security::DependencyFirewall::PolicyEvaluator) do |evaluator|
                expect(evaluator).to receive(:evaluate)
                  .with(name, hash_including(licenses: [], vulnerabilities: []))
                  .and_return([])
              end

              expect(firewall_check).to be_success
              expect(firewall_check.payload[:status]).to eq(described_class::SUCCESS_ALLOWED)
            end
          end

          context 'when the policy has only vulnerability rules and license data is empty' do
            let(:operation) { described_class::PACKAGE_DOWNLOAD }
            let(:fetched_vulnerabilities) do
              [{ id: 'CVE-2099-0001', severity: 'low' }]
            end

            before do
              stub_feature_flags(dependency_firewall_phase1: true)
              allow_next_instance_of(::Security::DependencyFirewall::FetchPackageLicensesService) do |svc|
                allow(svc).to receive(:execute).and_return([])
              end
              allow_next_instance_of(::Security::DependencyFirewall::FetchPackageVulnerabilitiesService) do |svc|
                allow(svc).to receive(:execute).and_return(fetched_vulnerabilities)
              end
              allow_next_instance_of(::Security::DependencyFirewall::PolicyEvaluator) do |ev|
                allow(ev).to receive(:evaluate)
                  .and_return([{ policy_name: 'vuln only', action: :allowed, reason: :evaluation }])
              end
            end

            it 'does not block because of the missing license data', :aggregate_failures do
              expect(firewall_check).to be_success
              expect(firewall_check.payload[:status]).to eq(described_class::SUCCESS_ALLOWED)
            end
          end

          context 'when the policy has only license rules and vulnerability data is empty' do
            let(:operation) { described_class::PACKAGE_DOWNLOAD }

            before do
              stub_feature_flags(dependency_firewall_phase1: true)
              allow_next_instance_of(::Security::DependencyFirewall::FetchPackageLicensesService) do |svc|
                allow(svc).to receive(:execute).and_return([{ name: 'MIT' }])
              end
              allow_next_instance_of(::Security::DependencyFirewall::FetchPackageVulnerabilitiesService) do |svc|
                allow(svc).to receive(:execute).and_return([])
              end
              allow_next_instance_of(::Security::DependencyFirewall::PolicyEvaluator) do |ev|
                allow(ev).to receive(:evaluate)
                  .and_return([{ policy_name: 'license only', action: :allowed, reason: :evaluation }])
              end
            end

            it 'does not block because of the missing vulnerability data', :aggregate_failures do
              expect(firewall_check).to be_success
              expect(firewall_check.payload[:status]).to eq(described_class::SUCCESS_ALLOWED)
            end
          end

          context 'when the policy has both license and vulnerability rules and neither allows' do
            let(:operation) { described_class::PACKAGE_DOWNLOAD }

            before do
              stub_feature_flags(dependency_firewall_phase1: true)
              allow_next_instance_of(::Security::DependencyFirewall::FetchPackageLicensesService) do |svc|
                allow(svc).to receive(:execute).and_return([{ name: 'GPL-3.0' }])
              end
              allow_next_instance_of(::Security::DependencyFirewall::FetchPackageVulnerabilitiesService) do |svc|
                allow(svc).to receive(:execute).and_return([{ id: 'CVE-2099-0001', severity: 'critical' }])
              end
              allow_next_instance_of(::Security::DependencyFirewall::PolicyEvaluator) do |ev|
                allow(ev).to receive(:evaluate).and_return([
                  { policy_name: 'license rule', action: :denied, reason: :evaluation },
                  { policy_name: 'vulnerability rule', action: :denied, reason: :evaluation }
                ])
              end
            end

            it 'blocks the package', :aggregate_failures do
              expect(firewall_check).to be_error
              expect(firewall_check.reason).to eq(described_class::SUCCESS_BLOCKED)
            end
          end

          context 'when evaluating policy result priority' do
            let(:operation) { described_class::PACKAGE_DOWNLOAD }

            before do
              stub_feature_flags(dependency_firewall_phase1: true)
              allow_next_instance_of(::Security::DependencyFirewall::FetchPackageLicensesService) do |svc|
                allow(svc).to receive(:execute).and_return([{ name: 'MIT' }])
              end
              allow_next_instance_of(::Security::DependencyFirewall::PolicyEvaluator) do |ev|
                allow(ev).to receive(:evaluate).and_return(evaluator_results)
              end
            end

            context 'when results are empty' do
              let(:evaluator_results) { [] }

              it 'returns allowed' do
                expect(firewall_check).to be_success
                expect(firewall_check.payload[:status]).to eq(described_class::SUCCESS_ALLOWED)
              end
            end

            context 'when all results are :allowed' do
              let(:evaluator_results) do
                [
                  { policy_name: 'policy 1', action: :allowed, reason: :evaluation },
                  { policy_name: 'policy 2', action: :allowed, reason: :user_bypassed }
                ]
              end

              it 'returns allowed' do
                expect(firewall_check).to be_success
                expect(firewall_check.payload[:status]).to eq(described_class::SUCCESS_ALLOWED)
              end

              it 'audits the bypass/exception result rather than an empty one' do
                audit_service = instance_double(Security::DependencyFirewall::CreateAuditEventsService, execute: nil)

                expect(Security::DependencyFirewall::CreateAuditEventsService).to receive(:new).with(
                  hash_including(
                    event_type: :allowed,
                    result: { policy_name: 'policy 2', action: :allowed, reason: :user_bypassed }
                  )
                ).and_return(audit_service)

                firewall_check
              end
            end

            context 'when all allowed results have a non-notable reason' do
              let(:evaluator_results) do
                [
                  { policy_name: 'policy 1', action: :allowed, reason: :evaluation },
                  { policy_name: 'policy 2', action: :allowed, reason: :no_matches }
                ]
              end

              it 'audits with an empty result' do
                audit_service = instance_double(Security::DependencyFirewall::CreateAuditEventsService, execute: nil)

                expect(Security::DependencyFirewall::CreateAuditEventsService).to receive(:new).with(
                  hash_including(event_type: :allowed, result: {})
                ).and_return(audit_service)

                firewall_check
              end
            end

            context 'when results include :allowed, :warned, and :denied' do
              let(:evaluator_results) do
                [
                  { policy_name: 'policy 1', action: :allowed, reason: :evaluation },
                  { policy_name: 'policy 2', action: :warned, reason: :user_bypassed },
                  { policy_name: 'policy 3', action: :denied, reason: :token_bypassed }
                ]
              end

              it 'returns blocked (denied takes highest priority)' do
                expect(firewall_check).to be_error
                expect(firewall_check.reason).to eq(described_class::SUCCESS_BLOCKED)
                expect(firewall_check.message).to eq("Package 'lodash' violates 'policy 3' policy")
              end
            end

            context 'when multiple results are of the same action, the first policy name is used' do
              context 'with multiple :denied results' do
                let(:evaluator_results) do
                  [
                    { policy_name: 'block policy 1', action: :denied, reason: :evaluation },
                    { policy_name: 'block policy 2', action: :denied, reason: :evaluation }
                  ]
                end

                it 'uses the first denied policy name in the message' do
                  expect(firewall_check).to be_error
                  expect(firewall_check.message).to eq("Package 'lodash' violates 'block policy 1' policy")
                end
              end

              context 'with :allowed and :warned results' do
                let(:evaluator_results) do
                  [
                    { policy_name: 'warn policy 1', action: :allowed, reason: :evaluation },
                    { policy_name: 'warn policy 2', action: :warned, reason: :evaluation }
                  ]
                end

                it 'uses the first warned policy name in the message' do
                  expect(firewall_check).to be_success
                  expect(firewall_check.payload[:status]).to eq(described_class::SUCCESS_WARNING)
                  expect(firewall_check.payload[:message]).to eq("Package 'lodash' violates 'warn policy 2' policy")
                end
              end
            end
          end
        end
      end
    end
  end
end
