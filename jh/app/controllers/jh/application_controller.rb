# frozen_string_literal: true

module JH
  module ApplicationController
    extend ActiveSupport::Concern
    extend ::Gitlab::Utils::Override
    include SafeFormatHelper
    include ::Users::IdentityVerificationHelper
    include Gitlab::DeviseFailure

    prepended do
      include ::Gitlab::HighAvailabilityChecker

      before_action :validate_user_service_ticket!
      before_action :enforce_phone_verification!, if: :should_enforce_phone_verification?
      before_action :assign_account_information
      before_action :prohibit_access_for_blocked_user!, unless: :allow_access_for_blocked_user?
      helper_method :gitee_import_enabled?
      skip_before_action :onboarding_redirect, if: :devise_controller?
      before_action :validate_free_license_ha!
    end

    override :require_email
    def require_email
      return if devise_controller?
      return unless user_with_temp_email?

      if current_user.require_email_skippable?
        flash[:notice] =
          safe_format(s_('JH|Please complete your profile with email address at %{url} before %{expires_at}'),
            url: helpers.link_to(s_('JH|Profile Settings'), user_settings_profile_path),
            expires_at: current_user.phone_registration_experience_expires_at.strftime('%F %H:%M %:z'))
      else
        super
      end
    end

    override :check_password_expiration
    def check_password_expiration
      return if session[:impersonator_id] || !current_user&.allow_password_authentication?

      if current_user&.jh_password_expired?
        redirect_to new_user_settings_password_path, notice: s_('JH|Your password has expired.')
      end

      redirect_to new_user_settings_password_path if current_user&.password_expired?
    end

    def gitee_import_enabled?
      ::Gitlab::CurrentSettings.import_sources.include?('gitee')
    end

    override :route_not_found
    def route_not_found
      return super unless ::Gitlab.com?
      return super if ::Gitlab.hk?

      if current_user || browser.bot.search_engine?
        not_found
      else
        store_location_for(:user, request.fullpath) unless request.xhr?

        unauthorized!
      end
    end

    def should_redirect_to_home_page?
      ::Gitlab.com? && !::Gitlab.hk? && !user_signed_in? && ::Gitlab::CurrentSettings.home_page_url.present?
    end

    def validate_user_service_ticket!
      user = current_user
      return unless user && session[:service_tickets]

      valid = session[:service_tickets].all? do |provider, ticket|
        ::Gitlab::Auth::OAuth::Session.valid?(provider, ticket)
      end

      return if valid

      session[:service_tickets] = nil
      sign_out user
      redirect_to new_user_session_path
    end

    private

    def validate_free_license_ha!
      render_402_ha_unavailable if should_block_instance?
    end

    def prohibit_access_for_blocked_user!
      redirect_to_sign_in_with_blocked_message if current_user&.state == 'blocked'
    end

    def allow_access_for_blocked_user?
      return true if devise_controller? || oauth_request?

      false
    end

    def oauth_request?
      request.path.start_with?('/oauth')
    end

    def unauthorized!
      render_401
    end

    def render_401
      respond_to do |format|
        format.html { render template: "errors/unauthorized", formats: :html, layout: "errors", status: :unauthorized }
        format.any { head :unauthorized }
      end
    end

    def render_402_ha_unavailable
      respond_to do |format|
        format.html do
          render(
            template: "errors/ha_unavailable",
            formats: :html,
            layout: "errors",
            status: :payment_required
          )
        end
        format.any { head :payment_required }
      end
    end

    def user_with_temp_email?
      current_user && current_user.temp_oauth_email? && session[:impersonator_id].nil?
    end

    def enforce_phone_verification!
      return unless current_user
      return unless current_user.phone_required?
      return if current_user.phone_present?

      message = s_("JH|RealName|Please verify your phone before continuing.")

      if sessionless_user?
        access_denied!(message)
      else
        redirect_to phone_path, status: :found
      end
    end

    def should_enforce_phone_verification?
      return false unless ::Gitlab::RealNameSystem.enabled?

      html_request? && !devise_controller?
    end

    def assign_account_information
      return unless current_user && ::Gitlab.com?

      suspension_data = account_suspension_data
      return unless suspension_data

      gon.jh_account_suspension = suspension_data
    end

    def account_suspension_data
      reminder_data = current_user.custom_attributes.by_key(::JH::User::FREE_TRIAL_LEFT_DAYS).first
      return unless reminder_data.present?

      duration = ::FreeTrial::ScanFreeTrialUserService::JH_FREE_TRIAL_BLOCK_DAY
      trial_used = duration - reminder_data.value.to_i

      billing_path = ::Gitlab::Utils.append_path(::Gitlab.config.gitlab.relative_url_root,
        '/-/subscriptions/new?source=account-suspension-card')

      { duration: duration, trial_used: trial_used, billing_path: billing_path }
    end
  end
end
