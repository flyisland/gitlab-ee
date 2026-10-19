# frozen_string_literal: true

module Security
  module SecurityOrchestrationPolicies
    module PolicyStore
      class BaseService
        def initialize(container:, current_user:, params: {})
          @container = container
          @current_user = current_user
          @params = params.to_h.symbolize_keys
        end

        private

        attr_reader :container, :current_user, :params

        def organization
          container.is_a?(::Group) ? container.organization : container
        end

        def namespace_id
          container.is_a?(::Group) ? container.id : nil
        end

        def readable_namespace_ids
          return unless container.is_a?(::Group)

          [nil, *container.self_and_hierarchy.pluck_primary_key]
        end

        def experiment_active?
          container.policy_store_experiment_active?
        end

        def authorized?(ability)
          Ability.allowed?(current_user, ability, container)
        end

        def find_readable_policy(policy_id)
          find_policy(policy_id) do |policy|
            namespace_id.nil? || policy.namespace_id.nil? || in_hierarchy?(policy.namespace_id)
          end
        end

        def in_hierarchy?(policy_namespace_id)
          container.self_and_hierarchy.id_in(policy_namespace_id).exists?
        end

        def find_writable_policy(policy_id)
          find_policy(policy_id) do |policy|
            namespace_id.nil? || policy.namespace_id == namespace_id
          end
        end

        # A policy outside the container returns the same not-found as a missing id,
        # so probing ids leaks nothing.
        def find_policy(policy_id)
          policy = ::Gitlab::PolicyStore.find(policy_id)

          return unless policy.organization_id == organization.id
          return unless yield(policy)

          policy
        rescue ::Gitlab::PolicyStore::NotFound
          nil
        end

        def experiment_not_active_error
          ServiceResponse.error(
            message: experiment_not_active_message,
            reason: :experiment_not_active
          )
        end

        def experiment_not_active_message
          if container.is_a?(::Group)
            s_('GovernPolicies|Policy Store experiment is not active for this group')
          else
            s_('GovernPolicies|Policy Store experiment is not active for this organization')
          end
        end

        def forbidden_error
          ServiceResponse.error(
            message: forbidden_message,
            reason: :forbidden
          )
        end

        def forbidden_message
          if container.is_a?(::Group)
            s_('GovernPolicies|You are not authorized to perform this action on policies in this group')
          else
            s_('GovernPolicies|You are not authorized to perform this action on policies in this organization')
          end
        end

        def policy_not_found_error
          ServiceResponse.error(
            message: s_('GovernPolicies|Policy was not found'),
            reason: :not_found
          )
        end

        def engine_error(error, **context)
          ::Gitlab::ErrorTracking.track_exception(error, organization_id: organization.id, **context)

          ServiceResponse.error(message: error.message, reason: :engine_error)
        end

        def conflicting_scope?
          params[:policy_scope].present? && params[:scope_rego].present?
        end

        def conflicting_scope_error
          ServiceResponse.error(
            message: s_('GovernPolicies|Only one of policy_scope or scope_rego can be provided'),
            reason: :invalid
          )
        end
      end
    end
  end
end
