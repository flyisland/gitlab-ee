# frozen_string_literal: true

module Gitlab
  module Usage
    module Metrics
      module Instrumentations
        class FoundationalAgentsDefaultEnabledMetric < GenericMetric
          value do
            ::Ai::Setting.instance.foundational_agents_default_enabled
          end
        end
      end
    end
  end
end
