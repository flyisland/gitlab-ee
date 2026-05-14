# frozen_string_literal: true

module Resolvers
  module Analytics
    module CustomDashboards
      class DashboardsResolver < BaseResolver
        include Gitlab::Graphql::Authorize::AuthorizeResource

        authorize :read_custom_dashboard

        type Types::Analytics::CustomDashboards::DashboardType.connection_type, null: true

        argument :organization_id,
          ::Types::GlobalIDType[::Organizations::Organization],
          required: true,
          description: 'Organization ID to filter dashboards.'

        argument :namespace_id,
          ::Types::GlobalIDType[::Namespace],
          required: false,
          description: 'Filter by namespace.'

        argument :created_by_id,
          ::Types::GlobalIDType[::User],
          required: false,
          description: 'Filter by dashboard creator.'

        argument :search,
          GraphQL::Types::String,
          required: false,
          description: 'Filter dashboards by name.'

        def resolve(organization_id:, **filter_args)
          organization = authorized_find!(id: organization_id)

          params = build_params(filter_args)

          ::Analytics::CustomDashboards::DashboardsFinder.new(
            current_user,
            organization: organization,
            params: params
          ).execute
        end

        private

        def build_params(filter_args)
          {
            namespace_id: parse_gid(filter_args[:namespace_id]),
            created_by_id: parse_gid(filter_args[:created_by_id]),
            search: filter_args[:search]
          }.compact
        end

        def parse_gid(gid)
          return unless gid

          GitlabSchema.parse_gid(gid).model_id
        end
      end
    end
  end
end
