# frozen_string_literal: true

module SecretsHelper
  def project_secrets_app_data(project)
    root_namespace = project.root_ancestor

    {
      base_path: project_secrets_path(project),
      can_enable_add_on: can_enable_secrets_manager_add_on?(root_namespace).to_s,
      can_provision: can?(current_user, :provision_secrets_manager, project).to_s,
      can_start_trial: can_start_secrets_manager_trial?(root_namespace).to_s,
      enrollment_settings_path: enrollment_settings_path(root_namespace),
      is_offline_license: ::SecretsManagement::InstanceEnrollment.offline_license?.to_s,
      manage_permissions_path: edit_project_path(project, anchor: 'js-shared-permissions'),
      project_path: project.full_path,
      top_level_group_full_path: root_namespace.is_a?(Group) ? root_namespace.full_path : ''
    }
  end

  def group_secrets_app_data(group)
    root_namespace = group.root_ancestor

    {
      base_path: group_secrets_path(group),
      can_enable_add_on: can_enable_secrets_manager_add_on?(root_namespace).to_s,
      can_provision: can?(current_user, :provision_secrets_manager, group).to_s,
      can_start_trial: can_start_secrets_manager_trial?(root_namespace).to_s,
      enrollment_settings_path: enrollment_settings_path(root_namespace),
      group_path: group.full_path,
      is_offline_license: ::SecretsManagement::InstanceEnrollment.offline_license?.to_s,
      manage_permissions_path: group_manage_permissions_path(group),
      top_level_group_full_path: root_namespace.full_path
    }
  end

  def namespace_enrollment_data(namespace, user)
    {
      can_manage_secrets_manager: can?(user, :admin_group, namespace).to_s, # rubocop:disable Gitlab/Authz/PermissionCheck -- will iterate on this. provision_secrets_manager is a good fit but it needs to be fetched/updated dynamically on enrollment
      can_enroll_namespace: can?(user, :create_secrets_manager_enrollment, namespace).to_s,
      can_start_trial: can?(user, :start_secrets_manager_trial, namespace).to_s,
      full_path: namespace.full_path,
      is_namespace_enrollable: (namespace.root? && Gitlab.com?).to_s, # rubocop:disable Gitlab/AvoidGitlabInstanceChecks -- testing SaaS behavior directly (feature is also available for self-managed, but enrollment behavior is different)
      top_level_group_full_path: namespace.root_ancestor.full_path
    }
  end

  def secrets_manager_cta_data(project, report_type)
    return {} unless report_type == 'secret_detection'
    return {} unless Feature.enabled?(:secrets_manager_vulnerability_cta, project, type: :gitlab_com_derisk)

    root_namespace = project.root_ancestor
    # Granted only to instance admins on self-managed; the group ability is only
    # granted on GitLab.com, so together they cover both without a SaaS check.
    instance_trial = can?(current_user, :start_secrets_manager_trial)
    start_trial_path = secrets_manager_cta_start_trial_path(root_namespace, instance_trial)

    # No destination means the trial ability has nowhere actionable to land,
    # so the Try button is withheld.
    can_start_trial = start_trial_path.present? &&
      (instance_trial || can_start_secrets_manager_trial?(root_namespace))
    secrets_manager_available = ::SecretsManagement::Availability.for_project?(project)

    # An empty payload hides the card. When the user can neither use nor try
    # the secrets manager, the card falls back to asking an owner or
    # administrator for access, which is only honest while the feature is
    # offered to the group at all: unlicensed (or a personal namespace),
    # there is nothing an owner could grant, so no card.
    return {} unless secrets_manager_available || can_start_trial ||
      secrets_manager_offered_to_group?(root_namespace)

    {
      secrets_manager_available: secrets_manager_available,
      can_start_trial: can_start_trial,
      secrets_path: project_secrets_path(project),
      start_trial_path: (start_trial_path if can_start_trial)
    }.compact
  end

  private

  # Same ability as SecretsManagerStartTrial, so the button and the mutation agree.
  # Personal namespaces have no trial concept, so return false there.
  def can_start_secrets_manager_trial?(root_namespace)
    return false unless root_namespace.is_a?(Group)

    can?(current_user, :start_secrets_manager_trial, root_namespace)
  end

  # Same ability as SecretsManagerEnableAddOn. On self-managed the add-on is
  # instance-wide (admin only), so this is false for every group there.
  def can_enable_secrets_manager_add_on?(root_namespace)
    return false unless root_namespace.is_a?(Group)

    can?(current_user, :enable_secrets_manager_add_on, root_namespace)
  end

  # Whether the secrets manager is offered to the group at all, regardless of
  # the current user's abilities or the enrollment state. Enrollment is
  # deliberately not consulted: an unenrolled or opted-out group is still
  # offered the feature, since an owner or administrator could enable it,
  # which is exactly what the card's request variant asks them to do. Only
  # an unlicensed group or a personal namespace is offered nothing. Decides
  # whether showing any CTA is honest, not whether anything is permitted.
  def secrets_manager_offered_to_group?(root_namespace)
    return false unless root_namespace.is_a?(Group)

    ::SecretsManagement::Availability.licensed?(root_namespace)
  end

  # Instance admins land on the Admin area enrollment settings; no license
  # check here because the instance-level trial ability itself is only
  # granted on a licensed instance (InstanceEnrollment.paid_experience_allowed?).
  #
  # For groups, the secrets page is the trial surface (its empty state
  # carries the Start trial and Enable buttons), so Try lands there, except
  # when the page would 404: an explicit opt-out revokes page access, and
  # re-enabling lives in Settings > Secure, so Try goes there instead, but
  # only while the feature is still licensed. Unlicensed, neither group page
  # works, so no path is returned and the caller withholds the Try button.
  def secrets_manager_cta_start_trial_path(root_namespace, instance_trial)
    return instance_enrollment_settings_path if instance_trial
    return unless root_namespace.is_a?(Group)

    if ::SecretsManagement::Availability.for_group?(root_namespace)
      group_secrets_path(root_namespace)
    elsif ::SecretsManagement::Availability.licensed?(root_namespace) &&
        ::SecretsManagement::NamespaceEnrollment.opted_out?(root_namespace)
      group_settings_secure_path(root_namespace, anchor: 'js-secrets-manager-settings')
    end
  end

  def instance_enrollment_settings_path
    general_admin_application_settings_path(anchor: 'js-secrets-manager-instance-enrollment-settings')
  end

  def enrollment_settings_path(root_group)
    if allow_secrets_manager_instance_enrollment?
      instance_enrollment_settings_path
    else
      # The top-level group's Secrets Manager settings live under the Secure tab.
      group_settings_secure_path(root_group, anchor: 'js-secrets-manager-settings')
    end
  end

  # Subgroups keep their Secrets Manager settings under General; only the
  # top-level group moves to the Secure tab.
  def group_manage_permissions_path(group)
    if group.root?
      group_settings_secure_path(group, anchor: 'js-secrets-manager-settings')
    else
      edit_group_path(group, anchor: 'js-permissions-settings')
    end
  end
end
