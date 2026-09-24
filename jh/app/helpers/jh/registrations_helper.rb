# frozen_string_literal: true

module JH
  module RegistrationsHelper
    include PhoneRegistrationsHelper

    def signup_box_template
      phone_registration_enabled? ? 'devise/shared/swichable_signup_box' : 'devise/shared/signup_box'
    end
  end
end
