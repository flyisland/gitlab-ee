# frozen_string_literal: true

module CloudConnector
  module StatusChecks
    module Probes
      class Registry
        include Gitlab::Utils::StrongMemoize

        CUSTOMERS_DOT_URL = ::Gitlab::Routing.url_helpers.subscription_portal_url.freeze
        CLOUD_CONNECTOR_URL = ::CloudConnector::Config.base_url.freeze

        def initialize(user)
          @user = user
        end

        # Carries out minimal checks for development and testing purposes
        def development_probes
          [
            ::CloudConnector::StatusChecks::Probes::HostProbe.new(::Gitlab::AiGateway.self_hosted_url),
            ::CloudConnector::StatusChecks::Probes::EndToEndProbe.new(@user)
          ]
        end

        def amazon_q_probes
          [
            ::CloudConnector::StatusChecks::Probes::AmazonQ::EndToEndProbe.new(@user)
          ]
        end

        def self_hosted_probes
          if at_least_one_vendored_feature?
            [
              *probes_for_vendored_features,
              *self_hosted_only_probes
            ]
          else
            [
              *self_hosted_only_probes,
              *foundational_flows_probes
            ]
          end
        end

        def default_probes
          [
            ::CloudConnector::StatusChecks::Probes::LicenseProbe.new,
            ::CloudConnector::StatusChecks::Probes::HostProbe.new(CUSTOMERS_DOT_URL),
            ::CloudConnector::StatusChecks::Probes::HostProbe.new(CLOUD_CONNECTOR_URL),
            ::CloudConnector::StatusChecks::Probes::AccessProbe.new,
            ::CloudConnector::StatusChecks::Probes::TokenProbe.new,
            ::CloudConnector::StatusChecks::Probes::EndToEndProbe.new(@user),
            ::CloudConnector::StatusChecks::Probes::DuoAgentPlatformProbe.new(@user,
              feature_setting: duo_agent_platform_feature_setting),
            *foundational_flows_probes
          ]
        end

        private

        def foundational_flows_probes
          [
            ::CloudConnector::StatusChecks::Probes::FoundationalFlows::AllowFlowExecutionProbe.new,
            ::CloudConnector::StatusChecks::Probes::FoundationalFlows::AllowFoundationalFlowsProbe.new,
            ::CloudConnector::StatusChecks::Probes::FoundationalFlows::CompatibleRunnerProbe.new
          ]
        end

        def probes_for_vendored_features
          probes = default_probes

          return probes if code_completions_is_vendored? && duo_agent_platform_feature_setting&.vendored?

          # If code completions is not vendored, we need to remove the end to end probe
          unless code_completions_is_vendored?
            probes = probes.reject { |probe| probe.is_a?(::CloudConnector::StatusChecks::Probes::EndToEndProbe) }
          end

          # If duo agent platform is not vendored, we need to remove the duo agent platform probe
          unless duo_agent_platform_feature_setting&.vendored?
            probes = probes.reject do |probe|
              probe.is_a?(::CloudConnector::StatusChecks::Probes::DuoAgentPlatformProbe)
            end
          end

          probes
        end

        def self_hosted_only_probes
          probes = [
            ::CloudConnector::StatusChecks::Probes::SelfHosted::AiGatewayUrlPresenceProbe.new,
            ::CloudConnector::StatusChecks::Probes::HostProbe.new(::Gitlab::AiGateway.self_hosted_url),
            ::CloudConnector::StatusChecks::Probes::SelfHosted::CodeSuggestionsLicenseProbe.new(@user)

          ]

          # If duo agent platform is self-hosted, we add the duo agent platform probe
          if duo_agent_platform_feature_setting&.self_hosted?
            probes <<
              ::CloudConnector::StatusChecks::Probes::DuoAgentPlatformProbe.new(
                @user,
                feature_setting: duo_agent_platform_feature_setting
              )
          end

          probes
        end

        def at_least_one_vendored_feature?
          ::Ai::FeatureSetting.vendored.exists? ||
            ::Ai::ModelSelection::InstanceModelSelectionFeatureSetting.exists?
        end

        def code_completions_is_vendored?
          ::Ai::FeatureSettingSelectionService
                  .new(
                    @user,
                    :code_completions,
                    nil
                  ).execute.payload&.vendored?
        end

        def duo_agent_platform_feature_setting
          ::Ai::FeatureSettingSelectionService
                            .new(
                              @user,
                              ::Ai::ModelSelection::FeaturesConfigurable.workflow_feature_name,
                              nil
                            ).execute.payload
        end
        strong_memoize_attr :duo_agent_platform_feature_setting
      end
    end
  end
end
