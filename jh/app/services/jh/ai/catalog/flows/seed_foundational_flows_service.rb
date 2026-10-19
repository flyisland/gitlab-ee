# frozen_string_literal: true

module JH
  module Ai
    module Catalog
      module Flows
        module SeedFoundationalFlowsService
          extend ::Gitlab::Utils::Override

          private

          override :save_item
          def save_item(item)
            # Reuse the loaded organization instead of querying it during each item's validation.
            item.organization = default_organization

            super
          end
        end
      end
    end
  end
end
