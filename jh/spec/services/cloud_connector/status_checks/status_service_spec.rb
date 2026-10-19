# frozen_string_literal: true

require 'spec_helper'

RSpec.describe CloudConnector::StatusChecks::StatusService, feature_category: :cloud_connector do
  let(:user) { build(:user) }

  describe '#initialize' do
    context 'when no probes are passed' do
      subject(:service) { described_class.new(user: user) }

      it 'has the expected default probes' do
        service_probes = service.probes

        expect(service_probes.count).to eq(10)
        expect(service_probes[0]).to be_an_instance_of(CloudConnector::StatusChecks::Probes::LicenseProbe)
        expect(service_probes[1]).to be_an_instance_of(CloudConnector::StatusChecks::Probes::HostProbe)
        expect(service_probes[2]).to be_an_instance_of(CloudConnector::StatusChecks::Probes::HostProbe)
        expect(service_probes[3]).to be_an_instance_of(CloudConnector::StatusChecks::Probes::AccessProbe)
        expect(service_probes[4]).to be_an_instance_of(CloudConnector::StatusChecks::Probes::TokenProbe)
        expect(service_probes[5]).to be_an_instance_of(CloudConnector::StatusChecks::Probes::EndToEndProbe)
        expect(service_probes[6]).to be_an_instance_of(CloudConnector::StatusChecks::Probes::DuoAgentPlatformProbe)
        expect(service_probes[1].instance_variable_get(:@host)).to eq('customers-stg.jihulab.com')
        expect(service_probes[2].instance_variable_get(:@host)).to eq('cloud.gitlab.com')
      end
    end
  end
end
