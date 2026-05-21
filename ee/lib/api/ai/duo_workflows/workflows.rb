# frozen_string_literal: true

module API
  module Ai
    module DuoWorkflows
      class Workflows < ::API::Base
        include PaginationParams
        include APIGuard

        HEADERS_TO_FORWARD_AS_GRPC_METADATA = %w[
          X-Gitlab-Language-Server-Version
          X-Gitlab-Client-Type
          Langsmith-Trace
          X-Gitlab-Client-Name
          X-Gitlab-Client-Version
        ].freeze

        WORKFLOW_EVENTS = {
          ::Vulnerabilities::TriggerFalsePositiveDetectionWorkflowWorker::WORKFLOW_DEFINITION =>
            'trigger_sast_vulnerability_fp_detection_workflow',
          ::Vulnerabilities::TriggerResolutionWorkflowWorker::WORKFLOW_DEFINITION =>
            'trigger_sast_vulnerability_resolution_workflow',
          ::Vulnerabilities::TriggerSecretDetectionFalsePositiveDetectionWorkflowWorker::WORKFLOW_DEFINITION =>
            'trigger_secret_detection_vulnerability_fp_detection_workflow'
        }.freeze

        helpers ::API::Helpers::DuoWorkflowHelpers
        helpers Gitlab::InternalEventsTracking

        feature_category :duo_agent_platform

        allow_access_with_scope :ai_workflows, if: ->(request) do
          request.get? && request.path.eql?('/api/v4/ai/duo_workflows/ws')
        end

        before do
          authenticate!
          set_current_organization
        end

        helpers do
          # Prefers the most specific (subgroup) namespace from namespace_id/header,
          # falling back to root_namespace_id. Use this when checking cascading
          # settings that subgroups can override.
          def find_most_specific_namespace
            subgroup_id = params[:namespace_id].presence ||
              headers['X-Gitlab-Namespace-Id'].presence

            if subgroup_id
              ns = find_namespace(subgroup_id)

              if ns.nil?
                Gitlab::AppLogger.warn(
                  message: 'Namespace not found, falling back to root namespace',
                  namespace_id: subgroup_id
                )
              elsif !Ability.allowed?(current_user, :read_group, ns, composite_identity_check: false)
                Gitlab::AppLogger.warn(
                  message: 'User lacks permission on namespace, falling back to root namespace',
                  namespace_id: subgroup_id
                )
              else
                return ns
              end
            end

            find_request_namespace
          end

          def most_specific_namespace_or_root(root_namespace)
            find_most_specific_namespace || root_namespace
          end

          def find_root_namespace!
            namespace_id = request_namespace_id

            # First find the namespace (returns nil if not found)
            namespace = namespace_id && find_namespace(namespace_id)
            return current_user.governing_namespace unless namespace

            # Then enforce authorization (raises 404 if no access)
            not_found!('Namespace') unless Ability.allowed?(
              current_user, :read_group, namespace, composite_identity_check: false)

            root_namespace = namespace.root_ancestor

            # Validate namespace is contextually relevant to prevent
            # unauthorized access to model settings from unrelated namespaces
            validate_namespace_context!(root_namespace)

            root_namespace
          end

          def validate_namespace_context!(namespace)
            # If working in a project context, namespace must be the project's root namespace
            if params[:project_id].presence
              project = find_project!(params[:project_id])
              forbidden!("Namespace does not match project context") unless namespace.id == project.root_namespace.id
            end

            # If working in a namespace context (without project), must match or be ancestor
            return unless params[:namespace_id].presence

            context_namespace = find_namespace(params[:namespace_id])
            not_found!('Namespace') unless Ability.allowed?(
              current_user, :read_group, context_namespace, composite_identity_check: false)

            return if namespace.id == context_namespace.root_ancestor.id

            forbidden!("Namespace does not match workflow context")
          end

          def cloud_service_for_self_hosted_config(feature_setting, cloud_connector_headers)
            return unless ::Ai::SelfHostedDapBilling.should_bill?(feature_setting)

            {
              Headers: cloud_connector_headers.merge(
                'authorization' => "Bearer #{::CloudConnector::Tokens.cloud_connector_token}"
              ),
              URI: Gitlab::DuoWorkflow::Client.cloud_connected_url(user: current_user),
              Secure: true
            }
          end

          def find_feature_setting_name
            # This header is sent only from the Node Executor.
            feature_setting_name_from_header =
              headers['X-Gitlab-Agent-Platform-Feature-Setting-Name'].presence

            # We treat agentic chat as the default feature for the /ws endpoint if
            # no header is present.
            (feature_setting_name_from_header ||
              ::Ai::ModelSelection::FeaturesConfigurable.agentic_chat_feature_name).to_sym
          end

          def find_user_selected_model_identifier
            # Currently, only the web agentic chat UI sends this attribute, as a query param.
            # The IDE does not yet send this attribute.
            params[:user_selected_model_identifier].presence
          end

          def find_workflow!(id)
            workflow = ::Ai::DuoWorkflows::Workflow.for_user_with_id!(current_user.id, id)
            return workflow if current_user.can?(:read_duo_workflow, workflow)

            forbidden!
          end

          def get_current_organization_id
            Current.organization.id if Current.organization_assigned
          end

          def find_catalog_consumer_for_workflow!(workflow)
            catalog_item = workflow.ai_catalog_item_version&.item
            not_found!('AI Catalog item not found for this workflow') unless catalog_item

            consumer = ::Ai::Catalog::ItemConsumersFinder.new(current_user, params: {
              project_id: workflow.project.id,
              item_id: catalog_item.id,
              include_inherited: true
            }).execute.first

            not_found!('AI Catalog consumer not found for this workflow') unless consumer

            consumer
          end

          def gitlab_oauth_token(workflow_context_service = nil)
            workflow_context_service ||= workflow_context_generation_service

            # TODO: https://gitlab.com/gitlab-org/gitlab/-/issues/581556
            # It should be if find_feature_setting_name == FeaturesConfigurable.agentic_chat_feature_name
            oauth_token_result =
              if headers['X-Gitlab-Agent-Platform-Feature-Setting-Name'].present?
                workflow_context_service.generate_oauth_token_with_composite_identity_support
              else
                workflow_context_service.generate_oauth_token
              end

            if oauth_token_result.error?
              render_api_error!(oauth_token_result[:message], oauth_token_result[:http_status] || :forbidden)
            end

            oauth_token_result[:oauth_access_token]
          end

          def duo_workflow_token
            workflow_context_service = workflow_context_generation_service
            workflow_token_result = workflow_context_service.generate_workflow_token
            bad_request!(workflow_token_result[:message]) if workflow_token_result.error?

            workflow_token_result
          end

          def duo_workflow_list_tools
            duo_workflow_list_tools_result = ::Ai::DuoWorkflow::DuoWorkflowService::Client.new(
              duo_workflow_service_url: Gitlab::DuoWorkflow::Client.url(user: current_user),
              current_user: current_user,
              secure: Gitlab::DuoWorkflow::Client.secure?(feature_setting: nil)
            ).list_tools
            bad_request!(duo_workflow_list_tools_result[:message]) if duo_workflow_list_tools_result[:status] == :error

            duo_workflow_list_tools_result
          end

          def create_workflow_params
            wrkf_params = declared_params(include_missing: false).except(
              :start_workflow,
              :source_branch,
              :additional_context,
              :shallow_clone,
              :ai_catalog_item_consumer_id,
              :requires_duo_cli_enabled
            )

            if wrkf_params[:ai_catalog_item_version_id]
              wrkf_params[:ai_catalog_item_version] = ::Ai::Catalog::ItemVersion
                                                        .find(wrkf_params.delete(:ai_catalog_item_version_id))
            end

            if wrkf_params[:issue_id] && wrkf_params[:project_id]
              project = find_project!(wrkf_params[:project_id])
              wrkf_params[:issue] = project.issues.find_by_iid!(wrkf_params.delete(:issue_id))
            end

            if wrkf_params[:merge_request_id] && wrkf_params[:project_id]
              project = find_project!(wrkf_params[:project_id])
              wrkf_params[:merge_request] = project.merge_requests.find_by_iid!(wrkf_params.delete(:merge_request_id))
            end

            wrkf_params
          end

          def track_event(params, consumer: nil)
            workflow_definition = params[:workflow_definition] || consumer&.item&.foundational_flow_reference
            return unless workflow_definition && WORKFLOW_EVENTS.key?(workflow_definition)

            vulnerability = Vulnerability.find_by_id(params[:goal])
            return unless vulnerability

            track_internal_event(
              WORKFLOW_EVENTS[workflow_definition],
              project: vulnerability.project,
              additional_properties: {
                label: 'manual',
                value: vulnerability.id,
                property: vulnerability.severity
              }
            )
          end

          def compute_server_capabilities(dws_capabilities:, namespace:)
            rails_capabilities = ["job_trace_pagination"]
            rails_capabilities << "advanced_search" if advanced_search_enabled?

            # Filter DWS capabilities based on admin/namespace/project settings
            dws_capabilities.delete('tool_call_approval') unless tool_approval_for_session_enabled?(namespace)

            (rails_capabilities + dws_capabilities).uniq
          end

          def tool_approval_for_session_enabled?(namespace)
            project = find_project(params[:project_id].presence)
            return project.project_setting.tool_approval_for_session_enabled? if project

            return false unless namespace

            !!namespace.namespace_settings&.tool_approval_for_session_enabled?
          end

          def advanced_search_enabled?
            project = find_project(params[:project_id].presence)
            namespace_id = params[:root_namespace_id].presence ||
              params[:namespace_id].presence ||
              headers['X-Gitlab-Namespace-Id'].presence
            namespace = find_namespace(namespace_id)

            ::Gitlab::CurrentSettings.search_using_elasticsearch?(scope: project || namespace)
          end

          params :workflow_params do
            optional :requires_duo_cli_enabled, type: Boolean,
              desc: 'Whether this workflow requires Duo CLI to be enabled',
              documentation: { example: true }
            optional :project_id, type: String, desc: 'The ID or path of the workflow project',
              documentation: { example: '1' }
            optional :namespace_id, type: String, desc: 'The ID or path of the workflow namespace',
              documentation: { example: '1' }
            optional :ai_catalog_item_consumer_id, type: Integer,
              desc: 'The ID of AI Catalog ItemConsumer that configures which catalog item to execute.',
              documentation: { example: 1 }
            optional :start_workflow, type: Boolean,
              desc: 'Optional parameter to start workflow in a CI pipeline.' \
                'This feature is currently in an experimental state.',
              documentation: { example: true }
            optional :goal, type: String, desc: 'Goal of the workflow',
              documentation: { example: 'Fix pipeline for merge request 1 in project 1' }
            optional :agent_privileges, type: [Integer], desc: 'The actions the agent is allowed to perform',
              documentation: { example: [1] }
            optional :pre_approved_agent_privileges, type: [Integer],
              desc: 'The actions the agent can perform without asking for approval',
              documentation: { example: [1] }
            optional :workflow_definition, type: String, desc: 'workflow type based on its capability',
              documentation: { example: 'software_developer' }
            optional :allow_agent_to_request_user, type: Boolean,
              desc: 'When this is enabled Duo Agent Platform may stop to ask the user questions before proceeding. ' \
                'When it is disabled Duo Agent Platform will always just run through the workflow without ever ' \
                'asking for user input. Defaults to true.',
              documentation: { example: true }
            optional :image, type: String, desc: 'Container image to use for running the workflow in CI pipeline.',
              documentation: { example: 'registry.gitlab.com/gitlab-org/duo-workflow/custom-image:latest' }
            optional :source_branch, type: String,
              desc: 'Source branch for the CI pipeline. Uses default branch when not specified.',
              documentation: { example: 'main' }
            optional :environment, type: String,
              values: ::Ai::DuoWorkflows::Workflow.environments.keys.map(&:to_s),
              desc: 'Environment for the workflow.',
              documentation: { example: 'web' }
            optional :ai_catalog_item_version_id, type: Integer,
              desc: 'The ID of AI Catalog ItemVersion that sourced flow config used by the workflow.',
              documentation: { example: 1 }
            optional :additional_context, type: Array,
              desc: 'Additional Context required by the Flow, in JSON format. Contains an array of context details, ' \
                'where each detail is a Hash with a minimum of "Category" and "Content" keys.',
              documentation: {
                example: '[{"Category": "agent_user_environment", "Content": "{\"merge_request_url\": ' \
                  '\"https://gitlab.com/project/-/merge_requests/1\"}", "Metadata": "{}"}]'
              } do
                requires :Category, type: String, desc: 'The category of the context detail'
                requires :Content, type: String, desc: 'The content type of the context detail'
              end
            optional :shallow_clone, type: Boolean,
              desc: 'Whether or not the workflow should use a shallow clone of the repository during its execution.  ' \
                'Defaults to true.',
              default: true,
              documentation: { example: true }
            optional :issue_id, type: Integer,
              desc: 'IID of the Issue noteable that the workflow is associated with.',
              documentation: { example: 123 }
            optional :merge_request_id, type: Integer,
              desc: 'IID of the MergeRequest noteable that the workflow is associated with.',
              documentation: { example: 123 }
          end
        end

        namespace :ai do
          namespace :duo_workflows do
            resources :direct_access do
              desc 'Connection details for accessing Duo Agent Platform Service directly' do
                tags ['gitlab_duo_workflows']
                success code: 201
                failure [
                  { code: 401, message: 'Unauthorized' },
                  { code: 403, message: 'Forbidden' },
                  { code: 404, message: 'Not found' },
                  { code: 429, message: 'Too many requests' }
                ]
              end

              params do
                optional :workflow_definition, type: String, desc: 'workflow type based on its capability',
                  documentation: { example: 'software_developer' }
                optional :root_namespace_id, type: String, desc: 'the ID of the root namespace',
                  documentation: { example: '1' }
                optional :project_id, type: String, desc: 'The ID or path of the project',
                  documentation: { example: '1' }
              end

              route_setting :lifecycle, :experiment
              post do
                check_rate_limit!(:duo_workflow_direct_access, scope: current_user)

                root_namespace = find_root_namespace!

                ai_feature = if params[:workflow_definition] == "chat"
                               :duo_chat
                             else
                               :duo_agent_platform
                             end

                quota_check_response = ::Ai::UsageQuotaService.new(
                  ai_feature: ai_feature,
                  user: current_user,
                  namespace: root_namespace
                ).execute

                if quota_check_response.error?
                  message = case quota_check_response.reason
                            when :usage_quota_exceeded
                              "USAGE_QUOTA_EXCEEDED: #{quota_check_response.message}"
                            when :namespace_missing
                              ::Ai::FoundationalFlowMessages.namespace_missing_error(current_user)
                            else
                              quota_check_response.message
                            end

                  forbidden!(message)
                end

                oauth_token = gitlab_oauth_token
                workflow_token = duo_workflow_token

                # Extract DWS capabilities from token response
                dws_capabilities = workflow_token[:capabilities] || []

                access = {
                  gitlab_rails: {
                    base_url: Gitlab.config.gitlab.url,
                    token: oauth_token.plaintext_token,
                    token_expires_at: oauth_token.expires_at
                  },
                  duo_workflow_service: {
                    base_url: Gitlab::DuoWorkflow::Client.url(user: current_user),
                    token: workflow_token[:token],
                    token_expires_at: workflow_token[:expires_at],
                    headers: Gitlab::DuoWorkflow::Client.headers(user: current_user).tap do |h|
                      Gitlab::AiGateway.add_organization_header!(h, get_current_organization_id)
                    end,
                    secure: Gitlab::DuoWorkflow::Client.secure?(feature_setting: nil)
                  },
                  duo_workflow_executor: {
                    executor_binary_url: Gitlab::DuoWorkflow::Executor.executor_binary_url,
                    executor_binary_urls: Gitlab::DuoWorkflow::Executor.executor_binary_urls,
                    version: Gitlab::DuoWorkflow::Executor.version
                  },
                  workflow_metadata: Gitlab::DuoWorkflow::Client.metadata(current_user,
                    namespace: find_request_namespace || root_namespace,
                    project: find_project(params[:project_id].presence)),
                  server_capabilities: compute_server_capabilities(
                    dws_capabilities: dws_capabilities,
                    namespace: most_specific_namespace_or_root(root_namespace)
                  )
                }

                present access, with: Grape::Presenters::Presenter
              end
            end

            resources :list_tools do
              desc 'List Duo Agent Platform tools' do
                tags ['gitlab_duo_workflows']
                success code: 200
                failure [
                  { code: 401, message: 'Unauthorized' },
                  { code: 404, message: 'Not found' },
                  { code: 429, message: 'Too many requests' }
                ]
              end

              params do
                optional :workflow_definition, type: String, desc: 'workflow type based on its capability',
                  documentation: { example: 'software_developer' }
              end

              route_setting :lifecycle, :experiment
              get do
                check_rate_limit!(:duo_workflow_direct_access, scope: current_user)

                result = duo_workflow_list_tools

                present(result.payload, with: Grape::Presenters::Presenter)
              end
            end

            desc 'Get Duo Workflows WebSocket connection details' do
              tags ['gitlab_duo_workflows']
            end
            route_setting :lifecycle, :experiment
            get :ws do
              require_gitlab_workhorse!

              status :ok
              content_type Gitlab::Workhorse::INTERNAL_API_CONTENT_TYPE

              root_namespace = find_root_namespace!

              forbidden!("Missing default GitLab Duo namespace user preference") unless root_namespace

              most_specific_namespace = most_specific_namespace_or_root(root_namespace)

              push_feature_flags(root_namespace)

              feature_setting_name = find_feature_setting_name

              model_metadata_headers = ::Ai::DuoWorkflows::DuoAgentPlatformModelMetadataService.new(
                root_namespace: root_namespace,
                current_user: current_user,
                user_selected_model_identifier: find_user_selected_model_identifier,
                feature_name: feature_setting_name
              ).execute

              feature_setting = ::Ai::FeatureSettingSelectionService
                                  .new(
                                    current_user,
                                    feature_setting_name,
                                    root_namespace
                                  ).execute.payload

              ns_settings = most_specific_namespace.namespace_settings
              model_prompt_cache_enabled =
                ns_settings ? ns_settings.model_prompt_cache_enabled : root_namespace.model_prompt_cache_enabled

              workflow_context_service = workflow_context_generation_service
              gitlab_token = if workflow_context_service.already_scoped_for_ai_workflows?(access_token)
                               parsed_oauth_token
                             else
                               gitlab_oauth_token(workflow_context_service).plaintext_token
                             end

              mcp_config_service = ::Ai::DuoWorkflows::McpConfigService.new(
                current_user,
                gitlab_token,
                workflow_definition: params[:workflow_definition],
                ai_catalog_item_version_id: params[:ai_catalog_item_version_id]
              )
              cloud_connector_headers = Gitlab::DuoWorkflow::Client.cloud_connector_headers(
                user: current_user,
                project_id: params[:project_id],
                namespace_id: params[:namespace_id].presence&.to_i,
                governing_namespace_id: root_namespace.id,
                feature_setting: feature_setting
              )

              client_type = params[:client_type].presence
              # client type from browser is sent as a query param in websocket request
              cloud_connector_headers['x-gitlab-client-type'] ||= client_type
              Gitlab::AiGateway.add_organization_header!(cloud_connector_headers, get_current_organization_id)

              grpc_headers = cloud_connector_headers.merge(
                'x-gitlab-oauth-token' => gitlab_token,
                'x-gitlab-unidirectional-streaming' => 'enabled',
                'x-gitlab-enabled-mcp-server-tools' => mcp_config_service.gitlab_enabled_tools.join(','),
                'x-gitlab-model-prompt-cache-enabled' => model_prompt_cache_enabled.to_s,
                'x-gitlab-self-hosted-dap-billing-enabled' =>
                  ::Ai::SelfHostedDapBilling.should_bill?(feature_setting).to_s
              ).merge(model_metadata_headers)

              HEADERS_TO_FORWARD_AS_GRPC_METADATA.each do |header|
                header_value = headers[header]

                grpc_headers[header.downcase] = header_value if header_value.present?
              end

              {
                DuoWorkflow: {
                  Service: {
                    Headers: grpc_headers,
                    URI: Gitlab::DuoWorkflow::Client.url_for(feature_setting: feature_setting, user: current_user),
                    Secure: Gitlab::DuoWorkflow::Client.secure?(feature_setting: feature_setting)
                  },
                  CloudServiceForSelfHosted: cloud_service_for_self_hosted_config(feature_setting,
                    cloud_connector_headers),
                  McpServers: mcp_config_service.execute,
                  LockConcurrentFlow: client_type == 'browser' || Feature.disabled?(:lock_workflows_for_web_only,
                    current_user),
                  TimeoutHTTPRequests: Feature.enabled?(:timeout_dap_http_requests_in_workhorse, current_user),
                  # dws_capabilities is empty here because this endpoint does not fetch a DWS token.
                  # DWS-advertised capabilities flow through the workflow access path instead.
                  # See https://gitlab.com/gitlab-org/gitlab/-/work_items/592850 for a longer-term fix.
                  ServerCapabilities: compute_server_capabilities(
                    dws_capabilities: [],
                    namespace: most_specific_namespace
                  )
                }
              }
            end

            namespace :workflows do
              desc 'Create workflow persistence' do
                tags ['gitlab_duo_workflows']
                success code: 200
                failure [
                  { code: 400, message: 'Validation failed' },
                  { code: 401, message: 'Unauthorized' },
                  { code: 403, message: '403 Forbidden' },
                  { code: 404, message: 'Not found' }
                ]
              end
              params do
                use :workflow_params
              end
              route_setting :lifecycle, :experiment
              post do
                if params[:requires_duo_cli_enabled] &&
                    Feature.enabled?(:duo_cli_enabled_setting, :instance) &&
                    !::Ai::Setting.instance.duo_cli_enabled
                  forbidden!('Duo CLI has been disabled by your administrator')
                end

                ::Gitlab::QueryLimiting.disable!(
                  'https://gitlab.com/gitlab-org/gitlab/-/issues/566195', new_threshold: 125
                )

                container = if params[:project_id]
                              find_project!(params[:project_id])
                            elsif params[:namespace_id]
                              find_namespace!(params[:namespace_id])
                            else
                              current_user.default_duo_namespace
                            end

                if container.nil?
                  bad_request!('No default namespace found. Please provide project_id or namespace_id, ' \
                    'or configure a default Duo namespace.')
                end

                forbidden!('Access to the container is not allowed') unless container_access_allowed?(container)

                if params[:ai_catalog_item_consumer_id]
                  unless container.is_a?(Project)
                    bad_request!('AI Catalog flows can only be executed in project context')
                  end

                  consumer = find_item_consumer!(params[:ai_catalog_item_consumer_id], container)

                  service_account = if consumer.project.present?
                                      consumer.parent_item_consumer&.service_account
                                    else
                                      consumer.service_account
                                    end

                  flow_params = {
                    item_consumer: consumer,
                    service_account: service_account,
                    execute_workflow: params[:start_workflow].present?,
                    event_type: 'api_execution',
                    user_prompt: params[:goal],
                    source_branch: params[:source_branch],
                    additional_context: params[:additional_context],
                    issue_id: params[:issue_id]
                  }

                  result = ::Ai::Catalog::Flows::ExecuteService.new(
                    project: container,
                    current_user: current_user,
                    params: flow_params
                  ).execute

                  bad_request!(result.message) if result.error?

                  workflow = result.payload[:workflow]
                  workload_id = result.payload[:workload_id]

                  track_event(params, consumer: consumer)

                  present workflow, with: ::API::Entities::Ai::DuoWorkflows::Workflow,
                    workload: { id: workload_id, message: result.message }
                else
                  workflow_params = create_workflow_params

                  resolve_foundational_flow_service_account!(workflow_params, container)

                  service = ::Ai::DuoWorkflows::CreateWorkflowService.new(
                    container: container, current_user: current_user, params: workflow_params)

                  result = service.execute

                  forbidden!(result.message) if result.error? && result.http_status == :forbidden
                  not_found!(result.message) if result.error? && result.http_status == :not_found
                  if result.error? && result.http_status == :payment_required
                    forbidden!("session failed to start due to insufficient GitLab credits. " \
                      "Purchase more credits to continue.")
                  end

                  bad_request!(result[:message]) if result[:status] == :error

                  push_ai_gateway_headers(scope: container)

                  if params[:start_workflow].present?
                    response = ::Ai::DuoWorkflows::StartWorkflowService.new(
                      workflow: result[:workflow],
                      params: start_workflow_params(result[:workflow].id, container: container,
                        service_account: workflow_params[:service_account])
                    ).execute

                    if response.error?
                      status_code = case response.reason
                                    when :unprocessable_entity
                                      :unprocessable_entity
                                    when :feature_unavailable, :invalid_service_account
                                      :forbidden
                                    when :workload_failure
                                      :unprocessable_entity
                                    else
                                      :internal_server_error
                                    end
                      render_api_error!(response.message, status_code)
                    else
                      workload_id = response.payload && response.payload[:workload_id]
                      message = response.message

                      track_event(params)
                    end
                  end

                  present result[:workflow], with: ::API::Entities::Ai::DuoWorkflows::Workflow,
                    workload: { id: workload_id, message: message }
                end
              end

              desc 'List all agent privileges and descriptions' do
                tags ['gitlab_duo_workflows']
                success code: 200
                failure [
                  { code: 401, message: 'Unauthorized' }
                ]
              end
              get 'agent_privileges' do
                present ::Ai::DuoWorkflows::Workflow::AgentPrivileges,
                  with: ::API::Entities::Ai::DuoWorkflows::Workflow::AgentPrivileges
              end

              namespace ':workflow_id' do
                desc 'Resume a paused workflow' do
                  tags ['gitlab_duo_workflows']
                  success code: 201
                  failure [
                    { code: 400, message: 'Validation failed' },
                    { code: 401, message: 'Unauthorized' },
                    { code: 403, message: 'Forbidden' },
                    { code: 404, message: 'Not found' },
                    { code: 422, message: 'Unprocessable entity' }
                  ]
                end
                params do
                  requires :workflow_id, type: String, desc: 'The ID of the workflow to resume',
                    documentation: { example: '1' }
                  requires :human_approval, type: Boolean,
                    desc: 'Whether the human approves resuming the workflow',
                    documentation: { example: true }
                  optional :human_message, type: String,
                    desc: 'Optional message accompanying the human decision',
                    documentation: { example: 'Looks good, please proceed' },
                    limit: 2000
                end
                route_setting :authorization, permissions: :resume_duo_workflow, boundary_type: :user
                post :resume do
                  workflow = find_workflow!(params[:workflow_id])
                  authorize!(:resume_duo_workflow, workflow)

                  container = workflow.project || workflow.namespace

                  push_ai_gateway_headers(scope: container)
                  consumer = find_catalog_consumer_for_workflow!(workflow)

                  service_account = if consumer.project.present?
                                      consumer.parent_item_consumer&.service_account
                                    else
                                      consumer.service_account
                                    end

                  flow_params = {
                    item_consumer: consumer,
                    service_account: service_account,
                    execute_workflow: true,
                    event_type: 'api_execution',
                    user_prompt: workflow.goal,
                    resume_context: {
                      existing_workflow: workflow,
                      human_approval: params[:human_approval],
                      human_message: params[:human_message]
                    }
                  }

                  result = ::Ai::Catalog::Flows::ExecuteService.new(
                    project: container,
                    current_user: current_user,
                    params: flow_params
                  ).execute

                  bad_request!(result.message) if result.error?

                  workload_id = result.payload[:workload_id]
                  message = result.message

                  present workflow, with: ::API::Entities::Ai::DuoWorkflows::Workflow,
                    workload: { id: workload_id, message: message }
                end
              end
            end
          end
        end
      end
    end
  end
end
