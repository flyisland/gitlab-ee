# frozen_string_literal: true

module JH
  module NamespacesHelper
    extend ::Gitlab::Utils::Override

    override :buy_additional_minutes_path
    def buy_additional_minutes_path(namespace)
      if defined?(current_user) && current_user&.require_email_skippable?
        profile_settings_url
      else
        super
      end
    end

    override :buy_storage_path
    def buy_storage_path(namespace)
      if defined?(current_user) && current_user&.require_email_skippable?
        profile_settings_url
      else
        ::Gitlab::Utils.add_url_parameters(
          ::Gitlab::Routing.url_helpers.subscription_portal_more_storage_url,
          gl_namespace_id: namespace.root_ancestor.id
        )
      end
    end

    def profile_settings_url
      ::Gitlab::Utils.add_url_parameters(
        user_settings_profile_path,
        redirected: true
      )
    end
  end
end
