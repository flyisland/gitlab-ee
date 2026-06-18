# frozen_string_literal: true

module Mutations
  module VirtualRegistries
    module Container
      module Upstream
        class Test < ::Mutations::VirtualRegistries::Upstream::Test
          graphql_name 'ContainerUpstreamTest'

          argument :id, ::Types::GlobalIDType[::VirtualRegistries::Container::Upstream],
            required: false,
            description: 'ID of the upstream registry to test. ' \
              'When provided, `groupPath`, `url`, `username`, and `password` are ignored.'

          private

          def available?(group)
            ::VirtualRegistries::Container.virtual_registry_available?(group, current_user)
          end

          def upstream_class
            ::VirtualRegistries::Container::Upstream
          end
        end
      end
    end
  end
end
