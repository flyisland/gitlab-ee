# frozen_string_literal: true

module JH
  module SeatAlert
    module Namespace
      module BaseComponent
        extend ::Gitlab::Utils::Override

        private

        override :purchase_link
        def purchase_link
          return super unless ::Gitlab.com?

          helpers.group_usage_quotas_path(root_namespace)
        end
      end
    end
  end
end
