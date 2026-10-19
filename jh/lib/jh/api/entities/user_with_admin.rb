# frozen_string_literal: true

module JH
  module API
    module Entities
      module UserWithAdmin
        extend ActiveSupport::Concern

        prepended do
          expose :preferred_language
        end
      end
    end
  end
end
