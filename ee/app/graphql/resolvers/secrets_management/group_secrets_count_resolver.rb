# frozen_string_literal: true

module Resolvers
  module SecretsManagement
    class GroupSecretsCountResolver < BaseResolver
      include Gitlab::Graphql::Authorize::AuthorizeResource
      include ResolvesGroup
      include ::SecretsManagement::ResolverErrorHandling

      type GraphQL::Types::Int, null: true

      argument :group_path, GraphQL::Types::ID,
        required: true,
        description: 'Full path of the group.'

      authorize :read_secret

      def resolve(group_path:)
        group = authorized_find!(group_path: group_path)
        return unless group.secrets_manager&.active?

        ::SecretsManagement::GroupSecretsCountService.new(group, current_user).execute
      end

      private

      def find_object(group_path:)
        resolve_group(full_path: group_path)
      end
    end
  end
end
