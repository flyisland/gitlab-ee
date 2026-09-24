# frozen_string_literal: true

module JH
  module API
    module API
      extend ActiveSupport::Concern

      prepended do
        mount ::API::ContentBlockedStates
        mount ::API::PerformanceAnalytics::Metrics

        before do
          validate_free_license_ha!
        end
      end
    end
  end
end
