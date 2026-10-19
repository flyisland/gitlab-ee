# frozen_string_literal: true

module EE
  module Gitlab
    module RateLimit
      module PlanRules
        extend ActiveSupport::Concern

        # Slack sends these unauthenticated from a shared IP pool, so they get a wider per-IP bucket.
        SLACK_APP_RULES = [
          ::Labkit::RateLimit::Rule.new(
            name: 'sustained_slack_app_traffic_per_ip', action: :limit,
            match: { requester_id: nil, runner_id: nil, unauthenticated_limits_active: true,
                     unauthenticated_enforced: true, path: ::Gitlab::PathRegex.slack_app_api_route_regex },
            characteristics: %i[ip], limit: 1_000, period: 1.hour
          ),
          ::Labkit::RateLimit::Rule.new(
            name: 'sustained_slack_app_traffic_per_ip_log', action: :log,
            match: { requester_id: nil, runner_id: nil, unauthenticated_limits_active: true,
                     unauthenticated_enforced: false, path: ::Gitlab::PathRegex.slack_app_api_route_regex },
            characteristics: %i[ip], limit: 1_000, period: 1.hour
          ),
          ::Labkit::RateLimit::Rule.new(
            name: 'burst_slack_app_traffic_per_ip', action: :limit,
            match: { requester_id: nil, runner_id: nil, unauthenticated_limits_active: true,
                     unauthenticated_enforced: true, path: ::Gitlab::PathRegex.slack_app_api_route_regex },
            characteristics: %i[ip], limit: 100, period: 1.minute
          ),
          ::Labkit::RateLimit::Rule.new(
            name: 'burst_slack_app_traffic_per_ip_log', action: :log,
            match: { requester_id: nil, runner_id: nil, unauthenticated_limits_active: true,
                     unauthenticated_enforced: false, path: ::Gitlab::PathRegex.slack_app_api_route_regex },
            characteristics: %i[ip], limit: 100, period: 1.minute
          )
        ].freeze

        UNAUTHENTICATED_RULES = [
          ::Labkit::RateLimit::Rule.new(
            name: 'unauthenticated_traffic_per_ip', action: :limit,
            match: { requester_id: nil, runner_id: nil, git_http: false,
                     unauthenticated_limits_active: true, unauthenticated_enforced: true,
                     path: [
                       { nre: ::Gitlab::PathRegex.jira_connect_atlassian_route_regex },
                       { nre: ::Gitlab::PathRegex.group_scim_api_route_regex },
                       { nre: ::Gitlab::PathRegex.slack_app_api_route_regex },
                       { nre: ::Gitlab::PathRegex.dependency_proxy_containers_route_regex },
                       { nre: ::Gitlab::PathRegex.sign_in_flow_route_regex },
                       { nre: ::Gitlab::PathRegex.oauth_token_grant_route_regex },
                       { nre: ::Gitlab::PathRegex.runner_registration_api_route_regex },
                       { nre: ::Gitlab::PathRegex.discovery_document_route_regex },
                       { nre: ::Gitlab::PathRegex.oauth_dynamic_registration_route_regex },
                       { nre: ::Gitlab::PathRegex.unleash_api_route_regex },
                       { nre: ::Gitlab::PathRegex.deprecated_secure_files_installer_route_regex },
                       { nre: ::Gitlab::PathRegex.pipeline_trigger_api_route_regex },
                       { nre: ::Gitlab::PathRegex.alert_notification_route_regex },
                       { nre: ::Gitlab::PathRegex.mailgun_webhook_route_regex },
                       { nre: ::Gitlab::PathRegex.haproxy_api_health_check_route_regex }
                     ] },
            characteristics: %i[ip], limit: 60, period: 1.hour
          ),
          ::Labkit::RateLimit::Rule.new(
            name: 'unauthenticated_traffic_per_ip_log', action: :log,
            match: { requester_id: nil, runner_id: nil, git_http: false,
                     unauthenticated_limits_active: true, unauthenticated_enforced: false,
                     path: [
                       { nre: ::Gitlab::PathRegex.jira_connect_atlassian_route_regex },
                       { nre: ::Gitlab::PathRegex.group_scim_api_route_regex },
                       { nre: ::Gitlab::PathRegex.slack_app_api_route_regex },
                       { nre: ::Gitlab::PathRegex.dependency_proxy_containers_route_regex },
                       { nre: ::Gitlab::PathRegex.sign_in_flow_route_regex },
                       { nre: ::Gitlab::PathRegex.oauth_token_grant_route_regex },
                       { nre: ::Gitlab::PathRegex.runner_registration_api_route_regex },
                       { nre: ::Gitlab::PathRegex.discovery_document_route_regex },
                       { nre: ::Gitlab::PathRegex.oauth_dynamic_registration_route_regex },
                       { nre: ::Gitlab::PathRegex.unleash_api_route_regex },
                       { nre: ::Gitlab::PathRegex.deprecated_secure_files_installer_route_regex },
                       { nre: ::Gitlab::PathRegex.pipeline_trigger_api_route_regex },
                       { nre: ::Gitlab::PathRegex.alert_notification_route_regex },
                       { nre: ::Gitlab::PathRegex.mailgun_webhook_route_regex },
                       { nre: ::Gitlab::PathRegex.haproxy_api_health_check_route_regex }
                     ] },
            characteristics: %i[ip], limit: 60, period: 1.hour
          )
        ].freeze

        # Per user the limits are the published ones, so each budget is a :limit rule
        # and a :log twin split on the enforce flag. Limits per
        # https://docs.gitlab.com/user/gitlab_com/rate_limits/#rate-limits-by-plan.
        #
        # Each rule states info-gates-enforce itself rather than reading a combined
        # fact, which is why both plan_limits_<plan>_info and _enforce appear here.
        PLAN_RULES = [
          # Free - per user, enforced
          ::Labkit::RateLimit::Rule.new(
            name: 'sustained_traffic_per_user_free_plan', action: :limit,
            match: { requester_plan: 'free', requester_id: /./,
                     plan_limits_free_info: true, plan_limits_free_enforce: true,
                     path: [
                       { nre: ::Gitlab::PathRegex.usage_data_telemetry_api_route_regex },
                       { nre: ::Gitlab::PathRegex.git_operation_continuation_route_regex }
                     ] },
            characteristics: %i[requester_type requester_id], limit: 5_000, period: 1.hour
          ),
          ::Labkit::RateLimit::Rule.new(
            name: 'sustained_traffic_per_user_free_plan_log', action: :log,
            match: { requester_plan: 'free', requester_id: /./,
                     plan_limits_free_info: true, plan_limits_free_enforce: false,
                     path: [
                       { nre: ::Gitlab::PathRegex.usage_data_telemetry_api_route_regex },
                       { nre: ::Gitlab::PathRegex.git_operation_continuation_route_regex }
                     ] },
            characteristics: %i[requester_type requester_id], limit: 5_000, period: 1.hour
          ),
          ::Labkit::RateLimit::Rule.new(
            name: 'burst_traffic_per_user_free_plan', action: :limit,
            match: { requester_plan: 'free', requester_id: /./,
                     plan_limits_free_info: true, plan_limits_free_enforce: true,
                     path: [
                       { nre: ::Gitlab::PathRegex.usage_data_telemetry_api_route_regex },
                       { nre: ::Gitlab::PathRegex.git_operation_continuation_route_regex }
                     ] },
            characteristics: %i[requester_type requester_id], limit: 100, period: 1.minute
          ),
          ::Labkit::RateLimit::Rule.new(
            name: 'burst_traffic_per_user_free_plan_log', action: :log,
            match: { requester_plan: 'free', requester_id: /./,
                     plan_limits_free_info: true, plan_limits_free_enforce: false,
                     path: [
                       { nre: ::Gitlab::PathRegex.usage_data_telemetry_api_route_regex },
                       { nre: ::Gitlab::PathRegex.git_operation_continuation_route_regex }
                     ] },
            characteristics: %i[requester_type requester_id], limit: 100, period: 1.minute
          ),

          # Premium - per user, enforced
          ::Labkit::RateLimit::Rule.new(
            name: 'sustained_traffic_per_user_premium_plan', action: :limit,
            match: { requester_plan: 'premium', requester_id: /./,
                     plan_limits_premium_info: true, plan_limits_premium_enforce: true,
                     path: [
                       { nre: ::Gitlab::PathRegex.usage_data_telemetry_api_route_regex },
                       { nre: ::Gitlab::PathRegex.git_operation_continuation_route_regex }
                     ] },
            characteristics: %i[requester_type requester_id], limit: 15_000, period: 1.hour
          ),
          ::Labkit::RateLimit::Rule.new(
            name: 'sustained_traffic_per_user_premium_plan_log', action: :log,
            match: { requester_plan: 'premium', requester_id: /./,
                     plan_limits_premium_info: true, plan_limits_premium_enforce: false,
                     path: [
                       { nre: ::Gitlab::PathRegex.usage_data_telemetry_api_route_regex },
                       { nre: ::Gitlab::PathRegex.git_operation_continuation_route_regex }
                     ] },
            characteristics: %i[requester_type requester_id], limit: 15_000, period: 1.hour
          ),
          ::Labkit::RateLimit::Rule.new(
            name: 'burst_traffic_per_user_premium_plan', action: :limit,
            match: { requester_plan: 'premium', requester_id: /./,
                     plan_limits_premium_info: true, plan_limits_premium_enforce: true,
                     path: [
                       { nre: ::Gitlab::PathRegex.usage_data_telemetry_api_route_regex },
                       { nre: ::Gitlab::PathRegex.git_operation_continuation_route_regex }
                     ] },
            characteristics: %i[requester_type requester_id], limit: 1_250, period: 1.minute
          ),
          ::Labkit::RateLimit::Rule.new(
            name: 'burst_traffic_per_user_premium_plan_log', action: :log,
            match: { requester_plan: 'premium', requester_id: /./,
                     plan_limits_premium_info: true, plan_limits_premium_enforce: false,
                     path: [
                       { nre: ::Gitlab::PathRegex.usage_data_telemetry_api_route_regex },
                       { nre: ::Gitlab::PathRegex.git_operation_continuation_route_regex }
                     ] },
            characteristics: %i[requester_type requester_id], limit: 1_250, period: 1.minute
          ),

          # Ultimate - per user, enforced
          ::Labkit::RateLimit::Rule.new(
            name: 'sustained_traffic_per_user_ultimate_plan', action: :limit,
            match: { requester_plan: 'ultimate', requester_id: /./,
                     plan_limits_ultimate_info: true, plan_limits_ultimate_enforce: true,
                     path: [
                       { nre: ::Gitlab::PathRegex.usage_data_telemetry_api_route_regex },
                       { nre: ::Gitlab::PathRegex.git_operation_continuation_route_regex }
                     ] },
            characteristics: %i[requester_type requester_id], limit: 25_000, period: 1.hour
          ),
          ::Labkit::RateLimit::Rule.new(
            name: 'sustained_traffic_per_user_ultimate_plan_log', action: :log,
            match: { requester_plan: 'ultimate', requester_id: /./,
                     plan_limits_ultimate_info: true, plan_limits_ultimate_enforce: false,
                     path: [
                       { nre: ::Gitlab::PathRegex.usage_data_telemetry_api_route_regex },
                       { nre: ::Gitlab::PathRegex.git_operation_continuation_route_regex }
                     ] },
            characteristics: %i[requester_type requester_id], limit: 25_000, period: 1.hour
          ),
          ::Labkit::RateLimit::Rule.new(
            name: 'burst_traffic_per_user_ultimate_plan', action: :limit,
            match: { requester_plan: 'ultimate', requester_id: /./,
                     plan_limits_ultimate_info: true, plan_limits_ultimate_enforce: true,
                     path: [
                       { nre: ::Gitlab::PathRegex.usage_data_telemetry_api_route_regex },
                       { nre: ::Gitlab::PathRegex.git_operation_continuation_route_regex }
                     ] },
            characteristics: %i[requester_type requester_id], limit: 2_000, period: 1.minute
          ),
          ::Labkit::RateLimit::Rule.new(
            name: 'burst_traffic_per_user_ultimate_plan_log', action: :log,
            match: { requester_plan: 'ultimate', requester_id: /./,
                     plan_limits_ultimate_info: true, plan_limits_ultimate_enforce: false,
                     path: [
                       { nre: ::Gitlab::PathRegex.usage_data_telemetry_api_route_regex },
                       { nre: ::Gitlab::PathRegex.git_operation_continuation_route_regex }
                     ] },
            characteristics: %i[requester_type requester_id], limit: 2_000, period: 1.minute
          )
        ].freeze

        MCP_PATH_REGEX = ::Gitlab::RateLimit::RequestClassification::MCP_PATH_REGEX

        MCP_RULES = [
          ::Labkit::RateLimit::Rule.new(
            name: 'burst_mcp_traffic_per_user_free_plan', action: :limit,
            match: { requester_plan: 'free', requester_id: /./,
                     mcp_limits_free_info: true, mcp_limits_free_enforce: true,
                     path: MCP_PATH_REGEX },
            characteristics: %i[requester_type requester_id], limit: 60, period: 1.minute
          ),
          ::Labkit::RateLimit::Rule.new(
            name: 'burst_mcp_traffic_per_user_free_plan_log', action: :log,
            match: { requester_plan: 'free', requester_id: /./,
                     mcp_limits_free_info: true, mcp_limits_free_enforce: false,
                     path: MCP_PATH_REGEX },
            characteristics: %i[requester_type requester_id], limit: 60, period: 1.minute
          ),
          ::Labkit::RateLimit::Rule.new(
            name: 'burst_mcp_traffic_per_user_premium_plan', action: :limit,
            match: { requester_plan: 'premium', requester_id: /./,
                     mcp_limits_premium_info: true, mcp_limits_premium_enforce: true,
                     path: MCP_PATH_REGEX },
            characteristics: %i[requester_type requester_id], limit: 600, period: 1.minute
          ),
          ::Labkit::RateLimit::Rule.new(
            name: 'burst_mcp_traffic_per_user_premium_plan_log', action: :log,
            match: { requester_plan: 'premium', requester_id: /./,
                     mcp_limits_premium_info: true, mcp_limits_premium_enforce: false,
                     path: MCP_PATH_REGEX },
            characteristics: %i[requester_type requester_id], limit: 600, period: 1.minute
          ),
          ::Labkit::RateLimit::Rule.new(
            name: 'burst_mcp_traffic_per_user_ultimate_plan', action: :limit,
            match: { requester_plan: 'ultimate', requester_id: /./,
                     mcp_limits_ultimate_info: true, mcp_limits_ultimate_enforce: true,
                     path: MCP_PATH_REGEX },
            characteristics: %i[requester_type requester_id], limit: 600, period: 1.minute
          ),
          ::Labkit::RateLimit::Rule.new(
            name: 'burst_mcp_traffic_per_user_ultimate_plan_log', action: :log,
            match: { requester_plan: 'ultimate', requester_id: /./,
                     mcp_limits_ultimate_info: true, mcp_limits_ultimate_enforce: false,
                     path: MCP_PATH_REGEX },
            characteristics: %i[requester_type requester_id], limit: 600, period: 1.minute
          )
        ].freeze

        RULES = (SLACK_APP_RULES + UNAUTHENTICATED_RULES + MCP_RULES + PLAN_RULES).freeze

        class_methods do
          extend ::Gitlab::Utils::Override

          override :flags
          def flags
            ::Gitlab::RateLimit::FlagPolicy::FLAGS
          end

          override :active?
          def active?
            ::Gitlab::RateLimit::FlagPolicy.any_flag_enabled?
          end

          override :for_limiter
          def for_limiter(limiter_name)
            return [] unless limiter_name == ::Gitlab::RackAttack::LabkitRateLimit::ThrottleRegistry::GENERAL
            return [] unless ::Gitlab::RateLimit::FlagPolicy.gitlab_com?

            RULES
          end
        end
      end
    end
  end
end
