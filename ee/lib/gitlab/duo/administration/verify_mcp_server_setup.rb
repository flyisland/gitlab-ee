# frozen_string_literal: true

module Gitlab
  module Duo
    module Administration
      class VerifyMcpServerSetup
        PASS = "✔"
        FAIL = "✗"
        WARN = "⚠"
        INFO = "ℹ"

        attr_reader :diagnostics

        def initialize(username = nil)
          @username = username
          @user = User.find_by_username(username) if username.present?
          @diagnostics = {}
          @failures = 0
        end

        def execute
          print_header

          collect_system_info
          check_license
          check_duo_availability
          check_duo_features_enabled
          check_beta_features_enabled
          check_oauth_discovery
          check_instance_access_rules

          if @user
            check_user(@user)
          elsif @username.present?
            record(:user_lookup,
              status: :fail,
              message: "User '#{@username}' not found.")
          else
            puts "#{INFO} No username provided. Skipping user-specific checks."
            puts "  Re-run with: rake gitlab:duo:verify_mcp_server_setup[username]"
            puts ""
          end

          print_summary
          output_diagnostics
        end

        private

        def print_header
          puts <<~HEADER

            #{'═' * 63}
            GitLab MCP Server Setup Verification
            #{'═' * 63}
            This task verifies that the MCP server endpoint (/api/v4/mcp)
            is correctly configured and accessible on this instance.

          HEADER
        end

        def print_summary
          puts('═' * 63)

          if @failures == 0
            puts "#{PASS} All checks passed. MCP server should be functional."
          else
            puts "#{FAIL} #{@failures} check(s) failed. MCP server may not work."
          end

          puts('═' * 63)
          puts ""
        end

        def record(key, status:, message:, detail: nil)
          passed = status != :fail
          @failures += 1 unless passed

          icon = case status
                 when :pass then PASS
                 when :fail then FAIL
                 when :warn then WARN
                 else INFO
                 end

          puts "#{icon} #{message}"
          puts "  #{detail}" if detail
          puts ""

          @diagnostics[key] = { status: status.to_s.upcase, message: message, detail: detail }.compact
          passed
        end

        # --- System Info ---

        def collect_system_info
          puts "Collecting system information..."

          edition = ::Gitlab.ee? ? 'EE' : 'CE'

          @diagnostics[:system] = {
            gitlab_version: ::Gitlab::VERSION,
            gitlab_revision: ::Gitlab.revision,
            gitlab_edition: edition,
            rails_env: Rails.env,
            timestamp: Time.current.iso8601,
            instance_url: ::Gitlab.config.gitlab.url,
            user: @username
          }

          puts "  GitLab #{::Gitlab::VERSION} (#{edition}) — #{::Gitlab.config.gitlab.url}"
          puts ""
        end

        # --- License ---

        def check_license
          license = ::License.current

          unless license
            return record(:license,
              status: :fail,
              message: "No active license found.",
              detail: "MCP server requires a Premium or Ultimate license.")
          end

          has_mcp = ::License.feature_available?(:mcp_server)

          if has_mcp
            record(:license,
              status: :pass,
              message: "License: #{license.plan.titleize} — :mcp_server feature is available.")
          else
            record(:license,
              status: :fail,
              message: "License: #{license.plan.titleize} — :mcp_server feature is NOT available.",
              detail: "MCP server requires Premium or Ultimate license.")
          end
        end

        # --- Duo Settings ---

        def check_duo_availability
          settings = ::ApplicationSetting.current
          availability = settings.duo_availability

          case availability
          when :default_on
            record(:duo_availability,
              status: :pass,
              message: "Duo availability: 'On by default' (duo_features_enabled=true, lock=false)")
          when :default_off
            record(:duo_availability,
              status: :fail,
              message: "Duo availability: 'Off by default' (duo_features_enabled=false, lock=false)",
              detail: "MCP server requires duo_features_enabled=true. " \
                "Go to Admin > GitLab Duo and set availability to 'On by default'.")
          when :never_on
            record(:duo_availability,
              status: :fail,
              message: "Duo availability: 'Always off' (duo_features_enabled=false, lock=true)",
              detail: "MCP server is completely blocked. All Duo features are disabled. " \
                "Go to Admin > GitLab Duo and change availability.")
          else
            record(:duo_availability,
              status: :fail,
              message: "Duo availability: unknown (#{availability})")
          end
        end

        def check_duo_features_enabled
          enabled = ::Gitlab::CurrentSettings.duo_features_enabled?

          if enabled
            record(:duo_features_enabled,
              status: :pass,
              message: "duo_features_enabled: true")
          else
            record(:duo_features_enabled,
              status: :fail,
              message: "duo_features_enabled: false",
              detail: "The MCP server checks this in feature_available?. " \
                "Enable via: Admin > GitLab Duo > set to 'On by default'.")
          end
        end

        def check_beta_features_enabled
          if ::Gitlab::Saas.feature_available?(:gitlab_duo_saas_only)
            return record(:instance_level_ai_beta_features_enabled,
              status: :pass,
              message: "instance_level_ai_beta_features_enabled: skipped (SaaS)",
              detail: "On GitLab.com, instance-level beta features check is bypassed. " \
                "The MCP server checks namespace-level experiment_features_enabled instead.")
          end

          enabled = ::Gitlab::CurrentSettings.instance_level_ai_beta_features_enabled?

          if enabled
            record(:instance_level_ai_beta_features_enabled,
              status: :pass,
              message: "instance_level_ai_beta_features_enabled: true")
          else
            record(:instance_level_ai_beta_features_enabled,
              status: :fail,
              message: "instance_level_ai_beta_features_enabled: false",
              detail: "The MCP server requires experiment and beta features to be enabled. " \
                "Enable via: Admin > GitLab Duo > Turn on experiment and beta features.")
          end
        end

        # --- OAuth Discovery ---

        def check_oauth_discovery
          base_url = ::Gitlab.config.gitlab.url
          mcp_url = "#{base_url}/api/v4/mcp"

          # MCP is a Grape API endpoint mounted via API::Mcp::Base, not a Rails route.
          # Rails.application.routes.recognize_path cannot detect Grape routes because
          # the Grape API is mounted as a Rack application. Instead, we check that the
          # Grape API class is defined and has registered routes.
          mcp_api_available = defined?(::API::Mcp::Base) &&
            ::API::Mcp::Base.routes.any? { |route| route.path.include?('mcp') }

          if mcp_api_available
            record(:oauth_discovery,
              status: :pass,
              message: "MCP Grape API endpoint is loaded (API::Mcp::Base).",
              detail: "Endpoint: #{mcp_url}\n  " \
                "OAuth discovery: #{base_url}/.well-known/oauth-authorization-server/api/v4/mcp\n  " \
                "Dynamic registration: #{base_url}/oauth/register")
          else
            record(:oauth_discovery,
              status: :fail,
              message: "MCP Grape API endpoint (API::Mcp::Base) is NOT loaded.",
              detail: "This may indicate the MCP module is not loaded. Ensure you are running GitLab EE.")
          end
        end

        # --- Instance Access Rules ---

        def check_instance_access_rules
          ff_enabled = ::Feature.enabled?(:duo_access_through_namespaces, :instance)

          unless ff_enabled
            return record(:instance_access_rules,
              status: :info,
              message: "Feature flag :duo_access_through_namespaces is disabled.",
              detail: "Group-based access control for Duo features is not active. " \
                "All users with appropriate license can use Duo features.")
          end

          # rubocop:disable CodeReuse/ActiveRecord -- diagnostic task needs direct AR queries
          rules = ::Ai::FeatureAccessRule.includes(:through_namespace).order(:accessible_entity).to_a
          # rubocop:enable CodeReuse/ActiveRecord

          unless rules.any?
            return record(:instance_access_rules,
              status: :info,
              message: "No instance-level access rules configured (Ai::FeatureAccessRule).",
              detail: "All users with appropriate license will have access to Duo features.")
          end

          rule_descriptions = rules.map do |rule|
            group_name = if rule.through_namespace
                           "#{rule.through_namespace.full_path} (ID: #{rule.through_namespace.id})"
                         else
                           "Default (no group)"
                         end

            "  - Entity: #{rule.accessible_entity}, Group: #{group_name}"
          end

          dap_rules = rules.select { |r| r.accessible_entity == 'duo_agent_platform' }

          detail = "Rules:\n#{rule_descriptions.join("\n")}"
          if dap_rules.any?
            detail += "\n\n  NOTE: duo_agent_platform access rules exist and restrict agentic chat, " \
              "workflows, AI catalog, etc. However, the MCP server endpoint does NOT enforce " \
              "these rules. All users can access /api/v4/mcp regardless."
          end

          record(:instance_access_rules,
            status: :warn,
            message: "#{rules.size} instance-level access rule(s) configured.",
            detail: detail)
        end

        # --- User Checks ---

        def check_user(user)
          puts "--- User-Specific Checks for @#{user.username} (ID: #{user.id}) ---"
          puts ""

          check_user_active(user)
          check_user_duo_banned
          check_user_namespace_beta_features(user)
          check_user_allowed_duo_agent_platform(user)
          check_user_instance_access_rules(user)
        end

        def check_user_active(user)
          if user.active?
            record(:user_active,
              status: :pass,
              message: "User @#{user.username} is active.")
          else
            record(:user_active,
              status: :fail,
              message: "User @#{user.username} is NOT active (state: #{user.state}).")
          end
        end

        def check_user_duo_banned
          if ::Gitlab::CurrentSettings.duo_never_on?
            record(:user_duo_banned,
              status: :fail,
              message: "Duo features are set to 'Always off' — all users are banned from AI features.")
          else
            record(:user_duo_banned,
              status: :pass,
              message: "Duo features are not globally banned.")
          end
        end

        def check_user_namespace_beta_features(user)
          return unless ::Gitlab::Saas.feature_available?(:gitlab_duo_saas_only)
          return unless user.respond_to?(:any_group_with_mcp_server_enabled?)

          if user.any_group_with_mcp_server_enabled?
            record(:user_namespace_beta_features,
              status: :pass,
              message: "@#{user.username} belongs to a group with MCP server enabled.",
              detail: "On SaaS, the MCP server checks namespace-level experiment_features_enabled " \
                "via any_group_with_mcp_server_enabled? instead of the instance-level setting.")
          else
            record(:user_namespace_beta_features,
              status: :fail,
              message: "@#{user.username} does NOT belong to any group with MCP server enabled.",
              detail: "On SaaS, the MCP server requires the user to be a member of at least one " \
                "Premium or Ultimate group with experiment and beta features enabled. " \
                "Ask a group owner to enable experiment and beta features in group settings.")
          end
        end

        def check_user_allowed_duo_agent_platform(user)
          unless user.respond_to?(:allowed_to_use?)
            return record(:user_allowed_duo_agent_platform,
              status: :info,
              message: "User#allowed_to_use? not available (may not be EE).")
          end

          allowed = user.allowed_to_use?(:duo_agent_platform)

          if allowed
            record(:user_allowed_duo_agent_platform,
              status: :pass,
              message: "@#{user.username} is allowed to use :duo_agent_platform.",
              detail: "Checks add-on seats, Duo Core, and namespace access rules.")
          else
            record(:user_allowed_duo_agent_platform,
              status: :warn,
              message: "@#{user.username} is NOT allowed to use :duo_agent_platform.",
              detail: "The user lacks a Duo seat assignment or is blocked by access rules. " \
                "However, the MCP server does NOT check allowed_to_use? — it only checks " \
                "duo_features_enabled and instance_level_ai_beta_features_enabled. " \
                "The user may still be able to access /api/v4/mcp despite this.")
          end
        end

        def check_user_instance_access_rules(user)
          unless defined?(::Ai::FeatureAccessRule) && ::Ai::FeatureAccessRule.exists?
            return # Already reported in instance-level check
          end

          dap_access = ::Ai::FeatureAccessRule.accessible_for_user(user, 'duo_agent_platform').exists?
          classic_access = ::Ai::FeatureAccessRule.accessible_for_user(user, 'duo_classic').exists?

          if dap_access
            record(:user_dap_access_rule,
              status: :pass,
              message: "@#{user.username} has duo_agent_platform access via instance access rules.")
          else
            record(:user_dap_access_rule,
              status: :warn,
              message: "@#{user.username} does NOT have duo_agent_platform access via instance access rules.",
              detail: "This blocks agentic chat, workflows, AI catalog, etc. " \
                "BUT the MCP server endpoint does NOT enforce this — " \
                "user can still access /api/v4/mcp.")
          end

          if classic_access
            record(:user_classic_access_rule,
              status: :pass,
              message: "@#{user.username} has duo_classic access via instance access rules.")
          else
            record(:user_classic_access_rule,
              status: :warn,
              message: "@#{user.username} does NOT have duo_classic access via instance access rules.",
              detail: "This blocks classic chat, code suggestions, etc.")
          end
        end

        def output_diagnostics
          puts ""
          puts('═' * 63)
          puts "DIAGNOSTIC SUMMARY (sanitize before sharing with support)"
          puts('═' * 63)
          puts ::Gitlab::Json.pretty_generate(@diagnostics)
          puts ""
          puts "NOTE: Review the above output and remove any sensitive information"
          puts "before sharing with GitLab support."
        end
      end
    end
  end
end
