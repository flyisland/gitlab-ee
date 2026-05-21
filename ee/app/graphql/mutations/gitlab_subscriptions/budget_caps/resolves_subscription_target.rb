# frozen_string_literal: true

module Mutations
  module GitlabSubscriptions
    module BudgetCaps
      module ResolvesSubscriptionTarget
        extend ActiveSupport::Concern

        private

        def check_budget_caps_feature_flag!(namespace = nil)
          return if Feature.enabled?(:budget_caps_graphql_api, namespace)

          raise_resource_not_available_error!(
            'budget_caps_graphql_api feature flag is disabled'
          )
        end

        def resolve_target(namespace_path)
          if namespace_path
            namespace = ::Namespace.find_by_full_path(namespace_path)
            raise_resource_not_available_error! unless namespace
            raise_resource_not_available_error! unless namespace.root? && namespace.group_namespace?

            [:namespace, namespace]
          else
            [:instance, nil]
          end
        end

        def authorize_mutation!(subscription_target, namespace)
          allowed = if subscription_target == :instance
                      Ability.allowed?(
                        current_user, :update_subscription_usage_cap
                      )
                    else
                      Ability.allowed?(
                        current_user, :update_subscription_usage_cap, namespace
                      )
                    end

          raise_resource_not_available_error! unless allowed
        end

        def build_subscription_usage_client(subscription_target, namespace)
          if subscription_target == :instance
            raise_resource_not_available_error! unless License.current

            license_key = License.current.data
          end

          ::Gitlab::SubscriptionPortal::SubscriptionUsageClient.new(
            license_key: license_key,
            namespace_id: namespace&.id
          )
        end
      end
    end
  end
end
