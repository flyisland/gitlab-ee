# frozen_string_literal: true

module Security
  module DependencyFirewall
    class EnforcementService
      private_class_method :new

      PACKAGE_DOWNLOAD = 1
      PACKAGE_UPLOAD   = 2
      CONTAINER_PULL   = 3
      CONTAINER_PUSH   = 4

      OPERATIONS = [
        PACKAGE_DOWNLOAD,
        PACKAGE_UPLOAD,
        CONTAINER_PULL,
        CONTAINER_PUSH
      ].freeze

      SUCCESS_ALLOWED = :allowed
      SUCCESS_BLOCKED = :blocked
      SUCCESS_WARNING = :warning

      ERROR_REASON_INVALID_PARAMETER = :invalid_parameter
      ERROR_REASON_NOT_LICENSED      = :not_licensed
      ERROR_REASON_FEATURE_DISABLED  = :feature_disabled

      def self.firewall_check(project:, pkg_type:, name:, version:, operation:)
        new(
          project: project,
          pkg_type: pkg_type,
          name: name,
          version: version,
          operation: operation
        ).execute
      end

      def initialize(project:, pkg_type:, name:, version:, operation:)
        @project    = project
        @pkg_type   = pkg_type
        @name       = name
        @version    = version
        @operation  = operation
      end

      def execute
        return error_result('Feature flag not enabled', ERROR_REASON_FEATURE_DISABLED) unless feature_enabled?
        return error_result('Not licensed', ERROR_REASON_NOT_LICENSED) unless licensed?
        # TODO: Project validation will be implemented in a future item: https://gitlab.com/gitlab-org/gitlab/-/work_items/591728
        return error_result('Project is not valid.', ERROR_REASON_INVALID_PARAMETER) if @project.nil?

        return error_result('Package type is missing', ERROR_REASON_INVALID_PARAMETER) if @pkg_type.blank?
        return error_result('Name is missing', ERROR_REASON_INVALID_PARAMETER) if @name.blank?
        return error_result('Version is missing', ERROR_REASON_INVALID_PARAMETER) if @version.blank?
        return error_result('Operation is not valid or empty', ERROR_REASON_INVALID_PARAMETER) unless valid_operation?

        license_result = fetch_licenses
        return license_result unless license_result.success?

        ServiceResponse.success(payload: { status: SUCCESS_ALLOWED })
      end

      private

      def error_result(message, reason)
        ServiceResponse.error(message: message, reason: reason)
      end

      def valid_operation?
        OPERATIONS.include?(@operation)
      end

      def licensed?
        return true if @project.nil?

        # licensed_feature_available? checks the license through the project's namespace hierarchy
        # https://gitlab.com/gitlab-org/gitlab/-/issues/588481 is a linked issue
        @project.licensed_feature_available?(:dependency_firewall)
      end

      def feature_enabled?
        Feature.enabled?(:dependency_firewall_phase1, @project)
      end

      def fetch_licenses
        FetchPackageLicensesService.new(
          name: @name,
          purl_type: @pkg_type,
          version: @version
        ).execute
      end
    end
  end
end
