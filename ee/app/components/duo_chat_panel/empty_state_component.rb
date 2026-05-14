# frozen_string_literal: true

module DuoChatPanel
  class EmptyStateComponent < ViewComponent::Base
    include DuoChatPanel::DuoChatHelper

    DEFAULT_TRIAL_DURATION = 30

    def initialize(source:, user:)
      @source = source
      @user = user
    end

    private

    attr_reader :source, :user

    def data
      path = trial_path

      trial_duration =
        if path.nil?
          nil
        elsif ::Gitlab::Saas.feature_available?(:subscriptions_trials)
          GitlabSubscriptions::TrialDurationService.new.execute
        else
          DEFAULT_TRIAL_DURATION
        end

      {
        new_trial_path: path,
        trial_duration: trial_duration,
        namespace_type: source.is_a?(Group) ? source.type : nil,
        can_start_trial: path.present?.to_s,
        auto_expand: should_auto_expand_panel?(user, 'duo_panel_empty_state_auto_expanded').to_s
      }.compact
    end

    def trial_path
      if saas?
        saas_trial_path
      else
        Ability.allowed?(user, :update_gitlab_subscription) ? helpers.new_self_managed_trials_path : nil
      end
    end

    def saas_trial_path
      if source.nil? || source.root_ancestor.is_a?(::Namespaces::UserNamespace)
        helpers.new_trial_path(glm_source: 'gitlab.com', glm_content: 'chat panel')
      elsif user_can_start_trial_in_source?(source)
        helpers.new_trial_path(
          namespace_id: source.root_ancestor.id, glm_source: 'gitlab.com', glm_content: 'chat panel'
        )
      end
    end

    def user_can_start_trial_in_source?(source)
      root = source.root_ancestor

      root&.persisted? && root.has_free_or_no_subscription? &&
        Ability.allowed?(user, :admin_namespace, root)
    end
  end
end
