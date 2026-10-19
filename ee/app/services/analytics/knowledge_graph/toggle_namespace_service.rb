# frozen_string_literal: true

module Analytics
  module KnowledgeGraph
    class ToggleNamespaceService
      include Gitlab::Utils::StrongMemoize

      def initialize(group:, current_user:, enabled:)
        @group = group
        @current_user = current_user
        @enabled = enabled
      end

      def execute
        unless Ability.allowed?(@current_user, :update_knowledge_graph_setting, @group)
          return ServiceResponse.error(
            message: s_("Orbit|You don't have permission to update Orbit for this namespace."),
            reason: :forbidden
          )
        end

        @enabled ? enable_namespace : disable_namespace
      end

      private

      def enable_namespace
        return success_response if @group.knowledge_graph_enabled_namespace
        return trial_blocked_response unless turn_on.allowed?

        record = EnabledNamespace.new(root_namespace_id: @group.id)

        ApplicationRecord.transaction do
          record.save!

          if trial_flow?
            # CDot says the trial is active again, so the ended-trials cron must check this group again.
            @group.orbit_namespace_enrollment&.update!(trial_ended_at: nil) unless promo_add_on_active?
          elsif !promo_gate_enabled?
            ::Analytics::Orbit::NamespaceEnrollment.record_beta(@group.id)
          end
        end

        # The check above cached a nil association, and callers return this group.
        @group.reset_knowledge_graph_enabled_namespace
        success_response
      rescue ActiveRecord::RecordInvalid
        ServiceResponse.error(message: record.errors.full_messages.to_sentence)
      rescue ActiveRecord::RecordNotUnique # concurrent request already created the record
        @group.reset
        success_response
      rescue ::Gitlab::SubscriptionPortal::ProductTrialResponse::Error => e
        ::Gitlab::ErrorTracking.track_exception(e, gl_namespace_id: @group.id)
        ServiceResponse.error(
          message: s_('Orbit|GitLab Orbit is not available right now. Try again later.'),
          reason: :unavailable
        )
      end

      def turn_on
        OrbitTurnOn.new(group: @group, promo_add_on: promo_add_on_active?)
      end
      strong_memoize_attr :turn_on

      def promo_gate_enabled?
        ::Analytics::KnowledgeGraph::OrbitLicense.promo_gate_enabled?(@group)
      end
      strong_memoize_attr :promo_gate_enabled?

      def promo_add_on_active?
        ::Analytics::KnowledgeGraph::OrbitLicense.promo_add_on_active?(@group)
      end
      strong_memoize_attr :promo_add_on_active?

      def trial_flow?
        ::Analytics::Orbit::Trial.available_for?(@group)
      end
      strong_memoize_attr :trial_flow?

      def trial_blocked_response
        if turn_on.denial_reason == :trial_ended
          ServiceResponse.error(
            message: s_('Orbit|The Orbit trial for this group has ended. Add GitLab credits to turn Orbit on again.'),
            reason: :trial_ended
          )
        else
          ServiceResponse.error(
            message: s_('Orbit|Start a free trial to turn on Orbit for this group.'),
            reason: :trial_required
          )
        end
      end

      def disable_namespace
        record = @group.knowledge_graph_enabled_namespace
        return success_response unless record

        if record.destroy
          @group.reset_knowledge_graph_enabled_namespace
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
