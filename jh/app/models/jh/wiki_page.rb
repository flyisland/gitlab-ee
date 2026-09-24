# frozen_string_literal: true

module JH
  module WikiPage
    extend ActiveSupport::Concern
    extend ::Gitlab::Utils::Override

    override :human_title
    def human_title
      return super unless ::ContentValidation::Setting.content_validation_enable?

      content_block_state = ::ContentValidation::ContentBlockedState.find_by_wiki_page(self, version)
      return super if content_block_state.blank?

      s_("JH|ContentValidation|Illegal content")
    end
  end
end
