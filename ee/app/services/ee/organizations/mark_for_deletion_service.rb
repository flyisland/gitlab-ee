# frozen_string_literal: true

module EE
  module Organizations
    module MarkForDeletionService
      extend ::Gitlab::Utils::Override

      private

      override :log_event
      def log_event
        super

        ::Gitlab::Audit::Auditor.audit(audit_context)
      end

      def audit_context
        {
          name: 'organization_deletion_marked',
          author: current_user,
          scope: ::Gitlab::Audit::InstanceScope.new,
          target: organization,
          message: "Marked organization '#{organization.name}' for deletion"
        }
      end
    end
  end
end
