# frozen_string_literal: true

module Gitlab
  module DuoWorkflow
    class Client
      def self.url(user:)
        self_hosted_url || cloud_connected_url(user: user)
      end

      def self.cloud_connected_url(user:)
        Gitlab.config.duo_workflow.service_url || default_service_url(user: user)
      end

      def self.default_service_url(user:)
        if Feature.enabled?(:duo_workflow_cloud_connector_url, user)
          return "#{::CloudConnector::Config.host}:#{::CloudConnector::Config.port}"
        end

        subdomain = ::CloudConnector::Config.host.include?('staging') ? '.staging' : ''

        # Cloudflare has been disabled untill
        # gets resolved https://gitlab.com/gitlab-org/gitlab/-/issues/509586
        # "#{::CloudConnector::Config.host}:#{::CloudConnector::Config.port}"
        "duo-workflow-svc#{subdomain}.runway.gitlab.net:#{::CloudConnector::Config.port}"
      end

      def self.url_for(feature_setting:, user:)
        if feature_setting&.self_hosted?
          self_hosted_url
        else
          cloud_connected_url(user: user)
        end
      end

      def self.self_hosted_url
        ::Ai::Setting.instance&.duo_agent_platform_service_url.presence
      end

      def self.secure?(feature_setting: nil)
        return ::Ai::Setting.instance&.self_hosted_duo_agent_platform_service_secure if feature_setting&.self_hosted?

        !!Gitlab.config.duo_workflow.secure
      end

      def self.debug_mode?
        !!Gitlab.config.duo_workflow.debug
      end

      def self.cloud_connector_headers(user:, feature_setting: nil, tool_access_policies: {}, **kwargs)
        Gitlab::AiGateway
          .public_headers(user: user, feature_setting: feature_setting, ai_feature_name: :duo_workflow,
            unit_primitive_name: :duo_workflow_execute_workflow, **kwargs)
          .transform_keys(&:downcase)
          .merge(
            'authorization' => "Bearer #{cloud_connector_token(user: user, feature_setting: feature_setting,
              tool_access_policies: tool_access_policies)}",
            'x-gitlab-authentication-type' => 'oidc'
          )
      end

      def self.cloud_connector_token(user:, feature_setting: nil, tool_access_policies: {})
        ::CloudConnector::Tokens.get(
          unit_primitive: :duo_agent_platform,
          resource: user,
          feature_setting: feature_setting,
          extra_claims: {
            skip_usage_cutoff: !!::Gitlab::Tracking::StandardContext.new.gitlab_team_member?(user&.id),
            tool_access_policies: tool_access_policies.to_json
          }
        )
      end

      def self.metadata(user, namespace: nil, project: nil)
        {
          extended_logging: enable_extended_logging?(user, namespace: namespace),
          is_team_member:
            ::Gitlab::Tracking::StandardContext.new.gitlab_team_member?(user&.id),
          tool_approval_for_session_enabled: tool_approval_for_session_enabled?(namespace: namespace,
            project: project)
        }
      end

      private_class_method def self.tool_approval_for_session_enabled?(namespace: nil, project: nil)
        return project.project_setting.tool_approval_for_session_enabled? if project

        return false unless namespace

        namespace.namespace_settings&.tool_approval_for_session_enabled?
      end

      private_class_method def self.enable_extended_logging?(user, namespace: nil)
        # For a self-hosted Duo instance, return the value of the
        # instance setting.
        return ::Ai::Setting.instance&.enabled_instance_verbose_ai_logs if self_hosted_url

        # Check if the feature flag is enabled for the user - this overrides namespace check
        return true if Feature.enabled?(:duo_workflow_extended_logging, user)

        # If a namespace is provided, return the value of the namespace setting
        return namespace.ai_usage_data_collection_enabled if namespace

        false
      end
    end
  end
end
