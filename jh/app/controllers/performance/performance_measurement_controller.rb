# frozen_string_literal: true

module Performance
  class PerformanceMeasurementController < ApplicationController
    feature_category :groups_and_projects

    before_action :check_feature_flag!, only: [:index]

    layout 'performance_measurement'
    def index; end

    private

    def check_feature_flag!
      access_denied! unless !!current_user && Feature.enabled?(:jh_new_performance_measurement, current_user)
    end
  end
end
