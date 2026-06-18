# frozen_string_literal: true

module SecretsManagement
  module GroupSecretsManagers
    class InitiateDeprovisionService
      include InitiateDeprovisionServiceHelpers

      # The secrets manager record is used for two things only:
      #   1. checking its status (active? deprovisioning?)
      #   2. holding the SM reference used in `success_payload`
      #
      # Every other identifying value (group_id, organization_id,
      # root_namespace_id) is a required kwarg. The caller must capture
      # those at the moment that matters (before any state change) and
      # pass them in explicitly. The service does not read those off
      # the live secrets manager or its parent records, which may have
      # moved or disappeared by the time we run.
      def initialize(secrets_manager, user = nil, group_id:, organization_id:, root_namespace_id:)
        @secrets_manager = secrets_manager
        @current_user = user
        @group_id = group_id
        @organization_id = organization_id
        @root_namespace_id = root_namespace_id
      end

      private

      def not_found_message
        'Secrets manager not found for the group.'
      end

      def create_maintenance_task
        SecretsManagement::GroupSecretsManagerMaintenanceTask.create!(
          group_id: @group_id,
          user: current_user,
          last_processed_at: Time.zone.now,
          action: :deprovision,
          organization_id: @organization_id,
          root_namespace_id: @root_namespace_id
        )
      end

      def enqueue_deprovision_worker(task)
        SecretsManagement::DeprovisionGroupSecretsManagerWorker.perform_async(task.id)
      end

      def success_payload
        { group_secrets_manager: secrets_manager }
      end

      class << self
        # Bulk-initiates deprovision for every active group SM under
        # `groups_relation`. See the project counterpart for context on
        # why this exists and why bulk SQL is safe here.
        #
        # `old_root_namespace_id` and `old_organization_id` are captured
        # by the caller BEFORE the transfer ran (group.root_ancestor.id /
        # group.organization_id), since super flips them to the NEW
        # parent. The OpenBao tear-down needs the OLD ids.
        def bulk_initiate_for_groups(groups_relation, user, old_root_namespace_id:, old_organization_id:)
          return unless user

          # rubocop:disable CodeReuse/ActiveRecord -- bulk SM transition needs scoped batch queries
          # rubocop:disable Database/AvoidUsingPluckWithoutLimit -- groups_relation comes from an each_batch slice, so the IN list is bounded by the caller's batch size
          active_sm_ids = ::SecretsManagement::GroupSecretsManager
            .where(status: ::SecretsManagement::BaseSecretsManager::STATUSES[:active])
            .where(group_id: groups_relation)
            .pluck(:id, :group_id)
          # rubocop:enable Database/AvoidUsingPluckWithoutLimit
          # rubocop:enable CodeReuse/ActiveRecord

          return if active_sm_ids.empty?

          now = Time.zone.now
          task_attrs = active_sm_ids.map do |_sm_id, group_id|
            {
              group_id: group_id,
              organization_id: old_organization_id,
              root_namespace_id: old_root_namespace_id,
              user_id: user.id,
              action: ::SecretsManagement::BaseSecretsManagerMaintenanceTask.actions[:deprovision],
              retry_count: 0,
              last_processed_at: now
            }
          end

          sm_ids = active_sm_ids.map(&:first)

          # `unique_by: :group_id` makes the conflict-skip explicit for
          # the race where a concurrent descendant deprovision inserts a
          # conflicting task between our fetch and this insert.
          # `insert_all` without `!` already skips, so this also guards
          # against a future switch to `insert_all!`.
          task_ids = ::ApplicationRecord.transaction do
            # rubocop:disable CodeReuse/ActiveRecord -- bulk update + bulk insert for scale
            ::SecretsManagement::GroupSecretsManager
              .where(id: sm_ids)
              .where(status: ::SecretsManagement::BaseSecretsManager::STATUSES[:active])
              .update_all(
                status: ::SecretsManagement::BaseSecretsManager::STATUSES[:deprovisioning],
                updated_at: now
              )

            ::SecretsManagement::GroupSecretsManagerMaintenanceTask
              .insert_all(task_attrs, returning: %w[id], unique_by: :group_id)
              .rows.flatten
            # rubocop:enable CodeReuse/ActiveRecord
          end

          # Sidekiq context is inherited from the enclosing transfer
          # request, which already carries the user and group metadata
          # we would otherwise attach per job.
          # rubocop:disable Scalability/BulkPerformWithContext -- parent transfer context applies
          ::SecretsManagement::DeprovisionGroupSecretsManagerWorker
            .bulk_perform_async(task_ids.map { |id| [id] })
          # rubocop:enable Scalability/BulkPerformWithContext
        end
      end
    end
  end
end
