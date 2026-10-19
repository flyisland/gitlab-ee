# frozen_string_literal: true

module JH
  module SnippetBlobPresenter
    include JH::ContentValidationMessages
    extend ::Gitlab::Utils::Override

    override :plain_data
    def plain_data
      content_blocked_state.present? ? content_blocked_data : super
    end

    override :raw_plain_data
    def raw_plain_data
      content_blocked_state.present? ? illegal_tips_with_appeal_email : super
    end

    override :rich_data
    def rich_data
      content_blocked_state.present? ? content_blocked_data : super
    end

    private

    def content_blocked_state
      @content_blocked_state ||= snippet.content_blocked_states.detect { |state| state.path == blob.path }
    end

    def content_blocked_data
      ::ApplicationController.new.render_to_string(
        "shared/_content_blocked",
        locals: { content_blocked_state: content_blocked_state },
        layout: false, formats: [:html])
    end
  end
end
