# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Analytics::KnowledgeGraph::GrpcClient, feature_category: :knowledge_graph do
  let_it_be(:user) { create(:user) }
  let_it_be(:group) { create(:group) }

  let(:endpoint) { 'localhost:50054' }
  let(:grpc_stub) { instance_double(::Orbit::V1::OrbitService::Stub) }
  let(:source_type) { Analytics::KnowledgeGraph::SourceType::REST }
  let(:request_context) { Analytics::KnowledgeGraph::RequestContext.new(source_type: source_type) }

  subject(:client) { described_class.new(endpoint: endpoint) }

  before_all do
    group.add_reporter(user)
  end

  before do
    stub_feature_flags(orbit_gql_queries: false)
    described_class.send(:instance_variable_set, :@stubs, nil)
    described_class.send(:instance_variable_set, :@channels, nil)
    Gitlab::Metrics::KnowledgeGraph::Request.instance_variable_set(:@histograms, nil)
    Gitlab::Metrics::KnowledgeGraph::Request.instance_variable_set(:@counters, nil)
    allow(described_class).to receive(:stub).and_return(grpc_stub)
    allow(Gitlab::Runtime).to receive(:sidekiq?).and_return(false)
    allow(Analytics::KnowledgeGraph::JwtAuth).to receive(:authorization_header).and_return('Bearer test-token')
  end

  describe '.stub' do
    before do
      allow(described_class).to receive(:stub).and_call_original
    end

    after do
      described_class.send(:instance_variable_set, :@stubs, nil)
      described_class.send(:instance_variable_set, :@channels, nil)
    end

    it 'caches stubs per endpoint' do
      channel = instance_double(GRPC::Core::Channel, target: endpoint, close: nil)
      allow(GRPC::ClientStub).to receive(:setup_channel).and_return(channel)
      allow(::Orbit::V1::OrbitService::Stub).to receive(:new).and_return(grpc_stub)

      stub_a = described_class.stub(endpoint)
      stub_b = described_class.stub(endpoint)

      expect(stub_a).to equal(stub_b)
      expect(::Orbit::V1::OrbitService::Stub).to have_received(:new).once
    end
  end

  describe '.clear_stubs!' do
    after do
      described_class.send(:instance_variable_set, :@stubs, nil)
      described_class.send(:instance_variable_set, :@channels, nil)
    end

    it 'closes channels and clears caches' do
      allow(described_class).to receive(:stub).and_call_original

      channel = instance_double(GRPC::Core::Channel, target: endpoint, close: nil)
      allow(GRPC::ClientStub).to receive(:setup_channel).and_return(channel)
      allow(::Orbit::V1::OrbitService::Stub).to receive(:new).and_return(grpc_stub)

      described_class.stub(endpoint)
      described_class.clear_stubs!

      expect(channel).to have_received(:close)
    end

    it 'handles nil channels gracefully' do
      described_class.send(:instance_variable_set, :@channels, nil)
      described_class.send(:instance_variable_set, :@stubs, nil)

      expect { described_class.clear_stubs! }.not_to raise_error
    end
  end

  describe '.base_metadata' do
    it 'returns the web client name and the correlation id' do
      Labkit::Correlation::CorrelationId.use_id('orbit-cid') do
        expect(described_class.base_metadata).to eq(
          'client_name' => 'gitlab-web', 'x-gitlab-correlation-id' => 'orbit-cid'
        )
      end
    end

    it 'returns the Sidekiq client name in Sidekiq' do
      allow(Gitlab::Runtime).to receive(:sidekiq?).and_return(true)

      expect(described_class.base_metadata).to include('client_name' => 'gitlab-sidekiq')
    end

    it 'omits the correlation id when there is none' do
      allow(Labkit::Correlation::CorrelationId).to receive(:current_id).and_return(nil)

      expect(described_class.base_metadata).to eq('client_name' => 'gitlab-web')
    end
  end

  describe '.configured_endpoint' do
    it 'logs a warning when falling back to default' do
      allow(Gitlab.config).to receive(:knowledge_graph)
        .and_raise(Gitlab::Configs::MissingConfig, 'knowledge_graph')

      expect_next_instance_of(Gitlab::KnowledgeGraph::Logger) do |logger|
        expect(logger).to receive(:warn).with(hash_including(
          message: 'Knowledge Graph gRPC endpoint not configured, using fallback',
          fallback_endpoint: described_class::DEFAULT_GRPC_ENDPOINT
        ))
      end

      described_class.send(:configured_endpoint)
    end
  end

  describe '.channel_credentials' do
    it 'returns insecure credentials for plain endpoints' do
      result = described_class.send(:channel_credentials, 'localhost:50054')
      expect(result).to eq(:this_channel_is_insecure)
    end

    it 'returns TLS credentials with ca_certs_bundle for tls scheme' do
      allow(::Gitlab::X509::Certificate).to receive(:ca_certs_bundle).and_return('cert-data')
      expect(GRPC::Core::ChannelCredentials).to receive(:new).with('cert-data')

      described_class.send(:channel_credentials, 'tls://gkg.example.com:443')
    end

    it 'returns TLS credentials for dns+tls scheme' do
      allow(::Gitlab::X509::Certificate).to receive(:ca_certs_bundle).and_return('cert-data')
      expect(GRPC::Core::ChannelCredentials).to receive(:new).with('cert-data')

      described_class.send(:channel_credentials, 'dns+tls://gkg.example.com:443')
    end

    it 'returns insecure credentials for invalid URI' do
      result = described_class.send(:channel_credentials, ':::invalid')
      expect(result).to eq(:this_channel_is_insecure)
    end
  end

  describe '.strip_scheme' do
    it 'strips tls:// prefix' do
      expect(described_class.send(:strip_scheme, 'tls://gkg.example.com:443')).to eq('gkg.example.com:443')
    end

    it 'strips tcp:// prefix' do
      expect(described_class.send(:strip_scheme, 'tcp://gkg.example.com:50054')).to eq('gkg.example.com:50054')
    end

    it 'converts dns+tls: to dns:' do
      expect(described_class.send(:strip_scheme, 'dns+tls:///gkg.example.com:443')).to eq('dns:///gkg.example.com:443')
    end

    it 'returns plain host:port unchanged' do
      expect(described_class.send(:strip_scheme, 'localhost:50054')).to eq('localhost:50054')
    end
  end

  describe '.create_channel' do
    before do
      allow(described_class).to receive(:stub).and_call_original
      described_class.send(:instance_variable_set, :@channels, nil)
    end

    after do
      described_class.send(:instance_variable_set, :@channels, nil)
    end

    it 'passes stripped address to setup_channel for tls:// endpoints' do
      channel = instance_double(GRPC::Core::Channel, target: 'localhost:50054', close: nil)
      allow(::Gitlab::X509::Certificate).to receive(:ca_certs_bundle).and_return('cert-data')
      allow(GRPC::Core::ChannelCredentials).to receive(:new).and_return(:tls_creds)

      expect(GRPC::ClientStub).to receive(:setup_channel)
        .with(nil, 'localhost:50054', :tls_creds, anything)
        .and_return(channel)

      described_class.send(:create_channel, 'tls://localhost:50054')
    end
  end

  describe '.private_address?' do
    it 'returns true for localhost' do
      expect(described_class.send(:private_address?, 'localhost:50054')).to be(true)
    end

    it 'returns true for 127.0.0.1' do
      expect(described_class.send(:private_address?, '127.0.0.1:50054')).to be(true)
    end

    it 'returns true for RFC1918 address' do
      expect(described_class.send(:private_address?, '10.0.0.1:50054')).to be(true)
    end

    it 'returns false for public address' do
      expect(described_class.send(:private_address?, '8.8.8.8:50054')).to be(false)
    end

    context 'when host is a DNS name' do
      let(:dns_resolver) { instance_double(Resolv::DNS) }

      before do
        allow(Resolv::DNS).to receive(:new).and_return(dns_resolver)
        allow(dns_resolver).to receive(:timeouts=)
        allow(dns_resolver).to receive(:close)
      end

      it 'returns true when all resolved addresses are private' do
        allow(dns_resolver).to receive(:getaddresses).with('gkg.orbit-stg')
          .and_return([Resolv::IPv4.create('10.0.0.5'), Resolv::IPv4.create('10.0.0.6')])

        expect(described_class.send(:private_address?, 'gkg.orbit-stg:50054')).to be(true)
      end

      it 'returns false when all resolved addresses are public' do
        allow(dns_resolver).to receive(:getaddresses).with('gkg.example.com')
          .and_return([Resolv::IPv4.create('93.184.216.34')])

        expect(described_class.send(:private_address?, 'gkg.example.com:50054')).to be(false)
      end

      it 'returns false when resolved addresses mix private and public' do
        allow(dns_resolver).to receive(:getaddresses).with('dual.example.com')
          .and_return([Resolv::IPv4.create('10.0.0.1'), Resolv::IPv4.create('93.184.216.34')])

        expect(described_class.send(:private_address?, 'dual.example.com:50054')).to be(false)
      end

      it 'returns false when DNS resolution fails' do
        allow(dns_resolver).to receive(:getaddresses).with('no-such-host.invalid')
          .and_raise(Resolv::ResolvError)

        expect(described_class.send(:private_address?, 'no-such-host.invalid:50054')).to be(false)
      end

      it 'returns false when DNS resolution times out' do
        allow(dns_resolver).to receive(:getaddresses).with('slow.example.com')
          .and_raise(Resolv::ResolvTimeout)

        expect(described_class.send(:private_address?, 'slow.example.com:50054')).to be(false)
      end

      it 'returns false when DNS returns no addresses' do
        allow(dns_resolver).to receive(:getaddresses).with('empty.example.com').and_return([])

        expect(described_class.send(:private_address?, 'empty.example.com:50054')).to be(false)
      end
    end
  end

  describe 'ConnectionError#client_error?' do
    using RSpec::Parameterized::TableSyntax

    where(:grpc_code, :expected) do
      GRPC::Core::StatusCodes::INVALID_ARGUMENT    | true
      GRPC::Core::StatusCodes::NOT_FOUND           | true
      GRPC::Core::StatusCodes::FAILED_PRECONDITION | true
      GRPC::Core::StatusCodes::UNAVAILABLE         | false
      GRPC::Core::StatusCodes::INTERNAL            | false
      GRPC::Core::StatusCodes::DEADLINE_EXCEEDED   | false
      GRPC::Core::StatusCodes::UNAUTHENTICATED     | false
      GRPC::Core::StatusCodes::PERMISSION_DENIED   | false
      nil                                          | false
    end

    with_them do
      it 'classifies the gRPC code' do
        error = described_class::ConnectionError.new('failed', grpc_code: grpc_code)

        expect(error.client_error?).to be(expected)
      end
    end
  end

  describe '#list_tools' do
    let(:tool_def) do
      ::Orbit::V1::ToolDefinition.new(
        name: 'search',
        description: 'Search the knowledge graph',
        parameters_json_schema: '{"type": "object"}'
      )
    end

    let(:response) { ::Orbit::V1::ListToolsResponse.new(tools: [tool_def]) }

    it 'returns formatted tool definitions' do
      allow(grpc_stub).to receive(:list_tools).and_return(response)

      result = client.list_tools(user: user, request_context: request_context)

      expect(result).to eq([{
        name: 'search',
        description: 'Search the knowledge graph',
        parameters: { 'type' => 'object' }
      }])
    end

    it 'passes JWT authorization metadata' do
      allow(grpc_stub).to receive(:list_tools).and_return(response)

      client.list_tools(user: user, request_context: request_context)

      expect(grpc_stub).to have_received(:list_tools) do |_request, **kwargs|
        expect(kwargs[:metadata]['authorization']).to start_with('Bearer ')
        expect(kwargs[:metadata]['client_name']).to eq('gitlab-web')
      end
    end

    it 'passes source_type to JWT auth header generation' do
      allow(grpc_stub).to receive(:list_tools).and_return(response)

      client.list_tools(
        user: user,
        request_context: Analytics::KnowledgeGraph::RequestContext.new(
          source_type: Analytics::KnowledgeGraph::SourceType::MCP
        )
      )

      expect(Analytics::KnowledgeGraph::JwtAuth).to have_received(:authorization_header)
        .with(user: user, request_context: having_attributes(source_type: Analytics::KnowledgeGraph::SourceType::MCP))
    end

    it 'uses sidekiq client name when running in sidekiq' do
      allow(Gitlab::Runtime).to receive(:sidekiq?).and_return(true)
      allow(grpc_stub).to receive(:list_tools).and_return(response)

      client.list_tools(user: user, request_context: request_context)

      expect(grpc_stub).to have_received(:list_tools) do |_request, **kwargs|
        expect(kwargs[:metadata]['client_name']).to eq('gitlab-sidekiq')
      end
    end

    it 'propagates correlation ID in metadata' do
      allow(grpc_stub).to receive(:list_tools).and_return(response)

      Labkit::Correlation::CorrelationId.use_id('test-correlation-id') do
        client.list_tools(user: user, request_context: request_context)
      end

      expect(grpc_stub).to have_received(:list_tools) do |_request, **kwargs|
        expect(kwargs[:metadata]['x-gitlab-correlation-id']).to eq('test-correlation-id')
      end
    end

    it 'sets a deadline on the request' do
      allow(grpc_stub).to receive(:list_tools).and_return(response)

      client.list_tools(user: user, request_context: request_context, timeout: 5)

      expect(grpc_stub).to have_received(:list_tools) do |_request, **kwargs|
        expect(kwargs[:deadline]).to be_a(Time)
      end
    end

    context 'when user is nil' do
      it 'raises ArgumentError' do
        expect { client.list_tools(user: nil, request_context: request_context) }
          .to raise_error(ArgumentError, 'user is required')
      end
    end

    context 'when authorization header is nil' do
      it 'raises AuthorizationError' do
        allow(Analytics::KnowledgeGraph::JwtAuth).to receive(:authorization_header).and_return(nil)

        expect { client.list_tools(user: user, request_context: request_context) }
          .to raise_error(described_class::AuthorizationError, 'Failed to generate authorization header')
      end
    end

    context 'when gRPC returns an error' do
      it 'raises ConnectionError carrying the gRPC code', :aggregate_failures do
        allow(grpc_stub).to receive(:list_tools)
          .and_raise(GRPC::Unavailable.new('connection refused'))

        expect { client.list_tools(user: user, request_context: request_context) }
          .to raise_error(described_class::ConnectionError, /list_tools failed/) do |error|
            expect(error.grpc_code).to eq(GRPC::Core::StatusCodes::UNAVAILABLE)
          end
      end

      it 'preserves the gRPC code for non-UNAVAILABLE errors', :aggregate_failures do
        allow(grpc_stub).to receive(:list_tools)
          .and_raise(GRPC::PermissionDenied.new('denied'))

        expect { client.list_tools(user: user, request_context: request_context) }
          .to raise_error(described_class::ConnectionError) do |error|
            expect(error.grpc_code).to eq(GRPC::Core::StatusCodes::PERMISSION_DENIED)
          end
      end
    end
  end

  describe '#list_agent_commands' do
    let(:command_def) do
      ::Orbit::V1::ToolDefinition.new(
        name: 'get_query_dsl',
        description: 'Return query DSL',
        parameters_json_schema: '{"type": "object"}'
      )
    end

    let(:response) { ::Orbit::V1::ListAgentCommandsResponse.new(commands: [command_def]) }

    it 'returns formatted command definitions' do
      allow(grpc_stub).to receive(:list_agent_commands).and_return(response)

      result = client.list_agent_commands(
        user: user,
        request_context: request_context,
        command_names: ['get_query_dsl']
      )

      expect(result).to eq([{
        name: 'get_query_dsl',
        description: 'Return query DSL',
        parameters: { 'type' => 'object' }
      }])
    end

    it 'passes command_names and JWT metadata' do
      allow(grpc_stub).to receive(:list_agent_commands).and_return(response)

      client.list_agent_commands(user: user, request_context: request_context, command_names: ['get_query_dsl'],
        format: :llm)

      expect(grpc_stub).to have_received(:list_agent_commands) do |request, **kwargs|
        expect(request.command_names).to eq(['get_query_dsl'])
        expect(request.format).to eq(:RESPONSE_FORMAT_LLM)
        expect(kwargs[:metadata]['authorization']).to start_with('Bearer ')
      end
    end

    it 'returns formatted text when requested' do
      response = ::Orbit::V1::ListAgentCommandsResponse.new(formatted_text: 'commands[1]:')
      allow(grpc_stub).to receive(:list_agent_commands).and_return(response)

      result = client.list_agent_commands(
        user: user,
        request_context: request_context,
        format: :llm
      )

      expect(result).to eq({ formatted_text: 'commands[1]:' })
    end
  end

  describe '#invoke_agent_command' do
    it 'returns parsed JSON command results' do
      response = ::Orbit::V1::InvokeAgentCommandResponse.new(result_json: '{"ok": true}')
      allow(grpc_stub).to receive(:invoke_agent_command).and_return(response)

      result = client.invoke_agent_command(
        command_name: 'get_response_format',
        parameters: { format: 'raw' },
        user: user,
        request_context: request_context
      )

      expect(result).to eq({ 'ok' => true })
    end

    it 'returns formatted text command results' do
      response = ::Orbit::V1::InvokeAgentCommandResponse.new(formatted_text: 'dsl text')
      allow(grpc_stub).to receive(:invoke_agent_command).and_return(response)

      result = client.invoke_agent_command(
        command_name: 'get_query_dsl',
        parameters: { format: 'llm' },
        user: user,
        request_context: request_context
      )

      expect(result).to eq({ formatted_text: 'dsl text' })
    end

    it 'passes command name, parameters, and JWT metadata' do
      response = ::Orbit::V1::InvokeAgentCommandResponse.new(result_json: '{}')
      allow(grpc_stub).to receive(:invoke_agent_command).and_return(response)

      client.invoke_agent_command(
        command_name: 'get_graph_schema',
        parameters: { expand_nodes: ['Project'] },
        user: user,
        request_context: request_context
      )

      expect(grpc_stub).to have_received(:invoke_agent_command) do |request, **kwargs|
        expect(request.command_name).to eq('get_graph_schema')
        expect(Gitlab::Json.safe_parse(request.parameters_json)).to eq({ 'expand_nodes' => ['Project'] })
        expect(kwargs[:metadata]['authorization']).to start_with('Bearer ')
      end
    end
  end

  describe '#get_cluster_health' do
    it 'returns formatted health status' do
      response = ::Orbit::V1::GetClusterHealthResponse.new(
        structured: ::Orbit::V1::StructuredClusterHealth.new(
          status: :CLUSTER_STATUS_HEALTHY,
          timestamp: '2026-02-22T00:00:00Z',
          version: '0.4.0',
          components: [
            ::Orbit::V1::ComponentHealth.new(
              name: 'clickhouse',
              status: :CLUSTER_STATUS_HEALTHY,
              replicas: ::Orbit::V1::ReplicaStatus.new(ready: 3, desired: 3),
              metrics: { 'queries_per_sec' => '42' }
            )
          ]
        )
      )
      allow(grpc_stub).to receive(:get_cluster_health).and_return(response)

      result = client.get_cluster_health(user: user, request_context: request_context)

      expect(result[:status]).to eq('healthy')
      expect(result[:version]).to eq('0.4.0')
      expect(result[:components].first[:name]).to eq('clickhouse')
      expect(result[:components].first[:replicas]).to eq({ ready: 3, desired: 3 })
    end

    it 'returns formatted_text for llm format' do
      response = ::Orbit::V1::GetClusterHealthResponse.new(
        formatted_text: 'status: healthy'
      )
      allow(grpc_stub).to receive(:get_cluster_health).and_return(response)

      result = client.get_cluster_health(user: user, request_context: request_context, format: :llm)

      expect(result).to eq({ formatted_text: 'status: healthy' })
    end

    it 'returns unknown status when response content is empty' do
      response = ::Orbit::V1::GetClusterHealthResponse.new
      allow(grpc_stub).to receive(:get_cluster_health).and_return(response)

      result = client.get_cluster_health(user: user, request_context: request_context)

      expect(result).to eq({ status: 'unknown' })
    end

    context 'when user is nil' do
      it 'raises ArgumentError' do
        expect { client.get_cluster_health(user: nil, request_context: request_context) }
          .to raise_error(ArgumentError, 'user is required')
      end
    end

    context 'when gRPC fails' do
      it 'returns unknown status with error' do
        allow(grpc_stub).to receive(:get_cluster_health)
          .and_raise(GRPC::Unavailable.new('connection refused'))

        result = client.get_cluster_health(user: user, request_context: request_context)

        expect(result[:status]).to eq('unknown')
        expect(result[:error]).to eq('Service unreachable')
      end
    end
  end

  describe '#get_graph_schema' do
    it 'returns formatted schema' do
      response = ::Orbit::V1::GetGraphSchemaResponse.new(
        structured: ::Orbit::V1::StructuredSchema.new(
          schema_version: '1.0',
          domains: [
            ::Orbit::V1::SchemaDomain.new(
              name: 'DevOps',
              description: 'DevOps domain',
              node_names: %w[Project Pipeline]
            )
          ],
          nodes: [
            ::Orbit::V1::SchemaNode.new(
              name: 'Project',
              domain: 'DevOps',
              description: 'A GitLab project',
              primary_key: 'id',
              label_field: 'name',
              properties: [
                ::Orbit::V1::SchemaProperty.new(
                  name: 'id',
                  data_type: 'Int64',
                  nullable: false
                )
              ],
              style: ::Orbit::V1::SchemaNodeStyle.new(size: 40, color: '#3B82F6')
            )
          ],
          edges: [
            ::Orbit::V1::SchemaEdge.new(
              name: 'BELONGS_TO',
              description: 'Ownership relationship',
              variants: [
                ::Orbit::V1::SchemaEdgeVariant.new(source_type: 'Pipeline', target_type: 'Project')
              ]
            )
          ]
        )
      )
      allow(grpc_stub).to receive(:get_graph_schema).and_return(response)

      result = client.get_graph_schema(user: user, request_context: request_context)

      expect(result[:schema_version]).to eq('1.0')
      expect(result[:domains].first[:name]).to eq('DevOps')
      expect(result[:nodes].first[:name]).to eq('Project')
      expect(result[:nodes].first[:style]).to eq({ size: 40, color: '#3B82F6' })
      expect(result[:edges].first[:variants]).to match_array([{ source_type: 'Pipeline', target_type: 'Project' }])
    end

    it 'returns empty hash when response content is empty' do
      response = ::Orbit::V1::GetGraphSchemaResponse.new
      allow(grpc_stub).to receive(:get_graph_schema).and_return(response)

      expect(client.get_graph_schema(user: user, request_context: request_context)).to eq({})
    end

    it 'returns formatted_text for llm format' do
      response = ::Orbit::V1::GetGraphSchemaResponse.new(
        formatted_text: 'nodes[2]: Project, User'
      )
      allow(grpc_stub).to receive(:get_graph_schema).and_return(response)

      result = client.get_graph_schema(user: user, request_context: request_context, format: :llm)

      expect(result).to eq({ formatted_text: 'nodes[2]: Project, User' })
    end

    context 'when user is nil' do
      it 'raises ArgumentError' do
        expect { client.get_graph_schema(user: nil, request_context: request_context) }
          .to raise_error(ArgumentError, 'user is required')
      end
    end

    context 'when gRPC fails' do
      it 'raises ConnectionError' do
        allow(grpc_stub).to receive(:get_graph_schema)
          .and_raise(GRPC::Unavailable.new('connection refused'))

        expect { client.get_graph_schema(user: user, request_context: request_context) }
          .to raise_error(described_class::ConnectionError, /get_graph_schema failed/)
      end
    end

    context 'when session_id and request_id are provided' do
      let(:response) { ::Orbit::V1::GetGraphSchemaResponse.new }

      before do
        allow(grpc_stub).to receive(:get_graph_schema).and_return(response)
      end

      it 'passes both to JwtAuth for the JWT claims' do
        allow(Analytics::KnowledgeGraph::JwtAuth).to receive(:authorization_header).and_return('Bearer test-token')

        client.get_graph_schema(
          user: user,
          request_context: Analytics::KnowledgeGraph::RequestContext.new(
            source_type: source_type, session_id: 'workflow-abc-123', request_id: 'request-abc-123'
          )
        )

        expect(Analytics::KnowledgeGraph::JwtAuth).to have_received(:authorization_header)
          .with(
            user: user,
            request_context: having_attributes(session_id: 'workflow-abc-123', request_id: 'request-abc-123')
          )
      end
    end
  end

  describe '#get_query_dsl' do
    it 'parses the raw JSON schema and folds in the version' do
      response = ::Orbit::V1::GetQueryDslResponse.new(
        version: '1.2.0',
        raw_json_schema: '{"title":"GraphQueryAsJSON"}'
      )
      allow(grpc_stub).to receive(:get_query_dsl).and_return(response)

      result = client.get_query_dsl(user: user, request_context: request_context)

      expect(result).to eq('title' => 'GraphQueryAsJSON', 'version' => '1.2.0')
    end

    it 'returns the formatted_text string for llm format' do
      response = ::Orbit::V1::GetQueryDslResponse.new(version: '1.2.0', formatted_text: 'QueryDSL v1.2.0:')
      allow(grpc_stub).to receive(:get_query_dsl).and_return(response)

      result = client.get_query_dsl(user: user, request_context: request_context, format: :llm)

      expect(result).to eq('QueryDSL v1.2.0:')
    end

    it 'returns empty hash when response content is empty' do
      allow(grpc_stub).to receive(:get_query_dsl).and_return(::Orbit::V1::GetQueryDslResponse.new)

      expect(client.get_query_dsl(user: user, request_context: request_context)).to eq({})
    end

    context 'when user is nil' do
      it 'raises ArgumentError' do
        expect { client.get_query_dsl(user: nil, request_context: request_context) }
          .to raise_error(ArgumentError, 'user is required')
      end
    end

    context 'when gRPC fails' do
      it 'raises ConnectionError' do
        allow(grpc_stub).to receive(:get_query_dsl).and_raise(GRPC::Unavailable.new('connection refused'))

        expect { client.get_query_dsl(user: user, request_context: request_context) }
          .to raise_error(described_class::ConnectionError, /get_query_dsl failed/)
      end
    end
  end

  describe 'unary query mode' do
    using RSpec::Parameterized::TableSyntax

    where(:method, :arguments, :response_class) do
      :list_tools | {} | ::Orbit::V1::ListToolsResponse
      :list_agent_commands | {} | ::Orbit::V1::ListAgentCommandsResponse
      :invoke_agent_command | { command_name: 'get_schema', parameters: {} } | ::Orbit::V1::InvokeAgentCommandResponse
      :get_query_dsl | {} | ::Orbit::V1::GetQueryDslResponse
      :list_named_queries | {} | ::Orbit::V1::ListNamedQueriesResponse
      :list_skills | {} | ::Orbit::V1::ListSkillsResponse
      :get_skill | { name: 'orbit' } | ::Orbit::V1::GetSkillResponse
    end

    with_them do
      it 'sends the selected language', :aggregate_failures do
        [false, true].each do |gql|
          stub_feature_flags(orbit_gql_queries: gql)
          expect(grpc_stub).to receive(method) do |request, **kwargs|
            expect(request.language).to eq(gql ? :QUERY_LANGUAGE_GQL : :QUERY_LANGUAGE_JSON)
            expect(kwargs[:metadata]).not_to have_key('x-gitlab-orbit-query-language')
            response_class.new
          end

          client.public_send(method, **arguments, user: user)
        end
      end
    end
  end

  describe '#list_skills' do
    let(:response) do
      ::Orbit::V1::ListSkillsResponse.new(
        skills: [
          ::Orbit::V1::SkillSummary.new(
            name: 'orbit',
            version: '0.29.0',
            compatibility: 'Orbit CLI',
            description: 'Use the glab orbit CLI.'
          )
        ],
        server_version: '0.31.0'
      )
    end

    it 'returns the skill catalog' do
      allow(grpc_stub).to receive(:list_skills).and_return(response)

      result = client.list_skills(user: user, request_context: request_context)

      expect(result).to eq(
        'skills' => [{
          'name' => 'orbit',
          'version' => '0.29.0',
          'compatibility' => 'Orbit CLI',
          'description' => 'Use the glab orbit CLI.'
        }],
        'server_version' => '0.31.0'
      )
    end

    it 'uses a typed request with JWT metadata and a deadline', :aggregate_failures do
      allow(grpc_stub).to receive(:list_skills).and_return(response)

      client.list_skills(user: user, request_context: request_context, timeout: 5)

      expect(grpc_stub).to have_received(:list_skills) do |request, **kwargs|
        expect(request).to be_a(::Orbit::V1::ListSkillsRequest)
        expect(kwargs[:metadata]['authorization']).to start_with('Bearer ')
        expect(kwargs[:deadline]).to be_a(Time)
      end
    end

    it 'requires a user' do
      expect { client.list_skills(user: nil, request_context: request_context) }
        .to raise_error(ArgumentError, 'user is required')
    end

    it 'maps gRPC errors to ConnectionError' do
      allow(grpc_stub).to receive(:list_skills).and_raise(GRPC::Unavailable.new('connection refused'))

      expect { client.list_skills(user: user, request_context: request_context) }
        .to raise_error(described_class::ConnectionError, /list_skills failed/)
    end
  end

  describe '#get_skill' do
    let(:response) do
      ::Orbit::V1::GetSkillResponse.new(
        name: 'orbit',
        version: '0.29.0',
        compatibility: 'Orbit CLI',
        server_version: '0.31.0',
        files: [
          ::Orbit::V1::SkillFile.new(path: 'SKILL.md', sha256: 'file-sha', content: "# Orbit skill\n")
        ]
      )
    end

    it 'returns the complete skill tree' do
      allow(grpc_stub).to receive(:get_skill).and_return(response)

      result = client.get_skill(name: 'orbit', user: user, request_context: request_context)

      expect(result).to eq(
        'name' => 'orbit',
        'version' => '0.29.0',
        'compatibility' => 'Orbit CLI',
        'server_version' => '0.31.0',
        'files' => [{
          'path' => 'SKILL.md',
          'sha256' => 'file-sha',
          'content' => "# Orbit skill\n"
        }]
      )
    end

    it 'passes the name and metadata_only flag in a typed request' do
      allow(grpc_stub).to receive(:get_skill).and_return(response)

      client.get_skill(
        name: 'orbit',
        metadata_only: true,
        user: user,
        request_context: request_context
      )

      expect(grpc_stub).to have_received(:get_skill) do |request, **kwargs|
        expect(request).to be_a(::Orbit::V1::GetSkillRequest)
        expect(request.name).to eq('orbit')
        expect(request.metadata_only).to be(true)
        expect(kwargs[:metadata]['authorization']).to start_with('Bearer ')
      end
    end

    it 'requires a user' do
      expect { client.get_skill(name: 'orbit', user: nil, request_context: request_context) }
        .to raise_error(ArgumentError, 'user is required')
    end

    it 'preserves NOT_FOUND details for the API response', :aggregate_failures do
      allow(grpc_stub).to receive(:get_skill)
        .and_raise(GRPC::NotFound.new('Unknown skill "missing". Known skills: ["orbit"]'))

      expect { client.get_skill(name: 'missing', user: user, request_context: request_context) }
        .to raise_error(described_class::ConnectionError, /Known skills: \["orbit"\]/) do |error|
          expect(error.grpc_code).to eq(GRPC::Core::StatusCodes::NOT_FOUND)
          expect(error.grpc_details).to eq('Unknown skill "missing". Known skills: ["orbit"]')
        end
    end
  end

  describe '#list_named_queries' do
    let(:query_def) do
      ::Orbit::V1::NamedQueryDefinition.new(
        name: 'my_neighbors',
        description: 'Immediate graph neighborhood of the current user.',
        raw_query: '{"query_type":"neighbors","limit":100}'
      )
    end

    let(:response) { ::Orbit::V1::ListNamedQueriesResponse.new(queries: [query_def]) }

    it 'returns named queries with the rendered DSL parsed' do
      allow(grpc_stub).to receive(:list_named_queries).and_return(response)

      result = client.list_named_queries(user: user, request_context: request_context)

      expect(result).to eq([{
        name: 'my_neighbors',
        description: 'Immediate graph neighborhood of the current user.',
        raw_query: { 'query_type' => 'neighbors', 'limit' => 100 }
      }])
    end

    context 'when GQL is enabled' do
      let(:query_def) do
        ::Orbit::V1::NamedQueryDefinition.new(
          name: 'my_neighbors',
          description: 'Immediate graph neighborhood of the current user.',
          raw_query: "MATCH (me:User {id: 1})--(neighbor)\nRETURN me, neighbor\nLIMIT 100"
        )
      end

      before do
        stub_feature_flags(orbit_gql_queries: true)
      end

      it 'returns the rendered GQL text unchanged' do
        allow(grpc_stub).to receive(:list_named_queries).and_return(response)

        result = client.list_named_queries(user: user, request_context: request_context)

        expect(result).to eq([{
          name: 'my_neighbors',
          description: 'Immediate graph neighborhood of the current user.',
          raw_query: "MATCH (me:User {id: 1})--(neighbor)\nRETURN me, neighbor\nLIMIT 100"
        }])
      end
    end

    it 'passes JWT metadata' do
      allow(grpc_stub).to receive(:list_named_queries).and_return(response)

      client.list_named_queries(user: user, request_context: request_context)

      expect(grpc_stub).to have_received(:list_named_queries) do |_request, **kwargs|
        expect(kwargs[:metadata]['authorization']).to start_with('Bearer ')
      end
    end

    context 'when user is nil' do
      it 'raises ArgumentError' do
        expect { client.list_named_queries(user: nil, request_context: request_context) }
          .to raise_error(ArgumentError, 'user is required')
      end
    end

    context 'when gRPC fails' do
      it 'raises ConnectionError' do
        allow(grpc_stub).to receive(:list_named_queries).and_raise(GRPC::Unavailable.new('connection refused'))

        expect { client.list_named_queries(user: user, request_context: request_context) }
          .to raise_error(described_class::ConnectionError, /list_named_queries failed/)
      end
    end
  end

  describe '#get_graph_status' do
    let(:traversal_path) { '9970-123-456/' }

    it 'returns structured graph status' do
      response = ::Orbit::V1::GetGraphStatusResponse.new(
        structured: ::Orbit::V1::StructuredGraphStatus.new(
          projects: ::Orbit::V1::ProjectsStatus.new(indexed: 5, total_known: 10, gaps: 2),
          domains: [
            ::Orbit::V1::GraphStatusDomain.new(
              name: 'SDLC',
              items: [::Orbit::V1::GraphStatusItem.new(name: 'MergeRequest', count: 42)]
            )
          ],
          indexing: ::Orbit::V1::IndexingStatus.new(
            state: :INDEXING_STATE_INDEXED,
            last_started_at: '2026-04-15T00:00:00Z',
            last_completed_at: '2026-04-15T01:00:00Z',
            last_duration_ms: 3_600_000
          )
        )
      )
      allow(grpc_stub).to receive(:get_graph_status).and_return(response)

      result = client.get_graph_status(
        user: user, request_context: request_context, traversal_path: traversal_path
      )

      expect(result[:projects]).to eq({ indexed: 5, total_known: 10, gaps: 2 })
      expect(result[:domains].first[:name]).to eq('SDLC')
      expect(result[:domains].first[:items].first[:count]).to eq(42)
      expect(result[:indexing][:state]).to eq('indexed')
    end

    it 'returns formatted_text for llm format' do
      response = ::Orbit::V1::GetGraphStatusResponse.new(
        formatted_text: 'Graph: 5/10 projects indexed'
      )
      allow(grpc_stub).to receive(:get_graph_status).and_return(response)

      result = client.get_graph_status(
        user: user, request_context: request_context, traversal_path: traversal_path, format: :llm
      )

      expect(result).to eq({ formatted_text: 'Graph: 5/10 projects indexed' })
    end

    it 'returns empty hash when response content is empty' do
      response = ::Orbit::V1::GetGraphStatusResponse.new
      allow(grpc_stub).to receive(:get_graph_status).and_return(response)

      result = client.get_graph_status(
        user: user, request_context: request_context, traversal_path: traversal_path
      )

      expect(result).to eq({})
    end

    it 'returns default projects when projects field is nil' do
      response = ::Orbit::V1::GetGraphStatusResponse.new(
        structured: ::Orbit::V1::StructuredGraphStatus.new(
          domains: [],
          indexing: ::Orbit::V1::IndexingStatus.new(state: :INDEXING_STATE_NOT_INDEXED)
        )
      )
      allow(grpc_stub).to receive(:get_graph_status).and_return(response)

      result = client.get_graph_status(
        user: user, request_context: request_context, traversal_path: traversal_path
      )

      expect(result[:projects]).to eq({ indexed: 0, total_known: 0, gaps: 0 })
    end

    it 'returns nil last_duration_ms when indexing duration is zero' do
      response = ::Orbit::V1::GetGraphStatusResponse.new(
        structured: ::Orbit::V1::StructuredGraphStatus.new(
          projects: ::Orbit::V1::ProjectsStatus.new(indexed: 1, total_known: 1),
          domains: [],
          indexing: ::Orbit::V1::IndexingStatus.new(
            state: :INDEXING_STATE_BACKFILLING,
            last_duration_ms: 0
          )
        )
      )
      allow(grpc_stub).to receive(:get_graph_status).and_return(response)

      result = client.get_graph_status(
        user: user, request_context: request_context, traversal_path: traversal_path
      )

      expect(result[:indexing][:state]).to eq('backfilling')
      expect(result[:indexing][:last_duration_ms]).to be_nil
    end

    it 'returns SDLC and code indexing phases' do
      response = ::Orbit::V1::GetGraphStatusResponse.new(
        structured: ::Orbit::V1::StructuredGraphStatus.new(
          sdlc_indexing: ::Orbit::V1::IndexingStatus.new(
            state: :INDEXING_STATE_INDEXED,
            last_completed_at: '2026-04-15T01:00:00Z'
          ),
          code_indexing: ::Orbit::V1::IndexingStatus.new(state: :INDEXING_STATE_BACKFILLING)
        )
      )
      allow(grpc_stub).to receive(:get_graph_status).and_return(response)

      result = client.get_graph_status(
        user: user, request_context: request_context, traversal_path: traversal_path
      )

      expect(result[:sdlc_indexing]).to eq(
        state: 'indexed',
        last_started_at: nil,
        last_completed_at: '2026-04-15T01:00:00Z',
        last_duration_ms: nil,
        last_error: nil
      )
      expect(result[:code_indexing][:state]).to eq('backfilling')
    end

    it 'returns nil SDLC and code indexing phases when they are absent' do
      response = ::Orbit::V1::GetGraphStatusResponse.new(
        structured: ::Orbit::V1::StructuredGraphStatus.new(
          indexing: ::Orbit::V1::IndexingStatus.new(state: :INDEXING_STATE_INDEXED)
        )
      )
      allow(grpc_stub).to receive(:get_graph_status).and_return(response)

      result = client.get_graph_status(
        user: user, request_context: request_context, traversal_path: traversal_path
      )

      expect(result[:sdlc_indexing]).to be_nil
      expect(result[:code_indexing]).to be_nil
    end

    it 'returns item state only when the item has one' do
      response = ::Orbit::V1::GetGraphStatusResponse.new(
        structured: ::Orbit::V1::StructuredGraphStatus.new(
          domains: [
            ::Orbit::V1::GraphStatusDomain.new(
              name: 'Code',
              items: [
                ::Orbit::V1::GraphStatusItem.new(name: 'File', count: 7, state: :INDEXING_STATE_INDEXING),
                ::Orbit::V1::GraphStatusItem.new(name: 'Definition', count: 3)
              ]
            )
          ]
        )
      )
      allow(grpc_stub).to receive(:get_graph_status).and_return(response)

      result = client.get_graph_status(
        user: user, request_context: request_context, traversal_path: traversal_path
      )

      expect(result[:domains].first[:items]).to eq([
        { name: 'File', count: 7, state: 'indexing' },
        { name: 'Definition', count: 3, state: nil }
      ])
    end

    {
      INDEXING_STATE_NOT_INDEXED: 'not_indexed',
      INDEXING_STATE_BACKFILLING: 'backfilling',
      INDEXING_STATE_INDEXED: 'indexed',
      INDEXING_STATE_ERROR: 'error',
      INDEXING_STATE_INDEXING: 'indexing',
      INDEXING_STATE_UNKNOWN: 'unknown'
    }.each do |proto_state, expected_string|
      it "maps #{proto_state} to '#{expected_string}'" do
        response = ::Orbit::V1::GetGraphStatusResponse.new(
          structured: ::Orbit::V1::StructuredGraphStatus.new(
            indexing: ::Orbit::V1::IndexingStatus.new(state: proto_state)
          )
        )
        allow(grpc_stub).to receive(:get_graph_status).and_return(response)

        result = client.get_graph_status(
          user: user, request_context: request_context, traversal_path: traversal_path
        )

        expect(result[:indexing][:state]).to eq(expected_string)
      end
    end

    it 'sets SOURCE_TYPE_PROJECT when target_type is :project' do
      response = ::Orbit::V1::GetGraphStatusResponse.new(
        structured: ::Orbit::V1::StructuredGraphStatus.new(
          projects: ::Orbit::V1::ProjectsStatus.new(indexed: 0, total_known: 0)
        )
      )
      allow(grpc_stub).to receive(:get_graph_status).and_return(response)

      client.get_graph_status(
        user: user, request_context: request_context, traversal_path: traversal_path, target_type: :project
      )

      expect(grpc_stub).to have_received(:get_graph_status) do |request, _kwargs|
        expect(request.source_type).to eq(:SOURCE_TYPE_PROJECT)
        expect(request.format).to eq(:RESPONSE_FORMAT_RAW)
      end
    end

    it 'sets SOURCE_TYPE_GROUP when target_type is :group' do
      response = ::Orbit::V1::GetGraphStatusResponse.new(
        structured: ::Orbit::V1::StructuredGraphStatus.new(
          projects: ::Orbit::V1::ProjectsStatus.new(indexed: 0, total_known: 0)
        )
      )
      allow(grpc_stub).to receive(:get_graph_status).and_return(response)

      client.get_graph_status(
        user: user, request_context: request_context, traversal_path: traversal_path, target_type: :group
      )

      expect(grpc_stub).to have_received(:get_graph_status) do |request, _kwargs|
        expect(request.source_type).to eq(:SOURCE_TYPE_GROUP)
        expect(request.format).to eq(:RESPONSE_FORMAT_RAW)
      end
    end

    context 'when user is nil' do
      it 'raises ArgumentError' do
        expect { client.get_graph_status(user: nil, request_context: request_context, traversal_path: traversal_path) }
          .to raise_error(ArgumentError, 'user is required')
      end
    end

    context 'when gRPC fails' do
      it 'raises ConnectionError' do
        allow(grpc_stub).to receive(:get_graph_status)
          .and_raise(GRPC::Unavailable.new('connection refused'))

        expect { client.get_graph_status(user: user, request_context: request_context, traversal_path: traversal_path) }
          .to raise_error(described_class::ConnectionError, /get_graph_status failed/)
      end
    end
  end

  describe '#get_indexing_status' do
    let(:traversal_paths) { ['9970-123/', '9970-123-456/'] }

    def get_indexing_status
      client.get_indexing_status(user: user, request_context: request_context, traversal_paths: traversal_paths)
    end

    def stub_statuses(*statuses)
      allow(grpc_stub).to receive(:get_indexing_status)
        .and_return(::Orbit::V1::GetIndexingStatusResponse.new(statuses: statuses))
    end

    it 'sends the traversal paths' do
      stub_statuses

      get_indexing_status

      expect(grpc_stub).to have_received(:get_indexing_status) do |request, _kwargs|
        expect(request.traversal_paths).to eq(traversal_paths)
      end
    end

    it 'returns the phase of each namespace and domain, with the project progress on the namespace' do
      stub_statuses(
        ::Orbit::V1::NamespaceIndexingStatus.new(
          traversal_path: '9970-123/',
          phase: :INDEXING_PHASE_ERROR,
          domains: [
            ::Orbit::V1::DomainIndexingStatus.new(name: 'plan', phase: :INDEXING_PHASE_READY),
            ::Orbit::V1::DomainIndexingStatus.new(
              name: 'source_code',
              phase: :INDEXING_PHASE_ERROR,
              projects: ::Orbit::V1::ProjectsStatus.new(indexed: 8, total_known: 10, gaps: 2)
            )
          ]
        )
      )

      expect(get_indexing_status).to eq(
        statuses: [
          {
            traversal_path: '9970-123/',
            phase: 'error',
            projects: { indexed: 8, total_known: 10, gaps: 2 },
            domains: [
              { name: 'plan', phase: 'ready' },
              { name: 'source_code', phase: 'error' }
            ]
          }
        ]
      )
    end

    it 'returns nil project progress when no domain reports it' do
      stub_statuses(
        ::Orbit::V1::NamespaceIndexingStatus.new(
          traversal_path: '9970-123/',
          domains: [::Orbit::V1::DomainIndexingStatus.new(name: 'plan', phase: :INDEXING_PHASE_READY)]
        )
      )

      expect(get_indexing_status[:statuses].first[:projects]).to be_nil
    end

    {
      INDEXING_PHASE_UNKNOWN: 'unknown',
      INDEXING_PHASE_NOT_STARTED: 'not_started',
      INDEXING_PHASE_SYNCING: 'syncing',
      INDEXING_PHASE_READY: 'ready',
      INDEXING_PHASE_ERROR: 'error',
      99 => 'unknown'
    }.each do |proto_phase, expected_phase|
      it "maps #{proto_phase} to '#{expected_phase}'" do
        stub_statuses(::Orbit::V1::NamespaceIndexingStatus.new(traversal_path: '9970-123/', phase: proto_phase))

        expect(get_indexing_status[:statuses].first[:phase]).to eq(expected_phase)
      end
    end

    context 'when user is nil' do
      it 'raises ArgumentError' do
        expect { client.get_indexing_status(user: nil, traversal_paths: traversal_paths) }
          .to raise_error(ArgumentError, 'user is required')
      end
    end

    context 'when gRPC fails' do
      it 'raises ConnectionError' do
        allow(grpc_stub).to receive(:get_indexing_status).and_raise(GRPC::Unimplemented.new('unknown method'))

        expect { get_indexing_status }.to raise_error(described_class::ConnectionError, /get_indexing_status failed/)
      end
    end
  end

  describe '#get_item_counts' do
    let(:traversal_path) { '9970-123/' }

    def get_item_counts
      client.get_item_counts(user: user, request_context: request_context, traversal_path: traversal_path)
    end

    it 'sends the one traversal path' do
      allow(grpc_stub).to receive(:get_item_counts).and_return(::Orbit::V1::GetItemCountsResponse.new)

      get_item_counts

      expect(grpc_stub).to have_received(:get_item_counts) do |request, _kwargs|
        expect(request.traversal_path).to eq(traversal_path)
      end
    end

    it 'returns the counts of each domain' do
      allow(grpc_stub).to receive(:get_item_counts).and_return(
        ::Orbit::V1::GetItemCountsResponse.new(
          domains: [
            ::Orbit::V1::DomainItemCount.new(
              name: 'plan',
              entities: [
                ::Orbit::V1::EntityItemCount.new(name: 'WorkItem', count: 12),
                ::Orbit::V1::EntityItemCount.new(name: 'Milestone', count: 3)
              ]
            )
          ]
        )
      )

      expect(get_item_counts).to eq(
        domains: [
          { name: 'plan', entities: [{ name: 'WorkItem', count: 12 }, { name: 'Milestone', count: 3 }] }
        ]
      )
    end

    context 'when user is nil' do
      it 'raises ArgumentError' do
        expect { client.get_item_counts(user: nil, traversal_path: traversal_path) }
          .to raise_error(ArgumentError, 'user is required')
      end
    end

    context 'when gRPC fails' do
      it 'raises ConnectionError' do
        allow(grpc_stub).to receive(:get_item_counts).and_raise(GRPC::Unavailable.new('connection refused'))

        expect { get_item_counts }.to raise_error(described_class::ConnectionError, /get_item_counts failed/)
      end
    end
  end

  describe 'gRPC metrics instrumentation' do
    it 'records duration on success' do
      allow(grpc_stub).to receive(:list_tools).and_return(
        ::Orbit::V1::ListToolsResponse.new(tools: [])
      )

      expect(Gitlab::Metrics::KnowledgeGraph::Request).to receive(:observe_grpc_duration)
        .with('list_tools', 'ok', a_value > 0)

      client.list_tools(user: user, request_context: request_context)
    end

    it 'records duration with error status when gRPC call raises' do
      allow(grpc_stub).to receive(:list_tools)
        .and_raise(GRPC::Unavailable.new('connection refused'))

      expect(Gitlab::Metrics::KnowledgeGraph::Request).to receive(:observe_grpc_duration)
        .with('list_tools', 'error', a_value >= 0)

      expect { client.list_tools(user: user, request_context: request_context) }
        .to raise_error(described_class::ConnectionError)
    end
  end

  describe 'insecure channel auth protection' do
    let(:endpoint) { '8.8.8.8:50054' }

    it 'omits authorization header on insecure non-private channels' do
      allow(grpc_stub).to receive(:list_tools).and_return(
        ::Orbit::V1::ListToolsResponse.new(tools: [])
      )

      client.list_tools(user: user, request_context: request_context)

      expect(grpc_stub).to have_received(:list_tools) do |_request, **kwargs|
        expect(kwargs[:metadata]).not_to have_key('authorization')
      end
    end
  end

  describe '.client_interceptors' do
    it 'returns empty array when tracing is disabled' do
      allow(Labkit::Tracing).to receive(:enabled?).and_return(false)

      result = described_class.send(:client_interceptors)

      expect(result).to eq([])
    end

    it 'includes tracing interceptor when enabled' do
      allow(Labkit::Tracing).to receive(:enabled?).and_return(true)

      result = described_class.send(:client_interceptors)

      expect(result).to include(Labkit::Tracing::GRPC::ClientInterceptor.instance)
    end
  end

  describe '#safe_json_parse' do
    it 'returns empty hash and logs error when parse returns nil' do
      allow(::Gitlab::Json).to receive(:safe_parse).and_return(nil)

      result = client.send(:safe_json_parse, 'not-valid')

      expect(result).to eq({})
    end

    it 'returns empty hash for blank string' do
      expect(client.send(:safe_json_parse, '')).to eq({})
      expect(client.send(:safe_json_parse, nil)).to eq({})
    end
  end

  describe '#cluster_status_to_string' do
    it 'maps all status values' do
      expect(client.send(:cluster_status_to_string, :CLUSTER_STATUS_HEALTHY)).to eq('healthy')
      expect(client.send(:cluster_status_to_string, :CLUSTER_STATUS_DEGRADED)).to eq('degraded')
      expect(client.send(:cluster_status_to_string, :CLUSTER_STATUS_UNHEALTHY)).to eq('unhealthy')
      expect(client.send(:cluster_status_to_string, :CLUSTER_STATUS_MIGRATING)).to eq('migrating')
      expect(client.send(:cluster_status_to_string, :UNKNOWN_STATUS)).to eq('unknown')
    end
  end

  describe '#component_to_hash' do
    it 'defaults replicas to 0 when nil' do
      component = ::Orbit::V1::ComponentHealth.new(
        name: 'test', status: :CLUSTER_STATUS_HEALTHY, metrics: {}
      )

      result = client.send(:component_to_hash, component)

      expect(result[:replicas]).to eq({ ready: 0, desired: 0 })
    end
  end

  describe '#schema_node_to_hash' do
    it 'omits properties, style, and edges when properties are empty' do
      node = ::Orbit::V1::SchemaNode.new(
        name: 'Test', domain: 'core', description: 'test',
        primary_key: 'id', label_field: 'name', properties: []
      )

      result = client.send(:schema_node_to_hash, node)

      expect(result).not_to have_key(:properties)
      expect(result).not_to have_key(:style)
      expect(result).not_to have_key(:outgoing_edges)
      expect(result).not_to have_key(:incoming_edges)
    end

    it 'includes properties, style, and edges when properties are present' do
      node = ::Orbit::V1::SchemaNode.new(
        name: 'Test', domain: 'core', description: 'test',
        primary_key: 'id', label_field: 'name',
        properties: [::Orbit::V1::SchemaProperty.new(name: 'id', data_type: 'Int64', nullable: false)],
        style: ::Orbit::V1::SchemaNodeStyle.new(size: 40, color: '#3B82F6'),
        outgoing_edges: ['HAS'],
        incoming_edges: ['BELONGS_TO']
      )

      result = client.send(:schema_node_to_hash, node)

      expect(result[:properties]).to eq([{ name: 'id', data_type: 'Int64', nullable: false, enum_values: [] }])
      expect(result[:style]).to eq({ size: 40, color: '#3B82F6' })
      expect(result[:outgoing_edges]).to eq(['HAS'])
      expect(result[:incoming_edges]).to eq(['BELONGS_TO'])
    end

    it 'uses default style when style is nil but properties exist' do
      node = ::Orbit::V1::SchemaNode.new(
        name: 'Test', domain: 'core', description: 'test',
        primary_key: 'id', label_field: 'name',
        properties: [::Orbit::V1::SchemaProperty.new(name: 'id', data_type: 'Int64', nullable: false)]
      )

      result = client.send(:schema_node_to_hash, node)

      expect(result[:style]).to eq({ size: 30, color: '#64748B' })
    end
  end

  describe 'metadata without correlation ID' do
    it 'omits correlation ID when not present' do
      allow(grpc_stub).to receive(:list_tools).and_return(
        ::Orbit::V1::ListToolsResponse.new(tools: [])
      )
      allow(Labkit::Correlation::CorrelationId).to receive(:current_id).and_return(nil)

      client.list_tools(user: user, request_context: request_context)

      expect(grpc_stub).to have_received(:list_tools) do |_request, **kwargs|
        expect(kwargs[:metadata]).not_to have_key('x-gitlab-correlation-id')
      end
    end
  end

  describe 'user agent metadata' do
    it 'includes x-client-user-agent when user_agent is provided' do
      allow(grpc_stub).to receive(:list_tools).and_return(
        ::Orbit::V1::ListToolsResponse.new(tools: [])
      )

      client.list_tools(
        user: user,
        request_context: Analytics::KnowledgeGraph::RequestContext.new(
          source_type: source_type, user_agent: 'TestAgent/1.0'
        )
      )

      expect(grpc_stub).to have_received(:list_tools) do |_request, **kwargs|
        expect(kwargs[:metadata]['x-client-user-agent']).to eq('TestAgent/1.0')
      end
    end

    it 'omits x-client-user-agent when user_agent is nil' do
      allow(grpc_stub).to receive(:list_tools).and_return(
        ::Orbit::V1::ListToolsResponse.new(tools: [])
      )

      client.list_tools(user: user, request_context: request_context)

      expect(grpc_stub).to have_received(:list_tools) do |_request, **kwargs|
        expect(kwargs[:metadata]).not_to have_key('x-client-user-agent')
      end
    end
  end

  describe 'verbose logging headers' do
    let(:verbose_ai_logs) { false }

    before do
      allow(grpc_stub).to receive(:list_tools).and_return(
        ::Orbit::V1::ListToolsResponse.new(tools: [])
      )
      stub_application_setting(enabled_instance_verbose_ai_logs: verbose_ai_logs)
    end

    def list_tools_metadata
      client.list_tools(user: user, request_context: request_context)

      captured = nil
      expect(grpc_stub).to have_received(:list_tools) do |_request, **kwargs|
        captured = kwargs[:metadata]
      end
      captured
    end

    context 'for x-gitlab-enabled-feature-flags (SaaS path)' do
      context 'on GitLab.com (SaaS)', :saas do
        context 'when gkg_verbose_logs flag is enabled' do
          it 'includes verbose_gkg_logs in the x-gitlab-enabled-feature-flags header' do
            metadata = list_tools_metadata

            flags = metadata['x-gitlab-enabled-feature-flags'].to_s.split(',')
            expect(flags).to include('verbose_gkg_logs')
          end
        end

        context 'when gkg_verbose_logs flag is disabled' do
          before do
            stub_feature_flags(gkg_verbose_logs: false)
          end

          it 'does not include verbose_gkg_logs in the feature-flags header' do
            metadata = list_tools_metadata

            flags = metadata.fetch('x-gitlab-enabled-feature-flags', '').to_s.split(',')
            expect(flags).not_to include('verbose_gkg_logs')
          end

          it 'omits the feature-flags header entirely when no flags are enabled' do
            metadata = list_tools_metadata

            expect(metadata).not_to have_key('x-gitlab-enabled-feature-flags')
          end
        end
      end

      context 'on self-managed (not SaaS)' do
        before do
          allow(::Gitlab::Saas).to receive(:feature_available?).with(:gitlab_com_subscriptions).and_return(false)
        end

        it 'does not send the x-gitlab-enabled-feature-flags header even when the flag is on' do
          metadata = list_tools_metadata

          expect(metadata).not_to have_key('x-gitlab-enabled-feature-flags')
        end
      end
    end

    context 'for x-gitlab-enabled-instance-verbose-ai-logs (self-hosted path)' do
      context 'when the instance setting is true' do
        let(:verbose_ai_logs) { true }

        it 'sends a truthy x-gitlab-enabled-instance-verbose-ai-logs header' do
          metadata = list_tools_metadata

          expect(metadata['x-gitlab-enabled-instance-verbose-ai-logs']).to eq('true')
        end
      end

      context 'when the instance setting is false' do
        let(:verbose_ai_logs) { false }

        it 'sends "false" as the header value (mirroring Gitlab::AiGateway)' do
          metadata = list_tools_metadata

          expect(metadata['x-gitlab-enabled-instance-verbose-ai-logs']).to eq('false')
        end
      end

      context 'when the instance setting is not set' do
        let(:verbose_ai_logs) { nil }

        it 'omits the x-gitlab-enabled-instance-verbose-ai-logs header' do
          metadata = list_tools_metadata

          expect(metadata).not_to have_key('x-gitlab-enabled-instance-verbose-ai-logs')
        end
      end
    end

    context 'when the gkg_verbose_logs flag is appended alongside other future flags' do
      # Guard against accidental clobber if/when another flag is added to the list.
      # Mirrors `Gitlab::AiGateway.enabled_feature_flags` append semantics.
      it 'preserves pre-existing flag names in the list' do
        allow(::Gitlab::Saas).to receive(:feature_available?).with(:gitlab_com_subscriptions).and_return(true)

        # Simulate an extension that adds a second flag by stubbing the class-level builder.
        original_method = described_class.method(:outgoing_headers)
        allow(described_class).to receive(:outgoing_headers) do
          headers = original_method.call
          existing_flags = headers['x-gitlab-enabled-feature-flags'].to_s
          combined = [existing_flags, 'some_other_future_flag'].reject(&:empty?).join(',')
          headers.merge('x-gitlab-enabled-feature-flags' => combined)
        end

        metadata = list_tools_metadata

        flags = metadata['x-gitlab-enabled-feature-flags'].to_s.split(',')
        expect(flags).to contain_exactly('verbose_gkg_logs', 'some_other_future_flag')
      end
    end
  end
end
