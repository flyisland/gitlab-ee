# frozen_string_literal: true

module Resolvers
  module SecretsManagement
    class InstanceEnrollmentResolver < BaseResolver
      include Gitlab::Graphql::Authorize::AuthorizeResource
      include ::SecretsManagement::ResolverErrorHandling

      type GraphQL::Types::Boolean, null: false
      description 'Check if Secrets Manager is enrolled at the instance level.'

      authorize :read_secrets_manager_enrollment

      def resolve
        authorize!(:global)

        ::Gitlab::CurrentSettings.secrets_manager_instance_enrolled
      end
    end
  end
end
