# frozen_string_literal: true

module Security
  class DashboardController < ::Security::ApplicationController
    include GovernUsageGroupTracking

    layout 'instance_security'
    track_internal_event :show, name: 'visit_security_center', category: name

    before_action only: :show do
      push_frontend_feature_flag(:security_inventory_no_longer_detected_vulnerabilities, :instance)
    end

    private

    def tracking_namespace_source
      nil
    end

    def tracking_project_source
      nil
    end
  end
end

Security::DashboardController.prepend_mod
