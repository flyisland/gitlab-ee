# frozen_string_literal: true

module Authn
  module TokenExchange
    # Issues short-lived JWTs that GitLab Rails hands to clients for use with
    # modular services (e.g. Artifact Registry). Reuses the instance's
    # `CloudConnector::Keys` keypair as the signing key only; the token shape
    # itself is purpose-built for the GATE-direction token-exchange flow.
    #
    # Will eventually be superseded by GATE L2's `iam-sts` (see ADR-016 / ADR-019).
    class TokenIssuer
      SIGNING_ALGORITHM = 'RS256'

      # Values for the binary gitlab_organization_role claim (see #organization_role).
      OWNER_ROLE = 'owner'
      MEMBER_ROLE = 'member'

      def initialize(audience:, user:, ttl:)
        @audience = audience
        @user = user
        @ttl = ttl
      end

      def token
        jwk = ::CloudConnector::CachingKeyLoader.private_jwk
        header = { typ: 'JWT', kid: jwk.kid }
        JWT.encode(payload, jwk.signing_key, SIGNING_ALGORITHM, header)
      end

      private

      def payload
        now = Time.current.to_i
        {
          jti: SecureRandom.uuid,
          iss: Doorkeeper::OpenidConnect.configuration.issuer,
          aud: @audience,
          sub: @user.id.to_s,
          iat: now,
          nbf: now,
          exp: now + @ttl,
          gitlab_realm: ::CloudConnector.gitlab_realm,
          gitlab_organization_id: @user.organization_id,
          gitlab_organization_role: organization_role
        }
      end

      # Binary `owner` / `member` claim for the bootstrapping case described in
      # AUTH-015 (interim GATE identity mapping): before any role assignments
      # exist in the Relationships datastore, the modular service needs to
      # know whether the caller is an organization owner to authorize the
      # first activation call. Once activation runs, role lookup moves to the
      # Relationships API and this claim is no longer consulted.
      def organization_role
        @user.owns_organization?(@user.organization_id) ? OWNER_ROLE : MEMBER_ROLE
      end
    end
  end
end
