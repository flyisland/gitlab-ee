# frozen_string_literal: true

module QA
  module JH
    module Specs
      module Runner
        extend ::Gitlab::Utils::Override

        JH_DEFAULT_TEST_PATH = File.expand_path("../../specs/features", __dir__).freeze

        private

        override :rspec_paths
        def rspec_paths
          paths = super

          return paths unless rspec_retried?

          [*paths, JH_DEFAULT_TEST_PATH].uniq
        end
      end
    end
  end
end
