# frozen_string_literal: true

require 'spec_helper'

RSpec.describe API::Mcp::Handlers::CallTool, feature_category: :mcp_server do
  let(:manager) { instance_double(Mcp::Tools::Manager) }
  let(:request) { instance_double(Rack::Request) }
  let_it_be(:current_user) { create(:user) }
  let_it_be(:group) { create(:group) }
  let_it_be(:project) { create(:project, group: group) }

  subject(:handler) { described_class.new(manager) }

  describe '#invoke' do
    let(:tool_name) { 'test_tool' }
    let(:arguments) { { param: 'value' } }
    let(:params) { { name: tool_name, arguments: arguments } }
    let(:success_result) { { content: [{ type: 'text', text: 'Success' }] } }
    let(:tool_class) { Class.new(Mcp::Tools::Base::BaseService) }
    let(:tool) { tool_class.new(name: tool_name) }
    let(:no_containers) do
      Mcp::Tools::Concerns::GovernanceContainerResolver::GovernanceContainerResolutionResult.none
    end

    before do
      allow(request).to receive(:[]).with(:id).and_return('1')
      allow(manager).to receive(:get_tool).with(name: tool_name).and_return(tool)
      allow(manager).to receive(:resolve_alias) { |name| name }
      allow(tool).to receive(:execute).and_return(success_result)
      allow(handler).to receive(:track_internal_event)
    end

    context 'when tool is found and version matches' do
      it 'executes the tool successfully and tracks events' do
        result = handler.invoke(request, params, current_user)

        expect(manager).to have_received(:get_tool).with(name: tool_name)
        expect(tool).to have_received(:execute).with(request: request, params: params)
        expect(result).to eq({ content: [{ type: 'text', text: 'Success' }] })

        expect(handler).to have_received(:track_internal_event).with(
          'start_mcp_tool_call',
          user: current_user,
          additional_properties: hash_including(tool_name: tool_name, request_id: '1')
        )

        expect(handler).to have_received(:track_internal_event).with(
          'finish_mcp_tool_call',
          user: current_user,
          additional_properties: hash_including(tool_name: tool_name, has_tool_call_success: 'true')
        )
      end
    end

    context 'when the client identity is known' do
      let(:client_info) { Gitlab::Mcp::ClientInfo.new(name: 'Cursor', version: '1.0.0') }

      subject(:invoke) { handler.invoke(request, params, current_user, client_info: client_info) }

      before do
        allow(handler).to receive(:track_internal_event).and_call_original
      end

      it 'tracks the client name and version as properties on the start and finish events' do
        expect { invoke }
          .to trigger_internal_events('start_mcp_tool_call')
          .with(
            user: current_user,
            additional_properties: {
              request_id: '1', tool_name: tool_name, mcp_client_name: 'Cursor', mcp_client_version: '1.0.0'
            }
          )
          .and trigger_internal_events('finish_mcp_tool_call')
          .with(
            user: current_user,
            additional_properties: {
              request_id: '1', tool_name: tool_name, has_tool_call_success: 'true',
              mcp_client_name: 'Cursor', mcp_client_version: '1.0.0'
            }
          )
      end

      context 'when the version is unknown' do
        let(:client_info) { Gitlab::Mcp::ClientInfo.new(name: 'node') }

        it 'tracks only the client name' do
          invoke

          expect(handler).to have_received(:track_internal_event)
            .with('start_mcp_tool_call', hash_including(additional_properties: hash_including(mcp_client_name: 'node')))
          expect(handler).not_to have_received(:track_internal_event)
            .with('start_mcp_tool_call', hash_including(additional_properties: hash_including(:mcp_client_version)))
        end
      end
    end

    context 'when tool is a custom service' do
      let(:custom_tool) { instance_double(Mcp::Tools::Base::CustomService) }

      before do
        allow(manager).to receive(:get_tool).with(name: tool_name).and_return(custom_tool)
        allow(custom_tool).to receive(:is_a?).with(Mcp::Tools::Base::CustomService).and_return(true)
        allow(custom_tool).to receive(:is_a?).with(Mcp::Tools::Base::GraphqlService).and_return(false)
        allow(custom_tool).to receive(:set_cred)
        allow(custom_tool).to receive_messages(
          governed_containers: no_containers,
          execute: { content: [{ type: 'text', text: 'Success' }] }
        )
      end

      it 'sets credentials before executing and tracks events' do
        result = handler.invoke(request, params, current_user)

        expect(custom_tool).to have_received(:set_cred).with(current_user: current_user)
        expect(custom_tool).to have_received(:execute).with(request: request, params: params)
        expect(result).to eq({ content: [{ type: 'text', text: 'Success' }] })

        expect(handler).to have_received(:track_internal_event).with(
          'finish_mcp_tool_call',
          user: current_user,
          additional_properties: hash_including(tool_name: tool_name, has_tool_call_success: 'true')
        )
      end
    end

    context 'when tool is a graphql service' do
      let(:graphql_tool) { instance_double(Mcp::Tools::Base::GraphqlService) }

      before do
        allow(manager).to receive(:get_tool).with(name: tool_name).and_return(graphql_tool)
        allow(graphql_tool).to receive(:is_a?).with(Mcp::Tools::Base::CustomService).and_return(false)
        allow(graphql_tool).to receive(:is_a?).with(Mcp::Tools::Base::GraphqlService).and_return(true)
        allow(graphql_tool).to receive(:set_cred)
        allow(graphql_tool).to receive_messages(
          governed_containers: no_containers,
          execute: { content: [{ type: 'text', text: 'Success' }] }
        )
      end

      it 'sets credentials before executing and tracks events' do
        result = handler.invoke(request, params, current_user)

        expect(graphql_tool).to have_received(:set_cred).with(current_user: current_user)
        expect(graphql_tool).to have_received(:execute).with(request: request, params: params)
        expect(result).to eq({ content: [{ type: 'text', text: 'Success' }] })

        expect(handler).to have_received(:track_internal_event).with(
          'finish_mcp_tool_call',
          user: current_user,
          additional_properties: hash_including(tool_name: tool_name, has_tool_call_success: 'true')
        )
      end
    end

    context 'when arguments do not contain project_id or group_id' do
      it 'tracks events without a project or namespace' do
        handler.invoke(request, params, current_user)

        expect(handler).to have_received(:track_internal_event).with(
          'start_mcp_tool_call',
          user: current_user,
          additional_properties: hash_including(tool_name: tool_name, request_id: '1')
        )

        expect(handler).to have_received(:track_internal_event).with(
          'finish_mcp_tool_call',
          user: current_user,
          additional_properties: hash_including(tool_name: tool_name, has_tool_call_success: 'true')
        )
      end
    end

    context 'when arguments include a project_id as an integer id' do
      let(:arguments) { { project_id: project.id.to_s } }

      it 'tracks events with the project (namespace auto-derived by InternalEvents)' do
        handler.invoke(request, params, current_user)

        expect(handler).to have_received(:track_internal_event).with(
          'start_mcp_tool_call',
          user: current_user,
          project: project,
          additional_properties: hash_including(tool_name: tool_name)
        )

        expect(handler).to have_received(:track_internal_event).with(
          'finish_mcp_tool_call',
          user: current_user,
          project: project,
          additional_properties: hash_including(has_tool_call_success: 'true')
        )
      end
    end

    context 'when arguments include a project_id as a full path' do
      let(:arguments) { { project_id: project.full_path } }

      it 'resolves the project from its full path' do
        handler.invoke(request, params, current_user)

        expect(handler).to have_received(:track_internal_event).with(
          'finish_mcp_tool_call',
          user: current_user,
          project: project,
          additional_properties: hash_including(has_tool_call_success: 'true')
        )
      end
    end

    context 'when arguments include a group_id as an integer id' do
      let(:arguments) { { group_id: group.id.to_s } }

      it 'tracks events with the group as the namespace' do
        handler.invoke(request, params, current_user)

        expect(handler).to have_received(:track_internal_event).with(
          'finish_mcp_tool_call',
          user: current_user,
          namespace: group,
          additional_properties: hash_including(has_tool_call_success: 'true')
        )
      end
    end

    context 'when arguments include a group_id as a full path' do
      let(:arguments) { { group_id: group.full_path } }

      it 'resolves the group from its full path' do
        handler.invoke(request, params, current_user)

        expect(handler).to have_received(:track_internal_event).with(
          'finish_mcp_tool_call',
          user: current_user,
          namespace: group,
          additional_properties: hash_including(has_tool_call_success: 'true')
        )
      end
    end

    context 'when arguments use string keys (JSON-originated params)' do
      let(:params) { { name: tool_name, 'arguments' => { 'project_id' => project.id.to_s } } }

      it 'still resolves the project from string-keyed arguments' do
        handler.invoke(request, params, current_user)

        expect(handler).to have_received(:track_internal_event).with(
          'finish_mcp_tool_call',
          user: current_user,
          project: project,
          additional_properties: hash_including(has_tool_call_success: 'true')
        )
      end
    end

    context 'when project_id is invalid or unknown' do
      let(:arguments) { { project_id: 'non-existent/project' } }

      it 'falls back to tracking without a project or namespace' do
        handler.invoke(request, params, current_user)

        expect(handler).to have_received(:track_internal_event).with(
          'finish_mcp_tool_call',
          user: current_user,
          additional_properties: hash_including(has_tool_call_success: 'true')
        )
      end
    end

    context 'when project_id is an unknown numeric id' do
      let(:arguments) { { project_id: non_existing_record_id.to_s } }

      it 'falls back to tracking without a project or namespace' do
        handler.invoke(request, params, current_user)

        expect(handler).to have_received(:track_internal_event).with(
          'finish_mcp_tool_call',
          user: current_user,
          additional_properties: hash_including(has_tool_call_success: 'true')
        )
      end
    end

    context 'when the tool raises an unexpected exception' do
      before do
        allow(tool).to receive(:execute).and_raise(StandardError, 'boom')
      end

      it 'records the generic category rather than the exception class' do
        expect { handler.invoke(request, params, current_user) }.to raise_error(StandardError, 'boom')

        expect(handler).to have_received(:track_internal_event).with(
          'finish_mcp_tool_call',
          user: current_user,
          additional_properties: hash_including(
            tool_name: tool_name,
            has_tool_call_success: 'false',
            failure_reason: 'error'
          )
        )
      end
    end

    context 'when the tool returns a response-level error' do
      let(:error_result) do
        {
          content: [{ type: 'text', text: 'Validation error: labels is invalid' }],
          structuredContent: {},
          isError: true,
          reason: Mcp::Tools::Base::Response::Reason::BAD_REQUEST
        }
      end

      before do
        allow(tool).to receive(:execute).and_return(error_result)
      end

      it 'tracks the finish event as a failure' do
        handler.invoke(request, params, current_user)

        expect(handler).to have_received(:track_internal_event).with(
          'finish_mcp_tool_call',
          user: current_user,
          additional_properties: hash_including(
            tool_name: tool_name,
            has_tool_call_success: 'false',
            failure_reason: 'bad_request'
          )
        )
      end
    end

    context 'when group_id is invalid or unknown' do
      let(:arguments) { { group_id: 'non-existent/group' } }

      it 'falls back to tracking without a project or namespace' do
        handler.invoke(request, params, current_user)

        expect(handler).to have_received(:track_internal_event).with(
          'finish_mcp_tool_call',
          user: current_user,
          additional_properties: hash_including(has_tool_call_success: 'true')
        )
      end
    end

    context 'when arguments include both a project_id and a group_id' do
      let(:arguments) { { project_id: project.id.to_s, group_id: group.id.to_s } }

      it 'tracks the event with both the project and the group namespace' do
        handler.invoke(request, params, current_user)

        expect(handler).to have_received(:track_internal_event).with(
          'finish_mcp_tool_call',
          user: current_user,
          project: project,
          namespace: group,
          additional_properties: hash_including(has_tool_call_success: 'true')
        )
      end
    end

    context 'when the scope is resolved for both the start and finish events' do
      let(:arguments) { { project_id: project.id.to_s } }

      it 'resolves the scope once and reuses it for both events and the log line' do
        expect(tool).to receive(:governed_containers).once.and_call_original

        handler.invoke(request, params, current_user)
      end
    end

    context 'when tool is not found' do
      let(:arguments) { { project_id: project.id.to_s } }

      before do
        allow(manager).to receive(:get_tool).with(name: tool_name)
          .and_raise(Mcp::Tools::Manager::ToolNotFoundError.new(tool_name))
      end

      it 'raises ArgumentError and tracks both start and finish events with the resolved project' do
        expect { handler.invoke(request, params, current_user) }
          .to raise_error(ArgumentError, "Tool '#{tool_name}' not found.")

        expect(handler).to have_received(:track_internal_event).with(
          'start_mcp_tool_call',
          user: current_user,
          project: project,
          additional_properties: hash_including(tool_name: tool_name, request_id: '1')
        )

        expect(handler).to have_received(:track_internal_event).with(
          'finish_mcp_tool_call',
          user: current_user,
          project: project,
          additional_properties: hash_including(tool_name: tool_name, has_tool_call_success: 'false')
        )
      end
    end

    context 'when logging the tool call' do
      let(:logger) { instance_double(Gitlab::Mcp::Logger) }

      before do
        allow(Gitlab::Mcp::Logger).to receive(:build).and_return(logger)
        allow(logger).to receive(:conditional_info)
      end

      context 'when arguments include a project_id' do
        let(:arguments) { { project_id: project.id.to_s } }

        it 'gates expanded logging on the root ancestor of the project namespace' do
          handler.invoke(request, params, current_user)

          expect(logger).to have_received(:conditional_info).with(
            current_user, hash_including(namespace: project.root_ancestor)
          )
        end
      end

      context 'when arguments include a group_id' do
        let(:arguments) { { group_id: group.id.to_s } }

        it 'gates expanded logging on the root ancestor of the group' do
          handler.invoke(request, params, current_user)

          expect(logger).to have_received(:conditional_info).with(
            current_user, hash_including(namespace: group.root_ancestor)
          )
        end
      end

      context 'when arguments contain no project_id or group_id' do
        it 'passes a nil namespace' do
          handler.invoke(request, params, current_user)

          expect(logger).to have_received(:conditional_info).with(
            current_user, hash_including(namespace: nil)
          )
        end
      end
    end
  end

  describe 'namespace attribution of the tool-call events' do
    let_it_be(:subgroup) { create(:group, :private, parent: group) }
    let_it_be(:private_project) { create(:project, :private, group: subgroup) }

    let(:tool_name) { 'test_tool' }
    let(:params) { { name: tool_name, arguments: arguments } }
    let(:success_result) { { content: [{ type: 'text', text: 'Success' }] } }
    let(:tool_class) { Class.new(Mcp::Tools::Base::BaseService) }
    let(:tool) { tool_class.new(name: tool_name) }
    let(:start_properties) { { request_id: '1', tool_name: tool_name } }
    let(:finish_properties) { start_properties.merge(has_tool_call_success: 'true') }

    subject(:invoke) { handler.invoke(request, params, current_user) }

    before do
      allow(request).to receive(:[]).with(:id).and_return('1')
      allow(manager).to receive(:get_tool).with(name: tool_name).and_return(tool)
      allow(manager).to receive(:resolve_alias) { |name| name }
      allow(tool).to receive(:execute).and_return(success_result)
    end

    shared_examples 'attributes both events' do
      it 'tracks the start and finish events with the resolved scope' do
        expect { invoke }
          .to trigger_internal_events('start_mcp_tool_call')
          .with(user: current_user, **expected_scope, additional_properties: start_properties)
          .and trigger_internal_events('finish_mcp_tool_call')
          .with(user: current_user, **expected_scope, additional_properties: finish_properties)
      end
    end

    context 'with a project_id argument' do
      let(:arguments) { { project_id: private_project.id.to_s } }
      let(:expected_scope) { { project: private_project } }

      # The user is not a member of the private project: telemetry must not check permissions.
      it_behaves_like 'attributes both events'
    end

    context 'with a URL-encoded project_id path' do
      let(:arguments) { { project_id: ERB::Util.url_encode(private_project.full_path) } }
      let(:expected_scope) { { project: private_project } }

      it_behaves_like 'attributes both events'
    end

    context 'with a group_id argument' do
      let(:arguments) { { group_id: subgroup.full_path } }
      let(:expected_scope) { { namespace: subgroup } }

      it_behaves_like 'attributes both events'
    end

    context 'with a url argument naming a project resource' do
      let(:arguments) { { url: "#{Gitlab.config.gitlab.url}/#{private_project.full_path}/-/merge_requests/1" } }
      let(:expected_scope) { { project: private_project } }

      it_behaves_like 'attributes both events'
    end

    context 'with a url argument naming a group' do
      let(:arguments) { { url: "#{Gitlab.config.gitlab.url}/groups/#{subgroup.full_path}/-/work_items/1" } }
      let(:expected_scope) { { namespace: subgroup } }

      it_behaves_like 'attributes both events'
    end

    context 'with a tool that declares a full_path style argument' do
      let(:arguments) { { full_path: subgroup.full_path } }
      let(:expected_scope) { { namespace: subgroup } }

      before do
        tool_class.container_arguments(project_or_group: :full_path)
      end

      it_behaves_like 'attributes both events'
    end

    context 'with a tool that declares a project_full_path argument' do
      let(:arguments) { { project_full_path: private_project.full_path } }
      let(:expected_scope) { { project: private_project } }

      before do
        tool_class.container_arguments(project: :project_full_path)
      end

      it_behaves_like 'attributes both events'
    end

    context 'with a route-backed API tool called with id' do
      let(:tool_name) { 'fork_repository' }
      let(:tool) { Mcp::Tools::Manager.new.list_tools['fork_repository'] }
      let(:arguments) { { id: private_project.id.to_s } }
      let(:expected_scope) { { project: private_project } }

      it_behaves_like 'attributes both events'
    end

    context 'with an aggregated tool that rewrites its arguments' do
      let(:tool_name) { 'semantic_search' }
      let(:underlying_tool) do
        instance_double(Mcp::Tools::Base::ApiTool, name: 'semantic_code_search', execute: success_result)
      end

      let(:tool) { Mcp::Tools::SemanticSearch::SemanticSearchService.new(tools: [underlying_tool]) }
      let(:arguments) { { scope: 'code', q: 'auth', project_id: private_project.full_path } }
      let(:expected_scope) { { project: private_project } }

      before do
        allow(tool).to receive(:execute).and_call_original
      end

      it_behaves_like 'attributes both events'

      it 'forwards the rewritten arguments, which no longer carry project_id' do
        invoke

        expect(underlying_tool).to have_received(:execute)
          .with(request: request, params: hash_including(arguments: { q: 'auth', id: private_project.full_path }))
      end
    end

    context 'with a tool marked ungovernable!' do
      let(:tool_class) { Class.new(Mcp::Tools::Base::BaseService) { ungovernable! } }
      let(:arguments) { { project_id: private_project.id.to_s } }
      let(:expected_scope) { {} }

      it_behaves_like 'attributes both events'
    end

    context 'when resolving the scope raises' do
      let(:arguments) { { project_id: private_project.id.to_s } }
      let(:expected_scope) { {} }

      before do
        allow(tool).to receive(:governed_containers).and_raise(ActiveRecord::StatementInvalid)
        allow(Gitlab::ErrorTracking).to receive(:track_exception)
      end

      it_behaves_like 'attributes both events'

      it 'still returns the tool response and reports the error' do
        expect(invoke).to eq(success_result)
        expect(Gitlab::ErrorTracking).to have_received(:track_exception)
          .with(an_instance_of(ActiveRecord::StatementInvalid), mcp_tool: tool_name).once
      end
    end

    context 'when a container argument names too many containers' do
      let(:arguments) { { project_id: Array.new(101, &:to_s) } }
      let(:expected_scope) { {} }

      it_behaves_like 'attributes both events'
    end

    context 'when logging the tool call' do
      let(:arguments) { { project_id: private_project.id.to_s } }
      let(:logger) { instance_double(Gitlab::Mcp::Logger, conditional_info: nil) }

      before do
        allow(Gitlab::Mcp::Logger).to receive(:build).and_return(logger)
      end

      it 'logs the root namespace id as an always-indexed field and gates expanded logging on it' do
        invoke

        expect(logger).to have_received(:conditional_info).with(
          current_user,
          hash_including(
            Labkit::Fields::GL_ROOT_NAMESPACE_ID => group.id,
            namespace: group,
            expanded: { arguments: arguments.stringify_keys }
          )
        )
      end
    end
  end
end
