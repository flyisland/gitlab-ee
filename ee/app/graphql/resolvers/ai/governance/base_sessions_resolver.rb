# frozen_string_literal: true

module Resolvers
  module Ai
    module Governance
      # Shared resolution for AI governance sessions. The group resolver adds `project_path`;
      # the project resolver omits it because the parent object fixes the project.
      class BaseSessionsResolver < ::Resolvers::BaseResolver
        type ::Types::Ai::Governance::SessionType.connection_type, null: true

        argument :id, ::Types::GlobalIDType[::Ai::Governance::Session],
          required: false,
          description: 'Global ID of the session.'

        argument :flow_type, GraphQL::Types::String,
          required: false,
          description: 'Filter by flow type.'

        argument :agent_class, ::Types::Ai::Governance::AgentClassEnum,
          required: false,
          description: 'Filter sessions by agent class. Defaults to all agent classes.'

        argument :session_started_after, ::Types::TimeType,
          required: false,
          description: 'Return sessions started at or after the timestamp.'

        argument :session_started_before, ::Types::TimeType,
          required: false,
          description: 'Return sessions started at or before the timestamp.'

        argument :triggered_by_user_id, ::Types::GlobalIDType[::User],
          required: false,
          description: 'Filter to sessions triggered by the user with the given global ID.'

        argument :not, ::Types::Ai::Governance::SessionNegatedFilterInput,
          required: false,
          description: 'Negated filter conditions.'

        # Sessions are read from ClickHouse only. Without it there is nothing to return yet;
        # a PostgreSQL path for self-managed instances follows separately.
        def resolve(**args)
          if args[:session_started_after] && args[:session_started_before] &&
              args[:session_started_after] > args[:session_started_before]
            raise Gitlab::Graphql::Errors::ArgumentError,
              'sessionStartedAfter must not be after sessionStartedBefore'
          end

          return ::Ai::Governance::Session.none unless feature_enabled? && click_house_enabled?

          ::Ai::Governance::Sessions::ClickHouseFinder.new(
            current_user: current_user,
            namespace: resolver_namespace,
            params: finder_params(args)
          ).execute
        end

        private

        def finder_params(args)
          {
            id: args[:id]&.model_id&.to_i,
            flow_type: args[:flow_type],
            agent_class: args[:agent_class],
            session_started_after: args[:session_started_after],
            session_started_before: args[:session_started_before],
            user_id: args[:triggered_by_user_id]&.model_id&.to_i,
            not: prepare_not_args(args[:not])
          }.compact
        end

        def resolver_namespace
          raise NotImplementedError
        end

        # Renames the negated user global ID to the `user_id` column the finder filters on.
        def prepare_not_args(not_arg)
          not_arg&.to_h&.tap do |not_hash|
            triggered_by_user_id = not_hash.delete(:triggered_by_user_id)
            not_hash[:user_id] = triggered_by_user_id.model_id.to_i if triggered_by_user_id
          end
        end

        def feature_enabled?
          ::Feature.enabled?(:ai_governance_sessions_api, object.root_ancestor)
        end

        def click_house_enabled?
          ::Gitlab::ClickHouse.globally_enabled_for_analytics?
        end
      end
    end
  end
end
