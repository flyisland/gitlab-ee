# frozen_string_literal: true

module Resolvers
  module Analytics
    module Orbit
      class NamespaceResolver < BaseResolver
        type ::Types::Analytics::Orbit::NamespaceType, null: true

        def resolve
          object if ::Analytics::KnowledgeGraph.accessible_for?(current_user)
        end
      end
    end
  end
end
