# frozen_string_literal: true

module EE
  module Autocomplete # rubocop:disable Gitlab/BoundedContexts -- FOSS finder is not bounded to a context
    module UsersFinder
      extend ::Gitlab::Utils::Override
      include ::Gitlab::Utils::StrongMemoize

      attr_reader :include_service_accounts_for_trigger_events, :preload_flow_triggers

      override :initialize
      def initialize(params:, current_user:, project:, group:)
        super
        @include_service_accounts_for_trigger_events = params[:include_service_accounts_for_trigger_events]
        @preload_flow_triggers = params.fetch(:preload_flow_triggers, false)
      end

      private

      override :project_users
      def project_users
        users = super

        if apply_duo_service_accounts_filter?(project)
          event_type_ids_to_hide = ::Ai::FlowTrigger::EVENT_TYPES.values - include_service_accounts_for_trigger_events
          users = users.without_duo_flows_service_accounts(project, event_type_ids_to_hide)
        end

        if project.ai_review_merge_request_allowed?(current_user)
          duo_code_review_bot = ::Users::Internal.in_organization(current_user.organization_id).duo_code_review_bot
          users = users.union_with_user(duo_code_review_bot)
        end

        users
      end

      override :associations_to_preload
      def associations_to_preload
        associations = super
        associations << :ai_flow_triggers if preload_flow_triggers
        associations
      end

      def apply_duo_service_accounts_filter?(project)
        return false if project.nil?
        return false if include_service_accounts_for_trigger_events.nil?

        ::Feature.enabled?(:remove_duo_flow_service_accounts_from_autocomplete_query, project)
      end
    end
  end
end
