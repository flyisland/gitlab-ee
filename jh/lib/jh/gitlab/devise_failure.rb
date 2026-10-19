# frozen_string_literal: true

module JH
  module Gitlab
    module DeviseFailure
      include ::PreferredLanguageSwitcher
      extend ::Gitlab::Utils::Override

      protected

      override :i18n_message

      def i18n_message(default = nil)
        message = warden_message || default

        ::Gitlab::I18n.with_locale(locale) do
          if invalid_phone_login?(message)
            phone_login_invalid_message
          elsif free_trial_ends?(message)
            block_free_trial_ends_message
          else
            super(default)
          end
        end
      end

      private

      def block_free_trial_ends_message
        s_('JH|FreeTrial|Your free trial of JiHu GitLab has expired. ' \
          'Please contact 400-088-8738 for offline purchase assistant.')
      end

      def free_trial_ends?(message, current_user = nil)
        return if message != :blocked || !::Gitlab.com?

        user = current_user || failure_user
        user&.blocked? && user.last_custom_attribute&.key == ::FreeTrial::BlockFreeTrialUserService::FREE_TRIAL_ENDS
      end

      def failure_user
        user_from_login || user_from_oauth
      end

      def user_from_login
        ::User.find_by_login(params&.dig('user', 'login'))
      end

      def user_from_oauth
        uid = request.env['omniauth.auth']&.dig('uid')
        provider = request.env['omniauth.auth']&.dig('provider')
        Identity.with_extern_uid(provider, uid).first&.user
      end

      def invalid_phone_login?(message)
        ::Gitlab.jh? &&
          ::Gitlab.com? &&
          !failure_user&.enterprise_user? &&
          [:invalid, :not_found_in_database].include?(message) &&
          ::Feature.enabled?(:phone_authenticatable)
      end

      def phone_login_invalid_message
        s_('JH|Your password is incorrect or this account doesn\'t ' \
          'exist. Please check and try again. Add country calling codes ' \
          'if your mobile phone number is outside the Chinese mainland.')
      end

      def locale
        preferred_language
      end
    end
  end
end
