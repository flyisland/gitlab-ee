# frozen_string_literal: true

module Types
  module Analytics
    module CustomDashboards
      class SystemDashboardType < BaseObject
        graphql_name 'CustomSystemDashboard'

        authorize :read_system_dashboard

        implements Types::Analytics::CustomDashboards::DashboardInterface

        description 'GitLab built-in analytics dashboard (read-only)'

        def config
          object.config_data
        end

        def system
          true
        end
      end
    end
  end
end
