# frozen_string_literal: true

module JH
  module ApplicationHelper
    extend ActiveSupport::Concern
    extend ::Gitlab::Utils::Override

    override :support_url
    def support_url
      ::Gitlab::CurrentSettings.current_application_settings.help_page_support_url.presence || "#{promo_url}/support/"
    end

    def render_ee(partial, locals = {})
      keys = locals.keys
      render template: find_ee_template(partial, keys), locals: locals
    end

    def find_ee_template(name, keys = [])
      prefixes = [] # So don't create extra [] garbage

      if ee_lookup_context.exists?(name, prefixes, true)
        ee_lookup_context.find(name, prefixes, true, keys)
      else
        ee_lookup_context.find(name, prefixes, false, keys)
      end
    end

    def ee_lookup_context
      @ee_lookup_context ||= fetch_lookup_context(::Gitlab.extensions.last)
    end

    override :ce_lookup_context
    def ce_lookup_context
      @ce_lookup_context ||= fetch_lookup_context(::Gitlab.extensions.reverse)
    end

    override :page_class
    def page_class
      super + jh_page_class
    end

    # Override subscription route helper method
    def buy_minutes_subscriptions_url(*args)
      if ::Feature.enabled?(:jh_new_purchase_flow)
        super
      else
        ::Gitlab::Routing.url_helpers.subscription_portal_more_minutes_url
      end
    end

    def buy_minutes_subscriptions_path(*args)
      if ::Feature.enabled?(:jh_new_purchase_flow)
        super
      else
        ::Gitlab::Routing.url_helpers.subscription_portal_more_minutes_url
      end
    end

    private

    def fetch_lookup_context(folders)
      raise 'folders should not be blank' if folders.blank?

      folder_paths = Array(folders).map { |folder| Rails.root.join(folder).to_s }
      view_paths = lookup_context.view_paths.paths.reject do |resolver|
        resolver.to_path.start_with?(*folder_paths)
      end

      ActionView::LookupContext.new(view_paths)
    end

    def jh_page_class
      class_names = ["jh-page-wrapper"]
      class_names << "jh-saas-page-wrapper" if ::Gitlab.com?
      class_names << "has-global-footer" if ::Gitlab.com? && !::Gitlab.hk?
      class_names
    end
  end
end
