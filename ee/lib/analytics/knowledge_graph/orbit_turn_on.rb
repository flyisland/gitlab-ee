# frozen_string_literal: true

module Analytics
  module KnowledgeGraph
    class OrbitTurnOn
      include ::Gitlab::Utils::StrongMemoize

      UNRESOLVED = Object.new
      private_constant :UNRESOLVED

      # Fetched lazily so a group with the add-on never calls CustomersDot.
      def initialize(group:, promo_add_on:, trial_status: UNRESOLVED)
        @group = group
        @promo_add_on = promo_add_on
        @given_trial_status = trial_status
      end

      def allowed?
        return true if promo_add_on

        if promo_gate_enabled?
          trial_flow? && trial_status.trial_active?
        else
          !trial_flow? || beta? || trial_status.trial_active?
        end
      end

      def denial_reason
        return if allowed?

        trial_flow? && trial_status.trial_ended? ? :trial_ended : :trial_required
      end

      private

      attr_reader :group, :promo_add_on

      def trial_status
        return @given_trial_status unless @given_trial_status.equal?(UNRESOLVED)

        ::Analytics::Orbit::Trial.status_for(group)
      end
      strong_memoize_attr :trial_status

      def promo_gate_enabled?
        OrbitLicense.promo_gate_enabled?(group)
      end
      strong_memoize_attr :promo_gate_enabled?

      def trial_flow?
        ::Analytics::Orbit::Trial.available_for?(group)
      end
      strong_memoize_attr :trial_flow?

      def beta?
        group.orbit_namespace_enrollment&.beta?
      end
      strong_memoize_attr :beta?
    end
  end
end
