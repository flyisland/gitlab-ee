# frozen_string_literal: true

module Onboarding
  class SubscriptionRegistration
    TRACKING_LABEL = 'subscription_registration'
    private_constant :TRACKING_LABEL

    # string methods

    def self.tracking_label
      TRACKING_LABEL
    end

    # internalization methods

    # predicate methods

    def self.read_from_stored_user_location?
      true
    end

    def self.preserve_stored_location?
      true
    end
  end
end
