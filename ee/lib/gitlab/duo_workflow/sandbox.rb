# frozen_string_literal: true

module Gitlab
  module DuoWorkflow
    # Service responsible for configuring SRT (Secure Runtime) sandbox for Duo Workflow execution
    # This class configures network firewall and filesystem restrictions for DAP ambient sessions.
    class Sandbox
      DUO_AGENT_PLATFORM_WRITE_DIR = "/tmp/gitlab_duo_agent_platform"

      def initialize(current_user:, duo_workflow_service_url:, duo_config:, unmask_env_variables: [])
        @current_user = current_user
        @duo_workflow_service_url = duo_workflow_service_url
        @duo_config = duo_config
        @unmask_env_variables = unmask_env_variables
      end

      # Wraps a command with SRT sandbox if enabled
      # @param command [String] The command to wrap
      # @return [Array<String>] Array with shell commands
      def wrap_command(command)
        srt_settings_path = "#{DUO_AGENT_PLATFORM_WRITE_DIR}/srt-settings.json"
        env_vars_flags = build_env_vars_flags
        [
          %(if which srt > /dev/null; then),
          %(  echo "SRT found, creating config..."),
          %(  echo '#{Gitlab::Json.dump(srt_config)}' > #{srt_settings_path}),
          %(  echo "Testing SRT sandbox capabilities..."),
          %(  if srt --settings #{srt_settings_path} true 2>/dev/null; then),
          %(    echo "SRT sandbox test successful, running command: #{command}"),
          %(    export GITLAB_WORKFLOW_SANDBOX=true),
          %(    unshare -m env -i #{env_vars_flags} srt --settings #{srt_settings_path} #{command}),
          %(  else),
          %(    echo "Warning: SRT found but can't create sandbox (insufficient privileges), running command directly"),
          %(    echo "For more details visit: https://docs.gitlab.com/user/duo_agent_platform/flows/execution/#configure-runners"),
          %(    #{command}),
          %(  fi),
          %(else),
          %(  echo "Warning: srt is not installed or not in PATH, running command directly without sandbox"),
          %(  echo "For more details visit: https://docs.gitlab.com/user/duo_agent_platform/flows/execution/#configure-runners"),
          %(  #{command}),
          %(fi),
          %(echo "Command execution completed with exit code: $?")
        ]
      end

      def environment_variables
        {
          NPM_CONFIG_CACHE: "#{DUO_AGENT_PLATFORM_WRITE_DIR}/.npm-cache",
          GITLAB_LSP_STORAGE_DIR: DUO_AGENT_PLATFORM_WRITE_DIR,
          TMPDIR: DUO_AGENT_PLATFORM_WRITE_DIR
        }
      end

      def setup_sandbox_commands
        [
          %(mkdir -p #{DUO_AGENT_PLATFORM_WRITE_DIR})
        ]
      end

      private

      # Builds environment variable flags for unshare command
      # Uses variable references (e.g., $VAR) instead of embedding values to avoid logging sensitive data
      # Combines passed variables with sandbox-specific environment variables
      # @return [String] Environment variable flags formatted for unshare command
      def build_env_vars_flags
        all_vars = @unmask_env_variables + environment_variables.keys + %w[PATH GITLAB_WORKFLOW_SANDBOX]
        all_vars.uniq.map { |var| "#{var}=\"$#{var}\"" }.join(' ')
      end

      # Generates SRT configuration for network and filesystem restrictions
      # @return [Hash] SRT configuration
      def srt_config
        allow_all_unix_sockets = load_duo_config_all_unix_sockets

        duo_config_allow_domains, duo_config_deny_domains = load_duo_config_domains

        allowed_domains = (minimal_allowlisted_domains + duo_config_allow_domains).compact.uniq
        denied_domains = duo_config_deny_domains.compact.uniq
        {
          network: {
            allowedDomains: allowed_domains,
            deniedDomains: denied_domains,
            allowAllUnixSockets: allow_all_unix_sockets
          },
          filesystem: {
            denyRead: ["~/.ssh"],
            allowWrite: ["./", DUO_AGENT_PLATFORM_WRITE_DIR],
            denyWrite: [],
            allowGitConfig: true
          }
        }
      end

      # Returns list of required domains allowed for network access
      # @return [Array<String>] Allowed domains
      def minimal_allowlisted_domains
        [
          "host.docker.internal",
          "localhost",
          extract_domain(Gitlab.config.gitlab.url),
          "*.#{extract_domain(Gitlab.config.gitlab.url)}",
          extract_domain(@duo_workflow_service_url)
        ]
      end

      def load_duo_config_all_unix_sockets
        default_allow_all_unix_sockets = false
        network_policy = @duo_config.network_policy
        return default_allow_all_unix_sockets unless network_policy

        network_policy.fetch("allow_all_unix_sockets", default_allow_all_unix_sockets)
      end

      def load_duo_config_domains
        network_policy = @duo_config.network_policy
        return [[], []] unless network_policy

        allowed_domains = network_policy.fetch("allowed_domains", [])
        denied_domains = network_policy.fetch("denied_domains", [])

        if network_policy["include_recommended_allowed"]
          allowed_domains += NetworkPolicyDomains.recommended_allowed_domains
        end

        [allowed_domains, denied_domains]
      end

      # Extracts domain from a URL
      # @param url [String] URL to extract domain from
      # @return [String, nil] Extracted domain
      def extract_domain(url)
        return url if url.blank?

        # Try parsing as a full URI first
        uri = URI.parse(url)
        return uri.host if uri.host

        # If no host found, try parsing as just host:port by prepending //
        uri = URI.parse("//#{url}")
        uri.host
      rescue URI::InvalidURIError
        # Fallback: if it contains a colon, assume it's host:port
        url.include?(':') ? url.split(':').first : url
      end
    end
  end
end
