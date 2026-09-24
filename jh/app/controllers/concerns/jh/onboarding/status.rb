# frozen_string_literal: true

module JH
  module Onboarding
    module Status
      extend ActiveSupport::Concern
      extend ::Gitlab::Utils::Override

      class_methods do
        extend ::Gitlab::Utils::Override

        override :glm_tracking_params
        def glm_tracking_params(params)
          super.merge(utm_params(params))
        end

        private

        def utm_params(params)
          params.permit(:utm_source, :utm_medium, :utm_keyword)
        end
      end
    end
  end
end
