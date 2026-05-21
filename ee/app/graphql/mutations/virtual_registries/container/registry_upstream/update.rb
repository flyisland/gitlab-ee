# frozen_string_literal: true

module Mutations
  module VirtualRegistries
    module Container
      module RegistryUpstream
        class Update < ::Mutations::VirtualRegistries::RegistryUpstream::Update
          graphql_name 'ContainerVirtualRegistryUpstreamUpdate'

          argument :id, ::Types::GlobalIDType[::VirtualRegistries::Container::RegistryUpstream],
            required: true,
            description: 'ID of the container virtual registry upstream.'

          field :registry_upstream,
            ::Types::VirtualRegistries::Container::RegistryUpstreamWithRegistryType,
            null: true,
            description: 'Container registry upstream after update.'

          private

          def enabled?(registry_upstream)
            ::VirtualRegistries::Container.feature_enabled?(registry_upstream.group)
          end
        end
      end
    end
  end
end
