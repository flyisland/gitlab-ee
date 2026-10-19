# frozen_string_literal: true

module JH
  module ProjectsHelper
    extend ::Gitlab::Utils::Override

    override :project_permissions_panel_data
    def project_permissions_panel_data(project)
      panel_data = super

      # result of `pagesAccessControlEnabled && pagesAvailable` control visibility of Pages permission section
      # for jihulab.com, hide it because force set pagesAccessControlEnabled false if access_control_is_forced? is true
      # for hk saas, do not force set pagesAccessControlEnabled false, so show if pages_available? is true
      if ::Gitlab.com? && ::Feature.enabled?(:jh_hide_pages_access_level) && ::Gitlab::Pages.access_control_is_forced?
        panel_data[:pagesAccessControlEnabled] = false
      end

      panel_data[:pagesAvailable] = project.pages_available?

      panel_data
    end
  end
end
