# frozen_string_literal: true

module Onboarding
  class SubscriptionSmRegistration
    TRACKING_LABEL = 'subscription_sm_registration'
    private_constant :TRACKING_LABEL

    def self.unification_enabled?
      ::Onboarding.enabled? && ::Feature.enabled?(:subscription_sm_unification, :instance)
    end

    def self.tracking_label
      TRACKING_LABEL
    end

    def self.get_started_subtext
      s_('InProductMarketing|Create a GitLab account to purchase the Premium tier of GitLab Self-Managed.')
    end

    def self.read_from_stored_user_location?
      true
    end

    def self.preserve_stored_location?
      true
    end
  end
end
