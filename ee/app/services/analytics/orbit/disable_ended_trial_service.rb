# frozen_string_literal: true

module Analytics
  module Orbit
    class DisableEndedTrialService
      include Gitlab::InternalEventsTracking

      def initialize(enrollment:)
        @enrollment = enrollment
        @group = enrollment.namespace
      end

      def execute
        return ServiceResponse.error(message: 'Orbit trials are not available') unless trials_in_use?
        return ServiceResponse.error(message: 'Group has the Orbit promo add-on') if promo_add_on_active?
        return ServiceResponse.error(message: 'Trial has not ended') unless Trial.status_for(group).trial_ended?
        return ServiceResponse.error(message: 'Orbit is already off') unless disable_orbit

        track_internal_event('orbit_trial_ended', namespace: group)
        ServiceResponse.success
      rescue ::Gitlab::SubscriptionPortal::ProductTrialResponse::UnavailableError
        raise
      rescue ::Gitlab::SubscriptionPortal::ProductTrialResponse::Error => e
        raise if e.cdot_status == 429

        ::Gitlab::ErrorTracking.track_exception(e, gl_namespace_id: group.id)
        ServiceResponse.error(message: e.message)
      end

      private

      attr_reader :enrollment, :group

      # Under the promo gate, a trial row gives access, so it must end also when orbit_trial is off.
      def trials_in_use?
        Trial.available_for?(group) || ::Analytics::KnowledgeGraph::OrbitLicense.promo_gate_enabled?(group)
      end

      def promo_add_on_active?
        ::Analytics::KnowledgeGraph::OrbitLicense.promo_add_on_active?(group)
      end

      # trial_ended_at is when GitLab turned Orbit off, which can be later than the trial end in CDot.
      def disable_orbit
        ApplicationRecord.transaction do
          deleted_count = ::Analytics::KnowledgeGraph::EnabledNamespace.for_root_namespace_id(group.id).delete_all
          next false if deleted_count == 0

          enrollment.update!(trial_ended_at: Time.current)
        end
      end
    end
  end
end
