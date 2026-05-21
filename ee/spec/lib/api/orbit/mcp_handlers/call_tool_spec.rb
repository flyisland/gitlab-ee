# frozen_string_literal: true

require 'spec_helper'

RSpec.describe API::Orbit::McpHandlers::CallTool, feature_category: :knowledge_graph do
  let_it_be(:user) { create(:user) }
  let_it_be(:access_token) { create(:oauth_access_token, user: user, scopes: [:mcp_orbit]) }

  let(:grpc_client) { instance_double(Analytics::KnowledgeGraph::GrpcClient) }
  let(:tool_name) { 'invoke_command' }
  let(:arguments) { invoke_command_arguments('query_graph', { 'query' => 'find pipelines' }) }
  let(:params) { { name: tool_name, arguments: arguments } }

  let(:request_context) do
    Analytics::KnowledgeGraph::RequestContext.new(source_type: Analytics::KnowledgeGraph::SourceType::MCP)
  end

  subject(:handler) do
    described_class.new(
      params,
      access_token,
      user,
      grpc_client: grpc_client,
      request_context: request_context
    )
  end

  def invoke_command_arguments(command_name, parameters)
    { 'command_name' => command_name, 'parameters' => parameters }
  end

  describe '#invoke' do
    before do
      auth_context = instance_double(
        Analytics::KnowledgeGraph::AuthorizationContext, has_enabled_namespaces?: true
      )
      allow(Analytics::KnowledgeGraph::AuthorizationContext).to receive(:new).and_return(auth_context)
    end

    context 'when query_graph tool is called' do
      let(:send_data_header) { 'Gitlab-Workhorse-Send-Data' }
      let(:send_data_value) { 'orbit-query:test-encoded-data' }

      before do
        allow(Gitlab::Workhorse).to receive(:send_orbit_query)
          .with(hash_including(query: 'find pipelines', user: user, format: :llm, mcp_id: nil))
          .and_return([send_data_header, send_data_value])
      end

      it 'returns a WorkhorseSendData struct' do
        result = handler.invoke

        expect(result).to be_a(described_class::WorkhorseSendData)
        expect(result.header_name).to eq(send_data_header)
        expect(result.header_value).to eq(send_data_value)
      end
    end

    context 'when query_graph is called with format raw' do
      let(:arguments) { invoke_command_arguments('query_graph', { 'query' => 'find pipelines', 'format' => 'raw' }) }

      before do
        allow(Gitlab::Workhorse).to receive(:send_orbit_query)
          .with(hash_including(query: 'find pipelines', user: user, format: :raw, mcp_id: nil))
          .and_return(['Gitlab-Workhorse-Send-Data', 'orbit-query:test'])
      end

      it 'passes raw format to Workhorse' do
        result = handler.invoke

        expect(result).to be_a(described_class::WorkhorseSendData)
        expect(Gitlab::Workhorse).to have_received(:send_orbit_query)
          .with(hash_including(format: :raw))
      end
    end

    context 'when query_graph is called without format' do
      before do
        allow(Gitlab::Workhorse).to receive(:send_orbit_query)
          .with(hash_including(query: 'find pipelines', user: user, format: :llm, mcp_id: nil))
          .and_return(['Gitlab-Workhorse-Send-Data', 'orbit-query:test'])
      end

      it 'defaults to llm format' do
        handler.invoke

        expect(Gitlab::Workhorse).to have_received(:send_orbit_query)
          .with(hash_including(format: :llm))
      end
    end

    context 'when query_graph is called with a Hash query' do
      let(:query) { { 'query_type' => 'search', 'node' => { 'id' => 'n', 'entity' => 'Project' } } }
      let(:arguments) { invoke_command_arguments('query_graph', { 'query' => query }) }

      before do
        allow(Gitlab::Workhorse).to receive(:send_orbit_query)
          .with(hash_including(query: query.to_json, user: user, format: :llm, mcp_id: nil))
          .and_return(['Gitlab-Workhorse-Send-Data', 'orbit-query:test'])
      end

      it 'serializes the Hash to JSON before passing to Workhorse' do
        result = handler.invoke

        expect(result).to be_a(described_class::WorkhorseSendData)
        expect(Gitlab::Workhorse).to have_received(:send_orbit_query)
          .with(hash_including(query: query.to_json))
      end
    end

    context 'when query_graph is called without enabled namespaces' do
      before do
        auth_context = instance_double(
          Analytics::KnowledgeGraph::AuthorizationContext, has_enabled_namespaces?: false
        )
        allow(Analytics::KnowledgeGraph::AuthorizationContext).to receive(:new).and_return(auth_context)
      end

      it 'returns a tool error response' do
        result = handler.invoke

        expect(result[:isError]).to be(true)
        expect(result[:content].first[:text]).to include('No Knowledge Graph enabled namespaces available')
      end

      it 'does not call Workhorse' do
        allow(Gitlab::Workhorse).to receive(:send_orbit_query)

        handler.invoke

        expect(Gitlab::Workhorse).not_to have_received(:send_orbit_query)
      end
    end

    context 'when get_graph_schema returns formatted_text (LLM format)' do
      let(:tool_name) { 'get_graph_schema' }
      let(:arguments) { { 'expand_nodes' => ['Pipeline'] } }
      let(:toon_text) { "Nodes:\n- Pipeline\n- Project" }
      let(:schema_result) { { formatted_text: toon_text } }

      before do
        allow(grpc_client).to receive(:get_graph_schema)
          .with(hash_including(expand_nodes: ['Pipeline'], format: :llm, user: user))
          .and_return(schema_result)
      end

      it 'extracts formatted_text directly without double-encoding' do
        result = handler.invoke

        expect(result[:isError]).to be(false)
        expect(result[:content].first[:text]).to eq(toon_text)
      end
    end

    context 'when get_graph_schema returns a hash without formatted_text' do
      let(:tool_name) { 'get_graph_schema' }
      let(:arguments) { { 'expand_nodes' => ['Pipeline'] } }
      let(:schema_result) { { 'nodes' => [{ 'name' => 'Pipeline' }], 'edges' => [] } }

      before do
        allow(grpc_client).to receive(:get_graph_schema)
          .with(hash_including(expand_nodes: ['Pipeline'], format: :llm, user: user))
          .and_return(schema_result)
      end

      it 'falls back to to_json for non-formatted_text results' do
        result = handler.invoke

        expect(result[:isError]).to be(false)
        parsed = Gitlab::Json.safe_parse(result[:content].first[:text])
        expect(parsed).to eq(schema_result)
      end
    end

    context 'when get_graph_schema is called with format raw' do
      let(:tool_name) { 'get_graph_schema' }
      let(:arguments) { { 'expand_nodes' => ['Pipeline'], 'format' => 'raw' } }
      let(:schema_result) { { 'nodes' => [{ 'name' => 'Pipeline' }], 'edges' => [] } }

      before do
        allow(grpc_client).to receive(:get_graph_schema)
          .with(hash_including(expand_nodes: ['Pipeline'], format: :raw, user: user))
          .and_return(schema_result)
      end

      it 'passes raw format to grpc_client' do
        result = handler.invoke

        expect(result[:isError]).to be(false)
        expect(grpc_client).to have_received(:get_graph_schema)
          .with(hash_including(format: :raw))
      end
    end

    context 'when list_commands is called' do
      let(:tool_name) { 'list_commands' }
      let(:arguments) { { 'command_names' => ['get_query_dsl'], 'format' => 'llm' } }
      let(:commands_result) do
        [{ name: 'get_query_dsl', description: 'Return query DSL', parameters: { 'type' => 'object' } }]
      end

      before do
        allow(grpc_client).to receive(:list_agent_commands)
          .with(user: user, command_names: ['get_query_dsl'], format: :llm,
            request_context: an_instance_of(Analytics::KnowledgeGraph::RequestContext))
          .and_return({ formatted_text: "commands[1]:\n  - name: get_query_dsl" })
      end

      it 'returns the LLM-formatted command catalog from gRPC' do
        result = handler.invoke

        expect(result[:isError]).to be(false)
        expect(result[:content].first[:text]).to include('commands[1]:')
        expect(result[:content].first[:text]).to include('name: get_query_dsl')
      end

      context 'with raw format' do
        let(:arguments) { { 'command_names' => ['get_query_dsl'], 'format' => 'raw' } }

        before do
          allow(grpc_client).to receive(:list_agent_commands)
            .with(user: user, command_names: ['get_query_dsl'], format: :raw,
              request_context: an_instance_of(Analytics::KnowledgeGraph::RequestContext))
            .and_return(commands_result)
        end

        it 'returns command metadata from gRPC as JSON text' do
          result = handler.invoke

          expect(result[:isError]).to be(false)
          parsed = Gitlab::Json.safe_parse(result[:content].first[:text])
          expect(parsed.first['name']).to eq('get_query_dsl')
        end
      end
    end

    context 'when invoke_command falls through to GKG' do
      let(:tool_name) { 'invoke_command' }
      let(:arguments) do
        {
          'command_name' => 'get_query_dsl',
          'parameters' => { 'format' => 'llm' }
        }
      end

      before do
        allow(grpc_client).to receive(:invoke_agent_command)
          .with(command_name: 'get_query_dsl', parameters: { 'format' => 'llm' }, user: user,
            request_context: an_instance_of(Analytics::KnowledgeGraph::RequestContext))
          .and_return({ formatted_text: 'dsl text' })
      end

      it 'invokes the command through gRPC' do
        result = handler.invoke

        expect(result[:isError]).to be(false)
        expect(result[:content].first[:text]).to eq('dsl text')
      end
    end

    context 'when invoke_command intercepts query_graph' do
      let(:tool_name) { 'invoke_command' }
      let(:arguments) do
        {
          'command_name' => 'query_graph',
          'parameters' => { 'query' => 'find pipelines' }
        }
      end

      before do
        allow(Gitlab::Workhorse).to receive(:send_orbit_query)
          .with(hash_including(query: 'find pipelines', user: user, format: :llm, mcp_id: nil))
          .and_return(['Gitlab-Workhorse-Send-Data', 'orbit-query:test'])
      end

      it 'routes to the existing Workhorse path' do
        result = handler.invoke

        expect(result).to be_a(described_class::WorkhorseSendData)
      end
    end

    context 'when invoke_command receives downstream arguments at the top level' do
      let(:tool_name) { 'invoke_command' }
      let(:arguments) { { 'command_name' => 'get_query_dsl', 'format' => 'llm' } }

      it 'raises an invalid parameter error' do
        expect { handler.invoke }.to raise_error(ArgumentError, /Put downstream command inputs inside 'parameters'/)
      end
    end

    context 'when get_graph_status is called with namespace_id' do
      let_it_be(:group) { create(:group) }
      let(:tool_name) { 'get_graph_status' }
      let(:arguments) { { 'namespace_id' => group.id } }
      let(:graph_status_result) do
        {
          projects: { indexed: 5, total_known: 10 },
          domains: [{ name: 'ci', items: [{ name: 'Pipeline', count: 42 }] }],
          indexing: { state: 'indexed', last_started_at: nil, last_completed_at: nil, last_duration_ms: nil,
                      last_error: nil }
        }
      end

      before_all do
        group.add_reporter(user)
      end

      before do
        allow(grpc_client).to receive(:get_graph_status).and_return(graph_status_result)
      end

      it 'returns graph status as formatted success' do
        result = handler.invoke

        expect(result[:isError]).to be(false)
        parsed = Gitlab::Json.safe_parse(result[:content].first[:text])
        expect(parsed['projects']['indexed']).to eq(5)
      end

      it 'forwards traversal_path to grpc client' do
        handler.invoke

        expect(grpc_client).to have_received(:get_graph_status).with(
          user: user,
          traversal_path: group.traversal_path(with_organization: true),
          target_type: :group,
          format: :llm,
          request_context: an_instance_of(Analytics::KnowledgeGraph::RequestContext)
        )
      end
    end

    context 'when get_graph_status is called with project_id' do
      let_it_be(:group) { create(:group) }
      let_it_be(:project) { create(:project, namespace: group) }
      let(:tool_name) { 'get_graph_status' }
      let(:arguments) { { 'project_id' => project.id } }

      before_all do
        group.add_reporter(user)
      end

      before do
        allow(grpc_client).to receive(:get_graph_status).and_return({ projects: {}, domains: [], indexing: nil })
      end

      it 'resolves project to its project_namespace traversal_path' do
        handler.invoke

        expect(grpc_client).to have_received(:get_graph_status).with(
          hash_including(
            traversal_path: project.project_namespace.traversal_path(with_organization: true),
            target_type: :project
          )
        )
      end
    end

    context 'when get_graph_status is called with full_path' do
      let_it_be(:group) { create(:group) }
      let(:tool_name) { 'get_graph_status' }
      let(:arguments) { { 'full_path' => group.full_path } }

      before_all do
        group.add_reporter(user)
      end

      before do
        allow(grpc_client).to receive(:get_graph_status).and_return({ projects: {}, domains: [], indexing: nil })
      end

      it 'resolves full_path to traversal_path' do
        handler.invoke

        expect(grpc_client).to have_received(:get_graph_status).with(
          hash_including(
            traversal_path: group.traversal_path(with_organization: true),
            target_type: :group
          )
        )
      end
    end

    context 'when get_graph_status target is not found' do
      let(:tool_name) { 'get_graph_status' }
      let(:arguments) { { 'namespace_id' => non_existing_record_id } }

      it 'returns an error result' do
        result = handler.invoke

        expect(result[:isError]).to be(true)
        expect(result[:content].first[:text]).to include('Namespace not found')
      end
    end

    context 'when get_graph_status target is a private group user cannot access' do
      let_it_be(:private_group) { create(:group, :private) }
      let(:tool_name) { 'get_graph_status' }
      let(:arguments) { { 'namespace_id' => private_group.id } }

      it 'returns an error result without leaking existence' do
        result = handler.invoke

        expect(result[:isError]).to be(true)
        expect(result[:content].first[:text]).to include('Namespace not found')
      end
    end

    context 'when get_graph_status is called without enabled namespaces' do
      let_it_be(:group) { create(:group) }
      let(:tool_name) { 'get_graph_status' }
      let(:arguments) { { 'namespace_id' => group.id } }

      before do
        auth_context = instance_double(
          Analytics::KnowledgeGraph::AuthorizationContext, has_enabled_namespaces?: false
        )
        allow(Analytics::KnowledgeGraph::AuthorizationContext).to receive(:new).and_return(auth_context)
      end

      it 'returns a tool error response' do
        result = handler.invoke

        expect(result[:isError]).to be(true)
        expect(result[:content].first[:text]).to include('No Knowledge Graph enabled namespaces available')
      end
    end

    context 'when get_graph_status raises ConnectionError' do
      let_it_be(:group) { create(:group) }
      let(:tool_name) { 'get_graph_status' }
      let(:arguments) { { 'namespace_id' => group.id } }

      before_all do
        group.add_reporter(user)
      end

      before do
        allow(grpc_client).to receive(:get_graph_status)
          .and_raise(Analytics::KnowledgeGraph::GrpcClient::ConnectionError, 'unavailable')
      end

      it 'raises API::Orbit::Mcp::InternalError' do
        expect { handler.invoke }.to raise_error(API::Orbit::Mcp::InternalError, /unavailable/)
      end
    end

    context 'when tool name is unknown' do
      let(:params) { { name: 'unknown_tool', arguments: {} } }

      it 'raises ArgumentError' do
        expect { handler.invoke }.to raise_error(ArgumentError, /Unknown tool: unknown_tool/)
      end
    end

    context 'when tool name is missing' do
      let(:params) { { name: nil, arguments: {} } }

      it 'raises ArgumentError' do
        expect { handler.invoke }.to raise_error(ArgumentError)
      end
    end

    context 'when tool name is empty' do
      let(:params) { { name: '', arguments: {} } }

      it 'raises ArgumentError' do
        expect { handler.invoke }.to raise_error(ArgumentError)
      end
    end

    context 'when get_graph_schema raises ConnectionError' do
      let(:tool_name) { 'get_graph_schema' }
      let(:arguments) { { 'expand_nodes' => [] } }

      before do
        allow(grpc_client).to receive(:get_graph_schema)
          .and_raise(Analytics::KnowledgeGraph::GrpcClient::ConnectionError, 'connection refused')
      end

      it 'raises API::Orbit::Mcp::InternalError' do
        expect { handler.invoke }.to raise_error(API::Orbit::Mcp::InternalError, /connection refused/)
      end
    end

    context 'when get_graph_schema raises ExecutionError' do
      let(:tool_name) { 'get_graph_schema' }
      let(:arguments) { { 'expand_nodes' => ['BadNode'] } }

      before do
        allow(grpc_client).to receive(:get_graph_schema)
          .and_raise(Analytics::KnowledgeGraph::GrpcClient::ExecutionError, 'INVALID_NODE: BadNode')
      end

      it 'returns MCP error result with isError true' do
        result = handler.invoke

        expect(result[:isError]).to be(true)
        expect(result[:content]).to be_an(Array)
        expect(result[:content].first[:type]).to eq('text')
        expect(result[:content].first[:text]).to include('INVALID_NODE: BadNode')
      end
    end

    context 'when get_graph_schema raises StreamError' do
      let(:tool_name) { 'get_graph_schema' }
      let(:arguments) { { 'expand_nodes' => [] } }

      before do
        allow(grpc_client).to receive(:get_graph_schema)
          .and_raise(Analytics::KnowledgeGraph::GrpcClient::StreamError, 'Stream ended without result')
      end

      it 'raises API::Orbit::Mcp::InternalError' do
        expect { handler.invoke }.to raise_error(API::Orbit::Mcp::InternalError, /Stream ended without result/)
      end
    end

    context 'when session_id is provided' do
      subject(:handler) do
        described_class.new(
          params,
          access_token,
          user,
          grpc_client: grpc_client,
          request_context: Analytics::KnowledgeGraph::RequestContext.new(
            source_type: Analytics::KnowledgeGraph::SourceType::MCP,
            session_id: 'workflow-abc-123'
          )
        )
      end

      context 'when calling query_graph' do
        before do
          allow(Gitlab::Workhorse).to receive(:send_orbit_query)
            .and_return(['Gitlab-Workhorse-Send-Data', 'orbit-query:test'])
        end

        it 'passes session_id to send_orbit_query' do
          handler.invoke

          expect(Gitlab::Workhorse).to have_received(:send_orbit_query)
            .with(hash_including(request_context: having_attributes(session_id: 'workflow-abc-123')))
        end
      end

      context 'when calling get_graph_schema' do
        let(:tool_name) { 'get_graph_schema' }
        let(:arguments) { { 'expand_nodes' => ['Pipeline'] } }

        before do
          allow(grpc_client).to receive(:get_graph_schema).and_return({ formatted_text: 'schema' })
        end

        it 'passes session_id to grpc_client.get_graph_schema' do
          handler.invoke

          expect(grpc_client).to have_received(:get_graph_schema)
            .with(hash_including(request_context: having_attributes(session_id: 'workflow-abc-123')))
        end
      end
    end

    context 'when session_id is not provided' do
      before do
        allow(Gitlab::Workhorse).to receive(:send_orbit_query)
          .and_return(['Gitlab-Workhorse-Send-Data', 'orbit-query:test'])
      end

      it 'passes nil session_id to send_orbit_query' do
        handler.invoke

        expect(Gitlab::Workhorse).to have_received(:send_orbit_query)
          .with(hash_including(request_context: having_attributes(session_id: nil)))
      end
    end

    context 'when user_agent is provided' do
      subject(:handler) do
        described_class.new(
          params,
          access_token,
          user,
          grpc_client: grpc_client,
          request_context: Analytics::KnowledgeGraph::RequestContext.new(
            source_type: Analytics::KnowledgeGraph::SourceType::MCP,
            user_agent: 'TestAgent/1.0'
          )
        )
      end

      context 'when calling query_graph' do
        before do
          allow(Gitlab::Workhorse).to receive(:send_orbit_query)
            .and_return(['Gitlab-Workhorse-Send-Data', 'orbit-query:test'])
        end

        it 'passes user_agent to send_orbit_query' do
          handler.invoke

          expect(Gitlab::Workhorse).to have_received(:send_orbit_query)
            .with(hash_including(request_context: having_attributes(user_agent: 'TestAgent/1.0')))
        end
      end

      context 'when calling get_graph_schema' do
        let(:tool_name) { 'get_graph_schema' }
        let(:arguments) { { 'expand_nodes' => ['Pipeline'] } }

        before do
          allow(grpc_client).to receive(:get_graph_schema).and_return({ formatted_text: 'schema' })
        end

        it 'passes user_agent to grpc_client.get_graph_schema' do
          handler.invoke

          expect(grpc_client).to have_received(:get_graph_schema)
            .with(hash_including(request_context: having_attributes(user_agent: 'TestAgent/1.0')))
        end
      end

      context 'when calling get_graph_status' do
        let_it_be(:group) { create(:group) }
        let(:tool_name) { 'get_graph_status' }
        let(:arguments) { { 'namespace_id' => group.id } }

        before_all do
          group.add_reporter(user)
        end

        before do
          allow(grpc_client).to receive(:get_graph_status).and_return({ projects: {}, domains: [], indexing: nil })
        end

        it 'passes user_agent to grpc_client.get_graph_status' do
          handler.invoke

          expect(grpc_client).to have_received(:get_graph_status)
            .with(hash_including(request_context: having_attributes(user_agent: 'TestAgent/1.0')))
        end
      end

      context 'when calling list_commands' do
        let(:tool_name) { 'list_commands' }
        let(:arguments) { { 'command_names' => ['get_query_dsl'], 'format' => 'llm' } }

        before do
          allow(grpc_client).to receive(:list_agent_commands)
            .and_return({ formatted_text: "commands[1]:\n  - name: get_query_dsl" })
        end

        it 'passes user_agent to grpc_client.list_agent_commands' do
          handler.invoke

          expect(grpc_client).to have_received(:list_agent_commands)
            .with(hash_including(request_context: having_attributes(user_agent: 'TestAgent/1.0')))
        end
      end

      context 'when calling invoke_command' do
        let(:tool_name) { 'invoke_command' }
        let(:arguments) { { 'command_name' => 'get_query_dsl', 'parameters' => { 'format' => 'llm' } } }

        before do
          allow(grpc_client).to receive(:invoke_agent_command).and_return({ formatted_text: 'dsl text' })
        end

        it 'passes user_agent to grpc_client.invoke_agent_command' do
          handler.invoke

          expect(grpc_client).to have_received(:invoke_agent_command)
            .with(hash_including(request_context: having_attributes(user_agent: 'TestAgent/1.0')))
        end
      end
    end

    context 'when user_agent is not provided' do
      before do
        allow(Gitlab::Workhorse).to receive(:send_orbit_query)
          .and_return(['Gitlab-Workhorse-Send-Data', 'orbit-query:test'])
      end

      it 'passes nil user_agent to send_orbit_query' do
        handler.invoke

        expect(Gitlab::Workhorse).to have_received(:send_orbit_query)
          .with(hash_including(request_context: having_attributes(user_agent: nil)))
      end
    end
  end
end
