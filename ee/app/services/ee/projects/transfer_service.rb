# frozen_string_literal: true

module EE
  module Projects
    module TransferService
      extend ::Gitlab::Utils::Override

      private

      override :execute_system_hooks
      def execute_system_hooks
        super

        ::Projects::ProjectChangesAuditor.new(current_user, project).execute
      end

      override :transfer_missing_group_resources
      def transfer_missing_group_resources(group)
        super

        ::Epics::TransferService.new(current_user, group, project).execute

        transfer_status_data
      end

      override :post_update_hooks
      def post_update_hooks(project, old_group)
        super

        ::Elastic::ProjectTransferWorker.perform_async(project.id, old_namespace.id, new_namespace.id)
        ::Search::Zoekt::ProjectTransferWorker.perform_async(project.id, old_namespace.id)

        delete_compliance_framework_setting(old_group)
        update_compliance_standards_adherence
        delete_compliance_statuses
        sync_security_policies
        deprovision_secrets_manager(project.secrets_manager)
      end

      override :remove_paid_features
      def remove_paid_features
        ::EE::Projects::RemovePaidFeaturesService.new(project).execute(new_namespace)
      end

      def sync_security_policies
        return unless project.licensed_feature_available?(:security_orchestration_policies)

        ::Security::Policies::ProjectTransferWorker.perform_async(
          project.id, current_user.id, old_namespace.id, new_namespace.id
        )
      end

      def delete_compliance_framework_setting(old_group)
        return if old_group&.root_ancestor == project.group&.root_ancestor

        deleted_framework_settings = project.compliance_framework_settings.each(&:delete)

        deleted_framework_settings.each do |framework_setting|
          ComplianceManagement::ComplianceFrameworkChangesAuditor.new(current_user, framework_setting, project).execute
        end
      end

      def update_compliance_standards_adherence
        project.compliance_standards_adherence.update_all(namespace_id: new_namespace.id)
      end

      def delete_compliance_statuses
        project.compliance_framework_settings.each do |framework_setting|
          enqueue_project_compliance_status_removal(framework_setting.framework_id)
        end
      end

      def enqueue_project_compliance_status_removal(framework_id)
        ComplianceManagement::ComplianceFramework::ProjectComplianceStatusesRemovalWorker.perform_async(
          project.id, framework_id, { "skip_framework_check" => true }
        )
      end

      def transfer_status_data
        ::WorkItems::Widgets::Statuses::TransferService.new(
          old_root_namespace: old_namespace.root_ancestor,
          new_root_namespace: new_namespace.root_ancestor,
          project_namespace_ids: [project.project_namespace_id]
        ).execute
      end

      # When this hook runs, the project has already been transferred to
      # its new parent. `project.namespace` and `project.root_ancestor`
      # now point at the NEW location. But the OpenBao paths we need to
      # clean up are the OLD ones (the namespace the project used to live
      # under).
      #
      # The base transfer service keeps a reference to where the project
      # was before the move, exposed as `old_namespace`. We use that here
      # to feed the deprovision service the right IDs.
      #
      # No rescue or log on purpose. By the time we reach this point the
      # transfer has already happened, so the only kind of error that can
      # surface is infrastructural (DB hiccup, Redis outage, OOM). Those
      # belong in Sentry, so we let them bubble. If something does slip
      # through, the secrets manager row stays behind looking like an
      # orphan and the reaper (gitlab-org/gitlab#600120) cleans it up.
      def deprovision_secrets_manager(secrets_manager)
        return unless secrets_manager

        ::SecretsManagement::ProjectSecretsManagers::InitiateDeprovisionService.new(
          secrets_manager,
          current_user,
          project_id: project.id,
          organization_id: old_namespace.organization_id,
          root_namespace_id: old_namespace.root_ancestor.id,
          parent_group_id: old_namespace.id
        ).execute
      end
    end
  end
end
