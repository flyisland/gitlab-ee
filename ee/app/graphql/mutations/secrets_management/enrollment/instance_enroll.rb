# frozen_string_literal: true

module Mutations
  module SecretsManagement
    module Enrollment
      class InstanceEnroll < BaseMutation
        graphql_name 'InstanceSecretsManagerEnroll'

        include ::SecretsManagement::MutationErrorHandling

        authorize :create_secrets_manager_enrollment

        def resolve
          authorize!(:global)

          result = ::SecretsManagement::InstanceEnrollmentService
            .new(current_user: current_user)
            .enroll

          {
            errors: result.success? ? [] : [result.message]
          }
        end
      end
    end
  end
end
