# frozen_string_literal: true

module DuoChatPanel
  class Component < ViewComponent::Base
    def initialize(user:, project:, group:, controller_name: nil)
      @user = user
      @project = project
      @group = group
      @controller_name = controller_name
    end

    def render?
      component_instance.present?
    end

    private

    attr_reader :user, :project, :group, :controller_name

    def component_instance
      @component_instance ||=
        if show_chat?
          ChatComponent.new(user: user, project: project, group: group, controller_name: controller_name)
        elsif show_trial_expired?
          TrialExpiredComponent.new(source: project || group, user: user)
        elsif show_empty_state?
          EmptyStateComponent.new(source: project || group, user: user)
        end
    end

    def show_chat?
      ::Gitlab::Llm::TanukiBot.new(user: user).show_duo_entry_point?
    end

    def show_trial_expired?
      namespace = (project || group)&.root_ancestor
      return false unless namespace

      GitlabSubscriptions::Trials.free_plan_expired?(namespace)
    end

    def show_empty_state?
      user && !::Gitlab::CurrentSettings.duo_never_on?
    end
  end
end
