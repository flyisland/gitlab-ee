# frozen_string_literal: true

module JH
  module CloudConnector
    module StatusChecks
      module Probes
        module Registry
          extend ::Gitlab::Utils::Override

          private

          override :duo_agent_platform_probes
          def duo_agent_platform_probes
            probes = super
            return probes unless ::Feature.enabled?(:jh_enable_upload_cloud_license)

            probes.reject { |probe| cloud_connected_duo_agent_platform_probe?(probe) }
          end

          def cloud_connected_duo_agent_platform_probe?(probe)
            probe.is_a?(::CloudConnector::StatusChecks::Probes::DuoAgentPlatformProbe) &&
              probe.instance_variable_get(:@deployment) == :cloud_connected
          end
        end
      end
    end
  end
end
