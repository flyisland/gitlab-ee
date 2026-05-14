# frozen_string_literal: true

module Types
  module SecurityOrchestration
    # rubocop: disable Graphql/AuthorizeTypes -- Authorization handled in the resolver
    # this represents a hash, from the orchestration policy configuration
    # the authorization happens for that configuration
    class SecurityPolicyType < BaseObject
      graphql_name 'SecurityPolicyType'
      description 'Represents the security policy'

      implements OrchestrationPolicyType

      field :policy_attributes, ::Types::SecurityOrchestration::PolicyAttributesUnion, null: false,
        description: 'Attributes specific to the policy type.'
      field :test_runs, Types::Security::PolicyScheduleTestRunType.connection_type,
        null: true,
        resolver: Resolvers::Security::PolicyTestRunsResolver,
        description: 'Test runs for this security policy.',
        experiment: { milestone: '18.10' }
      field :type, GraphQL::Types::String, null: true, description: 'Description of the policy type.'
    end
    # rubocop: enable Graphql/AuthorizeTypes
  end
end
