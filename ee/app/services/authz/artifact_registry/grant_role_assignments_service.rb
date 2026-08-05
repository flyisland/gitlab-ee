# frozen_string_literal: true

module Authz
  module ArtifactRegistry
    # Grants a set of Artifact Registry role assignments in a single
    # all-or-nothing write to the IAM Relationships API.
    #
    # Validates each assignment (same organization, valid resource UUID, known
    # role) and writes them all in one all-or-nothing IAM call. If any
    # assignment is invalid, nothing is written. Both the single and bulk grant
    # mutations use this service; the single grant passes a one-element array.
    class GrantRoleAssignmentsService
      TOKEN_AUDIENCE = %w[gitlab-iam-data-access].freeze

      def initialize(current_user:, organization:, assignments:)
        @current_user = current_user
        @organization = organization
        @assignments = assignments
      end

      def execute
        return error(s_('ArtifactRegistry|You must be signed in to grant a role.')) unless current_user
        return error(s_('ArtifactRegistry|Organization could not be determined.')) unless organization
        # The organization comes from the request context and can be influenced by
        # request headers, so confirm it is the caller's own before scoping the
        # IAM write to it.
        unless callers_own_organization?
          return error(s_('ArtifactRegistry|You cannot grant roles in another organization.'))
        end

        return error(s_('ArtifactRegistry|At least one assignment is required.')) if assignments.empty?

        # Validate every assignment and report each invalid one rather than
        # stopping at the first, so a caller fixing a bulk request sees all the
        # problems in one round-trip.
        errors = assignments.each_with_index.filter_map do |assignment, index|
          message = assignment_error(assignment)
          next unless message

          { number: index + 1, resource_id: assignment[:resource_id], message: message }
        end
        return error(validation_error(errors)) if errors.any?

        inputs = assignments.map { |assignment| build_input(assignment) }

        duplicates = duplicate_assignments
        return error(duplicate_error(duplicates)) if duplicates.any?

        client.assign_roles(inputs, organization_uuid: organization.uuid, token: token)

        ServiceResponse.success(payload: { granted_role_count: inputs.size })
      rescue ::Authn::IamService::RelationshipsClient::RequestError => e
        error(iam_error_message(e.reason))
      end

      private

      attr_reader :current_user, :organization, :assignments

      # Returns an error message if the assignment is invalid, otherwise nil.
      def assignment_error(assignment)
        assignee, resource_id, role = assignment.values_at(:assignee, :resource_id, :role)

        # Treat a cross-organization assignee the same as a missing one so the
        # error does not reveal whether the user exists in another organization.
        return s_('ArtifactRegistry|Assignee could not be found.') unless assignee && same_organization?(assignee)
        return s_('ArtifactRegistry|Resource ID must be a valid UUID.') unless ::Gitlab::UUID.uuid?(resource_id)

        role_id = Roles.uuid_for(role)
        return format(s_('ArtifactRegistry|Unknown Artifact Registry role: %{role}.'), role: role) unless role_id

        nil
      end

      # Builds the IAM assignment input for an assignment already validated by
      # assignment_error.
      def build_input(assignment)
        assignee, resource_id, role = assignment.values_at(:assignee, :resource_id, :role)

        {
          assignee_id: assignee.id,
          resource_id: resource_id,
          role_id: Roles.uuid_for(role)
        }
      end

      # A single assignment (the single-grant path) needs no position, so return
      # its bare message. With several, prefix each with its position and
      # resource so the caller can tell which assignments to fix.
      def validation_error(errors)
        return errors.first[:message] if assignments.size == 1

        errors.map do |error|
          format(
            s_('ArtifactRegistry|Assignment %{number} on resource %{resource_id}: %{message}'),
            error.slice(:number, :resource_id, :message)
          )
        end.join("\n")
      end

      # IAM stores one ASSIGNMENT per (subject, object), so a single request
      # cannot grant a user more than one role on the same resource. Catch that
      # here with a clear error rather than letting IAM reject the whole batch.
      # Runs after build_input, so every assignee is present.
      def duplicate_assignments
        assignments
          .group_by { |assignment| [assignment[:assignee].id, assignment[:resource_id]] }
          .values
          .select { |group| group.size > 1 }
      end

      def duplicate_error(duplicates)
        details = duplicates.map do |group|
          roles = group.map { |assignment| assignment[:role].to_s.upcase }.join(', ')
          "#{group.first[:assignee].to_global_id} on resource #{group.first[:resource_id]} (#{roles})"
        end.join("\n")

        message = s_('ArtifactRegistry|A user can hold only one Artifact Registry role per resource. ' \
          'The following are listed more than once.')

        "#{message}\n#{details}"
      end

      def callers_own_organization?
        current_user.organization_id == organization.id
      end

      def same_organization?(assignee)
        current_user.organization_id == assignee.organization_id
      end

      def token
        ::Authn::TokenExchange::TokenIssuer.new(
          audience: TOKEN_AUDIENCE,
          user: current_user
        ).token
      end

      def client
        ::Authn::IamService::RelationshipsClient.new
      end

      # Translates a RelationshipsClient failure reason into a user-facing
      # message. The client stays transport-only and reports a reason; the
      # Artifact Registry wording and translation live here.
      def iam_error_message(reason)
        case reason
        when :permission_denied
          s_('ArtifactRegistry|You are not authorized to grant this role on this resource.')
        when :unauthenticated
          s_('ArtifactRegistry|Could not authenticate with the Artifact Registry service.')
        when :invalid_request
          s_('ArtifactRegistry|The role assignment request was invalid.')
        when :unavailable
          s_('ArtifactRegistry|The Artifact Registry service is unavailable.')
        when :timeout
          s_('ArtifactRegistry|The Artifact Registry service did not respond in time.')
        else
          s_('ArtifactRegistry|The role assignment could not be completed.')
        end
      end

      def error(message)
        ServiceResponse.error(message: message)
      end
    end
  end
end
