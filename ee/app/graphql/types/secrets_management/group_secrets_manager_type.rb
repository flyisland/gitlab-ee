# frozen_string_literal: true

module Types
  module SecretsManagement
    class GroupSecretsManagerType < BaseObject
      graphql_name 'GroupSecretsManager'
      description 'Representation of a group secrets manager.'

      authorize :read_secret

      field :group,
        Types::GroupType,
        null: false,
        description: 'Group the secrets manager belongs to.'

      field :status,
        Types::SecretsManagement::GroupSecretsManagerStatusEnum,
        description: 'Status of the group secrets manager.'
    end
  end
end
