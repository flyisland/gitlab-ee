# frozen_string_literal: true

module Gitlab
  class GitAuditEvent # rubocop:disable Gitlab/NamespacedClass
    attr_reader :project, :user, :author

    def initialize(player, project)
      @project = project
      @author = player.is_a?(::API::Support::GitAccessActor) ? player.resolved_identity : player
      @user = player.is_a?(::API::Support::GitAccessActor) ? player.user : player
    end

    def enabled?
      return false if author.blank? || project.blank?

      # Deploy tokens are allowed now that HTTP support has been implemented.
      # Other non-human actors (e.g. deploy keys) are blocked until SSH support is added.
      # See: https://gitlab.com/gitlab-org/gitlab-shell/-/work_items/822
      return false unless author.is_a?(DeployToken) || user&.human?

      ::Feature.enabled?(:log_git_streaming_audit_events, project)
    end

    def send_audit_event(message)
      return if author.blank? || project.blank?

      ip_address = message.delete(:ip_address) if message.is_a?(Hash)

      audit_context = {
        name: 'repository_git_operation',
        stream_only: true,
        author: author,
        scope: project,
        target: project,
        message: message
      }

      audit_context[:ip_address] = ip_address if ip_address

      ::Gitlab::Audit::Auditor.audit(audit_context)
    end
  end
end
