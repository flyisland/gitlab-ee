# frozen_string_literal: true

module Ai
  module DuoWorkflows
    class StartWorkflowService
      IMAGE_PATH = "gitlab-org/duo-workflow/default-docker-image/workflow-generic-image:v0.0.12"
      HARDENED_IMAGE_PATH = "gitlab-org/duo-workflow/default-docker-image/workflow-generic-image-hardened:v0.0.12"
      DUO_CLI_VERSION = "8.109.0"
      DUO_CLI_PROJECT_ID = "46519181"
      DUO_CLI_INSTALL_DIR = "/usr/local/bin"
      DUO_CLI_REGISTRY_BASE_URL = "https://gitlab.com/api/v4/projects"
      DWS_STANDARD_CONTEXT_CATEGORY = "agent_platform_standard_context"
      DWS_TRIGGER_CONTEXT_CATEGORY = "agent_platform_trigger_context"
      # /tmp is within the sandbox allowWrite list, so this directory is writable by the agent.
      GIT_HOOKS_DIR = "/tmp/git-hooks"
      # Reads the OAuth token from GIT_PASSWORD at invocation time so the token is
      # never written into the clone URL or .git/config on disk.
      GIT_CREDENTIAL_HELPER = '!f() { echo "username=oauth"; echo "password=${GIT_PASSWORD}"; }; f'

      def initialize(workflow:, params:)
        @workflow = workflow
        @current_user = workflow.user
        @service_account = params[:service_account]
        @params = params
      end

      def execute
        unless @workflow.project_level?
          return ServiceResponse.error(
            message: 'Only project-level workflow is supported',
            reason: :unprocessable_entity)
        end

        unless @current_user.can?(:execute_duo_workflow_in_ci, @workflow)
          return ServiceResponse.error(message: 'Can not execute workflow in CI',
            reason: :feature_unavailable)
        end

        if duo_config.config_present? && !duo_config.valid_format?
          config_file = ::Gitlab::DuoAgentPlatform::Config::CONFIG_FILE_NAME
          errors = duo_config.validation_errors.join('; ').first(2000)
          return ServiceResponse.error(
            message: "Invalid config file #{config_file} -> #{errors}",
            reason: :unprocessable_entity)
        end

        unless service_account.present?
          return ServiceResponse.error(
            message: 'Service account is required but was not provided.',
            reason: :invalid_service_account)
        end

        link_composite_identity

        branch_response = create_workload_branch
        unless branch_response.success?
          return ServiceResponse.error(message: branch_response.message, reason: branch_response.reason)
        end

        @ref = branch_response.payload[:ref]

        run_workload
      end

      private

      attr_reader :service_account

      # Derives the legacy DUO_WORKFLOW_DEFINITION env var from the explicit
      # routing components. Older CLI versions use this for flow routing;
      # newer ones use FLOW_CONFIG_ID + FLOW_CONFIG_SCHEMA_VERSION directly.
      #
      # Custom (non-foundational) flows have no flow_config_id; fall back to
      # the stable identity on the workflow record (e.g. 'ai_catalog_agent').
      def resolved_workflow_definition
        return @workflow.workflow_definition if @params[:flow_config_id].blank?

        "#{@params[:flow_config_id]}/#{@params[:flow_config_schema_version]}"
      end

      def run_workload
        service = ::Ci::Workloads::RunWorkloadService.new(
          project: project,
          current_user: service_account,
          source: :duo_workflow,
          workload_definition: workload_definition,
          ref: @ref,
          # `duo_workflow_definition:` uses the stable identity (@workflow.workflow_definition,
          # e.g. "developer/v1") - NOT the resolved routing value. This string is the key for:
          #   - Pipeline rate-limit exclusions (Gitlab::Ci::Pipeline::Chain::Limit::RateLimit)
          #   - Credits/billing (Ai::UsageQuotaService -> CustomersDot feature_qualified_name)
          #   - Analytics (`duo_workflow_workload_completed` event property)
          # Changing it on a feature-flag route-switch would silently affect all three.
          # Routing-derived value is used for DUO_WORKFLOW_DEFINITION env var below.
          duo_workflow_definition: @workflow.workflow_definition
        )
        response = service.execute

        if response.success?
          workload = response.payload
          workflow_workload = @workflow.workflows_workloads.create(project_id: project.id, workload_id: workload.id)
          unless workflow_workload.persisted?
            return ServiceResponse.error(
              message: workflow_workload.errors.full_messages.join(', '),
              reason: :workflow_workload_failure
            )
          end

          ServiceResponse.success(payload: { workload_id: workload.id })
        else
          ServiceResponse.error(message: response.message, reason: :workload_failure)
        end
      end

      def workload_definition
        ::Ci::Workloads::WorkloadDefinition.new do |d|
          d.image = @workflow.image.presence || configured_image || instance_image
          d.variables = variables
          d.id_tokens = duo_config.id_tokens
          d.commands = commands
          d.cache = cache_configuration if cache_configuration.present?
          d.tags = [::Ai::DuoWorkflows::Workflow::WORKLOAD_TAG]
        end
      end

      def configured_image
        return unless project

        duo_config.default_image
      end

      def instance_image
        host = ci_template_registry_host

        # Return the host if it appears to be a full path to an image rather than
        # just a registry domain:
        return host if host.include?('/')

        "#{host}/#{instance_image_path}"
      end

      def instance_image_path
        if Feature.enabled?(:duo_workflow_use_hardened_image, project)
          HARDENED_IMAGE_PATH
        else
          IMAGE_PATH
        end
      end

      def ci_template_registry_host
        Gitlab::CurrentSettings.duo_workflows_default_image_registry.presence || 'registry.gitlab.com'
      end

      def sandbox
        @sandbox ||= ::Gitlab::DuoWorkflow::Sandbox.new(
          current_user: @current_user,
          duo_workflow_service_url: duo_workflow_service_url,
          duo_config: duo_config,
          unmask_env_variables: unmask_env_variables
        )
      end

      def duo_config
        @duo_config ||= ::Gitlab::DuoAgentPlatform::Config.new(project)
      end

      def cache_configuration
        return unless project

        duo_config.cache_config
      end

      def id_tokens
        return {} unless project

        duo_config.id_tokens || {}
      end

      # A list of environment variables which should not be stripped from the
      # running agent execution environment.
      def unmask_env_variables
        base_variables.merge(git_environment_variables)
          .merge(token_variables)
          .merge(id_tokens)
          .keys
      end

      def setup_script_commands
        return [] unless project

        duo_config.setup_script || []
      end

      # Installs a commit-msg git hook that appends Duo session trailers to every
      # commit. The hook is placed in GIT_HOOKS_DIR (/tmp/git-hooks), which is
      # within the sandbox allowWrite list. core.hooksPath is set via GIT_CONFIG_*
      # environment variables so all git invocations pick it up automatically,
      # regardless of whether they use run_git_command or run_command.
      #
      # The hook is only installed when session tracking is enabled for the project.
      def git_hooks_setup_commands
        return [] unless project.project_setting.dap_session_tracking_enabled?

        duo_session_url = @workflow.web_url

        # --if-exists addIfDifferent makes the operation idempotent: trailers are
        # only appended when not already present, so re-runs and amends are safe.
        hook_lines = [
          "#!/bin/sh",
          # Run the pre-existing (framework) commit-msg hook first, if we saved one.
          # Preserve its ability to reject the commit by propagating a non-zero exit.
          %(if [ -x "#{GIT_HOOKS_DIR}/commit-msg.orig" ]; then "#{GIT_HOOKS_DIR}/commit-msg.orig" "$1" || exit $?; fi),
          "git interpret-trailers \\",
          "  --if-exists addIfDifferent \\",
          "  --trailer #{Shellwords.escape('Co-authored-by: GitLab Duo <duo@gitlab.com>')} \\",
          "  --trailer #{Shellwords.escape("Duo-Session: #{duo_session_url}")} \\",
          "  --in-place \"$1\""
        ]

        hook_content = Shellwords.escape(hook_lines.join("\n"))

        [
          %(mkdir -p #{GIT_HOOKS_DIR}),
          # If a commit-msg hook already exists (e.g. installed by lefthook during
          # setup_script), preserve it as commit-msg.orig so our hook can chain to it.
          %([ -f #{GIT_HOOKS_DIR}/commit-msg ] && ) +
            %(mv #{GIT_HOOKS_DIR}/commit-msg #{GIT_HOOKS_DIR}/commit-msg.orig || true),
          %(printf %s #{hook_content} > #{GIT_HOOKS_DIR}/commit-msg),
          %(chmod +x #{GIT_HOOKS_DIR}/commit-msg)
        ]
      end

      def full_clone?
        return false unless @workflow.workflow_definition == "developer/v1"

        Feature.enabled?(:dap_full_clone, project)
      end

      def git_clone_variables
        return { GIT_STRATEGY: 'none', GIT_LFS_SKIP_SMUDGE: 1 } if full_clone?

        vars = {}

        if Feature.enabled?(:dap_git_tree_zero_option, project)
          vars[:GIT_DEPTH] = 1 if @params.fetch(:shallow_clone, false)
          vars[:GIT_FETCH_EXTRA_FLAGS] = "--filter=tree:0"
        else
          vars[:GIT_DEPTH] = 1 if @params.fetch(:shallow_clone, true)
          vars[:GIT_FETCH_EXTRA_FLAGS] = "--filter=blob:none"
        end

        vars[:GIT_LFS_SKIP_SMUDGE] = 1
        vars
      end

      def git_environment_variables
        vars = {
          GIT_TERMINAL_PROMPT: '0',
          GIT_CONFIG_NOSYSTEM: '1',
          GIT_AUTHOR_NAME: git_user_name(service_account),
          GIT_AUTHOR_EMAIL: git_user_email(service_account),
          GIT_COMMITTER_NAME: git_user_name(@current_user),
          GIT_COMMITTER_EMAIL: git_user_email(@current_user),
          GIT_CONFIG_KEY_0: 'safe.directory',
          GIT_CONFIG_VALUE_0: '/builds/*',
          GIT_CONFIG_KEY_1: "url.#{Gitlab.config.gitlab.url}/.insteadOf",
          GIT_CONFIG_VALUE_1: "git@#{URI.parse(Gitlab.config.gitlab.url).host}:"
        }

        count = 2

        if project.project_setting.dap_session_tracking_enabled?
          # Install a git hooks directory via GIT_CONFIG so that all git commands
          # (including those run via run_command / run_shell_command) pick up the
          # commit-msg hook that appends the session trailers.
          vars[:"GIT_CONFIG_KEY_#{count}"] = 'core.hooksPath'
          vars[:"GIT_CONFIG_VALUE_#{count}"] = GIT_HOOKS_DIR
          count += 1
        end

        if full_clone?
          # GIT_STRATEGY=none means the runner injects no credentials, so supply a
          # helper that authenticates our own clone and the agent's later git ops.
          vars[:"GIT_CONFIG_KEY_#{count}"] = 'credential.helper'
          vars[:"GIT_CONFIG_VALUE_#{count}"] = GIT_CREDENTIAL_HELPER
          count += 1
        end

        # Authenticate proactively (first request, not after a 401). No-op on
        # git < 2.46, which silently ignores the key. Scoped to the GitLab host
        # so credentials are not sent proactively to other hosts (submodules,
        # LFS, bundle URIs) - matching the runner's FF_USE_GIT_PROACTIVE_AUTH.
        vars[:"GIT_CONFIG_KEY_#{count}"] = "http.#{Gitlab.config.gitlab.url}.proactiveAuth"
        vars[:"GIT_CONFIG_VALUE_#{count}"] = 'basic'
        count += 1

        vars.merge(GIT_CONFIG_COUNT: count.to_s)
      end

      def base_variables
        secure = Gitlab::DuoWorkflow::Client.secure?(feature_setting: feature_setting)

        base_variables = {
          DUO_WORKFLOW_ADDITIONAL_CONTEXT_CONTENT: serialized_flow_additional_context,
          DUO_WORKFLOW_BASE_PATH: './',
          DUO_WORKFLOW_DEFINITION: resolved_workflow_definition,
          DUO_WORKFLOW_FLOW_CONFIG: serialized_duo_flow_config,
          DUO_WORKFLOW_FLOW_CONFIG_ID: @params[:flow_config_id],
          DUO_WORKFLOW_FLOW_CONFIG_SCHEMA_VERSION: @params[:flow_config_schema_version],
          DUO_WORKFLOW_FLOW_VERSION: @params[:flow_version],
          DUO_WORKFLOW_GOAL: workflow_goal,
          DUO_WORKFLOW_SOURCE_BRANCH: @params.fetch(:source_branch, nil),
          DUO_WORKFLOW_WORKFLOW_ID: String(@workflow.id),
          DUO_WORKFLOW_SERVICE_SERVER: duo_workflow_service_url,
          DUO_WORKFLOW_SERVICE_REALM: ::CloudConnector.gitlab_realm,
          DUO_WORKFLOW_GLOBAL_USER_ID: Gitlab::GlobalAnonymousId.user_id(@current_user),
          DUO_WORKFLOW_INSTANCE_ID: Gitlab::GlobalAnonymousId.instance_id,
          DUO_WORKFLOW_INSECURE: secure ? 'false' : 'true',
          DUO_WORKFLOW_DEBUG: Gitlab::DuoWorkflow::Client.debug_mode? ? 'true' : 'false',
          LOG_LEVEL: 'debug',
          DUO_WORKFLOW_GIT_HTTP_BASE_URL: Gitlab.config.gitlab.url,
          DUO_WORKFLOW_GIT_HTTP_USER: "oauth",
          DUO_WORKFLOW_GIT_USER_EMAIL: git_user_email(@current_user),
          DUO_WORKFLOW_GIT_USER_NAME: git_user_name(@current_user),
          DUO_WORKFLOW_GIT_AUTHOR_EMAIL: git_user_email(service_account),
          DUO_WORKFLOW_GIT_AUTHOR_USER_NAME: git_user_name(service_account),
          DUO_WORKFLOW_METADATA: workflow_metadata,
          DUO_WORKFLOW_PROJECT_ID: project.id,
          DUO_WORKFLOW_NAMESPACE_ID: project.root_namespace.id,
          GITLAB_BASE_URL: Gitlab.config.gitlab.url,
          GITLAB_PROJECT_PATH: project.full_path,
          AGENT_PLATFORM_GITLAB_VERSION: Gitlab.version_info.to_s,
          AGENT_PLATFORM_MODEL_METADATA: agent_platform_model_metadata_json,
          AGENT_PLATFORM_FEATURE_SETTING_NAME: feature_setting_name,
          GITLAB_ENABLE_GLOBAL_SKILLS: 'true',
          DUO_SESSION_TRACKING_ENABLED: project.project_setting.dap_session_tracking_enabled?.to_s,
          # The Duo Workflow executor image pins a specific glab version,
          # so glab's post-command "update available" nudge isn't actionable
          # for users. Silence it to avoid agents relaying misleading hints.
          GLAB_CHECK_UPDATE: '0'
        }

        base_variables[:LANGSMITH_TRACE] = @params[:langsmith_trace] if @params[:langsmith_trace].present?

        base_variables
      end

      def workflow_goal
        @params[:goal]
      end

      def token_variables
        {
          GITLAB_OAUTH_TOKEN: @params[:workflow_oauth_token],
          DUO_WORKFLOW_SERVICE_TOKEN: @params[:workflow_service_token],
          DUO_WORKFLOW_GIT_HTTP_PASSWORD: @params[:workflow_oauth_token],
          GITLAB_TOKEN: @params[:workflow_oauth_token],
          GIT_PASSWORD: @params[:workflow_oauth_token]
        }
      end

      def variables
        git_clone_variables
          .merge(base_variables)
          .merge(token_variables)
          .merge(git_environment_variables)
          .merge(sandbox.environment_variables)
      end

      def commands
        # full_clone_setup_commands is empty unless the full-clone flag is on; when on
        # it clones before git hooks and setup_script run so both see a populated repo.
        sandbox.setup_sandbox_commands +
          full_clone_setup_commands +
          setup_script_commands +
          git_hooks_setup_commands +
          main_workflow_commands
      end

      # Authentication relies on the credential.helper installed in
      # #git_environment_variables, so the clone URL stays credential-free.
      #
      # We clone into a sibling directory and move only .git into the build dir,
      # then check out. This preserves any cache or artifacts the runner restored
      # into the build dir (a plain `git clone` refuses a non-empty target, and
      # deleting the dir first would discard the restored cache). The sibling is on
      # the same filesystem, so the move is a rename, not a copy of the repository.
      def full_clone_setup_commands
        return [] unless full_clone?

        git_available_guard = 'command -v git >/dev/null 2>&1 || ' \
          '{ echo "git is required for the full clone but is not installed in the image. ' \
          'Add git to your image (not only setup_script)." >&2; exit 1; }'

        [
          git_available_guard,
          'rm -rf "${CI_PROJECT_DIR}.dap-tmp"',
          'git clone --no-checkout --filter=blob:none ' \
            '"${DUO_WORKFLOW_GIT_HTTP_BASE_URL}/${GITLAB_PROJECT_PATH}.git" "${CI_PROJECT_DIR}.dap-tmp"',
          'rm -rf "${CI_PROJECT_DIR}/.git"',
          'mv "${CI_PROJECT_DIR}.dap-tmp/.git" "${CI_PROJECT_DIR}/.git"',
          'rm -rf "${CI_PROJECT_DIR}.dap-tmp"',
          'cd "$CI_PROJECT_DIR"',
          'git checkout -f "${DUO_WORKFLOW_SOURCE_BRANCH:-$CI_DEFAULT_BRANCH}"'
        ]
      end

      def main_workflow_commands
        oauth_remote_commands + [
          %(echo $DUO_WORKFLOW_DEFINITION),
          %(echo $DUO_WORKFLOW_FLOW_CONFIG_ID),
          %(echo $DUO_WORKFLOW_FLOW_VERSION),
          %(echo $DUO_WORKFLOW_GOAL),
          %(echo $DUO_WORKFLOW_SOURCE_BRANCH),
          %(echo $DUO_WORKFLOW_FLOW_CONFIG),
          %(echo $DUO_WORKFLOW_FLOW_CONFIG_SCHEMA_VERSION),
          # NOTE: Do not echo $DUO_WORKFLOW_ADDITIONAL_CONTEXT_CONTENT. It can carry
          # sensitive payloads (e.g. the raw secret for the secrets_fp_detection flow,
          # or diffs/file contents for other flows) and the job trace is readable by
          # low-privilege/anonymous users. See gitlab-org/gitlab#602194.
          %(echo Starting Workflow #{@workflow.id})
        ] + set_up_executor_commands
      end

      # Point origin at an oauth URL so the runner's insteadOf rules (which inject the
      # CI job token) do not apply - they only match http://host, not http://user@host.
      # Not needed in full-clone mode, where we clone with our own credentials.
      def oauth_remote_commands
        return [] if full_clone?

        [
          "git remote set-url origin " \
            '"$(echo "${DUO_WORKFLOW_GIT_HTTP_BASE_URL}" | ' \
            "sed 's|://|://oauth:'\"${GIT_PASSWORD}\"'@|')/${GITLAB_PROJECT_PATH}.git\""
        ]
      end

      def set_up_executor_commands
        cli_setup_commands = if Feature.enabled?(:duo_agent_platform_executor_binary, project)
                               binary_cli_install_commands
                             else
                               npm_cli_install_commands
                             end

        wrapped_commands = sandbox.wrap_command(executor_cli_command)

        cli_setup_commands + glab_setup.commands + orbit_local_setup.commands + wrapped_commands
      end

      def binary_cli_install_commands
        registry_url = "#{DUO_CLI_REGISTRY_BASE_URL}/#{DUO_CLI_PROJECT_ID}" \
          "/packages/generic/duo-cli/#{DUO_CLI_VERSION}/${BINARY}"

        binary_install_command = [
          "command -v duo > /dev/null 2>&1 && ",
          "echo \"duo-cli already present, skipping installation\" || ",
          "{ ",
          "OS=$(uname -s | tr '[:upper:]' '[:lower:]') && ",
          "ARCH=$(uname -m) && ",
          "case \"${ARCH}\" in x86_64|amd64) ARCH=x64 ;; arm64|aarch64) ARCH=arm64 ;; *) " \
            "echo \"Unsupported architecture: ${ARCH}\" && exit 1 ;; esac && ",
          "BINARY=\"duo-${OS}-${ARCH}\" && ",
          "DOWNLOAD_URL=\"#{registry_url}\" && ",
          "echo \"Downloading duo-cli #{DUO_CLI_VERSION} (${BINARY})...\" && ",
          "curl -fsSL \"${DOWNLOAD_URL}\" -o \"#{DUO_CLI_INSTALL_DIR}/duo\" && ",
          "chmod +x \"#{DUO_CLI_INSTALL_DIR}/duo\"; ",
          "} || exit 1"
        ].join

        [
          binary_install_command,
          %(which duo || echo "duo not in PATH"),
          %(duo --version || echo "duo version check failed")
        ]
      end

      def npm_cli_install_commands
        npm_install_command = [
          "command -v duo > /dev/null 2>&1 && ",
          "echo \"duo-cli already present, skipping installation\" || ",
          "{ echo \"Installing @gitlab/duo-cli@#{DUO_CLI_VERSION}...\" && ",
          "npm install -g @gitlab/duo-cli@#{DUO_CLI_VERSION}; }"
        ].join

        [
          npm_install_command,
          %(ls -la $(npm root -g)/@gitlab/duo-cli || echo "GitLab Duo package not found"),
          %(export PATH="$(npm bin -g):$PATH"),
          %(which duo || echo "duo not in PATH"),
          %(duo --version || echo "duo version check failed")
        ]
      end

      def executor_cli_command
        %(duo run --existing-session-id #{@workflow.id} --connection-type websocket)
      end

      def glab_setup
        @glab_setup ||= ::Gitlab::DuoWorkflow::GlabSetup.new(current_user: @current_user)
      end

      def orbit_local_setup
        @orbit_local_setup ||= ::Gitlab::DuoWorkflow::OrbitLocalSetup.new(current_user: @current_user)
      end

      def workflow_metadata
        # TODO: This is temporary workaround to pass model selection via
        # metadata into node executor to address
        # https://gitlab.com/gitlab-org/editor-extensions/gitlab-lsp/-/issues/1767
        # it will be cleaned up by
        # https://gitlab.com/gitlab-org/editor-extensions/gitlab-lsp/-/issues/1630
        ::Gitlab::Json.dump(
          ::Gitlab::Json.safe_parse(@params[:workflow_metadata]).merge(
            'modelMetadata' => agent_platform_model_metadata_json
          )
        )
      end

      def duo_workflow_service_url
        Gitlab::DuoWorkflow::Client.url_for(
          feature_setting: feature_setting,
          user: @current_user
        )
      end

      def project
        @workflow.project
      end

      def feature_setting
        @params.fetch(:duo_agent_platform_feature_setting, nil)
      end

      def feature_setting_name
        # If no feature setting is provided, use the default workflow feature name,
        # which is :duo_agent_platform.

        # All workflows originating from CI should have a feature setting name set.
        # This is because the value of the feature_setting_name is sent as `AGENT_PLATFORM_FEATURE_SETTING_NAME`
        # to the Node Executor. Node executor then sends this value to the websockets endpoint as the header
        # `X-Gitlab-Agent-Platform-Feature-Setting-Name`.

        # We expect all non-chat workflows to have a feature setting name set. Consequently, if this header
        # does not exist, we treat that request as a chat request, so it is essential to have the fallback to
        # workflow_feature_name, just in case.
        (feature_setting&.feature || ::Ai::ModelSelection::FeaturesConfigurable.workflow_feature_name).to_s
      end

      def agent_platform_model_metadata_json
        response = ::Gitlab::Llm::AiGateway::AgentPlatform::ModelMetadata.new(
          feature_setting: feature_setting
        ).execute

        response.fetch(Gitlab::Llm::AiGateway::AgentPlatform::ModelMetadata::HEADER_KEY, nil)
      end

      def link_composite_identity
        identity = ::Gitlab::Auth::Identity.fabricate(service_account)
        identity.link!(@current_user) if identity&.composite?
      end

      def serialized_duo_flow_config
        return unless @params[:flow_config].present? && @params[:flow_config].is_a?(Hash)

        ::Gitlab::Json.dump(@params[:flow_config])
      end

      def serialized_flow_additional_context
        context_array = @params[:additional_context] || []

        # The standard and trigger context categories are controlled by the Rails
        # codebase: if the caller provides an envelope with a colliding category
        # it should be dropped
        context_array.delete_if do |envelope|
          [DWS_STANDARD_CONTEXT_CATEGORY, DWS_TRIGGER_CONTEXT_CATEGORY].include?(envelope[:Category])
        end

        source_branch = @params.fetch(:source_branch, nil)
        primary_branch =
          if project.repository.branch_exists?(source_branch)
            source_branch
          else
            project.default_branch_or_main
          end

        standard_context = {
          "Category" => DWS_STANDARD_CONTEXT_CATEGORY,
          "Content" => ::Gitlab::Json.dump({
            "workload_branch" => @ref,
            "primary_branch" => primary_branch,
            "session_owner_id" => @current_user.id.to_s,
            "service_account_name" => service_account&.username
          })
        }

        context_array << standard_context

        trigger_context = flow_trigger_context
        context_array << trigger_context if trigger_context

        ::Gitlab::Json.dump(context_array)
      end

      # Trigger metadata (how the flow was started) travels in its own envelope so the
      # standard context schema stays frozen across deploys: a Duo Workflow Service that
      # does not know this category skips the whole envelope with a warning, whereas an
      # unknown field inside a known category fails envelope validation. The envelope is
      # sent only when at least one value is present, and never carries null values (the
      # service-side input schemas reject non-string values).
      def flow_trigger_context
        content = {
          "event_type" => @params[:event_type],
          "triggering_conversation" => @params[:triggering_conversation]
        }.compact_blank

        return if content.empty?

        {
          "Category" => DWS_TRIGGER_CONTEXT_CATEGORY,
          "Content" => ::Gitlab::Json.dump(content)
        }
      end

      def git_user_email(user)
        return "" unless user.respond_to?(:commit_email_or_default)

        user.commit_email_or_default
      end

      def git_user_name(user)
        return "" unless user.respond_to?(:name)

        user.name
      end

      def create_workload_branch
        workload_branch_service = ::Ci::Workloads::WorkloadBranchService.new(
          current_user: service_account,
          project: project,
          source_branch: @params.fetch(:source_branch, nil)
        )
        workload_branch_service.execute
      end
    end
  end
end
