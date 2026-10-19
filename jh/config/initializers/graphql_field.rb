# frozen_string_literal: true

require "graphql"

module GraphQL
  class Schema
    class Member
      module HasFields
        def remove_field(name)
          own_fields.delete(name.to_s.camelize(:lower))
        end
      end
    end
  end
end
