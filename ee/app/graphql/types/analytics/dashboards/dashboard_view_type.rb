# frozen_string_literal: true

module Types
  module Analytics
    module Dashboards
      # rubocop:disable Graphql/AuthorizeTypes -- authorized by parent type
      class DashboardViewType < BaseObject
        graphql_name 'CustomizableDashboardView'
        description 'Represents a view that can be selected within a customizable dashboard.'

        authorize_granular_token skip_reason: :parent_authorizes

        field :title,
          type: GraphQL::Types::String,
          null: true,
          description: 'Title of the view.'

        field :panels,
          type: Types::Analytics::Dashboards::PanelType.connection_type,
          null: true,
          description: 'Panels shown when the view is selected.'
      end
      # rubocop:enable Graphql/AuthorizeTypes
    end
  end
end
