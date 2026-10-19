# frozen_string_literal: true

module Gitlab
  module Auth
    # Shared duo_workflow_use_token_issuer gating for every entry point that
    # verifies or issues a StatelessAccessToken, so they can't drift apart.
    #
    # Lives here (not under EE::Gitlab::Auth) since it has no CE counterpart
    # to extend; the EE:: namespace is reserved for extensions of an
    # existing CE class.
    module StatelessAccessTokenGate
      def self.enabled?(token)
        gating_user = token.identities.present? ? token.identity_user : token.user

        ::Feature.enabled?(:duo_workflow_use_token_issuer, gating_user)
      end

      # Issuance side. Also requires a Cloud Connector signing key, since
      # TokenIssuer raises without one; callers fall back to OAuth instead.
      def self.issuance_enabled?(user)
        ::Feature.enabled?(:duo_workflow_use_token_issuer, user) && ::CloudConnector::Keys.valid.present?
      end
    end
  end
end
