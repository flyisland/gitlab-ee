# frozen_string_literal: true

module Security
  class VAC
    def self.enabled?(actor)
      feature_enabled = Feature.enabled?(:vulnerabilities_across_contexts, actor)
      # Fall back to checking the Feature Flag if we're not handling a Project or we're not on Dedicated.
      return feature_enabled unless actor.is_a?(Project) && Gitlab::CurrentSettings.gitlab_dedicated_instance?

      feature_enabled || Gitlab::CurrentSettings.vac_project_ids.include?(actor.id)
    end

    def self.disabled?(actor)
      !enabled?(actor)
    end
  end
end
