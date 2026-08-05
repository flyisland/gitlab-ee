# frozen_string_literal: true

module Geo
  module Errors
    # SPIKE (gitlab-org/gitlab#602803): catalog of known Geo sync/verification errors.
    #
    # This is the single source of truth for error metadata. The Geo cleanup tools
    # (Geo::Tools) use it to detect and resolve known errors, and it is intended to back
    # the Geo Troubleshooting Dashboard metadata work in gitlab-org/gitlab#548532 (the
    # typed Geo::Errors::* classes would link to an entry here via their identifier).
    #
    # Built on the Fixed Items Model because this is static, version-controlled data.
    # The known-errors docs reference is generated from these entries, see the planned
    # `rake geo:tools:compile_docs` / `geo:tools:check_docs` tasks.
    class ErrorType
      include ActiveRecord::FixedItemsModel::Model

      SEVERITIES = %w[info warning critical].freeze
      SITES = %w[primary secondary].freeze

      # `match_pattern` matches against the free-text `last_sync_failure` column, because
      # the symptom taxonomy is finer-grained than the typed error classes, and because
      # existing registries only carry free-text failures (no error-class column yet, see
      # gitlab-org/gitlab#548529).
      ITEMS = [
        {
          id: 1,
          name: 'url_blocked',
          severity: 'warning',
          title: 'Download URL blocked',
          description: 'Object storage download URL was blocked by network filtering on ' \
            'the secondary site. Once the network fix is in place the failed registries ' \
            'just need to be resynced.',
          site: 'secondary',
          match_pattern: 'URL is blocked',
          resolvable: true,
          resolve_strategy: 'resync',
          docs: 'https://docs.gitlab.com/administration/geo/replication/troubleshooting/synchronization_verification/',
          troubleshooting_links: [],
          issues: ['https://gitlab.com/gitlab-org/gitlab/-/work_items/598514']
        },
        {
          id: 2,
          name: 'duplicate_registries',
          severity: 'warning',
          title: 'Duplicate registries',
          description: 'The same model record is tracked by more than one registry row. ' \
            'Registry rows are reconstructable, so the extra rows can be removed.',
          site: 'secondary',
          match_pattern: nil, # structural check, no failure-text pattern
          resolvable: true,
          resolve_strategy: 'remove_duplicate_registries',
          docs: 'https://docs.gitlab.com/administration/geo/replication/troubleshooting/synchronization_verification/',
          troubleshooting_links: [],
          issues: []
        },
        {
          id: 3,
          name: 'orphaned_uploads',
          severity: 'warning',
          title: 'Orphaned uploads',
          description: 'Uploads on the primary whose owning model is missing fail ' \
            'verification and can never be checksummed. The upload records can be deleted.',
          site: 'primary',
          match_pattern: 'The model which owns this upload is missing',
          resolvable: true,
          resolve_strategy: 'delete_orphaned_uploads',
          docs: 'https://docs.gitlab.com/administration/geo/replication/troubleshooting/synchronization_verification/',
          troubleshooting_links: [],
          issues: []
        }
      ].freeze

      attribute :id, :integer
      attribute :name, :string
      attribute :severity, :string
      attribute :title, :string
      attribute :description, :string
      attribute :site, :string
      attribute :match_pattern, :string
      attribute :resolvable, :boolean
      attribute :resolve_strategy, :string
      attribute :docs, :string
      # Untyped on purpose: these hold array payloads, and a default attribute type would
      # coerce them to strings.
      attribute :troubleshooting_links
      attribute :issues
    end
  end
end
