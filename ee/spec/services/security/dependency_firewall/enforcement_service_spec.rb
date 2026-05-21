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
          let(:operation) { 999 }

          it 'raises ArgumentError' do
            expect { firewall_check }.to raise_error(ArgumentError, /DependencyFirewall: operation/)
          end
        end

        context 'when operation is nil' do
          let(:operation) { nil }

          it 'raises ArgumentError' do
            expect { firewall_check }.to raise_error(ArgumentError, /DependencyFirewall: operation/)
          end
        end

        context 'when operation is valid' do
          where(:operation_type) do
            [
              [described_class::PACKAGE_DOWNLOAD],
              [described_class::PACKAGE_UPLOAD],
              [described_class::CONTAINER_PULL],
              [described_class::CONTAINER_PUSH]
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

          context 'when evaluating policy result priority' do
            let(:operation) { described_class::PACKAGE_DOWNLOAD }

            before do
              stub_feature_flags(dependency_firewall_phase1: true)
              allow_next_instance_of(Security::DependencyFirewall::FetchPackageLicensesService) do |svc|
                allow(svc).to receive(:execute).and_return([{ name: 'MIT' }])
              end
              allow_next_instance_of(Security::DependencyFirewall::LicenseRuleEvaluator) do |ev|
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
