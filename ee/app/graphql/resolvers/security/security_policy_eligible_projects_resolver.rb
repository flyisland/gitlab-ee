# frozen_string_literal: true

module Resolvers
  module Security
    class SecurityPolicyEligibleProjectsResolver < BaseResolver
      type Types::ProjectType.connection_type, null: true

      argument :search, GraphQL::Types::String,
        required: false,
        description: 'Search query for project name or path.'

      def resolve(**args)
        ::Security::SecurityPolicyEligibleProjectsFinder
          .new(current_user, object, args)
          .execute
      end
    end
  end
end
