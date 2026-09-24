# frozen_string_literal: true

module JH
  module Users
    module IdentityVerificationHelper
      extend ::Gitlab::Utils::Override
      include Gitlab::DeviseFailure

      override :pipl_restricted_country?
      def pipl_restricted_country?(_)
        return super if Rails.env.test?

        false
      end

      def redirect_to_sign_in_with_blocked_message
        rejection_message = if free_trial_ends?(:blocked, current_user)
                              block_free_trial_ends_message
                            else
                              ::Gitlab::Auth::UserAccessDeniedReason.new(current_user).rejection_message
                            end

        sign_out current_user
        redirect_to new_user_session_path, alert: rejection_message
      end
    end
  end
end
