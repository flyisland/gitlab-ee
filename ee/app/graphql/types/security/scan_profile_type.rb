# frozen_string_literal: true

module Types
  module Security
    # rubocop:disable Graphql/AuthorizeTypes -- Authorization occurs at parent level
    class ScanProfileType < BaseObject
      graphql_name 'ScanProfileType'
      description 'A scan profile.'

      field :created_at,
        type: GraphQL::Types::ISO8601DateTime,
        null: false,
        description: 'Timestamp of when the scan profile was created.'

      field :description,
        type: GraphQL::Types::String,
        null: false,
        description: 'Description of the security scan profile.'

      field :gitlab_recommended,
        type: GraphQL::Types::Boolean,
        null: false,
        description: 'Indicates whether the scan profile is a default profile.'

      field :id,
        type: ::Types::GlobalIDType[::Security::ScanProfile],
        null: true,
        resolver_method: :resolve_id,
        description: 'Global ID of the security scan profile.'

      field :name,
        type: GraphQL::Types::String,
        null: false,
        description: 'Name of the security scan profile.'

      field :scan_type,
        type: Types::Security::ScanProfileTypeEnum,
        null: false,
        description: 'Scan profile type.'

      field :triggers,
        type: [Types::Security::ScanProfileTriggerTypeEnum],
        null: false,
        description: 'Trigger types for the scan profile.',
        experiment: { milestone: '18.10' }

      field :updated_at,
        type: GraphQL::Types::ISO8601DateTime,
        null: false,
        description: 'Timestamp of when the scan profile was last updated.'

      def resolve_id
        object.persisted? ? object.to_global_id : ::Gitlab::GlobalId.build(object, id: object.scan_type)
      end

      def triggers
        object.scan_profile_triggers.map(&:trigger_type)
      end
    end
    # rubocop:enable Graphql/AuthorizeTypes
  end
end
