# frozen_string_literal: true

module Types
  module Sbom
    class DependencyAggregationType < BaseObject # rubocop:disable Graphql/AuthorizeTypes -- Authorization checks are implemented on the parent object.
      graphql_name 'DependencyAggregation'
      description 'A software dependency aggregation used by a group'

      implements Types::Sbom::DependencyInterface

      field :occurrence_count, GraphQL::Types::Int,
        null: false,
        description: 'Number of occurrences of the dependency across projects.'

      def licenses
        return [] unless object.licenses.present?

        apply_group_license_overrides(object.licenses)
      end

      private

      def apply_group_license_overrides(licenses)
        group = context[:group]
        return licenses unless group &&
          ::Security::LicenseOverrideApplicator.experiment_enabled_for_group?(group)

        applicator = group_license_override_applicator
        return licenses unless applicator.overrides?

        dep_purl = aggregation_purl
        return licenses unless dep_purl

        applicator.apply(licenses, purl: dep_purl)
      end

      def aggregation_purl
        return unless object.purl_type.present?

        base = "pkg:#{object.purl_type}/#{object.component_name}"
        version = object.version
        version.present? ? "#{base}@#{version}" : base
      end

      def group_license_override_applicator
        context[:security_group_license_override_applicator] ||=
          ::Security::LicenseOverrideApplicator.new_for_group(context[:group])
      end
    end
  end
end
