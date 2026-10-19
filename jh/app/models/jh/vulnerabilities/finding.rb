# frozen_string_literal: true

module JH
  module Vulnerabilities
    module Finding
      def other_identifier_values_with_links
        identifiers.select(&:other?).map { |identifier| [identifier.name, identifier.url].join(',') }
      end
    end
  end
end
