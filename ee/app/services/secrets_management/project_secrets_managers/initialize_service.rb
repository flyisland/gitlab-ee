# frozen_string_literal: true

module SecretsManagement
  module ProjectSecretsManagers
    class InitializeService < ProjectBaseService
      def execute
        if project.namespace.user_namespace?
          return ServiceResponse.error(message: 'Secrets manager is not available for projects in user namespaces.')
        end

        if project.secrets_manager.nil?
          secrets_manager = ProjectSecretsManager.create!(project: project)

          SecretsManagement::ProvisionProjectSecretsManagerWorker.perform_async(
            current_user.id,
            secrets_manager.id
          )

          ServiceResponse.success(payload: { project_secrets_manager: secrets_manager })
        else
          ServiceResponse.error(message: 'Secrets manager already initialized for the project.')
        end
      end
    end
  end
end
