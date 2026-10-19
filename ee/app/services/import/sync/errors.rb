# frozen_string_literal: true

module Import
  module Sync
    module Errors
      ProviderIdentityError = Class.new(StandardError)
      StaleApplicationError = Class.new(StandardError)
      PlaceholderReferenceLoadError = Class.new(StandardError)
      MappingConflictError = Class.new(StandardError)
      ProviderObjectError = Class.new(StandardError)
      MissingCredentialsError = Class.new(StandardError)
    end
  end
end
