# frozen_string_literal: true

module EE
  module Projects
    module DestroyService
      extend ::Gitlab::Utils::Override

      override :execute
      def execute
        # Grab a reference to the secrets manager and a snapshot of the IDs
        # we'll need later, BEFORE the project gets destroyed.
        #
        # Once super runs and the project is gone, two things become true
        # that make this awkward to do later:
        #
        #   - `project.secrets_manager` starts returning nil. The link
        #     between the project and its secrets manager goes through the
        #     `project_id` column on the secrets manager row, and that
        #     column gets set to NULL the moment the project is deleted.
        #
        #   - `project.root_ancestor` (and other walks up the namespace
        #     tree) can no longer be trusted. The project row is gone and
        #     anything that joins through it returns leftover data or nil.
        #
        # So we save what we need into plain values and a hash here, while
        # the live records still answer the right questions. We pass those
        # values to the deprovision service explicitly so it never has to
        # re-derive them from records that may have moved or disappeared.
        stale_secrets_manager = project.secrets_manager
        stale_secrets_manager_snapshot = build_secrets_manager_snapshot(project, stale_secrets_manager)
        super.tap do
          # Only start the deprovision once we know the project actually
          # got destroyed. Two reasons for waiting until after super:
          #
          #   - If we kicked off deprovision first, the async worker could
          #     pick up the job a split second later and start tearing
          #     down OpenBao paths while the project is still alive. Any
          #     pipeline running right then would suddenly lose access to
          #     its secrets.
          #
          #   - If super raises partway through, we want to leave
          #     everything alone (secrets manager still active, project
          #     still here) so the user can simply try again.
          if project&.destroyed?
            mirror_cleanup(project)
            deprovision_secrets_manager(stale_secrets_manager, stale_secrets_manager_snapshot)
          end
        end
      end

      private

      override :destroy_project_related_records
      def destroy_project_related_records(project)
        destroy_compliance_requirement_statuses!
        destroy_ai_catalog_items!

        with_scheduling_epic_cache_update do
          super && log_destroy_events
        end
      end

      # rubocop:disable Scalability/BulkPerformWithContext
      def with_scheduling_epic_cache_update
        ids = project.epic_ids_referenced_by_issues

        yield

        ::Epics::UpdateCachedMetadataWorker.bulk_perform_in(
          1.minute,
          ids.each_slice(::Epics::UpdateCachedMetadataWorker::BATCH_SIZE).map { |ids| [ids] }
        )
      end
      # rubocop:enable Scalability/BulkPerformWithContext

      def log_destroy_events
        log_geo_event(project)
        log_audit_event(project)
      end

      override :execute_hooks
      def execute_hooks(project)
        super
        return unless project.has_active_hooks?(:project_hooks)

        hook_data = ::Gitlab::HookData::ProjectBuilder.new(project).build(:destroy)
        project.execute_hooks(hook_data, :project_hooks)
      end

      def mirror_cleanup(project)
        return unless project.mirror?

        ::Gitlab::Mirror.decrement_capacity(project.id)
      end

      # No rescue or log here on purpose. By the time we reach this point
      # the project has already been destroyed, so the only kind of error
      # that can show up is something infrastructural: the database is
      # unhappy, Redis is unreachable, the process is out of memory.
      # Those are exactly the errors we want Sentry to tell us about, so
      # we let them bubble up untouched.
      #
      # If something does slip through (e.g. the call fails before the
      # maintenance task gets persisted), the secrets manager row stays
      # behind with `project_id = NULL`. The orphan reaper
      # (gitlab-org/gitlab#600120) sweeps those up.
      def deprovision_secrets_manager(stale_secrets_manager, snapshot)
        return unless stale_secrets_manager

        ::SecretsManagement::ProjectSecretsManagers::InitiateDeprovisionService.new(
          stale_secrets_manager,
          current_user,
          **snapshot
        ).execute
      end

      # The set of IDs the async deprovision worker will need to figure
      # out which OpenBao paths belong to this project. We pull them off
      # the live project record now, while it still exists; the worker
      # will run minutes later when none of these accessors would work.
      def build_secrets_manager_snapshot(project, secrets_manager)
        return {} unless secrets_manager

        {
          project_id: project.id,
          organization_id: project.organization_id,
          root_namespace_id: project.root_ancestor.id
        }
      end

      def log_geo_event(project)
        project.geo_handle_after_destroy
        project.wiki_repository.geo_handle_after_destroy if project.wiki_repository
        project.design_management_repository.geo_handle_after_destroy if project.design_management_repository
      end

      def log_audit_event(project)
        audit_scope = if project.parent.instance_of?(::Namespaces::UserNamespace)
                        ::Gitlab::Audit::InstanceScope.new
                      else
                        project.parent
                      end

        audit_context = {
          name: 'project_destroyed',
          author: current_user,
          scope: audit_scope,
          target: project,
          message: "Project '#{project.full_path}' was deleted",
          target_details: project.full_path,
          additional_details: {
            remove: 'project',
            project_id: project.id,
            project_name: project.name,
            project_full_path: project.full_path,
            namespace_id: project.namespace_id,
            namespace_name: project.namespace&.name,
            namespace_path: project.namespace&.path
          }
        }

        ::Gitlab::Audit::Auditor.audit(audit_context)
      end

      def destroy_compliance_requirement_statuses!
        ::ComplianceManagement::ComplianceFramework::ProjectRequirementComplianceStatus
          .delete_all_project_statuses(project.id)
      end

      def destroy_ai_catalog_items!
        project_owned_items = ::Ai::Catalog::Item.for_project(project)

        # Hard delete items that have no remaining consumers
        project_owned_items.without_consumers.delete_all

        # Soft delete all items owned by the project
        project_owned_items.update_all(
          project_id: nil,
          deleted_at: Time.zone.now
        )
      end
    end
  end
end
