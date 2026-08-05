# frozen_string_literal: true

module Mutations
  module Ai
    module DuoSettings
      class ClearDuoAvailability < BaseMutation
        graphql_name 'AdminClearDuoAvailability'
        description 'Clears an admin-locked GitLab Duo availability override from a group. ' \
          'Available only when the `admin_duo_availability_namespace_overrides` feature flag is enabled.'

        authorize :lock_namespace_duo_feature

        argument :group_id, ::Types::GlobalIDType[::Group],
          required: true,
          description: 'Group to clear the GitLab Duo availability override from.'

        field :availability, ::Types::Ai::DuoSettings::DuoAvailabilityEnum,
          null: true,
          description: 'Resolved GitLab Duo availability for the group after the override is cleared.'

        field :admin_locked, GraphQL::Types::Boolean,
          null: true,
          description: 'Whether the group has an admin-locked GitLab Duo availability override.'

        def resolve(group_id:)
          raise_resource_not_available_error! unless feature_enabled?

          group = authorized_find!(id: group_id)

          result = ::Ai::DuoSettings::ClearNamespaceOverrideService.new(
            namespace: group,
            current_user: current_user
          ).execute

          return { availability: nil, admin_locked: nil, errors: [result.message] } if result.error?

          namespace_setting = result.payload[:namespace_setting]

          {
            availability: namespace_setting.duo_availability.to_s,
            admin_locked: namespace_setting.admin_locked_duo_features_enabled,
            errors: []
          }
        end

        private

        def feature_enabled?
          Feature.enabled?(:admin_duo_availability_namespace_overrides, :instance)
        end
      end
    end
  end
end
