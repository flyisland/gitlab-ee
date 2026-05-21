# frozen_string_literal: true

module Users
  class SubscriptionSignupService < BaseService
    def initialize(current_user, params: {})
      @user = current_user
      @params = params.dup
    end

    def execute
      assign_attributes
      inject_validators

      if @user.save
        perform_troubleshooting_steps

        ServiceResponse.success(payload: payload)
      else
        ServiceResponse.error(message: user.errors.full_messages.join('. '), payload: payload)
      end
    end

    private

    attr_reader :user

    def perform_troubleshooting_steps
      # troubleshooting step we are performing to help diagnose https://gitlab.com/gitlab-org/gitlab/-/work_items/520090
      ::Onboarding.cache_onboarding_in_progress(user)
    end

    def payload
      { user: user }
    end

    def assign_attributes
      @user.assign_attributes(onboarding_in_progress: false, **user_params)
    end

    def user_params
      params.slice(
        :onboarding_status_joining_project,
        :onboarding_status_role,
        :onboarding_status_setup_for_company,
        :onboarding_status_registration_objective
      )
    end

    def inject_validators
      class << @user
        validates :onboarding_status_role, presence: true
        validates :onboarding_status_setup_for_company, inclusion: { in: [true, false], message: :blank }
      end
    end
  end
end
