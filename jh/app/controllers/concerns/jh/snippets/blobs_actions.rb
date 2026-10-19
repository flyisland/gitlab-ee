# frozen_string_literal: true

module JH
  module Snippets
    module BlobsActions
      extend ActiveSupport::Concern
      extend ::Gitlab::Utils::Override
      include ContentValidationMessages

      override :raw
      def raw
        return super unless ::ContentValidation::Setting.block_enabled?(snippet)

        last_commit = snippet.repository.last_commit_for_path(
          snippet.default_branch,
          blob.path,
          literal_pathspec: false
        )
        content_blocked_state = ::ContentValidation::ContentBlockedState.find_by_container_commit_path(
          snippet,
          last_commit&.id,
          blob.path)

        return super unless content_blocked_state.present?

        render plain: illegal_tips_with_appeal_email
      end
    end
  end
end
