# frozen_string_literal: true

module JH
  module PreferredLanguageSwitcher
    extend ActiveSupport::Concern
    extend ::Gitlab::Utils::Override

    private

    override :preferred_language
    def preferred_language
      default_preferred_language =
        ::Feature.enabled?(:qa_enforce_locale_to_en) ? 'en' : ::Gitlab::CurrentSettings.default_preferred_language

      # because will conflict with method helpers.cookies on ViewComponent, and invoke on jh Gitlab::DeviseFailure
      request.cookie_jar[:preferred_language].presence_in(::Gitlab::I18n.available_locales) ||
        selectable_language(marketing_site_language) ||
        selectable_language(browser_languages) ||
        default_preferred_language
    end

    def marketing_site_language
      return [] unless ::Gitlab::Saas.feature_available?(:marketing_site_language)

      locale = params[:glm_source]&.match(
        %r{\A#{::Gitlab.promo_host}|about.gitlab.com/([a-z]{2})-([a-z]{2})}i
      )&.captures

      return [] if locale.blank?

      [locale[0], "#{locale[0]}_#{locale[1]}"]
    end
  end
end
