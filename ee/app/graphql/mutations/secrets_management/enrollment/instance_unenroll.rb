# frozen_string_literal: true

module Mutations
  module SecretsManagement
    module Enrollment
      class InstanceUnenroll < BaseMutation
        graphql_name 'InstanceSecretsManagerUnenroll'

        include ::SecretsManagement::MutationErrorHandling

        authorize :delete_secrets_manager_enrollment

        def resolve
          authorize!(:global)

          result = ::SecretsManagement::InstanceEnrollmentService
            .new(current_user: current_user)
            .unenroll

          {
            errors: result.success? ? [] : [result.message]
          }
        end
      end
    end
  end
end
