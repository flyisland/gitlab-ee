# frozen_string_literal: true

module Resolvers
  module Security
    class PolicyTestRunsResolver < BaseResolver
      type Types::Security::PolicyScheduleTestRunType.connection_type, null: true
      description 'Find test runs for a security policy.'

      def resolve
        policy_index = object[:policy_index]
        policy_type = object[:type]
        return [] if policy_index.nil? || policy_type != 'pipeline_execution_schedule_policy'

        parent = context[:security_policy_parent]
        return [] unless parent

        policy_configuration = find_policy_configuration(parent)
        return [] unless policy_configuration

        return [] if Feature.disabled?(:security_policies_spep_dry_run,
          policy_configuration.security_policy_management_project)

        security_policy = find_security_policy(policy_configuration, policy_index)
        return [] unless security_policy

        find_test_runs(security_policy)
      end

      private

      def find_policy_configuration(parent)
        strong_memoize(:policy_configuration) do
          if parent.is_a?(Project)
            ::Security::OrchestrationPolicyConfiguration.for_project(parent.id).first
          else
            ::Security::OrchestrationPolicyConfiguration.for_namespace(parent.id).first
          end
        end
      end

      def find_security_policy(policy_configuration, policy_index)
        ::Security::Policy
          .for_policy_configuration(policy_configuration)
          .type_pipeline_execution_schedule_policy
          .for_policy_index(policy_index)
          .first
      end

      def find_test_runs(security_policy)
        ::Security::ScheduledPipelineExecutionPolicyTestRun
          .for_policy(security_policy)
          .with_associations
      end
    end
  end
end
