# frozen_string_literal: true

module Security
  module DependencyFirewall
    class CreateAuditEventsService
      DEFINED_EVENT_TYPES = %i[allowed blocked warned].freeze

      def initialize(project:, purl:, operation:, result:, author:, event_type:)
        @project    = project
        @purl       = purl
        @operation  = operation
        @result     = result
        @author     = author
        @event_type = event_type
      end

      def execute
        return unless @project

        validate_event_type!
        ::Gitlab::Audit::Auditor.audit(audit_context)
      rescue StandardError => e
        ::Gitlab::ErrorTracking.track_exception(e, project_id: @project.id, purl: @purl)
      end

      private

      def validate_event_type!
        raise ArgumentError, "Unknown DependencyFirewall event_type: #{@event_type.inspect}" \
          unless @event_type.in?(DEFINED_EVENT_TYPES)
      end

      def audit_context
        {
          name: event_name,
          author: @author || ::Gitlab::Audit::UnauthenticatedAuthor.new,
          scope: @project,
          target: @project,
          message: build_audit_message,
          additional_details: {
            purl: @purl,
            operation: operation_label,
            matched_rule: @result[:matched_rule],
            policy_name: @result[:policy_name],
            policies_evaluated: @result[:policies_evaluated]
          }
        }
      end

      def event_name
        case @event_type
        when :allowed then 'dependency_firewall_allowed'
        when :blocked then 'dependency_firewall_blocked'
        when :warned  then 'dependency_firewall_warned'
        end
      end

      def build_audit_message
        policy_name = @result[:policy_name] || 'dependency firewall policy'

        case @event_type
        when :allowed
          "Allowed #{operation_label} for dependency #{@purl}#{policies_suffix}"
        when :blocked
          "Blocked #{operation_label} for dependency #{@purl} due to #{policy_name} violation" \
            "#{license_suffix('blocked licenses')}"
        when :warned
          "Advisory policy matched for #{operation_label} of dependency #{@purl} (#{policy_name})" \
            "#{license_suffix('advisory licenses')}"
        end
      end

      def license_suffix(label)
        rule = @result[:matched_rule]
        return '' unless rule && rule[:type] == 'license'

        denied_names = rule[:denied]&.filter_map { |d| d[:name] } || []
        " (#{label}: #{denied_names.join(', ')})"
      end

      def policies_suffix
        policies_count = @result[:policies_evaluated]
        return '' unless policies_count

        " (#{policies_count} #{'policy'.pluralize(policies_count)} evaluated)"
      end

      def operation_label
        case @operation
        when EnforcementService::PACKAGE_DOWNLOAD then 'package download'
        when EnforcementService::PACKAGE_UPLOAD   then 'package upload'
        when EnforcementService::CONTAINER_PULL   then 'container pull'
        when EnforcementService::CONTAINER_PUSH   then 'container push'
        else 'operation'
        end
      end
    end
  end
end
