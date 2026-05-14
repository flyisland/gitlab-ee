# frozen_string_literal: true

module EE
  module API
    module Helpers
      module WorkItemsFilterParams
        extend ActiveSupport::Concern

        def transform
          transformed = super

          rewrite_param_name(transformed, :iteration_wildcard_id, :iteration_id)
          rewrite_param_name(transformed[:not], :iteration_wildcard_id, :iteration_id)

          rewrite_param_name(transformed, :health_status_filter, :health_status)
          rewrite_param_name(transformed[:not], :health_status_filter, :health_status)
          rewrite_param_name(transformed, :weight_wildcard_id, :weight)

          transformed
        end
      end
    end
  end
end
