# frozen_string_literal: true

require 'spec_helper'

RSpec.describe CloudConnector::StatusChecks::Probes::DuoAgentPlatformProbe, feature_category: :duo_setting do
  let(:user) { build(:user) }
  let(:feature_setting) { nil }
  let(:host) { 'duo-workflow-svc.runway.gitlab.net:443' }
  let(:secure) { true }
  let(:probe) { described_class.new(user, feature_setting: feature_setting) }
  let(:duo_workflow_client) { instance_double(Ai::DuoWorkflow::DuoWorkflowService::Client) }

  before do
    allow(Ai::DuoWorkflow::DuoWorkflowService::Client).to receive(:new).and_return(duo_workflow_client)
    allow(Gitlab::DuoWorkflow::Client)
      .to receive(:url_for).with(feature_setting: feature_setting, user: user).and_return(host)
    allow(Gitlab::DuoWorkflow::Client)
      .to receive(:secure?).with(feature_setting: feature_setting).and_return(secure)
  end

  shared_examples 'a successful probe' do
    before do
      allow(duo_workflow_client).to receive(:list_tools).and_return(status: :success)
    end

    it 'returns a successful result with the expected message' do
      result = probe.execute

      expect(result).to be_a(CloudConnector::StatusChecks::Probes::ProbeResult)
      expect(result.success?).to be(true)
      expect(result.message).to eq(expected_success_message)
    end

    it 'invokes DuoWorkflowService::Client with the resolved host and secure flag' do
      probe.execute

      expect(Ai::DuoWorkflow::DuoWorkflowService::Client).to have_received(:new).with(
        duo_workflow_service_url: host,
        current_user: user,
        secure: secure
      )
      expect(duo_workflow_client).to have_received(:list_tools)
    end
  end

  shared_examples 'a failed probe' do
    before do
      allow(duo_workflow_client).to receive(:list_tools).and_return(status: :error, message: 'Connection failed')
    end

    it 'returns a failed result with the not-operational message' do
      result = probe.execute

      expect(result).to be_a(CloudConnector::StatusChecks::Probes::ProbeResult)
      expect(result.success?).to be(false)
      expect(result.message).to eq("GitLab Duo Workflow Service at #{host} is not operational.")
    end
  end

  describe '#execute' do
    context 'when feature_setting is nil (cloud-connected)' do
      let(:feature_setting) { nil }
      let(:expected_success_message) do
        "GitLab Duo Workflow Service at #{host} is operational. " \
          "The model for Agents & flows is set to a GitLab managed model"
      end

      it_behaves_like 'a successful probe'
      it_behaves_like 'a failed probe'
    end

    context 'when feature_setting is vendored' do
      let(:feature_setting) { instance_double(Ai::FeatureSetting, self_hosted?: false) }
      let(:expected_success_message) do
        "GitLab Duo Workflow Service at #{host} is operational. " \
          "The model for Agents & flows is set to a GitLab managed model"
      end

      it_behaves_like 'a successful probe'
      it_behaves_like 'a failed probe'
    end

    context 'when feature_setting is self-hosted' do
      let(:host) { 'localhost:50052' }
      let(:feature_setting) { instance_double(Ai::FeatureSetting, self_hosted?: true) }
      let(:expected_success_message) do
        "GitLab Duo Workflow Service at #{host} is operational. " \
          "The model for Agents & flows is set to a self-hosted model."
      end

      it_behaves_like 'a successful probe'
      it_behaves_like 'a failed probe'

      context 'when list_tools fails with a TLS mismatch error and secure is enabled' do
        let(:secure) { true }
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

        it 'appends TLS guidance to the failure message' do
          result = probe.execute

          expect(result.success?).to be(false)
          expect(result.message).to include("GitLab Duo Workflow Service at #{host} is not operational.")
          expect(result.message).to include('It fails with a TLS mismatch error.')
          expect(result.message).to include('turn off TLS connection to the GitLab Duo Agent Platform service')
        end
      end

      context 'when list_tools fails with a TLS mismatch error but secure is disabled' do
        let(:secure) { false }

        before do
          allow(duo_workflow_client).to receive(:list_tools).and_return(
            status: :error,
            message: 'tls handshake error'
          )
        end

        it 'returns the plain failure message without TLS guidance' do
          result = probe.execute

          expect(result.success?).to be(false)
          expect(result.message).to eq("GitLab Duo Workflow Service at #{host} is not operational.")
        end
      end
    end
  end
end
