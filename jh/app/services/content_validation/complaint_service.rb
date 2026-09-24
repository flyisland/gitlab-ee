# frozen_string_literal: true

module ContentValidation
  class ComplaintService
    def initialize(content_blocked_state:, user:, description:)
      @content_blocked_state = content_blocked_state
      @user = user
      @description = description
    end

    def execute
      return false unless ::ContentValidation::Setting.block_enabled?(@content_blocked_state.container)

      complaint_data = {
        content_blocked_state_id: @content_blocked_state.id,
        commit_sha: @content_blocked_state.commit_sha,
        path: @content_blocked_state.path,
        container_identifier: @content_blocked_state.container_identifier,
        user_id: @user.id,
        user_username: @user.username,
        user_email: @user.email,
        description: @description
      }

      client.user_complaint(complaint_data)
    end

    private

    def client
      @client ||= ::Gitlab::ContentValidation::Client.new
    end
  end
end
