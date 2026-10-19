# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Querying Orbit data of a group or project', :clean_gitlab_redis_rate_limiting,
  feature_category: :knowledge_graph do
  include GraphqlHelpers

  let_it_be(:user) { create(:user, :with_namespace) }
  let_it_be(:group) { create(:group, :private) }
  let_it_be(:project) { create(:project, :private, group: group) }
  let_it_be(:personal_project) { create(:project, :private, namespace: user.namespace) }

  let(:grpc_client) { instance_double(Analytics::KnowledgeGraph::GrpcClient) }
  let(:out_of_scope_paths) { [] }
  let(:current_user) { user }

  let(:status_fields) { 'indexingStatus { phase projects { indexed totalKnown gaps } domains { name phase } }' }
  let(:item_counts_fields) { 'itemCounts { domains { name entities { name count } } }' }

  before_all do
    group.add_reporter(user)
  end

  before do
    stub_licensed_features(orbit: true)
    stub_config(knowledge_graph: { 'enabled' => true })

    allow(Analytics::KnowledgeGraph::GrpcClient).to receive(:new).and_return(grpc_client)
    allow(grpc_client).to receive(:get_indexing_status) do |traversal_paths:, **|
      { statuses: traversal_paths.map { |traversal_path| indexing_status(traversal_path) } }
    end
    allow(grpc_client).to receive(:get_item_counts).and_return(item_counts)

    authorization_context = instance_double(Analytics::KnowledgeGraph::AuthorizationContext)
    allow(authorization_context).to receive(:traversal_paths_in_scope) { |paths| paths - out_of_scope_paths }
    allow(Analytics::KnowledgeGraph::AuthorizationContext).to receive(:new).and_return(authorization_context)
  end

  def indexing_status(traversal_path)
    {
      traversal_path: traversal_path,
      phase: 'syncing',
      projects: { indexed: 1, total_known: 2, gaps: 1 },
      domains: [
        { name: 'ci', phase: 'ready' },
        { name: 'source_code', phase: 'syncing' }
      ]
    }
  end

  def item_counts
    { domains: [{ name: 'source_code', entities: [{ name: 'File', count: 3_000_000_000 }] }] }
  end

  def query_for(target, orbit_fields)
    graphql_query_for(target.is_a?(Project) ? :project : :group, { fullPath: target.full_path },
      "orbit { #{orbit_fields} }")
  end

  shared_examples 'an Orbit field' do
    let(:query) { query_for(target, "#{status_fields} #{item_counts_fields}") }

    it 'returns the Orbit data' do
      post_graphql(query, current_user: current_user)

      expect_graphql_errors_to_be_empty
      expect(graphql_data_at(parent, :orbit)).to be_present
    end

    it 'returns nil when the Orbit license is not available' do
      stub_licensed_features(orbit: false)

      post_graphql(query, current_user: current_user)

      expect(graphql_data_at(parent, :orbit)).to be_nil
    end

    context 'when the user cannot read the target' do
      let(:current_user) { create(:user) }

      it 'returns nil for the target' do
        post_graphql(query, current_user: current_user)

        expect(graphql_data_at(parent)).to be_nil
      end
    end
  end

  shared_examples 'an Orbit status field' do |field, rate_limit_key|
    let(:query) { query_for(target, fields) }

    context "when the target is out of the user's Orbit scope" do
      let(:out_of_scope_paths) { [traversal_path] }

      it 'returns nil without a gRPC call' do
        post_graphql(query, current_user: current_user)

        expect(graphql_data_at(parent, :orbit, field)).to be_nil
        expect(Analytics::KnowledgeGraph::GrpcClient).not_to have_received(:new)
      end
    end

    context 'when the Orbit server does not have the RPC' do
      before do
        allow(grpc_client).to receive(grpc_method).and_raise(
          Analytics::KnowledgeGraph::GrpcClient::ConnectionError.new(
            'boom', grpc_code: GRPC::Core::StatusCodes::UNIMPLEMENTED
          )
        )
      end

      it 'returns nil without an error' do
        post_graphql(query, current_user: current_user)

        expect_graphql_errors_to_be_empty
        expect(graphql_data_at(parent, :orbit, field)).to be_nil
      end
    end

    context 'when the gRPC call fails' do
      before do
        allow(grpc_client).to receive(grpc_method).and_raise(
          Analytics::KnowledgeGraph::GrpcClient::ConnectionError.new(
            'boom', grpc_code: GRPC::Core::StatusCodes::UNAVAILABLE
          )
        )
      end

      it 'returns an error' do
        post_graphql(query, current_user: current_user)

        expect_graphql_errors_to_include('Knowledge graph request failed')
      end
    end

    context 'when the Orbit authorization header cannot be built' do
      before do
        allow(grpc_client).to receive(grpc_method).and_raise(
          Analytics::KnowledgeGraph::GrpcClient::AuthorizationError, 'boom'
        )
      end

      it 'returns an error' do
        post_graphql(query, current_user: current_user)

        expect_graphql_errors_to_include('Knowledge graph request failed')
      end
    end

    context 'when the rate limit is exceeded' do
      before do
        allow(Gitlab::ApplicationRateLimiter).to receive(:throttled?).and_call_original
        allow(Gitlab::ApplicationRateLimiter).to receive(:throttled?)
          .with(rate_limit_key, scope: { user: current_user }).and_return(true)
      end

      it 'returns an error without a gRPC call' do
        post_graphql(query, current_user: current_user)

        expect_graphql_errors_to_include(/requested too many times/)
        expect(grpc_client).not_to have_received(grpc_method)
      end
    end
  end

  shared_examples 'Orbit data of a target' do
    it_behaves_like 'an Orbit field'

    describe 'indexingStatus' do
      let(:fields) { status_fields }
      let(:grpc_method) { :get_indexing_status }

      it_behaves_like 'an Orbit status field', :indexing_status, :orbit_indexing_status

      it 'returns the indexing status' do
        post_graphql(query_for(target, status_fields), current_user: current_user)

        expect_graphql_errors_to_be_empty
        expect(graphql_data_at(parent, :orbit, :indexing_status)).to eq(
          'phase' => 'SYNCING',
          'projects' => { 'indexed' => 1, 'totalKnown' => 2, 'gaps' => 1 },
          'domains' => [
            { 'name' => 'ci', 'phase' => 'READY' },
            { 'name' => 'source_code', 'phase' => 'SYNCING' }
          ]
        )
        expect(grpc_client).to have_received(:get_indexing_status).with(
          user: current_user, traversal_paths: [traversal_path], request_context: an_instance_of(
            Analytics::KnowledgeGraph::RequestContext
          )
        )
      end
    end

    describe 'itemCounts' do
      let(:fields) { item_counts_fields }
      let(:grpc_method) { :get_item_counts }

      it_behaves_like 'an Orbit status field', :item_counts, :orbit_item_counts

      it 'returns the item counts' do
        post_graphql(query_for(target, item_counts_fields), current_user: current_user)

        expect_graphql_errors_to_be_empty
        expect(graphql_data_at(parent, :orbit, :item_counts)).to eq(
          'domains' => [{ 'name' => 'source_code', 'entities' => [{ 'name' => 'File', 'count' => '3000000000' }] }]
        )
        expect(grpc_client).to have_received(:get_item_counts).with(
          user: current_user, traversal_path: traversal_path, request_context: an_instance_of(
            Analytics::KnowledgeGraph::RequestContext
          )
        )
      end
    end
  end

  context 'with a group' do
    let(:target) { group }
    let(:parent) { :group }
    let(:traversal_path) { group.traversal_path(with_organization: true) }

    it_behaves_like 'Orbit data of a target'
  end

  context 'with a project' do
    let(:target) { project }
    let(:parent) { :project }
    let(:traversal_path) { project.project_namespace.traversal_path(with_organization: true) }

    it_behaves_like 'Orbit data of a target'

    context 'when the project is in a personal namespace' do
      it 'returns nil for both fields without a gRPC call' do
        post_graphql(query_for(personal_project, "#{status_fields} #{item_counts_fields}"), current_user: current_user)

        expect(graphql_data_at(:project, :orbit, :indexing_status)).to be_nil
        expect(graphql_data_at(:project, :orbit, :item_counts)).to be_nil
        expect(Analytics::KnowledgeGraph::GrpcClient).not_to have_received(:new)
      end
    end
  end

  context 'when an admin is not a member of the group', :enable_admin_mode do
    let(:current_user) { create(:admin) }
    let(:traversal_path) { group.traversal_path(with_organization: true) }

    before do
      allow(Analytics::KnowledgeGraph::AuthorizationContext).to receive(:new).and_call_original
    end

    it 'returns the indexing status and item counts' do
      post_graphql(query_for(group, "#{status_fields} #{item_counts_fields}"), current_user: current_user)

      expect_graphql_errors_to_be_empty
      expect(graphql_data_at(:group, :orbit, :indexing_status, :phase)).to eq('SYNCING')
      expect(graphql_data_at(:group, :orbit, :item_counts)).to be_present
      expect(grpc_client).to have_received(:get_indexing_status)
        .with(hash_including(user: current_user, traversal_paths: [traversal_path]))
      expect(grpc_client).to have_received(:get_item_counts)
        .with(hash_including(user: current_user, traversal_path: traversal_path))
    end
  end

  describe 'batching' do
    let_it_be(:other_group) { create(:group, :private, reporters: user) }

    let(:query) do
      <<~GRAPHQL
        query {
          group(fullPath: "#{group.full_path}") { orbit { indexingStatus { phase } } }
          otherGroup: group(fullPath: "#{other_group.full_path}") { orbit { indexingStatus { phase } } }
          project(fullPath: "#{project.full_path}") { orbit { indexingStatus { phase } } }
        }
      GRAPHQL
    end

    def phases
      graphql_data.values.map { |target| target.dig('orbit', 'indexingStatus', 'phase') }
    end

    it 'sends one gRPC call for all groups and projects' do
      post_graphql(query, current_user: current_user)

      expect_graphql_errors_to_be_empty
      expect(phases).to all(eq('SYNCING'))
      expect(grpc_client).to have_received(:get_indexing_status).once.with(
        user: current_user,
        traversal_paths: contain_exactly(
          group.traversal_path(with_organization: true),
          other_group.traversal_path(with_organization: true),
          project.project_namespace.traversal_path(with_organization: true)
        ),
        request_context: an_instance_of(Analytics::KnowledgeGraph::RequestContext)
      )
    end

    context 'when the gRPC call fails' do
      before do
        allow(grpc_client).to receive(:get_indexing_status).and_raise(
          Analytics::KnowledgeGraph::GrpcClient::ConnectionError.new(
            'boom', grpc_code: GRPC::Core::StatusCodes::UNAVAILABLE
          )
        )
      end

      it 'returns the error on each field after one gRPC call and one rate limit check' do
        allow(Gitlab::ApplicationRateLimiter).to receive(:throttled?).and_call_original

        post_graphql(query, current_user: current_user)

        expect(graphql_errors.pluck('path')).to contain_exactly(
          %w[group orbit indexingStatus], %w[otherGroup orbit indexingStatus], %w[project orbit indexingStatus]
        )
        expect(graphql_errors.pluck('message')).to all(eq('Knowledge graph request failed'))
        expect(grpc_client).to have_received(:get_indexing_status).once
        expect(Gitlab::ApplicationRateLimiter).to have_received(:throttled?).with(:orbit_indexing_status, anything).once
      end
    end

    context "when one group is out of the user's Orbit scope" do
      let(:out_of_scope_paths) { [other_group.traversal_path(with_organization: true)] }

      it 'returns the statuses of the other targets' do
        post_graphql(query, current_user: current_user)

        expect_graphql_errors_to_be_empty
        expect(graphql_data_at(:group, :orbit, :indexing_status, :phase)).to eq('SYNCING')
        expect(graphql_data_at(:other_group, :orbit, :indexing_status)).to be_nil
        expect(graphql_data_at(:project, :orbit, :indexing_status, :phase)).to eq('SYNCING')
        expect(grpc_client).to have_received(:get_indexing_status).once.with(
          hash_including(traversal_paths: contain_exactly(
            group.traversal_path(with_organization: true),
            project.project_namespace.traversal_path(with_organization: true)
          ))
        )
      end
    end

    it 'sends more paths than the Orbit limit in more than one call' do
      stub_const("#{Resolvers::Analytics::Orbit::IndexingStatusResolver}::MAX_TRAVERSAL_PATHS_PER_CALL", 2)

      post_graphql(query, current_user: current_user)

      expect_graphql_errors_to_be_empty
      expect(phases).to all(eq('SYNCING'))
      expect(grpc_client).to have_received(:get_indexing_status).twice
    end

    it 'checks the rate limit before each gRPC call' do
      stub_const("#{Resolvers::Analytics::Orbit::IndexingStatusResolver}::MAX_TRAVERSAL_PATHS_PER_CALL", 2)
      allow(Gitlab::ApplicationRateLimiter).to receive(:throttled?).and_call_original
      allow(Gitlab::ApplicationRateLimiter).to receive(:throttled?)
        .with(:orbit_indexing_status, scope: { user: current_user }).and_return(false, true)

      post_graphql(query, current_user: current_user)

      expect(graphql_errors.pluck('message')).to all(match(/requested too many times/))
      expect(graphql_errors.size).to eq(3)
      expect(grpc_client).to have_received(:get_indexing_status).once
    end

    it 'does not run more SQL queries for more groups' do
      groups_query = graphql_query_for(:groups, {}, 'nodes { orbit { indexingStatus { phase } } }')

      control = ActiveRecord::QueryRecorder.new { post_graphql(groups_query, current_user: current_user) }

      create_list(:group, 2, :private, reporters: current_user)

      expect { post_graphql(groups_query, current_user: current_user) }.not_to exceed_query_limit(control)
      expect(graphql_data_at(:groups, :nodes).size).to eq(4)
    end
  end

  it 'sends an empty request context when the query has no HTTP request' do
    GitlabSchema.execute(query_for(group, item_counts_fields), context: { current_user: current_user })

    expect(grpc_client).to have_received(:get_item_counts).with(
      hash_including(request_context: Analytics::KnowledgeGraph::RequestContext.new)
    )
  end

  describe 'itemCounts call limit' do
    it 'returns an error when the field is requested for more than one group or project' do
      query = <<~GRAPHQL
        query {
          group(fullPath: "#{group.full_path}") { orbit { itemCounts { domains { name } } } }
          project(fullPath: "#{project.full_path}") { orbit { itemCounts { domains { name } } } }
        }
      GRAPHQL

      post_graphql(query, current_user: current_user)

      expect_graphql_errors_to_include(/can be requested only for 1/)
    end
  end

  describe 'granular token authorization' do
    let_it_be(:public_group) { create(:group, :public) }
    let_it_be(:public_project) { create(:project, :public, group: public_group) }

    let(:boundary_object) { :user }
    let(:orbit_fields) { "#{status_fields} #{item_counts_fields}" }

    def post_with_pat(target)
      post_graphql(query_for(target, orbit_fields), token: { personal_access_token: pat })
    end

    context 'with Group.orbit' do
      it_behaves_like 'authorizing granular token permissions for GraphQL', :read_orbit do
        let(:request) { post_with_pat(public_group) }
      end
    end

    context 'with Project.orbit' do
      it_behaves_like 'authorizing granular token permissions for GraphQL', :read_orbit do
        let(:request) { post_with_pat(public_project) }
      end
    end

    context 'when the token does not have read_orbit' do
      let(:pat) { create(:granular_pat, user: user, boundary: ::Authz::Boundary.for(public_group)) }

      it 'returns the group but not the Orbit data' do
        post_with_pat(public_group)

        expect(graphql_data_at(:group)).to be_present
        expect(graphql_data_at(:group, :orbit)).to be_nil
      end
    end
  end
end
