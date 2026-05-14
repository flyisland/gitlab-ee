# frozen_string_literal: true

module Mutations
  module VirtualRegistries
    module Container
      module Registry
        module Upstream
          class Destroy < ::Mutations::VirtualRegistries::Registry::Upstream::Destroy
            graphql_name 'ContainerVirtualRegistryUpstreamDelete'

            argument :upstream_id, ::Types::GlobalIDType[::VirtualRegistries::Container::RegistryUpstream],
              required: true,
              description: 'ID of the container virtual registry upstream.'

            field :registry_upstream,
              ::Types::VirtualRegistries::Container::RegistryUpstreamWithRegistryType,
              null: true,
              description: 'Deleted container registry upstream.'

            private

            def service_class
              ::VirtualRegistries::Container::DestroyRegistryUpstreamService
            end
          end
        end
      end
    end
  end
end
