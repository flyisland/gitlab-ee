# frozen_string_literal: true

module JH
  module Projects
    module BlameController
      extend ActiveSupport::Concern

      prepended do
        before_action :set_last_commit, only: [:show]
      end

      private

      def set_last_commit
        ref_extractor = ExtractsRef::RefExtractor.new(repository_container, params.permit(:id, :ref, :path, :ref_type))
        ref_extractor.extract!

        ref = ref_extractor.ref
        path = ref_extractor.path

        @last_commit = ::Gitlab::Git::Commit.last_for_path(repository, ref, path, literal_pathspec: true)
      end
    end
  end
end
