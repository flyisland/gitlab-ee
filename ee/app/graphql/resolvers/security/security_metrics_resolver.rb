# frozen_string_literal: true

#
# This resolver is a WIP and part of ongoing work for the Security Dashboard Project (https://gitlab.com/groups/gitlab-org/-/epics/16517)
#
module Resolvers
  module Security
    class SecurityMetricsResolver < BaseResolver
      include Gitlab::Utils::StrongMemoize
      include Gitlab::Graphql::Authorize::AuthorizeResource

      # A sentinel value used when filters resolve to no matching projects.
      # No real project has ID 0, so an ES terms query with this value
      # will match zero documents, correctly returning empty results.
      EMPTY_PROJECT_IDS_SENTINEL = [0].freeze

      type Types::Security::SecurityMetricsType, null: true

      argument :project_id, [GraphQL::Types::ID],
        required: false,
        description: 'Filter by project IDs in a group. This argument is ignored when we are querying for a project.'

      argument :report_type, [Types::VulnerabilityReportTypeEnum],
        required: false,
        description: 'Filter by report types.'

      argument :security_attributes_filters, [Types::Security::AttributeFilterInputType],
        required: false,
        experiment: { milestone: '18.8' },
        description: 'Filter by security attributes.'

      argument :tracked_ref_ids, [::Types::GlobalIDType[::Security::ProjectTrackedContext]],
        required: false,
        experiment: { milestone: '18.11' },
        description: 'Filter by tracked ref IDs. ' \
          'This argument is ignored when querying for a group. ' \
          'To use this argument, you must have advanced search configured, ' \
          'advanced vulnerability management set up and ' \
          '`vulnerabilities_across_contexts` feature flag enabled.'

      def resolve(**args)
        return unless Ability.allowed?(current_user, :read_security_resource, object)

        return unless object.is_a?(Project) || object.is_a?(Group)

        apply_project_id_filters(args) if object.is_a?(Group)

        context[:report_type] = args[:report_type] if args[:report_type].present?
        if object.is_a?(Project) && args[:tracked_ref_ids].present? &&
            ::Security::VAC.enabled?(object)
          context[:tracked_ref_ids] = args[:tracked_ref_ids].map(&:model_id)
        end

        object
      end

      private

      def apply_project_id_filters(args)
        explicit_project_ids = parse_project_ids(args[:project_id])
        attribute_project_ids = resolve_attribute_project_ids(args[:security_attributes_filters])

        resolved_ids = if explicit_project_ids && attribute_project_ids
                         explicit_project_ids & attribute_project_ids
                       elsif attribute_project_ids
                         attribute_project_ids
                       elsif explicit_project_ids
                         explicit_project_ids
                       end

        return unless resolved_ids

        # When filters resolve to an empty set, use a sentinel to ensure
        # downstream ES queries return zero results instead of all results.
        context[:project_id] = resolved_ids.empty? ? EMPTY_PROJECT_IDS_SENTINEL : resolved_ids
      end

      # Accepts both GID format and raw numeric strings. The FE project token sends numeric IDs, while GraphQL
      # API consumers may use the standard GID format.
      def parse_project_ids(gids)
        return unless gids.present?

        gids.filter_map do |gid|
          GitlabSchema.parse_gid(gid, expected_type: ::Project).model_id.to_i
        rescue Gitlab::Graphql::Errors::ArgumentError
          Integer(gid, 10, exception: false)
        end
      end

      def resolve_attribute_project_ids(filters)
        return unless filters.present?

        result = ::Security::Dashboard::SecurityAttributesProjectFilterService.new(
          namespace: object,
          attribute_filters: filters
        ).execute

        result[:project_ids] if result[:status] == :success
      end
    end
  end
end
