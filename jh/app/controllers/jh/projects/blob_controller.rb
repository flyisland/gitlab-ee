# frozen_string_literal: true

module JH
  module Projects
    module BlobController
      extend ActiveSupport::Concern
      extend ::Gitlab::Utils::Override

      prepended do
        before_action :set_content_blocked_state, only: [:show]
      end

      private

      override :show_json
      def show_json
        return super unless @content_blocked_state.present?

        json = {
          id: blob.id,
          last_commit_sha: @last_commit_sha,
          path: blob.path,
          name: blob.name,
          extension: blob.extension,
          size: blob.raw_size,
          mime_type: blob.mime_type,
          binary: blob.binary?,
          simple_viewer: blob.simple_viewer&.class&.partial_name,
          rich_viewer: blob.rich_viewer&.class&.partial_name,
          show_viewer_switcher: !!blob.show_viewer_switcher?,
          render_error: blob.simple_viewer&.render_error || blob.rich_viewer&.render_error,
          html: view_to_html_string("shared/_content_blocked", content_blocked_state: @content_blocked_state)
        }
        render json: json
      end

      def set_content_blocked_state
        return unless ::ContentValidation::Setting.block_enabled?(project)

        set_last_commit_sha
        @content_blocked_state = ::ContentValidation::ContentBlockedState.find_by_container_commit_path(
          project,
          @last_commit_sha,
          @blob.path)
      end
    end
  end
end
