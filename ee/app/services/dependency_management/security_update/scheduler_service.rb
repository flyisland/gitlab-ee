# frozen_string_literal: true

module DependencyManagement
  module SecurityUpdate
    class SchedulerService < BaseService
      include Gitlab::Utils::StrongMemoize
      include Gitlab::InternalEventsTracking

      # Auto Remediation is only supported for a limited set of package managers.
      SUPPORTED_PACKAGE_MANAGERS = Eligibility::SUPPORTED_PACKAGE_MANAGERS

      # These MUST stay sorted, so that we don't have to sort using Postgres.
      # Doing so is expensive, and we cannot add another index on the sbom_occurrences
      # table.
      SORTED_SEVERITY_LEVELS = %i[critical high medium low].freeze

      private_constant :SUPPORTED_PACKAGE_MANAGERS,
        :SORTED_SEVERITY_LEVELS

      def self.execute(...)
        new(...).execute
      end

      def initialize(project:, skip_dismissed_branches: false)
        super(project: project)

        @skip_dismissed_branches = skip_dismissed_branches
        @remediation_count = initial_open_remediation_count
      end

      def execute
        return unless project && remediation_profile

        SUPPORTED_PACKAGE_MANAGERS.each do |package_manager|
          break if merge_request_limit_reached?

          execute_for_package_manager(package_manager)
        end
      end

      private

      attr_accessor :remediation_count
      attr_reader :skip_dismissed_branches

      def initial_open_remediation_count
        open_remediation_branches.size
      end
      strong_memoize_attr :initial_open_remediation_count

      def open_remediation_branches
        return [] unless project

        DependencyManagement::SecurityUpdate::OpenRemediationsFinder
          .new(project: project)
          .source_branches
      end
      strong_memoize_attr :open_remediation_branches

      def user_closed_remediations_finder
        DependencyManagement::SecurityUpdate::UserClosedRemediationsFinder.new(project: project)
      end
      strong_memoize_attr :user_closed_remediations_finder

      def execute_for_package_manager(package_manager)
        severity_levels.each do |severity_level|
          break if merge_request_limit_reached?

          execute_for_package_manager_and_severity_level(package_manager, severity_level)
        end
      end

      def execute_for_package_manager_and_severity_level(package_manager, severity_level)
        finder = DependencyManagement::SecurityUpdate::VulnerableSbomOccurrencesFinder.new(
          project: project,
          package_manager: package_manager,
          severity_level: severity_level
        )

        finder.execute_in_batches do |occurrences|
          occurrences.each do |occurrence|
            break if merge_request_limit_reached?

            schedule_remediation(occurrence)
          end
        end
      end

      def merge_request_limit_reached?
        # WARNING: We should be careful here. If this limit is ever configured,
        # we can end up in a situation where we have more merge requests
        # open than the limit. If that happens and we do a strict check
        # then we'll continue to open merge requests. This limit will
        # be configurable by the customer, so we need to take this into account.
        remediation_count >= max_open_merge_request_limit
      end

      def remediation_profile
        Eligibility.remediation_profile(project)
      end
      strong_memoize_attr :remediation_profile

      def auto_remediation_configuration
        remediation_profile.effective_configuration(project:).fetch(:auto_remediation, {})
      end
      strong_memoize_attr :auto_remediation_configuration

      def max_open_merge_request_limit
        auto_remediation_configuration[:open_merge_requests_limit]
      end
      strong_memoize_attr :max_open_merge_request_limit

      def severity_levels
        threshold_index = SORTED_SEVERITY_LEVELS.index(severity_threshold)

        return SORTED_SEVERITY_LEVELS unless threshold_index

        SORTED_SEVERITY_LEVELS.first(threshold_index + 1)
      end
      strong_memoize_attr :severity_levels

      def severity_threshold
        auto_remediation_configuration[:severity_level].to_sym
      end

      # Schedules one update workload if there's at least one remediable vulnerability on
      # the occurrence. Each occurrence gets its own pipeline and MR so a vulnerability is
      # individually linked, tracked, and resolved.
      def schedule_remediation(sbom_occurrence)
        vulnerability = sbom_occurrence.vulnerabilities
          .sort_by { |v| [-Vulnerability.severities[v.severity], v.id] }
          .find { |v| Eligibility.remediable?(v) }

        return unless vulnerability

        request = Request.new(sbom_occurrence:, vulnerability:)

        # Skip while an MR is open on this branch to avoid resetting it and
        # running a workload on every pipeline. This also defers a newer bump
        # (e.g. 5.6.0 -> 5.6.2) until that MR is merged/closed and the
        # vulnerability still needs remediation.
        return if open_remediation_branches.include?(request.source_ref)

        # On a reschedule run (after a dismissed update freed a slot), don't re-pick a
        # branch a maintainer already closed - hand the slot to the next fresh candidate.
        # Initial runs still re-evaluate it so a newer version can resurface.
        return if skip_dismissed_branches && user_closed_remediations_finder.dismissed_branch?(request.source_ref)

        response = UpdateService.new(project:).execute(request)

        return unless response.success?

        self.remediation_count += 1

        track_internal_event(
          'trigger_dependency_management_auto_remediation_request',
          project: project,
          additional_properties: {
            purl_type: sbom_occurrence.component.purl_type
          }
        )
      end
    end
  end
end
