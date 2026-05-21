# frozen_string_literal: true

module Search
  module Elastic
    class DeleteWorker
      include ApplicationWorker
      include Search::Worker
      prepend ::Geo::SkipSecondary

      sidekiq_options retry: 3
      data_consistency :delayed
      urgency :throttled
      idempotent!
      pause_control :advanced_search

      # Add tasks here for project-scoped delete operations that should run when :all is passed.
      # Each entry is a config hash with:
      #   service:         (required) the service class to execute
      #   migration_guard: (optional) a migration name that must have finished before this task is scheduled
      PROJECT_TASKS = {
        delete_project_vulnerabilities: {
          service: ::Search::Elastic::Delete::VulnerabilityService
        },
        delete_project_vulnerability_reads: {
          service: ::Search::Elastic::Delete::VulnerabilityReadsService,
          migration_guard: :create_vulnerability_reads_index
        },
        delete_project_work_items: {
          service: ::Search::Elastic::Delete::ProjectWorkItemsService
        }
      }.freeze

      # Add tasks here for global/index-level delete operations that should only run individually
      TASKS = PROJECT_TASKS.merge(
        delete_all_blobs: { service: ::Search::Elastic::Delete::AllBlobsService }
      ).freeze

      def perform(options = {})
        return false unless Gitlab::CurrentSettings.elasticsearch_indexing?

        options = options.with_indifferent_access
        task = options[:task]
        raise ArgumentError, 'Task must be provided' if task.nil?

        return run_all_project_tasks(options) if task.to_sym == :all

        raise ArgumentError, "Unknown task: #{task.inspect}" unless TASKS.key?(task.to_sym)

        TASKS[task.to_sym][:service].execute(options)
      end

      private

      def run_all_project_tasks(options)
        PROJECT_TASKS.each do |task, config|
          guard_migration = config[:migration_guard]
          next if guard_migration && !::Elastic::DataMigrationService.migration_has_finished?(guard_migration)

          with_context(related_class: self.class) do
            self.class.perform_async(options.to_h.merge('task' => task.to_s))
          end
        end
      end
    end
  end
end
