# frozen_string_literal: true

module Ai
  module DuoAgentPlatform
    module AccessPolicy
      extend ActiveSupport::Concern

      included do
        condition(:duo_agent_platform_enabled, scope: :subject) do
          ::Ai::DuoWorkflow.duo_agent_platform_available?(@subject)
        end

        # Gates :duo_workflow (execution): entitlement with the identity
        # verification gate enforced.
        condition(:duo_workflow_available) { allowed_to_use_duo_agent_platform? }

        # DAP entitlement evaluated as if the user were already verified. Unlike
        # :duo_workflow it is not blocked by the identity verification gate, so it
        # grants access to the Duo Agent Platform page where the verification
        # banner is shown.
        condition(:duo_workflow_entitled) { allowed_to_use_duo_agent_platform?(skip_identity_verification: true) }

        rule { ~duo_agent_platform_enabled | ~duo_workflow_entitled }.prevent :read_duo_agent_platform
      end

      private

      def allowed_to_use_duo_agent_platform?(skip_identity_verification: false)
        # allowed_to_use? is defined on User (via Ai::UserAuthorizable), not on
        # PolicyActor, so guard against non-user actors before calling it.
        return false unless user_is_user?
        return false unless subject.duo_features_enabled
        return false unless ::Gitlab::Llm::StageCheck.available?(subject, :duo_workflow)

        options = { root_namespace: subject.root_ancestor }
        options[:skip_identity_verification] = true if skip_identity_verification

        user.allowed_to_use?(:duo_agent_platform, **options)
      end
    end
  end
end
