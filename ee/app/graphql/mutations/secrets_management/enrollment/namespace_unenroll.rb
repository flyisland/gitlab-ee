# frozen_string_literal: true

module Mutations
  module SecretsManagement
    module Enrollment
      class NamespaceUnenroll < BaseMutation
        graphql_name 'NamespaceSecretsManagerUnenroll'

        include Mutations::ResolvesGroup
        include ::SecretsManagement::MutationErrorHandling

        authorize :delete_secrets_manager_enrollment

        argument :namespace_path,
          GraphQL::Types::ID,
          required: true,
          description: 'Full path of the namespace to unenroll.'

        field :enrollment,
          Types::SecretsManagement::EnrollmentType,
          null: true,
          description: 'Enrollment record.'

        def resolve(namespace_path:)
          raise_resource_not_available_error! unless ::Gitlab.com? # rubocop:disable Gitlab/AvoidGitlabInstanceChecks -- namespace enrollment is SaaS only

          group = authorized_find!(group_path: namespace_path)

          result = ::SecretsManagement::NamespaceEnrollmentService
            .new(group, current_user: current_user)
            .unenroll

          {
            enrollment: nil,
            errors: result.success? ? [] : [result.message]
          }
        end

        private

        def find_object(group_path:)
          resolve_group(full_path: group_path)
        end
      end
    end
  end
end
