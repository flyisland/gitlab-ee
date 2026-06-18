# frozen_string_literal: true

module Types
  module Ai
    module DuoWorkflows
      class SessionArtifactNegatedFilterInput < ::Types::BaseInputObject
        graphql_name 'DuoWorkflowSessionArtifactNegatedFilterInput'
        description 'Negated filter arguments for Duo Agent Platform session artifacts.'

        argument :workflow_definition, GraphQL::Types::String,
          required: false,
          description: 'Exclude session artifacts with the workflow definition.'

        argument :project_path, GraphQL::Types::String,
          required: false,
          description: 'Exclude session artifacts belonging to the project full path.'
      end
    end
  end
end
