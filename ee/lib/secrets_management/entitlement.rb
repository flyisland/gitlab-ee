# frozen_string_literal: true

module SecretsManagement
  # Read-only value object describing the Secrets Manager entitlement state
  # for a top-level group (or instance). Resolved from CDot for SaaS and
  # from the local `GitlabSubscriptions::AddOnPurchase` mirror on
  # self-managed installs. No DB, no persistence, no state machine -- this
  # PORO observes, it does not transition.
  class Entitlement < Data.define(
    :state,
    :blocked_reason,
    :trial_started_at,
    :trial_expires_at,
    :credits_remaining,
    :credits_total,
    :on_demand_enabled
  )
    STATES = %i[trial_eligible trial paid offline_paid blocked ineligible].freeze
    BLOCKED_REASONS = %i[
      trial_expired
      credits_exhausted
      on_demand_disabled
      grace
      subscription_grace_period_expired
    ].freeze

    # Paid-deactivation grace only; trial expiry is a hard cutoff.
    # Window: days 0-29 of the grace period are read-only
    # (`blocked_reason: :grace`); day 30 flips to
    # `blocked_reason: :subscription_grace_period_expired` and the
    # enforcement layer's full lockout applies.
    GRACE_DAYS = 30

    def self.for(namespace, user: nil)
      Resolver.new(namespace, user: user).resolve
    end

    # Entitlement is only meaningful for top-level groups: a personal
    # namespace's `root_ancestor` is itself (not a Group), so it maps to
    # instance-level entitlement (nil). `namespace` is any Group or Project.
    # Shared by callers that need to resolve the entitlement-relevant
    # namespace for a Group/Project before calling `.for`.
    def self.root_namespace_for(namespace)
      return unless namespace

      root = namespace.root_ancestor
      root.is_a?(::Group) ? root : nil
    end

    # Only `state` is required; every other field defaults to nil so that
    # state-specific constructions (e.g. `:ineligible`) don't have to spell
    # out inapplicable trial / paid fields. `state` and `blocked_reason` are
    # enforced against `STATES` / `BLOCKED_REASONS` so the constants are a
    # contract rather than documentation.
    def initialize(
      state:,
      blocked_reason: nil,
      trial_started_at: nil,
      trial_expires_at: nil,
      credits_remaining: nil,
      credits_total: nil,
      on_demand_enabled: nil
    )
      validate_state!(state)
      validate_blocked_reason!(state, blocked_reason)
      super
    end

    def permits_writes?
      %i[trial paid offline_paid].include?(state)
    end

    def permits_access?
      %i[trial_eligible trial paid offline_paid].include?(state)
    end

    # Broader than `permits_access?`: `blocked` still permits reads, only `:ineligible` denies them.
    # Used by the UI/API ability layer; the stricter CI pipeline JWT gate uses
    # `permits_ci_read?` instead (see below).
    def permits_read?
      permits_access? || state == :blocked
    end

    def in_grace?
      state == :blocked && blocked_reason == :grace
    end

    # Narrower than `permits_read?`: only the `grace` window permits CI secret reads,
    # every other `blocked_reason` denies them. UI/API intentionally stays on the
    # broader `permits_read?` -- this is CI-pipeline-JWT-specific.
    def permits_ci_read?
      permits_access? || in_grace?
    end

    # Structured reason a write was denied, so callers can surface it
    # without re-querying the resolver. `nil` when writes are permitted.
    # `:blocked` carries its own (always-present) `blocked_reason`;
    # `:trial_eligible` is a state, not a blocked reason, so it maps to
    # `:trial_required` (the actionable reason from the caller's
    # perspective). Anything else left after `permits_writes?` is
    # `:ineligible`. Every branch returns a value from
    # `WriteActionDenialReasonEnum::VALUES`.
    def write_action_denial_reason
      return if permits_writes?

      { blocked: blocked_reason, trial_eligible: :trial_required }.fetch(state, :ineligible)
    end

    private

    def validate_state!(state)
      return if STATES.include?(state)

      raise ArgumentError, "Unknown state: #{state.inspect} (expected one of #{STATES.inspect})"
    end

    # `blocked_reason` is required when `state` is `:blocked` -- this is
    # what lets `write_action_denial_reason` avoid ever falling back to the
    # raw `:blocked` state, which isn't a valid `WriteActionDenialReasonEnum`
    # value.
    def validate_blocked_reason!(state, blocked_reason)
      if blocked_reason.nil?
        return unless state == :blocked

        raise ArgumentError,
          "blocked_reason is required when state is :blocked (expected one of #{BLOCKED_REASONS.inspect})"
      end

      return if BLOCKED_REASONS.include?(blocked_reason)

      raise ArgumentError,
        "Unknown blocked_reason: #{blocked_reason.inspect} (expected one of #{BLOCKED_REASONS.inspect})"
    end
  end
end
