# frozen_string_literal: true

module SecretsManagement
  class InstanceEnrollment
    def self.enrolled?
      ::Gitlab::CurrentSettings.secrets_manager_instance_enrolled
    end

    def self.enrollment_allowed?
      !::Gitlab.com? && # rubocop:disable Gitlab/AvoidGitlabInstanceChecks -- instance enrollment is self-managed only
        ::License.feature_available?(:native_secrets_management) &&
        ::Feature.enabled?(:secrets_manager_instance_enrollment) # rubocop:disable Gitlab/FeatureFlagWithoutActor -- instance-level flag has no actor
    end
  end
end
