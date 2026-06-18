# frozen_string_literal: true

module Gitlab
  module DuoWorkflow
    # Builds the shell commands that install and configure the glab CLI inside a
    # Duo Agent Platform workload.
    class GlabSetup
      # Version only enforced if glab is not already installed in the image.
      VERSION = "1.100.0"

      GLAB_BIN_DIR = "/tmp/bin"
      GLAB_EXTRACT_DIR = "/tmp/glab"

      def initialize(current_user:)
        @current_user = current_user
      end

      def commands
        setup_commands + config_commands + skills_install_commands
      end

      private

      def setup_commands
        glab_version_warning =
          'glab not working. Execution will continue but it is recommended that glab ' \
            'is properly installed to allow Agents access to GitLab.'

        [
          install_command,
          %(export PATH="#{GLAB_BIN_DIR}:$PATH"),
          %(which glab || echo "glab not in PATH"),
          %(glab version || echo "#{glab_version_warning}")
        ]
      end

      def config_commands
        [
          "mkdir -p ~/.config/glab-cli",
          config_file_command,
          "chmod 600 ~/.config/glab-cli/config.yml"
        ]
      end

      def skills_install_commands
        # Skills must be present before `duo run` so the Duo CLI can discover
        # them at startup and include them in the workspace_agent_skills context
        # sent to the AI Gateway. Global install (~/.agents/skills/) keeps
        # skill files outside the repo so they are not accidentally committed.
        [
          %(glab skills install --global || echo "Warning: glab skills install failed; continuing without glab skills")
        ]
      end

      def install_command
        # Install runs in a subshell so a failure (unsupported arch, network
        # error, bad archive) is caught by `||` and printed as a warning
        # instead of halting the runner. The downstream `glab version` check
        # surfaces an unusable install; users who want to proceed without
        # glab can do so.
        <<~BASH.squish
          if command -v glab > /dev/null 2>&1; then
            echo "glab already present, skipping installation";
          else
            (
              set -o pipefail &&
              echo "Installing glab@#{VERSION}..." &&
              GLAB_OS=$(uname -s | tr '[:upper:]' '[:lower:]') &&
              GLAB_ARCH=$(uname -m) &&
              case "$GLAB_ARCH" in
                x86_64) GLAB_ARCH=amd64 ;;
                aarch64|arm64) GLAB_ARCH=arm64 ;;
                *) echo "Unsupported architecture: $GLAB_ARCH" >&2; exit 1 ;;
              esac &&
              mkdir -p #{GLAB_BIN_DIR} #{GLAB_EXTRACT_DIR} &&
              curl --silent --show-error --fail --location "#{download_url}" | tar -xz -C #{GLAB_EXTRACT_DIR} &&
              mv #{GLAB_EXTRACT_DIR}/bin/glab #{GLAB_BIN_DIR}/
            ) || echo "Warning: glab installation failed; continuing without glab" >&2;
          fi
        BASH
      end

      def config_file_command
        # OAuth token settings are just used to suppress refresh behavior
        # and don't reflect actual token expiry date
        <<~GLAB_CONFIG_COMMAND.chomp
          cat > ~/.config/glab-cli/config.yml <<GLAB_CONFIG
          hosts:
            #{host}:
              is_oauth2: "true"
              client_id: "bypass"
              oauth2_refresh_token: ""
              oauth2_expiry_date: "01 Jan 2050 00:00 UTC"
              api_host: #{host}
              api_protocol: #{protocol}
              user: #{@current_user.username}
          check_update: "false"
          git_protocol: #{protocol}
          GLAB_CONFIG
        GLAB_CONFIG_COMMAND
      end

      def download_url
        "https://gitlab.com/gitlab-org/cli/-/releases/v#{VERSION}/downloads/" \
          "glab_#{VERSION}_${GLAB_OS}_${GLAB_ARCH}.tar.gz"
      end

      def host
        gitlab_uri.port == gitlab_uri.default_port ? gitlab_uri.host : "#{gitlab_uri.host}:#{gitlab_uri.port}"
      end

      def protocol
        gitlab_uri.scheme
      end

      def gitlab_uri
        @gitlab_uri ||= URI.parse(Gitlab.config.gitlab.url)
      end
    end
  end
end
