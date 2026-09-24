# frozen_string_literal: true

module JH
  module RegistrationsTracking
    extend ActiveSupport::Concern
    extend ::Gitlab::Utils::Override

    private

    override :glm_tracking_params
    def glm_tracking_params
      super.merge(utm_params)
    end

    def utm_params
      params.permit(:utm_source, :utm_medium, :utm_keyword)
    end
  end
end
