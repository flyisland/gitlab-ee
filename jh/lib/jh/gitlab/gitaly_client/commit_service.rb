# frozen_string_literal: true

module JH
  module Gitlab
    module GitalyClient
      module CommitService
        extend ::Gitlab::Utils::Override

        private

        override :single_file_lookahead?
        def single_file_lookahead?
          return super unless repository_actor.container.is_a?(::Snippet)

          ::Feature.enabled?(:diff_stitcher_single_file_lookahead)
        end
      end
    end
  end
end
