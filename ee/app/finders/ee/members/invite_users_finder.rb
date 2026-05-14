# frozen_string_literal: true

module EE
  module Members
    module InviteUsersFinder
      extend ::Gitlab::Utils::Override
      include ::Gitlab::Utils::StrongMemoize

      private

      def root_group
        root_ancestor = resource.root_ancestor

        root_ancestor if root_ancestor.group_namespace?
      end
      strong_memoize_attr :root_group

      override :scope_for_resource
      def scope_for_resource(users)
        scoped = root_group&.enforced_sso? ? sso_scoped_users(users) : super

        ::Members::ServiceAccounts::EligibilityChecker.new(**checker_args).filter_users(scoped)
      end

      def sso_scoped_users(users)
        ::User.from_union([
          users.with_saml_provider(root_group.saml_provider),
          users.service_account.with_provisioning_group(root_group.self_and_descendants),
          users.service_account.with_provisioning_project_in(root_group.self_and_descendants)
        ])
      end

      def checker_args
        case resource
        when Project
          { target_project: resource }
        when Group
          { target_group: resource }
        else
          {}
        end
      end

      strong_memoize_attr :checker_args
    end
  end
end
