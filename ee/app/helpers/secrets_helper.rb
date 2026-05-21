# frozen_string_literal: true

module SecretsHelper
  def project_secrets_app_data(project)
    {
      project_path: project.full_path,
      base_path: project_secrets_path(project)
    }
  end

  def group_secrets_app_data(group)
    {
      group_path: group.full_path,
      base_path: group_secrets_path(group)
    }
  end

  def namespace_enrollment_data(namespace, user)
    {
      can_manage_secrets_manager: can?(user, :admin_group, namespace).to_s, # rubocop:disable Gitlab/Authz/PermissionCheck -- will iterate on this. provision_secrets_manager is a good fit but it needs to be fetched/updated dynamically on enrollment
      can_enroll_namespace: can?(user, :create_secrets_manager_enrollment, namespace).to_s,
      full_path: namespace.full_path,
      group_path_regex: JsRegex.new(Gitlab::PathRegex::FULL_NAMESPACE_FORMAT_REGEX).source,
      is_namespace_enrollable: (namespace.root? && Gitlab.com?).to_s # rubocop:disable Gitlab/AvoidGitlabInstanceChecks -- testing SaaS behavior directly (feature is also available for self-managed, but enrollment behavior is different)
    }
  end
end
