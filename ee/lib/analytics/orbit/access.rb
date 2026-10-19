# frozen_string_literal: true

module Analytics
  module Orbit
    class Access < Data.define(:state, :reason, :turn_on_denial_reason, :trial)
      STATES = %i[
        not_configured
        unlicensed
        trial_eligible
        trial_active
        trial_ended
        trial_not_eligible
        trial_status_unavailable
        licensed
      ].freeze

      REASONS = %i[
        free_plan
        no_license
        no_access
        trial_expired
        credits_exhausted
        plan
        promo_add_on
        beta
      ].freeze

      TURN_ON_DENIAL_REASONS = %i[forbidden trial_required trial_ended unavailable].freeze

      def self.for(group:, current_user:, trial_status:)
        Builder.new(group: group, current_user: current_user, trial_status: trial_status).build
      end

      class Builder
        include ::Gitlab::Utils::StrongMemoize

        def initialize(group:, current_user:, trial_status:)
          @group = group
          @current_user = current_user
          @trial_status = trial_status
        end

        def build
          Access.new(
            state: classification.first,
            reason: classification.last,
            turn_on_denial_reason: turn_on_denial_reason,
            trial: trial_object
          )
        end

        private

        attr_reader :group, :current_user, :trial_status

        def classification
          return [:not_configured, nil] unless service_configured?
          return [:unlicensed, unlicensed_reason] unless can_toggle?

          return [:licensed, :beta] if beta? && !promo_gate?
          return trial_classification if trial_flow?

          # Under the promo gate Orbit can stay on after access lapsed, only so the Owner can turn it off.
          return [:unlicensed, :no_access] if promo_gate? && !entitled?

          [:licensed, licensed_reason]
        end
        strong_memoize_attr :classification

        def licensed_reason
          return :promo_add_on if promo_add_on_active?
          return :beta if beta?

          :plan
        end

        def unlicensed_reason
          return :no_access if promo_gate?

          saas? ? :free_plan : :no_license
        end

        def trial_classification
          return [:trial_status_unavailable, nil] if trial_status == :unavailable

          cdot_classification
        end

        def cdot_classification
          return [:trial_active, nil] if trial_status.trial_active?
          return [:trial_ended, trial_ended_reason] if trial_status.trial_ended?
          return [:licensed, licensed_reason] unless can_start_trial?
          return [:trial_eligible, nil] if trial_status.state == :trial_eligible

          [:trial_not_eligible, nil]
        end

        # CDot zeroes the balance when a trial expires, so only the date tells an
        # expired trial apart from one that burned through its credits early.
        def trial_ended_reason
          expires_at = trial_status.trial_expires_at
          expires_at.present? && expires_at.past? ? :trial_expired : :credits_exhausted
        end

        def turn_on_denial_reason
          return if enabled?
          return :forbidden unless can_toggle?
          return :unavailable if trial_status == :unavailable

          ::Analytics::KnowledgeGraph::OrbitTurnOn
            .new(group: group, trial_status: trial_status, promo_add_on: promo_add_on_active?)
            .denial_reason
        end

        def trial_object
          trial_status unless trial_status == :unavailable
        end

        def enabled?
          group.knowledge_graph_enabled_namespace.present?
        end
        strong_memoize_attr :enabled?

        def service_configured?
          ::Analytics::KnowledgeGraph.service_configured?
        end

        def promo_add_on_active?
          ::Analytics::KnowledgeGraph::OrbitLicense.promo_add_on_active?(group)
        end
        strong_memoize_attr :promo_add_on_active?

        def entitled?
          ::Analytics::KnowledgeGraph::OrbitLicense.entitled?(group)
        end

        def promo_gate?
          ::Analytics::KnowledgeGraph::OrbitLicense.promo_gate_enabled?(group)
        end
        strong_memoize_attr :promo_gate?

        def beta?
          group.orbit_namespace_enrollment&.beta?
        end

        # read_orbit_trial already folds in the trial flag, tier eligibility, and the add-on.
        def trial_flow?
          ::Ability.allowed?(current_user, :read_orbit_trial, group)
        end

        def saas?
          ::Gitlab::Saas.feature_available?(:gitlab_com_subscriptions)
        end

        def can_toggle?
          ::Ability.allowed?(current_user, :update_knowledge_graph_setting, group)
        end

        def can_start_trial?
          ::Ability.allowed?(current_user, :start_orbit_trial, group)
        end
      end
    end
  end
end
