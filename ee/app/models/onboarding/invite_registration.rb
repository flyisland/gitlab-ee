# frozen_string_literal: true

module Onboarding
  class InviteRegistration
    PRODUCT_INTERACTION = 'Invited User'
    private_constant :PRODUCT_INTERACTION
    TRACKING_LABEL = 'invite_registration'
    private_constant :TRACKING_LABEL

    # string methods

    def self.tracking_label
      TRACKING_LABEL
    end

    def self.product_interaction
      PRODUCT_INTERACTION
    end

    # internalization methods

    def self.get_started_subtext
      nil
    end

    # predicate methods

    def self.read_from_stored_user_location?
      false
    end

    def self.preserve_stored_location?
      false
    end

    def self.unification_enabled?
      false
    end
  end
end
