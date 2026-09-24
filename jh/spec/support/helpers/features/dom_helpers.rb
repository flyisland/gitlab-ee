# frozen_string_literal: true

require_relative '../../../../../spec/support/helpers/features/dom_helpers'

module JH
  module Features
    module DomHelpers
      extend ::Gitlab::Utils::Override

      override :page_breadcrumbs
      def page_breadcrumbs
        toggle_selector = '[data-testid=breadcrumb-links] button[aria-expanded=false]'

        # JH's wider logo can push leading breadcrumbs into the collapsed menu.
        # Expand it so Capybara's visible-link query includes all breadcrumbs.
        if page.has_css?(toggle_selector, wait: 0)
          find(toggle_selector).click
          find('[data-testid=breadcrumb-links] [data-testid=base-dropdown-menu]')
        end

        super
      end
    end
  end
end

::Features::DomHelpers.prepend_mod_with('Features::DomHelpers')
