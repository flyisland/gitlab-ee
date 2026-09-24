# frozen_string_literal: true

module JH
  module CacheMarkdownField
    extend ActiveSupport::Concern
    extend ::Gitlab::Utils::Override

    override :banzai_render_context
    def banzai_render_context(field)
      context = super

      if context[:project]&.import_from_gitee?
        # More options see: https://github.com/gjtorikian/commonmarker#options
        context[:common_mark_extra_render_options] = [:HARDBREAKS]
      end

      context
    end
  end
end
