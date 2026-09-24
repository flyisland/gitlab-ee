# frozen_string_literal: true

module JH
  module API
    module Entities
      module WikiPage
        extend ActiveSupport::Concern

        prepended do
          include ContentValidationMessages
          include ContentValidationHelper

          expose :content, override: true, documentation: {
            type: 'string', example: 'Here is an instruction how to deploy this project.'
          } do |wiki_page, options|
            super_render = -> {
              if options[:render_html]
                render_wiki_content(
                  wiki_page,
                  ref: wiki_page.version.id,
                  current_user: options[:current_user]
                )
              else
                wiki_page.raw_content
              end
            }

            if ::ContentValidation::Setting.block_enabled?(wiki_page.wiki)
              state = ::ContentValidation::ContentBlockedState.find_by_wiki_page(wiki_page, wiki_page.version)
              if state.present?
                if options[:render_html]
                  content_blocked_plain_message(state)
                else
                  illegal_tips_with_appeal_email
                end
              else
                super_render.call
              end
            else
              super_render.call
            end
          end
        end
      end
    end
  end
end
