# frozen_string_literal: true

require 'gitlab/json'

module Gitlab
  module Patch
    module ToolingGettextExtractor
      extend ::Gitlab::Utils::Override

      private

      override :parse_frontend_files
      def parse_frontend_files
        results, status = Open3.capture2('node jh/scripts/frontend/extract_gettext_all.js --all')
        raise StandardError, "Could not parse frontend files" unless status.success?

        Gitlab::Json.parse(results)
            .values
            .flatten(1)
            .collect { |entry| create_po_entry(*entry) }
      end
    end
  end
end
