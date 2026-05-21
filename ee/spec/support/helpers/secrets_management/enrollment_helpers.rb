# frozen_string_literal: true

module SecretsManagement
  module EnrollmentHelpers
    # Satisfies the instance-enrollment leg of `Availability.enabled_for_*?`
    # (`license AND FF AND enrollment`). Use in specs that exercise SM-gated
    # code paths without going through the `provision_*_secrets_manager`
    # helpers (which auto-enroll). For the SaaS namespace branch, set
    # `Gitlab.com?` and create a `:secrets_manager_namespace_enrollment`
    # record instead.
    def enroll_instance_in_secrets_manager
      stub_application_setting(secrets_manager_instance_enrolled: true)
    end
  end
end
