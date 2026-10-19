# frozen_string_literal: true

require 'spec_helper'

RSpec.describe CloudConnector::StatusChecks::Probes::Registry, feature_category: :duo_setting do
  let(:user) { build(:user) }
  let(:license) { build(:license) }
  let(:self_hosted_dws_url) { nil }
  let(:dap_probe_class) { CloudConnector::StatusChecks::Probes::DuoAgentPlatformProbe }

  subject(:registry) { described_class.new(user) }

  def dap_deployments(probes)
    probes.select { |probe| probe.is_a?(dap_probe_class) }.map do |probe|
      probe.instance_variable_get(:@deployment)
    end
  end

  before do
    allow(::License).to receive(:current).and_return(license)
    allow(license).to receive(:offline_cloud_license?).and_return(false)
    allow(::Gitlab::DuoWorkflow::Client).to receive(:self_hosted_url).and_return(self_hosted_dws_url)
  end

  describe 'Duo Agent Platform probe selection' do
    shared_examples 'selects Duo Agent Platform probes' do
      context 'when feature flag jh_enable_upload_cloud_license is enabled' do
        before do
          stub_feature_flags(jh_enable_upload_cloud_license: true)
        end

        it 'skips the cloud-connected Duo Agent Platform probe' do
          expect(dap_deployments(probes)).to be_empty
        end

        context 'and a self-hosted DWS URL is configured' do
          let(:self_hosted_dws_url) { 'localhost:50052' }

          it 'includes only the self-hosted probe' do
            expect(dap_deployments(probes)).to contain_exactly(:self_hosted)
          end
        end

        context 'and the license is an offline cloud license' do
          before do
            allow(license).to receive(:offline_cloud_license?).and_return(true)
          end

          it 'skips the cloud-connected probe' do
            expect(dap_deployments(probes)).to be_empty
          end
        end
      end

      context 'when feature flag jh_enable_upload_cloud_license is disabled' do
        before do
          stub_feature_flags(jh_enable_upload_cloud_license: false)
        end

        it 'includes the cloud-connected Duo Agent Platform probe' do
          expect(dap_deployments(probes)).to contain_exactly(:cloud_connected)
        end

        context 'and a self-hosted DWS URL is configured' do
          let(:self_hosted_dws_url) { 'localhost:50052' }

          it 'includes both the cloud-connected and self-hosted probes' do
            expect(dap_deployments(probes)).to contain_exactly(:cloud_connected, :self_hosted)
          end
        end

        context 'and the license is an offline cloud license' do
          before do
            allow(license).to receive(:offline_cloud_license?).and_return(true)
          end

          it 'excludes the cloud-connected probe' do
            expect(dap_deployments(probes)).to be_empty
          end

          context 'and a self-hosted DWS URL is configured' do
            let(:self_hosted_dws_url) { 'localhost:50052' }

            it 'includes only the self-hosted probe' do
              expect(dap_deployments(probes)).to contain_exactly(:self_hosted)
            end
          end
        end
      end
    end

    context 'with default probes' do
      let(:probes) { registry.default_probes }

      it_behaves_like 'selects Duo Agent Platform probes'
    end

    context 'with self-hosted probes' do
      let(:probes) { registry.self_hosted_probes }

      it_behaves_like 'selects Duo Agent Platform probes'
    end
  end
end
