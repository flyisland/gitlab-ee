# frozen_string_literal: true

module Mutations
  module Govern
    class PolicyCreate < ::Mutations::BaseMutation
      graphql_name 'GovernPolicyCreate'
      description 'Creates a policy in the policy store for an organization.'

      include CommonMutationArguments

      UnmappedReasonError = Class.new(StandardError)

      UNMAPPED_REASON_MESSAGE = 'Could not complete the policy store request'

      authorize :create_govern_policy
      authorize_granular_token permissions: :create_govern_policy,
        boundary: :instance,
        boundary_type: :instance

      argument :organization_id, ::Types::GlobalIDType[::Organizations::Organization],
        required: true,
        description: 'Global ID of the organization to create the policy in.'

      argument :name, GraphQL::Types::String,
        required: true,
        description: copy_field_description(::Types::Govern::PolicyType, :name)

      argument :trigger_type, GraphQL::Types::String,
        required: true,
        description: copy_field_description(::Types::Govern::PolicyType, :trigger_type)

      # Rules stay JSON for the experiment stage for the same reason as the fields on
      # PolicyType: the content is free-form and owned by the policy store experiment,
      # and a rule value is a hash or a Rego source string.
      argument :rules, [GraphQL::Types::JSON],
        required: true,
        validates: { length: { minimum: 1, maximum: ::Types::BaseArgument::MAX_ARRAY_SIZE } },
        description: 'Rules of the policy, at least one. ' \
          "No more than #{::Types::BaseArgument::MAX_ARRAY_SIZE} rules."

      field :policy, ::Types::Govern::PolicyType,
        null: true,
        description: 'Policy created in the policy store.'

      def resolve(args)
        organization = authorized_find!(organization_id: args.delete(:organization_id))

        response = ::Security::SecurityOrchestrationPolicies::PolicyStore::CreateService
          .new(container: organization, current_user: current_user, params: args)
          .execute

        if response.error?
          # The experiment gate acts as if the API does not exist, while validation
          # failures surface as user-facing errors on the payload. :forbidden is
          # intentionally unmapped: authorized_find! already checks the same ability.
          raise_resource_not_available_error! if response.reason == :experiment_not_active

          track_unmapped_reason!(response) unless response.reason == :invalid

          return { policy: nil, errors: [response.message] }
        end

        { policy: response.payload[:policy], errors: [] }
      end

      private

      # Mirror the policies resolver: track the unmapped reason and surface a generic
      # error rather than rendering an internal service message as user error.
      def track_unmapped_reason!(response)
        ::Gitlab::ErrorTracking.track_exception(
          UnmappedReasonError.new("Unmapped policy store reason: #{response.reason}"),
          service_message: response.message
        )

        raise GraphQL::ExecutionError, UNMAPPED_REASON_MESSAGE
      end

      def find_object(organization_id:)
        ::GitlabSchema.object_from_id(organization_id, expected_type: ::Organizations::Organization).sync
      end
    end
  end
end
