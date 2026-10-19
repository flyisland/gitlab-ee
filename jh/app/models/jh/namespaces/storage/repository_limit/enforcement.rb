# frozen_string_literal: true

# Handles enforcement for storage limit
#
# This class has the logic for repository size limits (a.k.a Project Enforcement Limits).
# Repository limits include repository size and LFS.
# Docs:
# - https://docs.gitlab.com/ee/administration/settings/account_and_limit_settings.html#repository-size-limit
# - https://docs.gitlab.com/ee/user/storage_usage_quotas.html
#
# Self-Managed customers can set this limit using the docs above.
# At GitLab.com an instance wide limit of 10 GiB per project is set. Some plans may have higher limits.
#
# At GitLab.com customers can purchase additional storage, which will be added to the root namespace and
# can be consumed by any project in the namespace hierarchy that is over the instance wide limit.
#

module JH
  module Namespaces
    module Storage
      module RepositoryLimit
        module Enforcement
          extend ActiveSupport::Concern
          extend ::Gitlab::Utils::Override

          # upstream epic: https://gitlab.com/groups/gitlab-org/-/epics/14207
          # JH issue https://jihulab.com/gitlab-cn/gitlab/-/issues/4858
          override :subject_to_high_limit?
          def subject_to_high_limit?
            return super unless ::Feature.enabled?(:jh_disable_subject_to_high_limit)

            false
          end

          # Same purchased/included thresholds as EmailNotificationService#notification_level.
          override :has_projects_over_high_limit_warning_threshold?
          def has_projects_over_high_limit_warning_threshold?
            return false unless subject_to_high_limit?

            purchased_ratio = purchased_storage_usage_ratio

            if purchased_ratio == 0 || purchased_ratio >= 1
              super
            elsif purchased_ratio >= self.class::HIGH_LIMIT_WARNING_THRESHOLD
              root_namespace.projects_with_repository_size_limit_usage_ratio_greater_than(ratio: 1).exists?
            else
              false
            end
          end

          private

          def purchased_storage_usage_ratio
            purchased_available = root_namespace.additional_purchased_storage_size.megabytes
            return 0 if purchased_available == 0

            BigDecimal(current_size) / BigDecimal(purchased_available)
          end
        end
      end
    end
  end
end
