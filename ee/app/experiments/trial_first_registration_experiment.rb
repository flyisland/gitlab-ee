# frozen_string_literal: true

class TrialFirstRegistrationExperiment < ApplicationExperiment
  class CachedControlRollout < Gitlab::ExperimentFeatureRollout
    extend ::Gitlab::Utils::Override

    override :resolve
    def resolve
      validate!

      # Override to ensure control assignments are cached.
      # The default GLEX Rollout#resolve returns nil for control, which prevents
      # cache.write from being called. By returning a non-nil value (:control),
      # we ensure the assignment is persisted in cache, enabling only_assigned: true
      # to find and track control variant assignments.
      # See: https://gitlab.com/gitlab-org/ruby/gems/gitlab-experiment/-/blob/main/lib/gitlab/experiment/rollout.rb#L49
      execute_assignment
    end

    private

    override :execute_assignment
    def execute_assignment
      # When a variant is assigned, super returns the variant name (non-nil).
      # When control is assigned, super returns nil.
      # We convert nil to :control so the cache receives a non-nil value,
      # which triggers cache.write in gitlab-experiment's cached_variant method.
      # This ensures control assignments are persisted in cache, allowing
      # only_assigned: true to find the assignment and properly execute tracking and be seen as assigned.
      # See: https://gitlab.com/gitlab-org/ruby/gems/gitlab-experiment/-/blob/main/lib/gitlab/experiment/cache.rb#L46
      super.presence || :control
    end
  end

  control
  variant(:candidate)

  default_rollout CachedControlRollout

  private

  def control_behavior; end
  def candidate_behavior; end
end
