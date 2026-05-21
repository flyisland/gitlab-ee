# frozen_string_literal: true

module EE
  module SessionsHelper
    extend ::Gitlab::Utils::Override

    override :registration_path_params
    def registration_path_params(invite_email)
      params = super
      params[:from_sign_in] = true if invite_email.blank? && ::Gitlab::Saas.feature_available?(:onboarding)
      params
    end
  end
end
