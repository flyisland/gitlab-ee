# frozen_string_literal: true

module Ai
  module FlowTriggers
    class RunService
      include ::Gitlab::Utils::StrongMemoize
      include ::Ai::Catalog::Loggable

      def initialize(project:, current_user:, flow_trigger:, resource: nil)
        @project = project
        @current_user = current_user
        @resource = resource
        @flow_trigger = flow_trigger
        @service_account = flow_trigger.service_account
        @catalog_consumer = flow_trigger.ai_catalog_item_consumer
        @catalog_item = catalog_consumer&.item
        @catalog_item_pinned_version = catalog_consumer&.pinned_version_prefix

        ai_catalog_logger.context(consumer: catalog_consumer, item: catalog_item)

        link_composite_identity! if can_use_composite_identity?
      end

      def execute(params)
        return execute_flow(params)[0] unless resource.is_a?(Noteable)

        note_service = ::Ai::FlowTriggers::CreateNoteService.new(
          project: project, resource: resource, author: service_account, discussion: params[:discussion]
        )

        note_service.execute(params) do |updated_params|
          execute_flow(updated_params)
        end
      end

      private

      def execute_flow(params)
        if validation_error
          ai_catalog_logger.error(message: 'Flow trigger validation failed', error_message: validation_error.message)
          return [validation_error, nil]
        end

        response, workflow =
          if catalog_item&.flow?
            start_catalog_workflow(params)
          else
            run_workload(params)
          end

        ai_catalog_logger.error(message: 'Flow execution failed', error_message: response.message) if response.error?

        [response, workflow]
      end

      strong_memoize_attr def validation_error
        return ServiceResponse.error(message: 'cannot be triggered by non-human users') unless current_user.human?

        return unless catalog_item&.third_party_flow? &&
          !Ability.allowed?(current_user, :execute_ai_catalog_item, catalog_consumer)

        ServiceResponse.error(message: 'current user not permitted to execute external agent')
      end

      attr_reader :project, :current_user, :resource, :flow_trigger, :service_account,
        :catalog_item, :catalog_consumer, :catalog_item_pinned_version

      def create_workflow(params)
        workflow_params = {
          workflow_definition: "Trigger - #{flow_trigger.description}",
          status: :running,
          goal: params[:input],
          environment: :web,
          service_account: resolve_service_account(service_account)
        }

        result = ::Ai::DuoWorkflows::CreateWorkflowService.new(
          container: project,
          current_user: current_user,
          params: workflow_params
        ).execute

        return ServiceResponse.error(message: result[:message]) if result.error?

        ServiceResponse.success(payload: { workflow: result[:workflow] })
      end

      def run_workload(params)
        flow_definition = fetch_flow_definition
        return ServiceResponse.error(message: 'invalid or missing flow definition') unless flow_definition

        wf_create_result = create_workflow(params)
        return wf_create_result unless wf_create_result.success?

        workflow = wf_create_result.payload[:workflow]

        if flow_definition['injectGatewayToken'] == true
          token_response = ::Ai::ThirdPartyAgents::TokenService.new(
            current_user: current_user,
            project: project,
            organization: project.organization,
            agent_name: catalog_item&.name,
            workflow_id: workflow.id
          ).direct_access_token

          return token_response if token_response.error?

          params[:token] = token_response.payload
        end

        workload_definition = ::Ci::Workloads::WorkloadDefinition.new do |d|
          d.image = flow_definition['image']
          d.commands = flow_definition['commands']
          d.variables = build_variables(params)
          d.tags = [::Ai::DuoWorkflows::Workflow::WORKLOAD_TAG]
        end

        branch_result = branch_args
        return branch_result unless branch_result.success?

        response = ::Ci::Workloads::RunWorkloadService.new(
          project: project,
          current_user: service_account,
          source: :duo_workflow,
          workload_definition: workload_definition,
          ci_variables_included: flow_definition['variables'] || [],
          ref: branch_result.payload[:ref]
        ).execute

        if response.success?
          workflow.workflows_workloads.create(project_id: project.id,
            workload_id: response.payload.id)

          log_external_agent_execution
        end

        status_event = response.success? ? "start" : "drop"
        ::Ai::DuoWorkflows::UpdateWorkflowStatusService.new(
          workflow: workflow, status_event: status_event, current_user: current_user
        ).execute

        [response, workflow]
      end

      def start_catalog_workflow(params)
        execute_params = {
          item_consumer: catalog_consumer,
          flow: catalog_item,
          service_account: service_account,
          flow_version: catalog_item.resolve_version(catalog_item_pinned_version),
          event_type: params[:event].to_s,
          user_prompt: catalog_item_user_prompt(params[:input], params[:event], params),
          execute_workflow: true,
          source_branch: source_branch,
          additional_context: additional_context
        }

        execute_params[:issue_id] = resource.iid if resource.is_a?(Issue)
        execute_params[:merge_request_id] = resource.iid if resource.is_a?(MergeRequest)

        response = ::Ai::Catalog::Flows::ExecuteService.new(
          project: project,
          current_user: current_user,
          params: execute_params
        ).execute

        workflow = response.payload[:workflow]

        [response, workflow]
      end

      def fetch_flow_definition
        return catalog_item.definition(catalog_item_pinned_version) if catalog_item&.third_party_flow?

        root_ref = project.repository.root_ref
        flow_definition_yaml = project.repository.blob_data_at(root_ref, flow_trigger.config_path)
        return unless flow_definition_yaml

        flow_definition = YAML.safe_load(flow_definition_yaml)
        return unless flow_definition.is_a?(Hash)

        flow_definition
      rescue Psych::Exception => e
        ai_catalog_logger.error(message: 'Failed to parse flow definition YAML', error_message: e.message)
        nil
      end

      def build_variables(params)
        base_variables = {
          AI_FLOW_CONTEXT: serialized_resource,
          AI_FLOW_DISCUSSION_ID: params[:discussion_id],
          AI_FLOW_EVENT: params[:event].to_s,
          AI_FLOW_GITLAB_TOKEN: composite_identity_token,
          AI_FLOW_INPUT: params[:input],
          AI_FLOW_PROJECT_PATH: project.full_path,
          AI_FLOW_GITLAB_HOSTNAME: gitlab_hostname
        }

        if params.key?(:token)
          gateway_token = params[:token]

          headers_string = if gateway_token[:headers].present?
                             gateway_token[:headers].filter_map { |k, v| "#{k}: #{v}" if v.present? }.join("\n")
                           else
                             ''
                           end

          base_variables.merge!({
            AI_FLOW_AI_GATEWAY_TOKEN: gateway_token[:token],
            AI_FLOW_AI_GATEWAY_HEADERS: headers_string
          })
        end

        base_variables
      end

      def branch_args
        source_branch = resource.source_branch if resource.is_a?(MergeRequest)
        workload_branch_service = ::Ci::Workloads::WorkloadBranchService.new(
          current_user: service_account,
          project: project,
          source_branch: source_branch
        )
        branch_response = workload_branch_service.execute
        return branch_response unless branch_response.success?

        ServiceResponse.success(payload: { ref: branch_response.payload[:ref] })
      end

      def composite_identity_token
        return unless can_use_composite_identity?

        composite_oauth_token_result = ::Ai::DuoWorkflows::CreateCompositeOauthAccessTokenService.new(
          current_user: current_user,
          organization: project.organization,
          service_account: service_account
        ).execute

        return if composite_oauth_token_result.error?

        composite_oauth_token_result[:oauth_access_token].plaintext_token
      end

      def can_use_composite_identity?
        return false unless current_user
        return false unless Feature.enabled?(:ai_flow_triggers_use_composite_identity, current_user)
        return false if Ai::Setting.instance.duo_workflow_oauth_application.nil?

        service_account.composite_identity_enforced?
      end

      def link_composite_identity!
        identity = ::Gitlab::Auth::Identity.fabricate(service_account)
        identity.link!(current_user) if identity&.composite?
      end

      def serialized_resource
        return unless resource

        ::Ai::AiResource::Wrapper.new(current_user, resource).wrap.serialize_for_ai.to_json
      end

      def gitlab_hostname
        host = Gitlab.config.gitlab.host
        port = Gitlab.config.gitlab.port

        return host if [80, 443].include?(port)

        "#{host}:#{port}"
      end

      def catalog_item_user_prompt(user_input, event_type, params = {})
        goal_template_class = foundational_flow&.goal_templates

        if goal_template_class.present?
          goal_template_class.resolve(
            event_type: event_type,
            resource: resource,
            user_input: user_input,
            params: params
          )
        elsif event_type == :mention
          ::Ai::Catalog::GoalTemplates::Base.default_mention_goal(
            resource: resource,
            user_input: user_input
          )
        elsif foundational_flow?
          Gitlab::UrlBuilder.build(@resource)
        else
          user_input
        end
      end

      def foundational_flow
        return unless @catalog_item&.foundational_flow_reference.present?

        ::Ai::Catalog::FoundationalFlow[@catalog_item.foundational_flow_reference]
      end
      strong_memoize_attr :foundational_flow

      def foundational_flow?
        foundational_flow.present?
      end

      def source_branch
        resource.source_ref if resource.is_a?(::Ci::Pipeline)
      end

      def additional_context
        return unless resource.is_a?(::Ci::Pipeline)

        merge_request_url = resource.merge_request.present? ? ::Gitlab::UrlBuilder.build(resource.merge_request) : ""

        [
          {
            "Category" => "merge_request",
            "Content" => ::Gitlab::Json.dump({ "url" => merge_request_url })
          },
          {
            "Category" => "pipeline",
            "Content" => ::Gitlab::Json.dump({ "source_branch" => resource.source_ref })
          }
        ]
      end

      def log_external_agent_execution
        ai_catalog_logger.info(message: 'External agent executed') if catalog_item
      end

      def resolve_service_account(service_account)
        return unless service_account.service_account?

        service_account
      end
    end
  end
end
