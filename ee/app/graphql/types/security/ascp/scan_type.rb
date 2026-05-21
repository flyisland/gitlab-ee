# frozen_string_literal: true

module Types
  module Security
    module Ascp
      # rubocop: disable Graphql/AuthorizeTypes -- Authorization handled by parent resolver
      class ScanType < BaseObject
        graphql_name 'AscpScan'
        description 'An ASCP scan of a project'

        field :id, ::Types::GlobalIDType[::Security::Ascp::Scan],
          null: false,
          description: 'ID of the scan.'

        field :scan_sequence, GraphQL::Types::Int,
          null: false,
          description: 'Sequence number of the scan within the project.'

        field :commit_sha, GraphQL::Types::String,
          null: false,
          description: 'Git commit SHA that was scanned.'

        # rubocop: disable GraphQL/ExtractType -- scan_type is a core attribute, not suitable for extraction
        field :scan_type, Types::Security::Ascp::ScanTypeEnum,
          null: false,
          description: 'Type of scan (full or incremental).'
        # rubocop: enable GraphQL/ExtractType

        field :base_commit_sha, GraphQL::Types::String,
          null: true,
          description: 'Base commit SHA for incremental scans.'

        # rubocop: disable GraphQL/ExtractType -- base_scan is a self-reference, not suitable for extraction
        field :base_scan, Types::Security::Ascp::ScanType,
          null: true,
          description: 'Reference to the base scan for incremental scans.'
        # rubocop: enable GraphQL/ExtractType

        field :created_at, Types::TimeType,
          null: false,
          description: 'Timestamp when the scan was created.'

        field :updated_at, Types::TimeType,
          null: false,
          description: 'Timestamp when the scan was last updated.'
      end
      # rubocop: enable Graphql/AuthorizeTypes
    end
  end
end
