# frozen_string_literal: true

require 'spec_helper'

RSpec.describe CloudConnector::StatusChecks::Probes::Registry, feature_category: :duo_setting do
  let(:user) { build(:user) }

  let(:foundational_flows_probe_types) do
    [
      an_instance_of(CloudConnector::StatusChecks::Probes::FoundationalFlows::AllowFlowExecutionProbe),
      an_instance_of(CloudConnector::StatusChecks::Probes::FoundationalFlows::AllowFoundationalFlowsProbe),
      an_instance_of(CloudConnector::StatusChecks::Probes::FoundationalFlows::CompatibleRunnerProbe)
    ]
  end

  let(:default_probe_types) do
    [
      an_instance_of(CloudConnector::StatusChecks::Probes::LicenseProbe),
      an_instance_of(CloudConnector::StatusChecks::Probes::HostProbe),
      an_instance_of(CloudConnector::StatusChecks::Probes::HostProbe),
      an_instance_of(CloudConnector::StatusChecks::Probes::AccessProbe),
      an_instance_of(CloudConnector::StatusChecks::Probes::TokenProbe),
      an_instance_of(CloudConnector::StatusChecks::Probes::EndToEndProbe),
      an_instance_of(CloudConnector::StatusChecks::Probes::DuoAgentPlatformProbe),
      *foundational_flows_probe_types
    ]
  end

  let(:development_probe_types) do
    [
      an_instance_of(CloudConnector::StatusChecks::Probes::HostProbe),
      an_instance_of(CloudConnector::StatusChecks::Probes::EndToEndProbe)
    ]
  end

  let(:amazon_q_probe_types) do
    [
      an_instance_of(CloudConnector::StatusChecks::Probes::AmazonQ::EndToEndProbe)
    ]
  end

  let(:self_hosted_only_probe_types) do
    [
      an_instance_of(CloudConnector::StatusChecks::Probes::SelfHosted::AiGatewayUrlPresenceProbe),
      an_instance_of(CloudConnector::StatusChecks::Probes::HostProbe),
      an_instance_of(CloudConnector::StatusChecks::Probes::SelfHosted::CodeSuggestionsLicenseProbe)
    ]
  end

  subject(:registry) { described_class.new(user) }

  def stub_feature_setting_selection(feature, payload)
    service = instance_double(Ai::FeatureSettingSelectionService)
    allow(Ai::FeatureSettingSelectionService)
      .to receive(:new).with(user, feature, nil).and_return(service)
    allow(service).to receive(:execute).and_return(ServiceResponse.success(payload: payload))
  end

  def build_feature_setting(self_hosted: false, vendored: false)
    instance_double(Ai::FeatureSetting, self_hosted?: self_hosted, vendored?: vendored)
  end

  before do
    # Default: neither feature is configured (selection service returns nil payload).
    stub_feature_setting_selection(:code_completions, nil)
    stub_feature_setting_selection(:duo_agent_platform, nil)
  end

  describe '#default_probes' do
    it 'returns the correct number and types of default probes' do
      expect(registry.default_probes).to match(default_probe_types)
    end
  end

  describe '#development_probes' do
    it 'returns the correct number and types of development probes' do
      expect(registry.development_probes).to match(development_probe_types)
    end
  end

  describe '#amazon_q_probes' do
    it 'returns the correct number and types of Amazon Q probes' do
      expect(registry.amazon_q_probes).to match(amazon_q_probe_types)
    end
  end

  describe '#self_hosted_probes' do
    context 'when no vendored feature setting and no instance model selection exists' do
      it 'returns the self-hosted-only probes followed by the foundational-flows probes' do
        probes = registry.self_hosted_probes

        expect(probes).to match(self_hosted_only_probe_types + foundational_flows_probe_types)
        expect(probes).not_to include(an_instance_of(CloudConnector::StatusChecks::Probes::DuoAgentPlatformProbe))
      end

      context 'when the duo agent platform is configured as self-hosted' do
        before do
          stub_feature_setting_selection(:duo_agent_platform, build_feature_setting(self_hosted: true))
        end

        it 'appends the DuoAgentPlatformProbe before the foundational-flows probes' do
          probes = registry.self_hosted_probes

          expect(probes).to match(
            self_hosted_only_probe_types +
              [an_instance_of(CloudConnector::StatusChecks::Probes::DuoAgentPlatformProbe)] +
              foundational_flows_probe_types
          )
        end
      end
    end

    context 'when at least one vendored feature exists' do
      context 'with an Ai::FeatureSetting record' do
        before do
          create(:ai_feature_setting, feature: :code_completions, provider: :vendored)
        end

        context 'and both code completions and duo agent platform are vendored' do
          before do
            stub_feature_setting_selection(:code_completions, build_feature_setting(vendored: true))
            stub_feature_setting_selection(:duo_agent_platform, build_feature_setting(vendored: true))
          end

          it 'returns default probes combined with self-hosted-only probes' do
            expect(registry.self_hosted_probes).to match(default_probe_types + self_hosted_only_probe_types)
          end
        end

        context 'and code completions is not vendored' do
          before do
            stub_feature_setting_selection(:code_completions, build_feature_setting(vendored: false))
            stub_feature_setting_selection(:duo_agent_platform, build_feature_setting(vendored: true))
          end

          it 'excludes EndToEndProbe and keeps DuoAgentPlatformProbe' do
            probes = registry.self_hosted_probes

            expect(probes).not_to include(an_instance_of(CloudConnector::StatusChecks::Probes::EndToEndProbe))
            expect(probes).to include(an_instance_of(CloudConnector::StatusChecks::Probes::DuoAgentPlatformProbe))
          end
        end

        context 'and duo agent platform is not vendored' do
          before do
            stub_feature_setting_selection(:code_completions, build_feature_setting(vendored: true))
            stub_feature_setting_selection(:duo_agent_platform, build_feature_setting(vendored: false))
          end

          it 'excludes DuoAgentPlatformProbe from the default-side probes' do
            probes = registry.self_hosted_probes

            expect(probes).to include(an_instance_of(CloudConnector::StatusChecks::Probes::EndToEndProbe))
            expect(probes).not_to include(an_instance_of(CloudConnector::StatusChecks::Probes::DuoAgentPlatformProbe))
          end

          context 'and duo agent platform is self-hosted' do
            before do
              stub_feature_setting_selection(
                :duo_agent_platform,
                build_feature_setting(self_hosted: true, vendored: false)
              )
            end

            it 'still adds DuoAgentPlatformProbe via the self-hosted-only branch' do
              probes = registry.self_hosted_probes

              expect(probes).to include(an_instance_of(CloudConnector::StatusChecks::Probes::DuoAgentPlatformProbe))
            end
          end
        end
      end

      context 'with an Ai::ModelSelection::InstanceModelSelectionFeatureSetting record' do
        before do
          allow(::Ai::FeatureSetting).to receive_message_chain(:vendored, :exists?).and_return(false)
          allow(::Ai::ModelSelection::InstanceModelSelectionFeatureSetting).to receive(:exists?).and_return(true)
        end

        it 'still routes through the vendored-features path' do
          expect(registry.self_hosted_probes)
            .to include(an_instance_of(CloudConnector::StatusChecks::Probes::LicenseProbe))
        end
      end
    end
  end
end
