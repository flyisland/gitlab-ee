# frozen_string_literal: true

module Gitlab
  module Usage
    module Metrics
      module Instrumentations
        class DuoAgentPlatformEnabledMetric < GenericMetric
          value do
            ::Ai::Setting.instance.duo_agent_platform_enabled
          end
        end
      end
    end
  end
end
