# frozen_string_literal: true

module SecretsManagement
  module ProjectSecretsManagers
    class InitiateDeprovisionService
      include InitiateDeprovisionServiceHelpers

      # The secrets manager record is used for two things only:
      #   1. checking its status (active? deprovisioning?)
      #   2. anchoring the foreign-key association on the maintenance task
      #
      # Every other identifying value (project_id, organization_id,
      # root_namespace_id) is a required kwarg. The caller must capture
      # those at the moment that matters (before any state change) and
      # pass them in explicitly. The service does not read those off the
      # live secrets manager or its parent records, which may have moved
      # or disappeared by the time we run.
      def initialize(
        secrets_manager,
        user = nil,
        project_id:,
        organization_id:,
        root_namespace_id:
      )
        @secrets_manager = secrets_manager
        @current_user = user
        @project_id = project_id
        @organization_id = organization_id
        @root_namespace_id = root_namespace_id
      end

      private

      def not_found_message
        'Secrets manager not found for the project.'
      end

      def create_maintenance_task
        SecretsManagement::ProjectSecretsManagerMaintenanceTask.create!(
          user: current_user,
          last_processed_at: Time.zone.now,
          action: :deprovision,
          project_id: @project_id,
          organization_id: @organization_id,
          root_namespace_id: @root_namespace_id
        )
      end

      def enqueue_deprovision_worker(task)
        SecretsManagement::DeprovisionProjectSecretsManagerWorker.perform_async(task.id)
      end

      def success_payload
        { project_secrets_manager: secrets_manager }
      end

      class << self
        # Bulk-initiates deprovision for every active project SM under
        # `projects_relation`. Skips inactive SMs. Designed for the group
        # transfer flow where a large subtree of SMs may need
        # deprovisioning at once; per-record InitiateDeprovisionService
        # calls would generate N x 5 SQL ops + N Sidekiq enqueues, which
        # does not scale.
        #
        # Bulk SQL bypasses the state_machine callback path. That is safe
        # because BaseSecretsManager has no after_transition hooks; the
        # status change is the only state effect.
        #
        # `old_root_namespace_id` and `old_organization_id` are captured by
        # the caller BEFORE the transfer ran (group.root_ancestor.id /
        # group.organization_id), since once super has committed those
        # values would reflect the NEW parent. OpenBao state lives at the
        # OLD path, so the deprovision worker needs the OLD ids.
        def bulk_initiate_for_projects(projects_relation, user, old_root_namespace_id:, old_organization_id:)
          return unless user

          # rubocop:disable CodeReuse/ActiveRecord -- bulk SM transition needs scoped batch queries
          active_sms = ::SecretsManagement::ProjectSecretsManager
            .where(status: ::SecretsManagement::BaseSecretsManager::STATUSES[:active])
            .where(project_id: projects_relation)
            .preload(:project)
            .to_a
          # rubocop:enable CodeReuse/ActiveRecord

          return if active_sms.empty?

          now = Time.zone.now
          task_attrs = active_sms.map do |sm|
            {
              project_id: sm.project_id,
              organization_id: old_organization_id,
              root_namespace_id: old_root_namespace_id,
              user_id: user.id,
              action: ::SecretsManagement::BaseSecretsManagerMaintenanceTask.actions[:deprovision],
              retry_count: 0,
              last_processed_at: now
            }
          end

          sm_ids = active_sms.map(&:id)

          # Bulk UPDATE + INSERT must commit together. Enqueue is outside
          # the transaction so a rollback never leaves a Sidekiq job
          # pointing at a non-existent task row. `unique_by: :project_id`
          # makes the conflict-skip explicit for the race where a
          # concurrent descendant deprovision inserts a conflicting task
          # between our fetch and this insert. `insert_all` without `!`
          # already skips, so this also guards against a future switch
          # to `insert_all!`.
          task_ids = ::ApplicationRecord.transaction do
            # rubocop:disable CodeReuse/ActiveRecord -- bulk update + bulk insert for scale
            ::SecretsManagement::ProjectSecretsManager
              .where(id: sm_ids)
              .where(status: ::SecretsManagement::BaseSecretsManager::STATUSES[:active])
              .update_all(
                status: ::SecretsManagement::BaseSecretsManager::STATUSES[:deprovisioning],
                updated_at: now
              )

            ::SecretsManagement::ProjectSecretsManagerMaintenanceTask
              .insert_all(task_attrs, returning: %w[id], unique_by: :project_id)
              .rows.flatten
            # rubocop:enable CodeReuse/ActiveRecord
          end

          # Sidekiq context is inherited from the enclosing transfer
          # request, which already carries the user and group metadata
          # we would otherwise attach per job.
          # rubocop:disable Scalability/BulkPerformWithContext -- parent transfer context applies
          ::SecretsManagement::DeprovisionProjectSecretsManagerWorker
            .bulk_perform_async(task_ids.map { |id| [id] })
          # rubocop:enable Scalability/BulkPerformWithContext
        end
      end
    end
  end
end
