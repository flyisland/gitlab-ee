# frozen_string_literal: true

module JH
  module Types
    module Repository
      module BlobType
        extend ActiveSupport::Concern
        include ContentValidationMessages

        prepended do
          remove_field :raw_text_blob
          field :raw_text_blob, GraphQL::Types::String, calls_gitaly: true, null: true, method: :raw_plain_data,
            description: 'Raw content of the blob, if the blob is text data.',
            complexity: 2
        end

        def raw_text_blob
          super_result = object.data unless object.binary?
          return super_result unless ::ContentValidation::Setting.block_enabled?(object.project)

          commit_sha = ::Gitlab::Git::Commit.last_for_path(object.repository, object.commit_id, object.path,
            literal_pathspec: true).sha
          content_blocked_state = ::ContentValidation::ContentBlockedState.find_by_container_commit_path(
            object.project, commit_sha, object.path)
          return super_result if content_blocked_state.blank?

          illegal_tips_with_appeal_email
        end
      end
    end
  end
end
