# frozen_string_literal: true

module Analytics
  module Orbit
    class StartTrialService
      include Gitlab::InternalEventsTracking

      def initialize(group:, current_user:)
        @group = group
        @current_user = current_user
      end

      def execute
        return error(:forbidden) unless Ability.allowed?(current_user, :start_orbit_trial, group)

        indexable = ::Analytics::KnowledgeGraph::EnabledNamespace.new(root_namespace_id: group.id)
        return error(:cannot_be_indexed, indexable.errors.full_messages.to_sentence) unless indexable.valid?

        started = client.start_product_trial(trial_type: Trial::TRIAL_TYPE, namespace_id: group.id)
        if started.error_code.in?(%i[ineligible not_found])
          return error(:ineligible, cdot_reason: started.error_message.presence || started.error_code.to_s)
        end

        # 201 and 409 both mean "a trial exists". Only the next read says if it is active.
        client.expire_product_trial_cache(trial_type: Trial::TRIAL_TYPE, namespace_id: group.id)
        NamespaceEnrollment.record_trial(group.id)

        return error(:trial_ended) unless Trial.status_for(group).trial_active?

        NamespaceEnrollment.convert_beta_to_trial(group.id)
        enable_orbit(new_trial: started.success?)
      rescue ::Gitlab::SubscriptionPortal::StartProductTrialResponse::Error,
        ::Gitlab::SubscriptionPortal::ProductTrialResponse::Error => e
        ::Gitlab::ErrorTracking.track_exception(e, gl_namespace_id: group.id)
        error(:unavailable)
      end

      private

      attr_reader :group, :current_user

      def enable_orbit(new_trial:)
        result = ::Analytics::KnowledgeGraph::ToggleNamespaceService
          .new(group: group, current_user: current_user, enabled: true).execute
        return error(:unavailable, result.message) if result.error?

        track_internal_event('orbit_trial_started', namespace: group, user: current_user) if new_trial
        ServiceResponse.success(payload: { group: group })
      end

      # CDot reasons are internal codes, so they go to the event and not to the user.
      def error(reason, message = nil, cdot_reason: nil)
        unless reason == :forbidden
          track_internal_event('orbit_trial_start_failed', namespace: group, user: current_user,
            additional_properties: { label: reason.to_s, property: cdot_reason }.compact)
        end

        ServiceResponse.error(message: message.presence || message_for(reason), reason: reason)
      end

      def message_for(reason)
        {
          forbidden: s_("Orbit|You don't have permission to start an Orbit trial for this group."),
          cannot_be_indexed: s_('Orbit|This group cannot be indexed.'),
          ineligible: s_('Orbit|This group is not eligible for a GitLab Orbit trial.'),
          trial_ended: s_('Orbit|Your GitLab Orbit trial has ended.'),
          unavailable: s_('Orbit|GitLab Orbit is not available right now. Try again later.')
        }.fetch(reason)
      end

      def client
        ::Gitlab::SubscriptionPortal::Client
      end
    end
  end
end
