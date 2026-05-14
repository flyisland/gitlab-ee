# frozen_string_literal: true

require 'spec_helper'

RSpec.describe CloudConnector::StatusChecks::Probes::DuoAgentPlatformProbe, feature_category: :duo_setting do
  let(:user) { build(:user) }
  let(:probe) { described_class.new(user) }
  let(:duo_workflow_client) { instance_double(Ai::DuoWorkflow::DuoWorkflowService::Client) }
  let(:global_secure) { true }
  let(:self_hosted_secure) { false }
  let(:ai_settings) do
    instance_double(Ai::Setting, self_hosted_duo_agent_platform_service_secure: self_hosted_secure)
  end

  before do
    allow(Ai::DuoWorkflow::DuoWorkflowService::Client).to receive(:new).and_return(duo_workflow_client)
    allow(Gitlab::DuoWorkflow::Client).to receive(:secure?).with(feature_setting: nil).and_return(global_secure)
    allow(Ai::Setting).to receive(:instance).and_return(ai_settings)
  end

  shared_examples 'successful probe execution' do
    let(:success_response) { { status: :success, message: 'Tools listed successfully', payload: { tools: [] } } }

    before do
      allow(duo_workflow_client).to receive(:list_tools).and_return(success_response)
    end

    it 'returns a successful result' do
      result = probe.execute

      expect(result).to be_a(CloudConnector::StatusChecks::Probes::ProbeResult)
      expect(result.success?).to be(true)
      expect(result.message).to eq("GitLab Duo Workflow Service at #{host} is operational.")
    end

    it 'calls DuoWorkflowService::Client with correct parameters' do
      probe.execute

      expect(Ai::DuoWorkflow::DuoWorkflowService::Client).to have_received(:new).with(
        duo_workflow_service_url: host,
        current_user: user,
        secure: expected_secure
      )
      expect(duo_workflow_client).to have_received(:list_tools)
    end
  end

  shared_examples 'failed probe execution' do
    let(:error_response) { { status: :error, message: 'Connection failed' } }

    before do
      allow(duo_workflow_client).to receive(:list_tools).and_return(error_response)
    end

    it 'returns a failed result' do
      result = probe.execute

      expect(result).to be_a(CloudConnector::StatusChecks::Probes::ProbeResult)
      expect(result.success?).to be(false)
      expect(result.message).to eq("GitLab Duo Workflow Service at #{host} is not operational.")
    end
  end

  describe '#execute' do
    context 'when using cloud-connected URL' do
      let(:host) { 'duo-workflow-svc.runway.gitlab.net:443' }
      let(:expected_secure) { global_secure }

      before do
        allow(Gitlab::DuoWorkflow::Client).to receive(:self_hosted_url).and_return(nil)
        allow(Gitlab::DuoWorkflow::Client).to receive(:cloud_connected_url).with(user: user).and_return(host)
      end

      context 'when list_tools succeeds' do
        include_examples 'successful probe execution'
      end

      context 'when list_tools fails' do
        include_examples 'failed probe execution'
      end

      context 'with staging environment' do
        let(:staging_host) { 'duo-workflow-svc.staging.runway.gitlab.net:443' }

        before do
          allow(Gitlab::DuoWorkflow::Client).to receive(:cloud_connected_url).with(user: user).and_return(staging_host)
          allow(duo_workflow_client).to receive(:list_tools).and_return({ status: :success })
        end

        it 'uses the staging URL' do
          probe.execute

          expect(Ai::DuoWorkflow::DuoWorkflowService::Client).to have_received(:new).with(
            duo_workflow_service_url: staging_host,
            current_user: user,
            secure: expected_secure
          )
        end
      end
    end

    context 'when using self-hosted URL' do
      let(:host) { 'localhost:50052' }
      let(:expected_secure) { self_hosted_secure }

      before do
        allow(Gitlab::DuoWorkflow::Client).to receive(:self_hosted_url).and_return(host)
      end

      context 'when list_tools succeeds' do
        include_examples 'successful probe execution'
      end

      context 'when list_tools fails' do
        include_examples 'failed probe execution'
      end

      context 'when list_tools fails due to TLS mismatch with secure enabled' do
        let(:self_hosted_secure) { true }
        let(:error_response) do
          {
            status: :error,
            message: 'Ssl handshake failed (TSI_PROTOCOL_FAILURE): ' \
              'SSL_ERROR_SSL: error:100000f7:' \
              'SSL routines:OPENSSL_internal:WRONG_VERSION_NUMBER'
          }
        end

        before do
          allow(duo_workflow_client).to receive(:list_tools).and_return(error_response)
        end

        it 'adds guidance to disable TLS for non-TLS self-hosted endpoints' do
          result = probe.execute

          expect(result.success?).to be(false)
          expect(result.message).to include("GitLab Duo Workflow Service at #{host} is not operational.")
          expect(result.message).to include('It fails with a TLS mismatch error.')
          expect(result.message).to include('turn off TLS connection to the GitLab Duo Agent Platform service')
        end
      end

      context 'when global secure differs from self-hosted secure' do
        let(:global_secure) { false }
        let(:self_hosted_secure) { true }

        before do
          allow(duo_workflow_client).to receive(:list_tools).and_return({ status: :success })
        end

        it 'uses self-hosted secure value based on resolved host' do
          probe.execute

          expect(Ai::DuoWorkflow::DuoWorkflowService::Client).to have_received(:new).with(
            duo_workflow_service_url: host,
            current_user: user,
            secure: true
          )
        end
      end
    end
  end
end
