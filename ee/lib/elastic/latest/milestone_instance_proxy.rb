# frozen_string_literal: true

module Elastic
  module Latest
    class MilestoneInstanceProxy < ApplicationInstanceProxy
      extend ::Gitlab::Utils::Override

      SCHEMA_VERSION = 26_01

      DEFAULT_INDEX_ATTRIBUTES = %i[
        id
        iid
        title
        description
        project_id
        created_at
        updated_at
      ].freeze

      override :es_parent
      def es_parent
        return super if target.project_id

        "n_#{target.group.traversal_ids.first}"
      end

      def as_indexed_json(_options = {})
        data = {}

        DEFAULT_INDEX_ATTRIBUTES.each do |attribute|
          data[attribute.to_s] = safely_read_attribute_for_elasticsearch(attribute)
        end

        data.merge!(build_extra_data)
        data.merge!(build_project_data(target))
        data.merge!(build_group_data(target))

        data.merge(generic_attributes).stringify_keys
      end

      private

      def build_extra_data
        {
          schema_version: SCHEMA_VERSION
        }
      end

      def build_project_data(target)
        return {} unless target.project.present?

        {
          archived: target.project.self_or_ancestors_archived?,
          visibility_level: target.project.visibility_level,
          issues_access_level: safely_read_project_feature_for_elasticsearch(:issues),
          merge_requests_access_level: safely_read_project_feature_for_elasticsearch(:merge_requests),
          traversal_ids: target.project.elastic_namespace_ancestry
        }
      end

      def build_group_data(target)
        return {} unless target.group.present?

        {
          namespace_id: target.group_id,
          archived: target.group.self_or_ancestors_archived?,
          visibility_level: target.group.visibility_level,
          traversal_ids: target.group.elastic_namespace_ancestry
        }
      end
    end
  end
end
