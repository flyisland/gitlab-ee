# frozen_string_literal: true

module EE
  module Organizations
    module Transfer
      module TopLevelGroupService
        extend ::Gitlab::Utils::Override

        override :execute
        def execute
          result = super

          log_audit_events if result.success?

          result
        end

        private

        override :transfer_validation_error
        def transfer_validation_error
          return if new_organization.default?
          return unless ::Gitlab::Saas.feature_available?(:gitlab_com_subscriptions)

          multiple_subscriptions_error if multiple_group_subscriptions?
        end

        def multiple_group_subscriptions?
          group_ids = (existing_top_level_groups | groups).map(&:id)

          GitlabSubscription.many_active_paid_or_trial_for_namespaces?(group_ids)
        end

        def multiple_subscriptions_error
          s_(
            "TransferOrganization|There can only be one top-level group with a GitLab subscription in an Organization."
          )
        end

        def log_audit_events
          groups.each do |group|
            log_audit_event(group)
          end
        end

        def log_audit_event(group)
          audit_context = {
            name: 'group_transferred_to_organization',
            author: current_user || ::Gitlab::Audit::UnauthenticatedAuthor.new(name: '(System)'),
            scope: group,
            target: new_organization,
            message: "Transferred group to organization #{new_organization.name}"
          }

          ::Gitlab::Audit::Auditor.audit(audit_context)
        end
      end
    end
  end
end
