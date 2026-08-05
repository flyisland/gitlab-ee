# frozen_string_literal: true

module Mutations
  module SecretsManagement
    class StartTrial < BaseMutation
      graphql_name 'SecretsManagerStartTrial'

      include Mutations::ResolvesGroup
      include Gitlab::InternalEventsTracking

      authorize :admin_group # rubocop:disable Gitlab/Authz/PermissionCheck -- group-admin action per issue 602353

      # Token scope matches the entitlement read surface; the write is gated by :admin_group above.
      authorize_granular_token permissions: :read_secrets_manager,
        boundary_argument: :group_path,
        boundary_type: :group

      argument :group_path,
        GraphQL::Types::ID,
        required: true,
        description: 'Full path of the top-level group to start a Secrets Manager trial for.'

      field :entitlement,
        ::Types::SecretsManagement::EntitlementType,
        null: true,
        description: 'Secrets Manager entitlement state after starting the trial. ' \
          'Null when the post-trial state cannot be resolved; query the group entitlement directly instead.'

      OFFLINE_ERROR = 'Secrets Manager trials are not available on offline (air-gapped) instances.'
      UNAVAILABLE_ERROR = 'Unable to reach the subscription service. Please try again later.'

      ERROR_MESSAGES = {
        trial_already_active: 'A Secrets Manager trial is already active for this group.',
        ineligible: 'This group is not eligible to start a Secrets Manager trial.',
        not_found: 'This group is not recognized by the subscription service.'
      }.freeze

      def resolve(group_path:)
        group = authorized_find!(group_path: group_path)

        raise_resource_not_available_error! unless ::Feature.enabled?(:secrets_manager_paid_experience, group)

        unless group.root?
          raise ::Gitlab::Graphql::Errors::ArgumentError,
            'Secrets Manager trials can only be started for top-level groups.'
        end

        unavailable = self_managed_unavailable_reason
        return error_response(unavailable) if unavailable

        result = ::Gitlab::SubscriptionPortal::Client.start_secrets_manager_trial(**cdot_identifier_kwargs(group))

        if result.success?
          track_internal_event('secrets_manager_trial_started', namespace: group, user: current_user)

          # Trial is already started on CDot; a post-trial lookup failure must not fail the mutation.
          { entitlement: resolve_entitlement(group), errors: [] }
        else
          error_response(error_message_for(result))
        end
      rescue ::Gitlab::SubscriptionPortal::SecretsManagerStartTrialResponse::Error
        error_response(UNAVAILABLE_ERROR)
      end

      private

      def find_object(group_path:)
        resolve_group(full_path: group_path)
      end

      def error_response(message)
        { entitlement: nil, errors: [message] }
      end

      def error_message_for(result)
        return result.error_message if result.error_code == :ineligible && result.error_message.present?

        ERROR_MESSAGES.fetch(result.error_code, UNAVAILABLE_ERROR)
      end

      def resolve_entitlement(group)
        entitlement_for(group)
      rescue StandardError
        nil
      end

      def entitlement_for(group)
        entitlement = ::SecretsManagement::Entitlement.for(group, user: current_user)
        ::Types::SecretsManagement::EntitlementType::Adapter.new(entitlement: entitlement, group: group)
      end

      def cdot_identifier_kwargs(group)
        if saas?
          { namespace_id: group.id }
        else
          { instance_id: ::Gitlab::CurrentSettings.uuid }
        end
      end

      # Self-managed routing mirrors SecretsManagement::Entitlement::Resolver:
      #   no license     -> ineligible (no entitlement)
      #   offline license-> air-gapped, trials require live CDot connectivity
      #   online cloud   -> proceeds to CDot
      def self_managed_unavailable_reason
        return if saas?

        license = ::License.current
        return ERROR_MESSAGES.fetch(:ineligible) if license.nil?
        return OFFLINE_ERROR unless license.online_cloud_license?

        nil
      end

      # rubocop:disable Gitlab/AvoidGitlabInstanceChecks -- CDot identity axis; matches SubscriptionPortal::Client and Entitlement::Resolver
      def saas?
        ::Gitlab.com?
      end
      # rubocop:enable Gitlab/AvoidGitlabInstanceChecks
    end
  end
end
