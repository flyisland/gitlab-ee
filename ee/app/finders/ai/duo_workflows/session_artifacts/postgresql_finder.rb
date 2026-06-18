# frozen_string_literal: true

module Ai
  module DuoWorkflows
    module SessionArtifacts
      class PostgresqlFinder
        def initialize(namespace:, params: {})
          @namespace = namespace
          @params = params
        end

        def execute
          scope = if namespace.is_a?(::Namespaces::ProjectNamespace)
                    ::Ai::DuoWorkflows::SessionArtifact.for_project_namespace(namespace)
                  else
                    ::Ai::DuoWorkflows::SessionArtifact.in_namespace(namespace)
                  end

          scope
            .with_keyset_order
            .with_project
        end

        private

        attr_reader :namespace, :params
      end
    end
  end
end
