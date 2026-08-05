# frozen_string_literal: true

module EE
  module Organizations
    module OrganizationPolicy
      extend ActiveSupport::Concern
      extend ::Gitlab::Utils::Override

      prepended do
        include RemoteDevelopment::OrganizationPolicy
        include ::Analytics::CustomDashboards::OrganizationPolicy
        include ::Ai::Catalog::McpServers::OrganizationPolicy

        condition(:dependency_scanning_enabled) do
          License.feature_available?(:dependency_scanning)
        end

        condition(:license_scanning_enabled) do
          License.feature_available?(:license_scanning)
        end

        condition(:product_analytics_enabled) do
          License.feature_available?(:product_analytics)
        end

        condition(:configurable_work_item_types_enabled) do
          License.feature_available?(:configurable_work_item_types)
        end

        rule { (admin | organization_user) & dependency_scanning_enabled }.enable :read_dependency
        rule { (admin | organization_user) & license_scanning_enabled }.enable :read_licenses

        rule { admin | organization_owner }.policy do
          enable :read_work_item_setting
          enable :create_work_item_type
          enable :update_work_item_type
          enable :update_work_item_setting
        end

        rule { ~configurable_work_item_types_enabled }.policy do
          prevent :create_work_item_type
          prevent :update_work_item_type
          prevent :read_work_item_setting
          prevent :update_work_item_setting
        end

        rule { admin | organization_owner }.policy do
          enable :read_cd_application
          enable :create_cd_application
          enable :update_cd_application
          enable :read_cd_environment
          enable :create_cd_environment
          enable :update_cd_environment
          enable :create_cd_service
          enable :update_cd_service
          enable :create_cd_artifact_source
          enable :create_cd_version_set
          enable :create_cd_application_flow_definition
          enable :create_cd_rollout
          enable :resolve_cd_rollout_gate
          enable :create_cd_application_link
          enable :read_cd_service
          enable :read_cd_artifact_source
          enable :read_cd_version_set
          enable :read_cd_application_flow_definition
          enable :read_cd_rollout
          enable :read_cd_application_link
        end
      end
    end
  end
end
