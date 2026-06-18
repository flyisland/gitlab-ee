# frozen_string_literal: true

module EE
  module Groups
    module DestroyService
      extend ::Gitlab::Utils::Override

      override :execute
      def execute
        with_scheduling_epic_cache_update do
          result = super
          next result if result.error?

          after_destroy(result[:group])
          result
        end
      end

      override :unsafe_execute
      def unsafe_execute
        # The work happens in two phases:
        #
        # BEFORE super: take a snapshot of this group's secrets manager
        # (just plain data, we don't change anything yet) so we can
        # kick off deprovision later. We only worry about THIS group's
        # secrets manager here. Child groups and child projects each
        # get destroyed by their own destroy service, which fires the
        # same kind of EE hook, so they take care of their own cleanup.
        #
        # We do NOT block destroy based on the secrets manager state.
        # If the SM is mid-provisioning when destroy fires, we just let
        # the destroy proceed and leave the SM in whatever state it
        # ends up in. The orphan reaper (gitlab-org/gitlab#600120)
        # finds it later via `where(group_id: nil)` and finishes the
        # cleanup. Blocking the destroy would be a worse user
        # experience, especially for large hierarchies.
        #
        # AFTER super: if the destroy actually succeeded, kick off the
        # async deprovision. We wait until after for two reasons:
        #
        #   - If we kicked it off first, the worker could start tearing
        #     down OpenBao paths within milliseconds, while the group is
        #     still in the database; anything using those paths would
        #     suddenly fail.
        #
        #   - If super raises partway, we want to leave everything alone
        #     so the user can simply try again.
        snapshot = capture_secrets_manager_snapshot

        super.tap do
          initiate_deprovision_for_snapshot(snapshot)
        end
      end

      private

      def capture_secrets_manager_snapshot
        sm = group.secrets_manager
        return unless sm

        {
          secrets_manager: sm,
          group_id: group.id,
          organization_id: group.organization_id,
          root_namespace_id: group.root_ancestor.id
        }
      end

      def initiate_deprovision_for_snapshot(snapshot)
        return unless snapshot

        sm = snapshot[:secrets_manager]
        # If the secrets manager is already deprovisioning, a previous
        # attempt left a maintenance task behind that never finished
        # (the worker died, an earlier destroy was aborted, etc.). We
        # don't want to create a second task. We just re-enqueue the
        # existing one and let it run.
        return re_enqueue_latest_deprovision_task(snapshot) if sm.deprovisioning?
        return unless sm.active?

        # We don't rescue or log here on purpose. The group has already
        # been destroyed at this point, so the only kind of error that
        # could pop up is infrastructural (DB hiccup, Redis outage, OOM).
        # Those are exactly the errors we want Sentry to flag; a
        # swallowed log line would be invisible to us.
        #
        # If a call does fail before the maintenance task gets created,
        # the secrets manager row stays behind with `group_id = NULL`.
        # That's our orphan signal: the reaper (gitlab-org/gitlab#600120)
        # picks it up via `GroupSecretsManager.where(group_id: nil)`.
        ::SecretsManagement::GroupSecretsManagers::InitiateDeprovisionService.new(
          sm,
          current_user,
          group_id: snapshot[:group_id],
          organization_id: snapshot[:organization_id],
          root_namespace_id: snapshot[:root_namespace_id]
        ).execute
      end

      def re_enqueue_latest_deprovision_task(snapshot)
        task = ::SecretsManagement::GroupSecretsManagerMaintenanceTask
          .for_group(snapshot[:group_id])
          .deprovision
          .order_by_id_asc
          .last

        return unless task

        # Edge case: SM is in `deprovisioning` but no maintenance task
        # remains (a prior worker already finished OpenBao teardown but
        # the SM row was left behind). We intentionally do nothing here.
        # Once super finishes destroying the parent group, the SM ends
        # up with `group_id = NULL` and the orphan reaper
        # (gitlab-org/gitlab#600120) sweeps it up. Bespoke cleanup here
        # would duplicate the reaper's job.
        ::SecretsManagement::DeprovisionGroupSecretsManagerWorker.perform_async(task.id)
      end

      # rubocop:disable CodeReuse/ActiveRecord
      def users_to_destroy
        group.service_accounts.pluck(:user_id) + super
      end
      # rubocop:enable CodeReuse/ActiveRecord

      def after_destroy(group)
        delete_dependency_proxy_blobs(group)

        return if group&.persisted?

        log_audit_event

        return unless ::Gitlab::Geo.primary? && group.group_wiki_repository

        group.group_wiki_repository.geo_handle_after_destroy
      end

      # rubocop:disable Scalability/BulkPerformWithContext
      def with_scheduling_epic_cache_update
        ids = group.parent_epic_ids_in_ancestor_groups

        group = yield

        ::Epics::UpdateCachedMetadataWorker.bulk_perform_in(
          1.minute,
          ids.each_slice(::Epics::UpdateCachedMetadataWorker::BATCH_SIZE).map { |ids| [ids] }
        )

        group
      end
      # rubocop:enable Scalability/BulkPerformWithContext

      def delete_dependency_proxy_blobs(group)
        # the blobs reference files that need to be destroyed that cascade delete
        # does not remove
        group.dependency_proxy_blobs.destroy_all # rubocop:disable Cop/DestroyAll
      end

      def log_audit_event
        audit_context = {
          name: 'group_destroyed',
          author: current_user,
          scope: group.root_ancestor,
          target: group,
          message: 'Group destroyed',
          target_details: group.full_path,
          additional_details: {
            remove: 'group'
          }
        }

        ::Gitlab::Audit::Auditor.audit(audit_context)
      end
    end
  end
end
