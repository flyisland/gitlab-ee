# frozen_string_literal: true

module DependencyManagement
  module SecurityUpdate
    class SchedulerService < BaseService
      # This limits the amount of auto remediation merge requests that can
      # be open at any given time per project.
      MAX_OPEN_MERGE_REQUEST_LIMIT = 3

      private_constant :MAX_OPEN_MERGE_REQUEST_LIMIT

      # Auto Remediation is only supported for a limited set of package managers.
      SUPPORTED_PACKAGE_MANAGERS = %w[bundler].freeze

      private_constant :SUPPORTED_PACKAGE_MANAGERS

      # These MUST stay sorted, so that we don't have to sort using Postgres.
      # Doing so is expensive, and we cannot add another index on the sbom_occurrences
      # table.
      SORTED_SEVERITY_LEVELS = %i[critical high medium low].freeze

      private_constant :SORTED_SEVERITY_LEVELS

      # This regex is used to filter out vulnerabilities that have a non-empty
      # solution string that simply states that there's **not** a vulnerability.
      # Unfortunately, we made a decision some time ago to include a templated
      # solution for vulnerabilities that do not have a solution which, means
      # that we cannot simply filter out vulnerabilities with empty solution when
      # we're querying the database. Instead, we have to filter things out on the
      # client side with this regex.
      UNKNOWN_SOLUTION_REGEX = /^Unfortunately,?\s*there is no solution available/i

      private_constant :UNKNOWN_SOLUTION_REGEX

      def self.execute(...)
        new(...).execute
      end

      def initialize(project:)
        super

        @remediation_count = 0
      end

      def execute
        return unless project

        SUPPORTED_PACKAGE_MANAGERS.each do |package_manager|
          break if merge_request_limit_reached?

          execute_for_package_manager(package_manager)
        end
      end

      private

      attr_accessor :remediation_count

      def execute_for_package_manager(package_manager)
        SORTED_SEVERITY_LEVELS.each do |severity_level|
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

            schedule_remediations(occurrence)
          end
        end
      end

      def merge_request_limit_reached?
        # WARNING: We should be careful here. If this limit is ever configured,
        # we can end up in a situation where we have more merge requests
        # open than the limit. If that happens and we do a strict check
        # then we'll continue to open merge requests. This limit will
        # be configurable by the customer, so we need to take this into account.
        #
        # NOTE: This only counts remediations scheduled in the current run.
        # It does not account for already-open remediation MRs from previous runs.
        #
        # TODO: Add currently_open_remediation_count once MR tracking is implemented.
        # See https://gitlab.com/gitlab-org/gitlab/-/work_items/594095
        remediation_count >= MAX_OPEN_MERGE_REQUEST_LIMIT
      end

      # Schedules one update workload per remediable vulnerability on the occurrence.
      # Each vulnerability gets its own pipeline and MR so it can be individually
      # linked, tracked, and resolved.
      def schedule_remediations(occurrence)
        occurrence.vulnerabilities.each do |vulnerability|
          break if merge_request_limit_reached?

          next unless remediable?(vulnerability)

          request = Request.new(sbom_occurrence: occurrence, vulnerability: vulnerability)
          response = UpdateService.new(project: project).execute(request)
          self.remediation_count += 1 if response.success?
        end
      end

      def remediable?(vulnerability)
        solution = vulnerability.solution
        solution.present? && !UNKNOWN_SOLUTION_REGEX.match?(solution)
      end
    end
  end
end
