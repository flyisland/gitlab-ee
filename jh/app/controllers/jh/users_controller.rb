# frozen_string_literal: true

module JH
  module UsersController
    extend ActiveSupport::Concern
    extend ::Gitlab::Utils::Override
    include CheckPhoneAndCode

    prepended do
      skip_before_action :user, only: [:email_exists, :reset_password_token]

      feature_category :user_profile, [:email_exists, :reset_password_token]

      before_action only: [:email_exists] do
        check_rate_limit!(:email_exists, scope: request.ip)
      end

      urgency :high, [:email_exists]
    end

    def email_exists
      if ::Gitlab.jh? && ::Gitlab.com?
        render json: { exists: !!::User.find_by_any_email(params[:email]) }
      else
        render json: { error: s_('JH|You must be authorized to access this path.') }, status: :unauthorized
      end
    end

    def reset_password_token
      message = check_verification_code
      if message
        render json: { message: message }, status: :precondition_failed
      else
        user = ::UserDetail.find_by_phone(params[:phone]).user
        render json: { token: user.set_reset_password_token }
      end
    end
  end
end
