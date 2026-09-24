# frozen_string_literal: true

module JH
  module Gitlab
    module QueryLimiting
      module Transaction
        extend ActiveSupport::Concern
        extend ::Gitlab::Utils::Override

        JH_QUERY_LIMITING_PLUS = ENV['JH_QUERY_LIMITING_PLUS'] || '6'

        class_methods do
          extend ::Gitlab::Utils::Override

          override :default_threshold
          def default_threshold
            super + JH_QUERY_LIMITING_PLUS.to_i
          end
        end

        override :threshold
        def threshold
          super + JH_QUERY_LIMITING_PLUS.to_i
        end
      end
    end
  end
end
