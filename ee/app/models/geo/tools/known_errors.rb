# frozen_string_literal: true

module Geo
  module Tools
    # SPIKE (gitlab-org/gitlab#602803): entry point to the known-error catalog, wrapping
    # each Geo::Errors::ErrorType in a KnownError that adds detection behaviour.
    module KnownErrors
      module_function

      def catalog
        Geo::Errors::ErrorType.all.map { |error_type| KnownError.new(error_type) }
      end

      def find(key)
        error_type = Geo::Errors::ErrorType.find_by(name: key.to_s)
        KnownError.new(error_type) if error_type
      end
    end
  end
end
