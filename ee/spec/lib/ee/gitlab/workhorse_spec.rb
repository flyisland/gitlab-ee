# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Gitlab::Workhorse, feature_category: :knowledge_graph do
  def decode_workhorse_header(array)
    key, value = array
    command, encoded_params = value.split(":")
    params = ::Gitlab::Json.safe_parse(Base64.urlsafe_decode64(encoded_params))

    [key, command, params]
  end

  describe '.send_orbit_query' do
    let(:user) { create(:user) }
    let(:query) { '{"nodes":["MergeRequest"]}' }
    let(:format) { :raw }
    let(:endpoint) { 'localhost:50054' }
    let(:jwt_token) { 'test-jwt-token' }
    let(:source_type) { 'rest' }
    let(:validated_source_type) { source_type }

    subject(:response) do
      described_class.send_orbit_query(query: query, user: user, format: format, source_type: source_type)
    end

    before do
      allow(Analytics::KnowledgeGraph::GrpcClient).to receive(:configured_endpoint).and_return(endpoint)
      allow(Analytics::KnowledgeGraph::JwtAuth).to receive(:generate_token)
        .with(user: user, source_type: validated_source_type).and_return(jwt_token)
      allow(Analytics::KnowledgeGraph::GrpcClient).to receive(:secure_channel?).with(endpoint).and_return(false)
      allow(Analytics::KnowledgeGraph::GrpcClient).to receive(:private_address?).with(endpoint).and_return(true)
    end

    it 'sets the header correctly' do
      key, command, params = decode_workhorse_header(response)

      expect(key).to eq('Gitlab-Workhorse-Send-Data')
      expect(command).to eq('orbit-query')
      expect(params).to eq({
        'GkgServer' => {
          'address' => endpoint,
          'jwt' => jwt_token,
          'tls' => false
        },
        'Query' => query,
        'Format' => format.to_s,
        'TimeoutSeconds' => 30
      })
    end

    context 'when mcp_id is provided' do
      subject(:response) do
        described_class.send_orbit_query(query: query, user: user, format: format, mcp_id: 'mcp-123',
          source_type: source_type)
      end

      it 'includes McpId in the params' do
        _, _, params = decode_workhorse_header(response)

        expect(params).to include('McpId' => 'mcp-123')
      end
    end

    context 'when mcp_id is nil' do
      it 'does not include McpId in the params' do
        _, _, params = decode_workhorse_header(response)

        expect(params).not_to have_key('McpId')
      end
    end

    context 'when the channel is secure' do
      before do
        allow(Analytics::KnowledgeGraph::GrpcClient).to receive(:secure_channel?).with(endpoint).and_return(true)
      end

      it 'sets tls to true' do
        _, _, params = decode_workhorse_header(response)

        expect(params.dig('GkgServer', 'tls')).to be(true)
      end
    end

    context 'when the channel is insecure and not private' do
      before do
        allow(Analytics::KnowledgeGraph::GrpcClient).to receive(:secure_channel?).with(endpoint).and_return(false)
        allow(Analytics::KnowledgeGraph::GrpcClient).to receive(:private_address?).with(endpoint).and_return(false)
      end

      it 'does not include the JWT' do
        _, _, params = decode_workhorse_header(response)

        expect(params.dig('GkgServer', 'jwt')).to be_nil
      end
    end

    context 'when source_type is provided' do
      let(:source_type) { 'rest' }

      it 'passes source_type into JWT generation' do
        response

        expect(Analytics::KnowledgeGraph::JwtAuth).to have_received(:generate_token)
          .with(user: user, source_type: 'rest')
      end
    end

    context 'when source_type is invalid' do
      let(:source_type) { 'invalid' }
      let(:validated_source_type) { 'rest' }

      it 'logs a warning and falls back to rest' do
        allow(Gitlab::AppLogger).to receive(:warn)

        response

        expect(Gitlab::AppLogger).to have_received(:warn)
          .with("Invalid source_type for Orbit query: \"invalid\", falling back to 'rest'")
        expect(Analytics::KnowledgeGraph::JwtAuth).to have_received(:generate_token)
          .with(user: user, source_type: 'rest')
      end
    end
  end
end
