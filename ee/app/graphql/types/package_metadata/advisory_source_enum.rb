# frozen_string_literal: true

module Types
  # rubocop: disable Gitlab/BoundedContexts -- this namespace is already established, embedding it deeper into another namespace would make things inconsistent.
  module PackageMetadata
    class AdvisorySourceEnum < BaseEnum
      graphql_name 'PackageMetadataAdvisorySource'
      description 'Source of the package metadata advisory.'

      ::Enums::PackageMetadata.advisory_sources.each do |advisory_source, enum_value|
        value advisory_source.underscore.upcase, value: enum_value, description: "Advisory from #{advisory_source}"
      end
    end
  end
  # rubocop: enable Gitlab/BoundedContexts
end
