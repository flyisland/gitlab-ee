# frozen_string_literal: true

module Analytics
  module KnowledgeGraph
    class ToggleNamespaceService
      def initialize(group:, current_user:, enabled:)
        @group = group
        @current_user = current_user
        @enabled = enabled
      end

      def execute
        unless Ability.allowed?(@current_user, :update_knowledge_graph_setting, @group)
          return ServiceResponse.error(message: 'Not authorized', reason: :forbidden)
        end

        if @enabled
          enable_namespace
        else
          disable_namespace
        end
      end

      private

      def enable_namespace
        return success_response if @group.knowledge_graph_enabled_namespace

        record = EnabledNamespace.new(root_namespace_id: @group.id)

        if record.save
          success_response
        else
          ServiceResponse.error(message: record.errors.full_messages.to_sentence)
        end
      rescue ActiveRecord::RecordNotUnique # concurrent request already created the record
        @group.reset
        success_response
      end

      def disable_namespace
        record = @group.knowledge_graph_enabled_namespace
        return success_response unless record

        if record.destroy
          success_response
        else
          ServiceResponse.error(message: record.errors.full_messages.to_sentence)
        end
      end

      def success_response
        ServiceResponse.success(payload: { group: @group })
      end
    end
  end
end
