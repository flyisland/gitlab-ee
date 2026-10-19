# frozen_string_literal: true

module Elastic
  module Latest
    class SnippetInstanceProxy < ApplicationInstanceProxy
      SCHEMA_VERSION = 26_02
      PREVIOUS_SCHEMA_VERSION = 26_01

      def as_indexed_json(options = {})
        # We don't use as_json(only: ...) because it calls all virtual and serialized attributes
        # https://gitlab.com/gitlab-org/gitlab/issues/349
        data = {}

        [
          :id,
          :title,
          :description,
          :created_at,
          :updated_at,
          :project_id,
          :author_id,
          :visibility_level
        ].each do |attr|
          data[attr.to_s] = safely_read_attribute_for_elasticsearch(attr)
        end

        data.merge!(build_project_access_data)
        data['schema_version'] = schema_version

        data.merge(generic_attributes)
      end

      # TODO: Reenable support for public/internal project snippets
      # https://gitlab.com/gitlab-org/gitlab/issues/2358
      def es_parent
        nil
      end

      private

      def build_project_access_data
        return {} unless target.project && project_access_fields_available?

        {
          'project_visibility_level' => target.project.visibility_level,
          'snippets_access_level' => safely_read_project_feature_for_elasticsearch(:snippets)
        }
      end

      # A document must not claim a schema version whose fields it does not
      # carry, or a `MigrationReindexBasedOnSchemaVersion` would skip it.
      def schema_version
        project_access_fields_available? ? SCHEMA_VERSION : PREVIOUS_SCHEMA_VERSION
      end

      def project_access_fields_available?
        return @project_access_fields_available if defined?(@project_access_fields_available)

        @project_access_fields_available =
          ::Elastic::DataMigrationService.migration_has_finished?(:add_project_visibility_level_to_snippets)
      end
    end
  end
end
