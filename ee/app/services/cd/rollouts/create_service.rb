# frozen_string_literal: true

module Cd
  module Rollouts
    class CreateService
      def initialize(parent:, current_user: nil, params: {})
        @parent = parent
        @current_user = current_user
        @params = params.dup
      end

      def execute
        if cross_organization_resources?
          return error([_('One or more referenced resources do not belong to the organization.')])
        end

        rollout = build_rollout
        rollout.save!

        ::Cd::Rollouts::StartWorker.perform_async(rollout.id)

        ServiceResponse.success(payload: { rollout: rollout })
      rescue ActiveRecord::RecordInvalid => e
        error(e.record.errors.full_messages, rollout)
      end

      private

      attr_reader :parent, :current_user, :params

      # Ensures every resource resolved from a client-supplied Global ID belongs
      # to the authorized organization, preventing a caller with permission on
      # one organization from referencing another organization's resources.
      def cross_organization_resources?
        version_set = params[:version_set]

        version_set.present? && version_set.organization_id != parent.id
      end

      def build_rollout
        version_set = params[:version_set]
        application = version_set&.application

        ::Cd::Rollout.new(
          organization: parent,
          version_set: version_set,
          application: application,
          application_flow_definition: latest_flow_definition(application)
        )
      end

      # The rollout uses the application's current (latest) flow definition. The
      # association is ordered by version descending, so the first record is the
      # latest. Returns nil when the application has no flow definition yet.
      def latest_flow_definition(application)
        application&.application_flow_definitions&.first
      end

      def error(messages, rollout = nil)
        ServiceResponse.error(message: messages, payload: { rollout: rollout })
      end
    end
  end
end
