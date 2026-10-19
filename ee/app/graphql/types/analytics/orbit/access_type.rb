# frozen_string_literal: true

module Types
  module Analytics
    module Orbit
      class AccessType < BaseObject # rubocop:disable Graphql/AuthorizeTypes -- parent field authorizes
        graphql_name 'OrbitAccess'
        description 'Orbit access state of a group.'

        include ::Gitlab::Utils::StrongMemoize

        authorize_granular_token skip_reason: :parent_authorizes

        field :state, AccessStateEnum,
          null: false,
          description: 'Access state of the group for Orbit.',
          experiment: { milestone: '19.5' }

        field :reason, AccessReasonEnum,
          null: true,
          description: 'Cause of the access state when it has more than one cause. ' \
            'Null when the state has a single cause.',
          experiment: { milestone: '19.5' }

        field :turn_on_denial_reason, TurnOnDenialReasonEnum,
          null: true,
          description: 'Reason the user cannot turn Orbit on. Null when turning on is allowed or Orbit is already on.',
          experiment: { milestone: '19.5' }

        field :trial, TrialType,
          null: true,
          description: 'Orbit trial of the group. Null when the group is not in the trial flow.',
          experiment: { milestone: '19.5' }

        delegate :state, :reason, :turn_on_denial_reason, to: :access

        def trial
          TrialType::Adapter.new(trial: access.trial, group: object) if access.trial
        end

        private

        def access
          ::Analytics::Orbit::Access.for(group: object, current_user: current_user, trial_status: trial_status)
        end
        strong_memoize_attr :access

        def trial_status
          return unless ::Ability.allowed?(current_user, :read_orbit_trial, object)

          ::Analytics::Orbit::Trial.status_for(object)
        rescue ::Gitlab::SubscriptionPortal::ProductTrialResponse::Error => e
          ::Gitlab::ErrorTracking.track_exception(e, gl_namespace_id: object.id)
          :unavailable
        end
      end
    end
  end
end
