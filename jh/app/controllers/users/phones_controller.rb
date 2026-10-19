# frozen_string_literal: true

module Users
  class PhonesController < ApplicationController
    include CheckPhoneAndCode

    skip_before_action :enforce_phone_verification!
    skip_before_action :enforce_terms!
    skip_before_action :check_password_expiration
    skip_before_action :check_two_factor_requirement
    skip_before_action :require_email
    skip_before_action :onboarding_redirect # break onboarding and phone dead loop 304
    skip_before_action :authenticate_user!, only: [:exists] # forget password skip auth

    before_action -> { not_found unless ::Gitlab::RealNameSystem.enabled? }
    before_action :verify_code_received_by_phone, only: [:verify]

    layout 'minimal'

    feature_category :user_profile

    def show
      return if current_user.phone_required? && !current_user.phone_present?

      redirect_to root_path, notice: phone_verified_message
    end

    def verify
      return respond_422 if ::UserDetail.find_by_phone(user_params[:phone]).present?

      result = ::Users::UpdateService.new(current_user, user_params.merge(user: current_user)).execute

      if result[:status] == :success
        redirect_to users_sign_up_welcome_path, notice: phone_verified_message
      else
        flash[:alert] = s_('JH|RealName|Phone saved failed.')
        redirect_to action: :show
      end
    end

    def exists
      render json: { exists: ::UserDetail.by_encrypted_phone(params[:phone]).exists? }
    end

    private

    def verify_code_received_by_phone
      return respond_422 if current_user.phone_present?

      message = check_verification_code

      return unless message

      flash[:alert] = message

      redirect_to(action: :show) && return
    end

    def user_params
      @user_params ||= params.permit(:phone)
    end

    def phone_verified_message
      s_("JH|RealName|You have already verified your phone.")
    end
  end
end
