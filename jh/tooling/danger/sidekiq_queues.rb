# frozen_string_literal: true

require "active_support/core_ext/enumerable"

module Tooling
  module Danger
    module SidekiqQueues
      def changed_queue_files
        @changed_queue_files ||= git.modified_files.grep(%r{\A(ee/)?app/workers/all_queues\.yml})
      end

      def added_queue_names
        @added_queue_names ||= new_queues.keys - old_queues.keys
      end

      def changed_queue_names
        @changed_queue_names ||=
          (new_queues.values_at(*old_queues.keys) - old_queues.values)
            .compact.map { |queue| queue[:name] }
      end

      private

      def old_queues
        @old_queues ||= queues_for(gitlab.base_commit)
      end

      def new_queues
        @new_queues ||= queues_for(gitlab.head_commit)
      end

      def queues_for(branch)
        changed_queue_files
          .flat_map { |file| YAML.safe_load(`git show #{branch}:#{file}`, permitted_classes: [Symbol]) }
          .index_by { |queue| queue[:name] }
      end
    end
  end
end
