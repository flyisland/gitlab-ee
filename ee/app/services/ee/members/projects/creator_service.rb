# frozen_string_literal: true

module EE
  module Members
    module Projects
      module CreatorService
        extend ActiveSupport::Concern
        extend ::Gitlab::Utils::Override

        private

        override :can_create_new_member?
        def can_create_new_member?
          return false unless service_account_eligible_for_membership?

          if member_user_is_service_account_with_composite_identity_enforced?
            return current_user.can?(:admin_service_account_member, member.project) # rubocop:disable Gitlab/Authz/PermissionCheck -- Match the group member creator authorization for service account membership management.
          end

          return super if adding_the_creator_as_owner_in_a_personal_project?

          super && current_user.can?(:invite_project_members, member.project)
        end

        def member_user_is_service_account_with_composite_identity_enforced?
          user = member.user

          return false if user.nil?

          user.service_account? && user.composite_identity_enforced?
        end
      end
    end
  end
end
