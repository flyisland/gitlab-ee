# frozen_string_literal: true

module Authz
  module ArtifactRegistry
    class BaseService
      TOKEN_AUDIENCE = %w[gitlab-iam-data-access].freeze

      private

      attr_reader :current_user, :organization

      # Membership, not the home organization. A user is owned by exactly one
      # organization but can be a member of several, and at launch everyone
      # stays owned by the default one while gaining membership of the
      # organizations their groups move into. Ownership is deliberately not
      # required here: IAM's AuthorizeWrite already accepts an organization
      # owner or a caller holding the right grant, so demanding ownership would
      # reject grant holders before IAM ever sees the request.
      def caller_in_organization?
        current_user.member_of_organization?(organization)
      end

      def token
        ::Authn::TokenExchange::TokenIssuer.new(
          audiences: TOKEN_AUDIENCE,
          user: current_user,
          organization: organization
        ).token
      end

      # A single-item request needs no position, so return its bare message.
      # With several, prefix each with its position and resource so the caller
      # can tell which items to fix. Subclasses define request_items (the
      # submitted collection) and position_error_format (the verb wording).
      def validation_error(errors)
        # Precondition, not a runtime case: every caller establishes that it has
        # something to report before formatting it. Named here so a future caller
        # that does not gets this rather than a nil dereference.
        raise ArgumentError, 'validation_error needs at least one error' if errors.empty?

        return errors.first[:message] if request_items.size == 1

        errors.map do |error|
          format(position_error_format, error.slice(:number, :resource_id, :message))
        end.join("\n")
      end

      # Translates a client failure reason into a user-facing message. The
      # client stays transport-only and reports a reason; the wording lives
      # here. These three reasons read the same for every operation; the rest
      # are verb-specific and live in the subclasses.
      def iam_error_message(reason)
        case reason
        when :unauthenticated
          s_('ArtifactRegistry|Could not authenticate with the Artifact Registry service.')
        when :unavailable
          s_('ArtifactRegistry|The Artifact Registry service is unavailable.')
        when :timeout
          s_('ArtifactRegistry|The Artifact Registry service did not respond in time.')
        else
          fallback_error_message(reason)
        end
      end

      def client
        raise NotImplementedError, "#{self.class} must implement #client"
      end

      def error(message, reason: nil)
        ServiceResponse.error(message: message, reason: reason)
      end
    end
  end
end
