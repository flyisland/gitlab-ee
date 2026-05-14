# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Security::DependencyFirewall::EnforcementService, feature_category: :dependency_firewall do
  let_it_be(:project) { create(:project) }

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
        operation: operation)
    end

    context 'when project is nil' do
      let(:project) { nil }

      before do
        stub_feature_flags(dependency_firewall_phase1: true)
      end

      it 'returns error with invalid parameter reason' do
        expect(firewall_check).to be_error
        expect(firewall_check.reason).to eq(described_class::ERROR_REASON_INVALID_PARAMETER)
        expect(firewall_check.message).to eq('Project is not valid.')
      end
    end

    context 'when project is valid' do
      context 'when feature flag is disabled' do
        before do
          stub_feature_flags(dependency_firewall_phase1: false)
        end

        it 'returns error with feature disabled reason' do
          expect(firewall_check).to be_error
          expect(firewall_check.reason).to eq(described_class::ERROR_REASON_FEATURE_DISABLED)
          expect(firewall_check.message).to eq('Feature flag not enabled')
        end
      end

      context 'when project is not licensed' do
        before do
          allow(project).to receive(:licensed_feature_available?).with(:dependency_firewall).and_return(false)
        end

        it 'returns error with not licensed reason' do
          expect(firewall_check).to be_error
          expect(firewall_check.reason).to eq(described_class::ERROR_REASON_NOT_LICENSED)
          expect(firewall_check.message).to eq('Not licensed')
        end
      end

      context 'when project is licensed' do
        before do
          allow(project).to receive(:licensed_feature_available?).with(:dependency_firewall).and_return(true)
        end

        context 'when pkg_type is blank' do
          where(:pkg_type) { [[''], [nil]] }

          with_them do
            it 'returns error with invalid parameter reason' do
              expect(firewall_check).to be_error
              expect(firewall_check.reason).to eq(described_class::ERROR_REASON_INVALID_PARAMETER)
              expect(firewall_check.message).to eq('Package type is missing')
            end
          end
        end

        context 'when name is blank' do
          where(:name) { [[''], [nil]] }

          with_them do
            it 'returns error with invalid parameter reason' do
              expect(firewall_check).to be_error
              expect(firewall_check.reason).to eq(described_class::ERROR_REASON_INVALID_PARAMETER)
              expect(firewall_check.message).to eq('Name is missing')
            end
          end
        end

        context 'when version is blank' do
          where(:version) { [[nil], ['']] }

          with_them do
            it 'returns error with invalid parameter reason' do
              expect(firewall_check).to be_error
              expect(firewall_check.reason).to eq(described_class::ERROR_REASON_INVALID_PARAMETER)
              expect(firewall_check.message).to eq('Version is missing')
            end
          end
        end

        context 'when operation is invalid' do
          let(:operation) { 999 }

          it 'returns error with invalid parameter reason' do
            expect(firewall_check).to be_error
            expect(firewall_check.reason).to eq(described_class::ERROR_REASON_INVALID_PARAMETER)
            expect(firewall_check.message).to eq('Operation is not valid or empty')
          end
        end

        context 'when operation is nil' do
          let(:operation) { nil }

          it 'returns error with invalid parameter reason' do
            expect(firewall_check).to be_error
            expect(firewall_check.reason).to eq(described_class::ERROR_REASON_INVALID_PARAMETER)
            expect(firewall_check.message).to eq('Operation is not valid or empty')
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

            it 'returns success with allowed status' do
              expect(firewall_check).to be_success
              expect(firewall_check.payload[:status]).to eq(described_class::SUCCESS_ALLOWED)
            end
          end

          context 'when the license fetch fails' do
            let(:operation) { described_class::PACKAGE_DOWNLOAD }

            before do
              allow_next_instance_of(Security::DependencyFirewall::FetchPackageLicensesService) do |svc|
                allow(svc).to receive(:execute).and_return(
                  ServiceResponse.error(message: 'something went wrong')
                )
              end
            end

            it 'propagates the error' do
              expect(firewall_check).to be_error
              expect(firewall_check.message).to eq('something went wrong')
            end
          end

          context 'when the package does not exist in the package metadata database' do
            let(:pkg_type) { 'maven' }
            let(:name) { 'unknown-lib' }
            let(:version) { '1.0.0' }
            let(:operation) { described_class::PACKAGE_DOWNLOAD }

            # TODO: should not return SUCCESS_ALLOWED when
            # https://gitlab.com/gitlab-org/gitlab/-/work_items/593844 is implemented
            it 'still returns success with allowed status' do
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
        end
      end
    end
  end
end
