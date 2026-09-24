# frozen_string_literal: true

module JH
  module Resolvers
    module Snippets
      module BlobsResolver
        extend ActiveSupport::Concern
        extend ::Gitlab::Utils::Override

        override :resolve
        def resolve(paths: [])
          snippet.content_blocked_states

          super
        end
      end
    end
  end
end
