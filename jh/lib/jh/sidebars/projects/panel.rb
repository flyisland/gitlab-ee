# frozen_string_literal: true

module JH
  module Sidebars
    module Projects
      module Panel
        extend ::Gitlab::Utils::Override

        ALWAYS_HIDDEN_INTEGRATION_MENUS = %w[Ones Zentao].freeze

        override :configure_menus
        def configure_menus
          super

          return unless need_remove_external_issue_tracker?

          remove_menu(::Sidebars::Projects::Menus::ExternalIssueTrackerMenu)
        end

        private

        override :third_party_wiki_menu
        def third_party_wiki_menu
          wiki_menu_list = [::Sidebars::Projects::Menus::ConfluenceMenu, ::Sidebars::Projects::Menus::ShimoMenu]

          wiki_menu_list.find { |wiki_menu| wiki_menu.new(context).render? }
        end

        def need_remove_external_issue_tracker?
          menu = ::Sidebars::Projects::Menus::IssuesMenu.new(context)

          menu.show_ligaai_menu_items? ||
            ALWAYS_HIDDEN_INTEGRATION_MENUS.any? do |m|
              context.project.external_issue_tracker.is_a?("::Integrations::#{m}".constantize)
            end
        end
      end
    end
  end
end
