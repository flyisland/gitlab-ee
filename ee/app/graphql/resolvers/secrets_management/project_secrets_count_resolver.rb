# frozen_string_literal: true

module Resolvers
  module SecretsManagement
    class ProjectSecretsCountResolver < BaseResolver
      include Gitlab::Graphql::Authorize::AuthorizeResource
      include ResolvesProject
      include ::SecretsManagement::ResolverErrorHandling

      type GraphQL::Types::Int, null: true

      argument :project_path, GraphQL::Types::ID,
        required: true,
        description: 'Full path of the project.'

      authorize :read_project_secrets

      def resolve(project_path:)
        project = authorized_find!(project_path: project_path)
        return unless project.secrets_manager&.active?

        ::SecretsManagement::ProjectSecretsCountService.new(project, current_user).execute
      end

      private

      def find_object(project_path:)
        resolve_project(full_path: project_path)
      end
    end
  end
end
