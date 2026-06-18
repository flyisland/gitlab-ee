# frozen_string_literal: true

module CloudConnector
  module StatusChecks
    module Probes
      class DuoAgentPlatformProbe < BaseProbe
        extend ::Gitlab::Utils::Override
        include Gitlab::Utils::StrongMemoize

        TLS_MISMATCH_ERROR_PATTERN = /(ssl handshake failed|wrong_version_number|tls)/i

        validate :verify_request_success

        def initialize(user, feature_setting:)
          @user = user
          @feature_setting = feature_setting
        end

        private

        def host
          Gitlab::DuoWorkflow::Client.url_for(feature_setting: @feature_setting, user: @user)
        end
        strong_memoize_attr :host

        def result
          ::Ai::DuoWorkflow::DuoWorkflowService::Client.new(
            duo_workflow_service_url: host,
            current_user: @user,
            secure: secure_for_host
          ).list_tools
        end

        def secure_for_host
          Gitlab::DuoWorkflow::Client.secure?(feature_setting: @feature_setting)
        end

        def verify_request_success
          return if result[:status] == :success

          errors.add(:base, result[:message])
        end

        override :success_message
        def success_message
          if feature_is_self_hosted?
            format(
              _('GitLab Duo Workflow Service at %{host} is operational. ' \
                'The model for Agents & flows is set to a self-hosted model.'),
              host: host
            )
          else
            format(
              _('GitLab Duo Workflow Service at %{host} is operational. ' \
                'The model for Agents & flows is set to a GitLab managed model'),
              host: host
            )
          end
        end

        def failure_message
          message = format(_('GitLab Duo Workflow Service at %{host} is not operational.'), host: host)
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

        def feature_is_self_hosted?
          @feature_setting&.self_hosted?
        end

        def tls_mismatch_error?
          feature_is_self_hosted? &&
            secure_for_host &&
            errors.full_messages.any? { |error_message| error_message.match?(TLS_MISMATCH_ERROR_PATTERN) }
        end
      end
    end
  end
end
