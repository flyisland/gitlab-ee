# frozen_string_literal: true

module CloudConnector
  module StatusChecks
    module Probes
      class DuoAgentPlatformProbe < BaseProbe
        extend ::Gitlab::Utils::Override

        TLS_MISMATCH_ERROR_PATTERN = /(ssl handshake failed|wrong_version_number|tls)/i

        validate :verify_request_success

        def initialize(user)
          @user = user
          @host = determine_host
        end

        private

        def determine_host
          Gitlab::DuoWorkflow::Client.self_hosted_url.presence ||
            Gitlab::DuoWorkflow::Client.cloud_connected_url(user: @user)
        end

        def result
          ::Ai::DuoWorkflow::DuoWorkflowService::Client.new(
            duo_workflow_service_url: @host,
            current_user: @user,
            secure: secure_for_host
          ).list_tools
        end

        def secure_for_host
          return ::Ai::Setting.instance&.self_hosted_duo_agent_platform_service_secure if url_is_self_hosted?

          Gitlab::DuoWorkflow::Client.secure?(feature_setting: nil)
        end

        def verify_request_success
          return if result[:status] == :success

          errors.add(:base, result[:message])
        end

        override :success_message
        def success_message
          format(_('GitLab Duo Workflow Service at %{host} is operational.'), host: @host)
        end

        def failure_message
          message = format(_('GitLab Duo Workflow Service at %{host} is not operational.'), host: @host)
          tls_guidance = _(
            'It fails with a TLS mismatch error. ' \
              'If your self-hosted Duo Agent Platform service endpoint does not support TLS, ' \
              'turn off TLS connection to the GitLab Duo Agent Platform service '
          )

          return message unless tls_mismatch_error?

          format(
            _("%{message} %{tls_guidance}"),
            tls_guidance: tls_guidance,
            message: message
          )
        end

        def url_is_self_hosted?
          Gitlab::DuoWorkflow::Client.self_hosted_url.presence == @host
        end

        def tls_mismatch_error?
          url_is_self_hosted? &&
            secure_for_host &&
            errors.full_messages.any? { |error_message| error_message.match?(TLS_MISMATCH_ERROR_PATTERN) }
        end
      end
    end
  end
end
