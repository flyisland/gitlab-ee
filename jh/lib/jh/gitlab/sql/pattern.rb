# frozen_string_literal: true

module JH
  module Gitlab
    module SQL
      module Pattern
        extend ActiveSupport::Concern
        extend ::Gitlab::Utils::Override
        include Gitlab::SQL::Pattern

        class_methods do
          extend ::Gitlab::Utils::Override

          override :partial_matching?
          def partial_matching?(query, use_minimum_char_limit: true)
            super || ::Issue.contains_chinese?(query)
          end
        end
      end
    end
  end
end
