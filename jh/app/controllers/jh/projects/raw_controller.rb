# frozen_string_literal: true

module JH
  module Projects
    module RawController
      extend ActiveSupport::Concern
      extend ::Gitlab::Utils::Override
      include ContentValidationMessages

      override :show
      def show
        return super unless ::ContentValidation::Setting.block_enabled?(project)

        ref_extractor = ExtractsRef::RefExtractor.new(project, {})
        ref, path = ref_extractor.extract_ref(params[:id])
        last_commit = ::Gitlab::Git::Commit.last_for_path(repository, ref, path, literal_pathspec: true)
        content_blocked_state = ::ContentValidation::ContentBlockedState.find_by_container_commit_path(
          project,
          last_commit,
          path)

        return super unless content_blocked_state.present?

        render plain: illegal_tips_with_appeal_email
      end
    end
  end
end
