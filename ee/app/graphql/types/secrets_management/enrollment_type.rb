# frozen_string_literal: true

module Types
  module SecretsManagement
    class EnrollmentType < BaseObject
      graphql_name 'SecretsManagerEnrollment'
      description 'Representation of a Secrets Manager namespace enrollment.'

      authorize :read_secrets_manager_enrollment

      field :namespace,
        Types::NamespaceType,
        null: false,
        description: 'Namespace the enrollment belongs to.'
    end
  end
end
