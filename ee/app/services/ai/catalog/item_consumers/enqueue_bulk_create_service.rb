# frozen_string_literal: true

module Ai
  module Catalog
    module ItemConsumers
      class EnqueueBulkCreateService
        include Gitlab::Utils::StrongMemoize

        def initialize(current_user:, item:, project_ids:, trigger_types: nil, trigger_filter: nil)
          @current_user = current_user
          @item = item
          @project_ids = GitlabSchema.parse_gids(project_ids, expected_type: ::Project).map(&:model_id).uniq
          @trigger_types = trigger_types
          @trigger_filter = trigger_filter
        end

        def execute
          return error(foundational_item_message) if item.foundational? && !item.third_party_flow?
          return error(trigger_types_required_message) if should_have_trigger_types? && trigger_types.blank?
          return error(trigger_types_not_supported_message) if !should_have_trigger_types? && trigger_types.present?
          return error(trigger_filter_not_supported_message) if !should_have_trigger_types? && trigger_filter.present?
          return error(projects_not_available_message) unless all_projects_exist_and_authorized?
          return error(organization_mismatch_message) unless all_projects_in_item_organization?

          Gitlab::ApplicationContext.with_context(organization: item.organization) do
            BulkCreateWorker.perform_async(
              current_user.id,
              item.id,
              projects.map(&:id),
              worker_params
            )
          end

          ServiceResponse.success
        end

        private

        attr_reader :current_user, :item, :project_ids, :trigger_types, :trigger_filter

        def worker_params
          { 'trigger_types' => trigger_types, 'trigger_filter' => trigger_filter }.compact
        end

        strong_memoize_attr def projects
          Project.id_in(project_ids).with_project_setting
        end

        def should_have_trigger_types?
          item.flow? || item.third_party_flow?
        end

        def all_projects_exist_and_authorized?
          return false unless projects.size == project_ids.size

          ::Preloaders::ProjectPolicyPreloader.new(projects, current_user).execute

          DeclarativePolicy.user_scope do
            projects.all? { |project| allowed_for_project?(project) }
          end
        end

        def all_projects_in_item_organization?
          projects.all? { |project| project.organization_id == item.organization_id }
        end

        def allowed_for_project?(project)
          if item.agent?
            Ability.allowed?(current_user, :create_ai_catalog_agent_item_consumer, project)
          elsif item.flow?
            Ability.allowed?(current_user, :create_ai_catalog_flow_item_consumer, project)
          elsif item.third_party_flow?
            Ability.allowed?(current_user, :create_ai_catalog_third_party_flow_item_consumer, project)
          else
            raise ArgumentError, "Unsupported item type: #{item.item_type}"
          end
        end

        def error(message)
          ServiceResponse.error(message:)
        end

        def foundational_item_message
          s_('AICatalog|Foundational agents and flows must be enabled in the Admin area or group settings.')
        end

        def trigger_types_required_message
          s_('AICatalog|Trigger types are required for flows.')
        end

        def trigger_types_not_supported_message
          s_('AICatalog|Trigger types are not supported for this item type.')
        end

        def trigger_filter_not_supported_message
          s_('AICatalog|Trigger filters are not supported for this item type.')
        end

        def projects_not_available_message
          s_('AICatalog|One or more projects not found, or you do not have permission to ' \
            'enable this item in the project.')
        end

        def organization_mismatch_message
          s_('AICatalog|All projects must belong to the same organization as the agent or flow.')
        end
      end
    end
  end
end
