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

      def self.firewall_check(project:, pkg_type:, name:, version:, operation:, current_user:)
        new(
          project: project,
          pkg_type: pkg_type,
          name: name,
          version: version,
          operation: operation,
          current_user: current_user
        ).execute
      end

      def initialize(project:, pkg_type:, name:, version:, operation:, current_user:)
        @project      = project
        @pkg_type     = pkg_type
        @name         = name
        @version      = version
        @operation    = operation
        @current_user = current_user
      end

      def execute
        return ServiceResponse.success(payload: { status: SUCCESS_ALLOWED }) unless feature_enabled? && licensed?

        # TODO: Project validation will be implemented in a future item: https://gitlab.com/gitlab-org/gitlab/-/work_items/591728
        raise ArgumentError, "DependencyFirewall: project is nil" if @project.nil?

        raise ArgumentError, "DependencyFirewall: pkg_type is blank" if @pkg_type.blank?
        raise ArgumentError, "DependencyFirewall: name is blank" if @name.blank?

        unless OPERATIONS.include?(@operation)
          raise ArgumentError, "DependencyFirewall: operation #{@operation.inspect} is not valid"
        end

        enforce_policy(fetch_licenses.filter_map { |license| license[:name] })
      end

      private

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

      def enforce_policy(license_names)
        if license_names.empty?
          audit(:allowed, {})
          return response(SUCCESS_ALLOWED)
        end

        results = Array(
          ::Security::DependencyFirewall::LicenseRuleEvaluator
            .new(@project, @current_user)
            .evaluate(@name, purl_type: @pkg_type, version: @version, licenses: license_names)
        )

        denied = results.find { |r| r[:action] == ::Security::DependencyFirewallPolicies::Rule::ACTION_DENIED }
        if denied
          audit(:blocked, denied)
          return error_response(build_violation_message(denied), SUCCESS_BLOCKED)
        end

        warned = results.find { |r| r[:action] == ::Security::DependencyFirewallPolicies::Rule::ACTION_WARNED }
        if warned
          audit(:warned, warned)
          return response(SUCCESS_WARNING, result: warned)
        end

        audit(:allowed, {})
        response(SUCCESS_ALLOWED)
      end

      def response(status, result: nil)
        return ServiceResponse.success(payload: { status: status }) if result.nil?

        ServiceResponse.success(payload: { status: status, message: build_violation_message(result) })
      end

      def error_response(message, reason)
        ServiceResponse.error(message: message, reason: reason)
      end

      def build_violation_message(result)
        "Package '#{@name}' violates '#{result[:policy_name]}' policy"
      end

      def purl
        "pkg:#{@pkg_type}/#{@name}@#{@version}"
      end

      def audit(event_type, result)
        purl = "pkg:#{@pkg_type}/#{@name}@#{@version}"

        CreateAuditEventsService.new(
          project: @project, purl: purl, operation: @operation,
          result: result, author: @current_user, event_type: event_type
        ).execute
      end
    end
  end
end
