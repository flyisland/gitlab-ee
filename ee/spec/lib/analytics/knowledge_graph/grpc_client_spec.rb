# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Analytics::KnowledgeGraph::GrpcClient, feature_category: :knowledge_graph do
  let_it_be(:user) { create(:user) }
  let_it_be(:group) { create(:group) }

  let(:endpoint) { 'localhost:50054' }
  let(:grpc_stub) { instance_double(Gkg::V1::KnowledgeGraphService::Stub) }
  let(:source_type) { Analytics::KnowledgeGraph::SourceType::REST }

  subject(:client) { described_class.new(endpoint: endpoint) }

  before_all do
    group.add_reporter(user)
  end

  before do
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
      allow(Gkg::V1::KnowledgeGraphService::Stub).to receive(:new).and_return(grpc_stub)

      stub_a = described_class.stub(endpoint)
      stub_b = described_class.stub(endpoint)

      expect(stub_a).to equal(stub_b)
      expect(Gkg::V1::KnowledgeGraphService::Stub).to have_received(:new).once
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
      allow(Gkg::V1::KnowledgeGraphService::Stub).to receive(:new).and_return(grpc_stub)

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

  describe '.configured_endpoint' do
    it 'logs a warning when falling back to default' do
      allow(Gitlab.config).to receive(:knowledge_graph).and_raise(GitlabSettings::MissingSetting, 'knowledge_graph')

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

  describe '#list_tools' do
    let(:tool_def) do
      Gkg::V1::ToolDefinition.new(
        name: 'search',
        description: 'Search the knowledge graph',
        parameters_json_schema: '{"type": "object"}'
      )
    end

    let(:response) { Gkg::V1::ListToolsResponse.new(tools: [tool_def]) }

    it 'returns formatted tool definitions' do
      allow(grpc_stub).to receive(:list_tools).and_return(response)

      result = client.list_tools(user: user, source_type: source_type)

      expect(result).to eq([{
        name: 'search',
        description: 'Search the knowledge graph',
        parameters: { 'type' => 'object' }
      }])
    end

    it 'passes JWT authorization metadata' do
      allow(grpc_stub).to receive(:list_tools).and_return(response)

      client.list_tools(user: user, source_type: source_type)

      expect(grpc_stub).to have_received(:list_tools) do |_request, **kwargs|
        expect(kwargs[:metadata]['authorization']).to start_with('Bearer ')
        expect(kwargs[:metadata]['client_name']).to eq('gitlab-web')
      end
    end

    it 'passes source_type to JWT auth header generation' do
      allow(grpc_stub).to receive(:list_tools).and_return(response)

      client.list_tools(user: user, source_type: Analytics::KnowledgeGraph::SourceType::MCP)

      expect(Analytics::KnowledgeGraph::JwtAuth).to have_received(:authorization_header)
        .with(user: user, source_type: Analytics::KnowledgeGraph::SourceType::MCP)
    end

    it 'uses sidekiq client name when running in sidekiq' do
      allow(Gitlab::Runtime).to receive(:sidekiq?).and_return(true)
      allow(grpc_stub).to receive(:list_tools).and_return(response)

      client.list_tools(user: user, source_type: source_type)

      expect(grpc_stub).to have_received(:list_tools) do |_request, **kwargs|
        expect(kwargs[:metadata]['client_name']).to eq('gitlab-sidekiq')
      end
    end

    it 'propagates correlation ID in metadata' do
      allow(grpc_stub).to receive(:list_tools).and_return(response)

      Labkit::Correlation::CorrelationId.use_id('test-correlation-id') do
        client.list_tools(user: user, source_type: source_type)
      end

      expect(grpc_stub).to have_received(:list_tools) do |_request, **kwargs|
        expect(kwargs[:metadata]['x-gitlab-correlation-id']).to eq('test-correlation-id')
      end
    end

    it 'sets a deadline on the request' do
      allow(grpc_stub).to receive(:list_tools).and_return(response)

      client.list_tools(user: user, source_type: source_type, timeout: 5)

      expect(grpc_stub).to have_received(:list_tools) do |_request, **kwargs|
        expect(kwargs[:deadline]).to be_a(Time)
      end
    end

    context 'when user is nil' do
      it 'raises ArgumentError' do
        expect { client.list_tools(user: nil, source_type: source_type) }
          .to raise_error(ArgumentError, 'user is required')
      end
    end

    context 'when authorization header is nil' do
      it 'raises AuthorizationError' do
        allow(Analytics::KnowledgeGraph::JwtAuth).to receive(:authorization_header).and_return(nil)

        expect { client.list_tools(user: user, source_type: source_type) }
          .to raise_error(described_class::AuthorizationError, 'Failed to generate authorization header')
      end
    end

    context 'when gRPC returns an error' do
      it 'raises ConnectionError' do
        allow(grpc_stub).to receive(:list_tools)
          .and_raise(GRPC::Unavailable.new('connection refused'))

        expect { client.list_tools(user: user, source_type: source_type) }
          .to raise_error(described_class::ConnectionError, /list_tools failed/)
      end
    end
  end

  describe '#execute_query' do
    let(:result_json) { '{"rows": []}' }
    let(:query_metadata) do
      Gkg::V1::QueryMetadata.new(
        query_type: 'cypher',
        raw_query_strings: ['MATCH (n) RETURN n'],
        row_count: 5
      )
    end

    it 'returns raw result_json string with metadata for raw format' do
      result_msg = Gkg::V1::ExecuteQueryMessage.new(
        result: Gkg::V1::ExecuteQueryResult.new(
          result_json: result_json,
          metadata: query_metadata
        )
      )
      allow(grpc_stub).to receive(:execute_query).and_return([result_msg])

      result = client.execute_query(query: { query: 'test' }, user: user, source_type: source_type)

      expect(result).to eq({
        result: '{"rows": []}',
        query_type: 'cypher',
        raw_query_strings: ['MATCH (n) RETURN n'],
        row_count: 5
      })
    end

    it 'returns nil content when result has no content oneof set' do
      result_msg = Gkg::V1::ExecuteQueryMessage.new(
        result: Gkg::V1::ExecuteQueryResult.new(
          metadata: query_metadata
        )
      )
      allow(grpc_stub).to receive(:execute_query).and_return([result_msg])

      result = client.execute_query(query: { query: 'test' }, user: user, source_type: source_type)

      expect(result[:result]).to be_nil
      expect(result[:query_type]).to eq('cypher')
    end

    it 'handles result with nil metadata' do
      result_msg = Gkg::V1::ExecuteQueryMessage.new(
        result: Gkg::V1::ExecuteQueryResult.new(
          result_json: '{"data": true}'
        )
      )
      allow(grpc_stub).to receive(:execute_query).and_return([result_msg])

      result = client.execute_query(query: '{"query": "test"}', user: user, source_type: source_type)

      expect(result).to eq({
        result: '{"data": true}',
        query_type: nil,
        raw_query_strings: nil,
        row_count: 0
      })
    end

    it 'returns formatted_text with metadata for llm format' do
      result_msg = Gkg::V1::ExecuteQueryMessage.new(
        result: Gkg::V1::ExecuteQueryResult.new(
          formatted_text: 'Here are the results...',
          metadata: query_metadata
        )
      )
      allow(grpc_stub).to receive(:execute_query).and_return([result_msg])

      result = client.execute_query(query: '{"query": "test"}', user: user, source_type: source_type, format: :llm)

      expect(result).to eq({
        result: 'Here are the results...',
        query_type: 'cypher',
        raw_query_strings: ['MATCH (n) RETURN n'],
        row_count: 5
      })
    end

    it 'handles redaction exchange' do
      redaction_msg = Gkg::V1::ExecuteQueryMessage.new(
        redaction: Gkg::V1::RedactionExchange.new(
          required: Gkg::V1::RedactionRequired.new(
            result_id: 'r1',
            resources: [
              Gkg::V1::ResourceToAuthorize.new(
                resource_type: 'Issue',
                resource_ids: [10],
                abilities: ['read_issue']
              )
            ]
          )
        )
      )
      result_msg = Gkg::V1::ExecuteQueryMessage.new(
        result: Gkg::V1::ExecuteQueryResult.new(
          result_json: result_json,
          metadata: query_metadata
        )
      )

      redaction_service = instance_double(Authz::RedactionService)
      allow(Authz::RedactionService).to receive(:new).and_return(redaction_service)
      allow(redaction_service).to receive(:execute).and_return('Issue' => { 10 => true })

      allow(grpc_stub).to receive(:execute_query).and_return([redaction_msg, result_msg])

      result = client.execute_query(query: { query: 'test' }, user: user, source_type: source_type)

      expect(result).to include(result: '{"rows": []}')
    end

    it 'injects metrics_observer into RedactionService' do
      redaction_msg = Gkg::V1::ExecuteQueryMessage.new(
        redaction: Gkg::V1::RedactionExchange.new(
          required: Gkg::V1::RedactionRequired.new(
            result_id: 'r1',
            resources: [
              Gkg::V1::ResourceToAuthorize.new(
                resource_type: 'Issue',
                resource_ids: [10],
                abilities: ['read_issue']
              )
            ]
          )
        )
      )
      result_msg = Gkg::V1::ExecuteQueryMessage.new(
        result: Gkg::V1::ExecuteQueryResult.new(
          result_json: result_json,
          metadata: query_metadata
        )
      )

      redaction_service = instance_double(Authz::RedactionService)
      allow(redaction_service).to receive(:execute).and_return('Issue' => { 10 => true })
      allow(grpc_stub).to receive(:execute_query).and_return([redaction_msg, result_msg])

      expect(Authz::RedactionService).to receive(:new).with(
        hash_including(metrics_observer: an_instance_of(Proc))
      ).and_return(redaction_service)

      client.execute_query(query: { query: 'test' }, user: user, source_type: source_type)
    end

    context 'when user is nil' do
      it 'raises ArgumentError' do
        expect { client.execute_query(query: {}, user: nil, source_type: source_type) }
          .to raise_error(ArgumentError, 'user is required')
      end
    end

    context 'when stream contains unknown message type' do
      it 'skips unknown messages and returns result' do
        unknown_msg = Gkg::V1::ExecuteQueryMessage.new
        result_msg = Gkg::V1::ExecuteQueryMessage.new(
          result: Gkg::V1::ExecuteQueryResult.new(
            result_json: result_json,
            metadata: query_metadata
          )
        )
        allow(grpc_stub).to receive(:execute_query).and_return([unknown_msg, result_msg])

        result = client.execute_query(query: { query: 'test' }, user: user, source_type: source_type)

        expect(result).to include(result: '{"rows": []}')
      end
    end

    context 'when server sends an error message' do
      it 'raises ExecutionError' do
        error_msg = Gkg::V1::ExecuteQueryMessage.new(
          error: Gkg::V1::ExecuteQueryError.new(code: 'QUERY_FAILED', message: 'Invalid syntax')
        )
        allow(grpc_stub).to receive(:execute_query).and_return([error_msg])

        expect do
          client.execute_query(query: { query: 'bad' }, user: user, source_type: source_type)
        end.to raise_error(described_class::ExecutionError, 'QUERY_FAILED: Invalid syntax')
      end
    end

    context 'when stream ends without result' do
      it 'raises StreamError' do
        allow(grpc_stub).to receive(:execute_query).and_return([])

        expect do
          client.execute_query(query: { query: 'test' }, user: user, source_type: source_type)
        end.to raise_error(described_class::StreamError)
      end
    end

    context 'when gRPC connection fails' do
      it 'raises ConnectionError' do
        allow(grpc_stub).to receive(:execute_query)
          .and_raise(GRPC::Unavailable.new('connection refused'))

        expect do
          client.execute_query(query: { query: 'test' }, user: user, source_type: source_type)
        end.to raise_error(described_class::ConnectionError, /execute_query failed/)
      end
    end
  end

  describe '#get_cluster_health' do
    it 'returns formatted health status' do
      response = Gkg::V1::GetClusterHealthResponse.new(
        structured: Gkg::V1::StructuredClusterHealth.new(
          status: :CLUSTER_STATUS_HEALTHY,
          timestamp: '2026-02-22T00:00:00Z',
          version: '0.4.0',
          components: [
            Gkg::V1::ComponentHealth.new(
              name: 'clickhouse',
              status: :CLUSTER_STATUS_HEALTHY,
              replicas: Gkg::V1::ReplicaStatus.new(ready: 3, desired: 3),
              metrics: { 'queries_per_sec' => '42' }
            )
          ]
        )
      )
      allow(grpc_stub).to receive(:get_cluster_health).and_return(response)

      result = client.get_cluster_health(user: user, source_type: source_type)

      expect(result[:status]).to eq('healthy')
      expect(result[:version]).to eq('0.4.0')
      expect(result[:components].first[:name]).to eq('clickhouse')
      expect(result[:components].first[:replicas]).to eq({ ready: 3, desired: 3 })
    end

    it 'returns formatted_text for llm format' do
      response = Gkg::V1::GetClusterHealthResponse.new(
        formatted_text: 'status: healthy'
      )
      allow(grpc_stub).to receive(:get_cluster_health).and_return(response)

      result = client.get_cluster_health(user: user, source_type: source_type, format: :llm)

      expect(result).to eq({ formatted_text: 'status: healthy' })
    end

    it 'returns unknown status when response content is empty' do
      response = Gkg::V1::GetClusterHealthResponse.new
      allow(grpc_stub).to receive(:get_cluster_health).and_return(response)

      result = client.get_cluster_health(user: user, source_type: source_type)

      expect(result).to eq({ status: 'unknown' })
    end

    context 'when user is nil' do
      it 'raises ArgumentError' do
        expect { client.get_cluster_health(user: nil, source_type: source_type) }
          .to raise_error(ArgumentError, 'user is required')
      end
    end

    context 'when gRPC fails' do
      it 'returns unknown status with error' do
        allow(grpc_stub).to receive(:get_cluster_health)
          .and_raise(GRPC::Unavailable.new('connection refused'))

        result = client.get_cluster_health(user: user, source_type: source_type)

        expect(result[:status]).to eq('unknown')
        expect(result[:error]).to eq('Service unreachable')
      end
    end
  end

  describe '#get_graph_schema' do
    it 'returns formatted schema' do
      response = Gkg::V1::GetGraphSchemaResponse.new(
        structured: Gkg::V1::StructuredSchema.new(
          schema_version: '1.0',
          domains: [
            Gkg::V1::SchemaDomain.new(
              name: 'DevOps',
              description: 'DevOps domain',
              node_names: %w[Project Pipeline]
            )
          ],
          nodes: [
            Gkg::V1::SchemaNode.new(
              name: 'Project',
              domain: 'DevOps',
              description: 'A GitLab project',
              primary_key: 'id',
              label_field: 'name',
              properties: [
                Gkg::V1::SchemaProperty.new(
                  name: 'id',
                  data_type: 'Int64',
                  nullable: false
                )
              ],
              style: Gkg::V1::SchemaNodeStyle.new(size: 40, color: '#3B82F6')
            )
          ],
          edges: [
            Gkg::V1::SchemaEdge.new(
              name: 'BELONGS_TO',
              description: 'Ownership relationship',
              variants: [
                Gkg::V1::SchemaEdgeVariant.new(source_type: 'Pipeline', target_type: 'Project')
              ]
            )
          ]
        )
      )
      allow(grpc_stub).to receive(:get_graph_schema).and_return(response)

      result = client.get_graph_schema(user: user, source_type: source_type)

      expect(result[:schema_version]).to eq('1.0')
      expect(result[:domains].first[:name]).to eq('DevOps')
      expect(result[:nodes].first[:name]).to eq('Project')
      expect(result[:nodes].first[:style]).to eq({ size: 40, color: '#3B82F6' })
      expect(result[:edges].first[:variants]).to match_array([{ source_type: 'Pipeline', target_type: 'Project' }])
    end

    it 'returns empty hash when response content is empty' do
      response = Gkg::V1::GetGraphSchemaResponse.new
      allow(grpc_stub).to receive(:get_graph_schema).and_return(response)

      expect(client.get_graph_schema(user: user, source_type: source_type)).to eq({})
    end

    it 'returns formatted_text for llm format' do
      response = Gkg::V1::GetGraphSchemaResponse.new(
        formatted_text: 'nodes[2]: Project, User'
      )
      allow(grpc_stub).to receive(:get_graph_schema).and_return(response)

      result = client.get_graph_schema(user: user, source_type: source_type, format: :llm)

      expect(result).to eq({ formatted_text: 'nodes[2]: Project, User' })
    end

    context 'when user is nil' do
      it 'raises ArgumentError' do
        expect { client.get_graph_schema(user: nil, source_type: source_type) }
          .to raise_error(ArgumentError, 'user is required')
      end
    end

    context 'when gRPC fails' do
      it 'raises ConnectionError' do
        allow(grpc_stub).to receive(:get_graph_schema)
          .and_raise(GRPC::Unavailable.new('connection refused'))

        expect { client.get_graph_schema(user: user, source_type: source_type) }
          .to raise_error(described_class::ConnectionError, /get_graph_schema failed/)
      end
    end
  end

  describe 'gRPC metrics instrumentation' do
    it 'records duration on success' do
      allow(grpc_stub).to receive(:list_tools).and_return(
        Gkg::V1::ListToolsResponse.new(tools: [])
      )

      expect(Gitlab::Metrics::KnowledgeGraph::Request).to receive(:observe_grpc_duration)
        .with('list_tools', 'ok', a_value > 0)

      client.list_tools(user: user, source_type: source_type)
    end

    it 'records duration with error status when gRPC call raises' do
      allow(grpc_stub).to receive(:list_tools)
        .and_raise(GRPC::Unavailable.new('connection refused'))

      expect(Gitlab::Metrics::KnowledgeGraph::Request).to receive(:observe_grpc_duration)
        .with('list_tools', 'error', a_value >= 0)

      expect { client.list_tools(user: user, source_type: source_type) }
        .to raise_error(described_class::ConnectionError)
    end
  end

  describe '#redaction_metrics_observer' do
    it 'observes duration, batch size, and filtered count' do
      observer = client.send(:redaction_metrics_observer)

      expect(Gitlab::Metrics::KnowledgeGraph::Request).to receive(:observe_redaction_duration).with(0.5)
      expect(Gitlab::Metrics::KnowledgeGraph::Request).to receive(:observe_redaction_batch_size).with(10)
      expect(Gitlab::Metrics::KnowledgeGraph::Request).to receive(:observe_redaction_filtered).with(3)

      observer.call(total: 10, filtered: 3, duration: 0.5)
    end

    it 'skips batch_size and filtered when zero' do
      observer = client.send(:redaction_metrics_observer)

      expect(Gitlab::Metrics::KnowledgeGraph::Request).to receive(:observe_redaction_duration).with(0.1)
      expect(Gitlab::Metrics::KnowledgeGraph::Request).not_to receive(:observe_redaction_batch_size)
      expect(Gitlab::Metrics::KnowledgeGraph::Request).not_to receive(:observe_redaction_filtered)

      observer.call(total: 0, filtered: 0, duration: 0.1)
    end
  end

  describe 'insecure channel auth protection' do
    let(:endpoint) { '8.8.8.8:50054' }

    it 'omits authorization header on insecure non-private channels' do
      allow(grpc_stub).to receive(:list_tools).and_return(
        Gkg::V1::ListToolsResponse.new(tools: [])
      )

      client.list_tools(user: user, source_type: source_type)

      expect(grpc_stub).to have_received(:list_tools) do |_request, **kwargs|
        expect(kwargs[:metadata]).not_to have_key('authorization')
      end
    end
  end

  describe '#build_request_enumerator' do
    it 'yields messages from queue and stops on :done' do
      queue = Queue.new
      queue.push('msg1')
      queue.push('msg2')
      queue.push(:done)

      enumerator = client.send(:build_request_enumerator, queue)
      results = enumerator.to_a

      expect(results).to eq(%w[msg1 msg2])
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

  describe '#build_resources_by_type' do
    it 'merges IDs when duplicate resource_type appears' do
      resources = [
        Gkg::V1::ResourceToAuthorize.new(resource_type: 'Project', resource_ids: [1, 2], abilities: ['read_project']),
        Gkg::V1::ResourceToAuthorize.new(resource_type: 'Project', resource_ids: [3], abilities: ['read_project'])
      ]

      result = client.send(:build_resources_by_type, resources)

      expect(result['Project']['ids']).to match_array([1, 2, 3])
      expect(result['Project']['ability']).to eq('read_project')
    end

    it 'skips resources with blank abilities' do
      resources = [
        Gkg::V1::ResourceToAuthorize.new(resource_type: 'Project', resource_ids: [1], abilities: [])
      ]

      result = client.send(:build_resources_by_type, resources)

      expect(result).to be_empty
    end
  end

  describe '#authorize_resources' do
    it 'returns empty hash when resources_by_type is empty' do
      result = client.send(:authorize_resources, user, [])

      expect(result).to eq({})
    end

    it 'returns empty hash and logs when RedactionService raises' do
      resources = [
        Gkg::V1::ResourceToAuthorize.new(
          resource_type: 'Project',
          resource_ids: [1],
          abilities: ['read_project']
        )
      ]
      allow(Authz::RedactionService).to receive(:new).and_raise(StandardError, 'boom')

      result = client.send(:authorize_resources, user, resources)

      expect(result).to eq({})
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
      expect(client.send(:cluster_status_to_string, :UNKNOWN_STATUS)).to eq('unknown')
    end
  end

  describe '#component_to_hash' do
    it 'defaults replicas to 0 when nil' do
      component = Gkg::V1::ComponentHealth.new(
        name: 'test', status: :CLUSTER_STATUS_HEALTHY, metrics: {}
      )

      result = client.send(:component_to_hash, component)

      expect(result[:replicas]).to eq({ ready: 0, desired: 0 })
    end
  end

  describe '#schema_node_to_hash' do
    it 'omits properties, style, and edges when properties are empty' do
      node = Gkg::V1::SchemaNode.new(
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
      node = Gkg::V1::SchemaNode.new(
        name: 'Test', domain: 'core', description: 'test',
        primary_key: 'id', label_field: 'name',
        properties: [Gkg::V1::SchemaProperty.new(name: 'id', data_type: 'Int64', nullable: false)],
        style: Gkg::V1::SchemaNodeStyle.new(size: 40, color: '#3B82F6'),
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
      node = Gkg::V1::SchemaNode.new(
        name: 'Test', domain: 'core', description: 'test',
        primary_key: 'id', label_field: 'name',
        properties: [Gkg::V1::SchemaProperty.new(name: 'id', data_type: 'Int64', nullable: false)]
      )

      result = client.send(:schema_node_to_hash, node)

      expect(result[:style]).to eq({ size: 30, color: '#64748B' })
    end
  end

  describe 'metadata without correlation ID' do
    it 'omits correlation ID when not present' do
      allow(grpc_stub).to receive(:list_tools).and_return(
        Gkg::V1::ListToolsResponse.new(tools: [])
      )
      allow(Labkit::Correlation::CorrelationId).to receive(:current_id).and_return(nil)

      client.list_tools(user: user, source_type: source_type)

      expect(grpc_stub).to have_received(:list_tools) do |_request, **kwargs|
        expect(kwargs[:metadata]).not_to have_key('x-gitlab-correlation-id')
      end
    end
  end
end
