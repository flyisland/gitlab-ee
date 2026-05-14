# frozen_string_literal: true

module DuoChatPanel
  module DuoChatHelper
    private

    def saas?
      ::Gitlab::Saas.feature_available?(:gitlab_com_subscriptions)
    end

    def should_auto_expand_panel?(user, callout)
      return false unless user

      !user.dismissed_callout?(feature_name: callout)
    end
  end
end
