# frozen_string_literal: true

module EE
  module Namespaces
    module ServiceAccounts
      module BaseCreateService
        extend ActiveSupport::Concern
        extend ::Gitlab::Utils::Override
        include ::Gitlab::Utils::StrongMemoize

        private

        override :creation_allowed?
        def creation_allowed?
          if saas?
            ::Authn::ServiceAccounts.creation_allowed_for_saas?(
              root_namespace,
              service_accounts_provisioned_count
            )
          else
            super
          end
        end

        def service_accounts_provisioned_count
          return 0 unless root_namespace

          namespace_ids = root_namespace.self_and_descendant_ids

          # rubocop: disable CodeReuse/ActiveRecord -- this is an optimized query to count service accounts across group
          # hierarchy for subscription, its not used anywhere else.
          group_provisioned_scope = ::User
            .service_accounts_without_composite_identity
            .with_provisioning_group(namespace_ids)
            .select(:id)

          project_ids = ::Project.where(namespace_id: namespace_ids).select(:id)
          project_provisioned_scope = ::User
            .service_accounts_without_composite_identity
            .joins(:user_detail)
            .where(user_details: { provisioned_by_project_id: project_ids })
            .select(:id)

          ::User.from_union([group_provisioned_scope, project_provisioned_scope]).count
          # rubocop: enable CodeReuse/ActiveRecord
        end

        def saas?
          return false unless root_namespace

          ::Gitlab::Saas.feature_available?(:gitlab_com_subscriptions)
        end
        strong_memoize_attr :saas?
      end
    end
  end
end
