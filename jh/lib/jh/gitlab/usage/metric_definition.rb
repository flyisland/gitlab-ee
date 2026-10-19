# frozen_string_literal: true

module JH
  module Gitlab
    module Usage
      module MetricDefinition
        extend ActiveSupport::Concern

        class_methods do
          extend ::Gitlab::Utils::Override

          override :paths
          def paths
            @jh_paths ||= [Rails.root.join('jh/config/metrics/[^agg]*/*.yml')] + super
          end
        end
      end
    end
  end
end
