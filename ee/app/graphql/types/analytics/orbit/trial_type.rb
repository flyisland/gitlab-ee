# frozen_string_literal: true

module Types
  module Analytics
    module Orbit
      class TrialType < BaseObject
        graphql_name 'OrbitTrial'
        description 'Orbit trial of a top-level group, as reported by CustomersDot.'

        authorize :read_orbit_trial
        authorize_granular_token skip_reason: :parent_authorizes

        # The CDot response has no policy, so the group is the policy subject.
        Adapter = Struct.new(:trial, :group, keyword_init: true) do
          delegate :state, :trial_active?, :trial_ended?, :trial_expires_at, :credits_remaining, :credits_total,
            :offer_duration_days, :offer_credits, to: :trial

          def declarative_policy_subject
            group
          end
        end

        field :state, TrialStateEnum,
          null: false,
          description: 'State of the trial.',
          experiment: { milestone: '19.5' }

        field :expires_on, ::Types::DateType,
          null: true,
          description: 'Last day of the trial, in UTC. Null before a trial starts.',
          experiment: { milestone: '19.5' }

        field :credits, TrialCreditsType,
          null: true,
          method: :itself,
          description: 'Credits of the trial.',
          experiment: { milestone: '19.5' }

        field :offer, TrialOfferType,
          null: true,
          description: 'Terms of a new trial. Null unless the group can start one and CustomersDot sends valid terms.',
          experiment: { milestone: '19.6' }

        def state
          return :active if object.trial_active?
          return :ended if object.trial_ended?

          object.state == :trial_eligible ? :eligible : :not_eligible
        end

        # CDot sets expires_at to 23:59:59 UTC on the last day.
        def expires_on
          object.trial_expires_at&.utc&.to_date
        end

        def offer
          return unless state == :eligible

          object if object.offer_duration_days && object.offer_credits
        end
      end
    end
  end
end
