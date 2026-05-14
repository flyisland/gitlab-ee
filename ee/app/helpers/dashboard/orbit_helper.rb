# frozen_string_literal: true

module Dashboard
  module OrbitHelper
    def orbit_app_data
      {
        router_base: dashboard_orbit_path
      }
    end

    def orbit_page_label
      case params[:vueroute]
      when 'schema' then _('Schema')
      when 'configuration' then _('Configuration')
      else _('Data Explorer')
      end
    end
  end
end
