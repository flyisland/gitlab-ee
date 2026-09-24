# frozen_string_literal: true

module JH
  module AuthHelper
    extend ::Gitlab::Utils::Override

    JH_POPULAR_PROVIDERS = %w[github gitlab dingtalk alicloud cas3].freeze

    # WeCom sign-in only works for a member who has already bound their account
    # from their profile, so it sits after the providers anyone can use.
    TRAILING_PROVIDERS = %w[wecom].freeze

    override :enabled_button_based_providers
    def enabled_button_based_providers
      providers = super

      if ::Gitlab.com? && ::Gitlab.jh?
        providers = providers.sort_by do |provider|
          JH_POPULAR_PROVIDERS.index(provider) || JH_POPULAR_PROVIDERS.length
        end
      end

      (providers - TRAILING_PROVIDERS) + (providers & TRAILING_PROVIDERS)
    end

    override :popular_enabled_button_based_providers
    def popular_enabled_button_based_providers
      return super unless ::Gitlab.com? && ::Gitlab.jh?

      enabled_button_based_providers & JH_POPULAR_PROVIDERS
    end

    PROVIDERS_WITH_ICONS = %w[dingtalk wecom].freeze

    override :provider_has_builtin_icon?
    def provider_has_builtin_icon?(name)
      super || PROVIDERS_WITH_ICONS.include?(name.to_s)
    end

    SIGNUP_EXCLUDED_PROVIDERS = %w[wecom].freeze

    # WeCom hands back no trustworthy email address, so it cannot create an
    # account: a member binds WeCom to an account they already have. Upstream
    # already hides the button when `allow_single_sign_on` is a list without
    # `wecom`, but an instance that sets it to `true` offers every provider, and
    # the button would then lead nowhere.
    override :enabled_button_based_providers_for_signup
    def enabled_button_based_providers_for_signup
      super - SIGNUP_EXCLUDED_PROVIDERS
    end

    # The JH sign-up page offers every enabled provider rather than the
    # allow_single_sign_on subset upstream filters by. Keep that, and drop only
    # the providers that cannot create an account.
    def jh_signup_button_based_providers
      enabled_button_based_providers - SIGNUP_EXCLUDED_PROVIDERS
    end
  end
end
