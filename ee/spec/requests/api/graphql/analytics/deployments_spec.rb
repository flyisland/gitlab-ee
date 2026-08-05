# frozen_string_literal: true

require 'spec_helper'

RSpec.describe '(Group|Project).analytics.deployments (aggregation engine)',
  :click_house, time_travel_to: '2026-01-30',
  feature_category: :dora_metrics do
  include GraphqlHelpers
  include ClickHouseHelpers

  let_it_be(:group) { create(:group) }
  let_it_be(:project1) { create(:project, group: group) }
  let_it_be(:project2) { create(:project) }
  let_it_be(:current_user) { create(:user, reporter_of: group) }
  let_it_be(:guest) { create(:user, guest_of: group) }
  let_it_be(:environment1) { create(:environment, project: project1) }
  let_it_be(:environment2) { create(:environment, project: project1) }

  let(:deployments_data) do
    [
      { id: 1, ref: 'main', status: ::Deployment.statuses[:success], environment_id: environment1.id,
        created_at: 100.days.ago, finished_at: 100.days.ago, project: project1 },
      { id: 2, ref: 'main', status: ::Deployment.statuses[:success], environment_id: environment1.id,
        created_at: 50.days.ago, finished_at: 50.days.ago, project: project1 },
      { id: 3, ref: 'main', status: ::Deployment.statuses[:failed], environment_id: environment1.id,
        created_at: 15.days.ago, finished_at: 15.days.ago, project: project1 },
      { id: 4, ref: 'main', status: ::Deployment.statuses[:success], environment_id: environment1.id,
        created_at: 12.days.ago, finished_at: 12.days.ago, project: project1 },
      { id: 5, ref: 'develop', status: ::Deployment.statuses[:canceled], environment_id: environment2.id,
        created_at: 8.days.ago, finished_at: 8.days.ago, project: project1 },
      { id: 6, ref: 'main', status: ::Deployment.statuses[:success], environment_id: environment1.id,
        created_at: 8.days.ago, finished_at: 8.days.ago, project: project1 },
      { id: 7, ref: 'main', status: ::Deployment.statuses[:success], environment_id: environment1.id,
        created_at: 8.days.ago, finished_at: 8.days.ago, project: project2 }
    ]
  end

  before do
    stub_licensed_features(dora4_analytics: true)
    allow(Gitlab::ClickHouse).to receive(:globally_enabled_for_analytics?).and_return(true)

    rows = deployments_data.map do |d|
      {
        id: d[:id],
        iid: d[:id],
        project_id: d[:project].id,
        environment_id: d[:environment_id],
        ref: d[:ref],
        tag: false,
        sha: 'abc123',
        user_id: nil,
        status: d[:status],
        finished_at: d[:finished_at],
        created_at: d[:created_at],
        updated_at: d[:created_at],
        traversal_path: d[:project].project_namespace.traversal_path(with_organization: true).to_s,
        _siphon_replicated_at: d[:created_at],
        _siphon_deleted: false
      }
    end

    clickhouse_fixture(:siphon_deployments, rows)
  end

  shared_examples 'deployments query' do
    context 'when user does not have access' do
      let(:query) do
        <<~QUERY
          query {
            #{query_type}(fullPath: "#{query_path}") {
              analytics {
                deployments {
                  aggregated {
                    nodes { totalCount }
                  }
                }
              }
            }
          }
        QUERY
      end

      it 'returns no data for guest' do
        post_graphql(query, current_user: guest)

        expect(graphql_data.dig(query_type, 'analytics', 'deployments')).to be_nil
      end
    end

    context 'when dora4_analytics feature is not licensed' do
      let(:query) do
        <<~QUERY
          query {
            #{query_type}(fullPath: "#{query_path}") {
              analytics {
                deployments {
                  aggregated {
                    nodes { totalCount }
                  }
                }
              }
            }
          }
        QUERY
      end

      it 'returns no data' do
        stub_licensed_features(dora4_analytics: false)

        post_graphql(query, current_user: current_user)

        expect(graphql_data.dig(query_type, 'analytics', 'deployments')).to be_nil
      end
    end

    context 'when querying with filters and dimensions' do
      let(:query) do
        <<~QUERY
          query {
            #{query_type}(fullPath: "#{query_path}") {
              analytics {
                deployments(
                  ref: ["main"]
                  finishedAtFrom: "#{30.days.ago.iso8601}"
                  finishedAtTo: "#{5.days.ago.iso8601}"
                ) {
                  aggregated(
                    orderBy: [
                      { identifier: "status", direction: ASC }
                    ]
                  ) {
                    nodes {
                      dimensions {
                        status
                        ref
                      }
                      totalCount
                      successRate
                      failureRate
                    }
                  }
                }
              }
            }
          }
        QUERY
      end

      it 'returns filtered and aggregated deployment data', :aggregate_failures do
        post_graphql(query, current_user: current_user)

        expect(graphql_errors).to be_nil

        nodes = graphql_data.dig(query_type, 'analytics', 'deployments', 'aggregated', 'nodes')

        expect(nodes.size).to eq(2)

        expect(nodes[0]).to eq(
          'dimensions' => {
            'status' => 'success',
            'ref' => 'main'
          },
          'totalCount' => 2,
          'successRate' => 1.0,
          'failureRate' => 0.0
        )

        expect(nodes[1]).to eq(
          'dimensions' => {
            'status' => 'failed',
            'ref' => 'main'
          },
          'totalCount' => 1,
          'successRate' => 0.0,
          'failureRate' => 1.0
        )
      end
    end

    context 'when querying without filters' do
      let(:query) do
        <<~QUERY
          query {
            #{query_type}(fullPath: "#{query_path}") {
              analytics {
                deployments {
                  aggregated {
                    nodes {
                      totalCount
                      successRate
                      failureRate
                    }
                  }
                }
              }
            }
          }
        QUERY
      end

      it 'aggregates all deployments in scope' do
        post_graphql(query, current_user: current_user)

        expect(graphql_errors).to be_nil

        nodes = graphql_data.dig(query_type, 'analytics', 'deployments', 'aggregated', 'nodes')

        expect(nodes.size).to eq(1)
        expect(nodes[0]).to match(
          'totalCount' => expected_total_count,
          'successRate' => be_within(0.01).of(expected_success_rate),
          'failureRate' => be_within(0.01).of(expected_failure_rate)
        )
      end
    end

    context 'when querying count' do
      let(:query) do
        <<~QUERY
          query {
            #{query_type}(fullPath: "#{query_path}") {
              analytics {
                deployments(
                  ref: ["main", "develop"]
                ) {
                  aggregated {
                    count
                    nodes {
                      dimensions {
                        ref
                      }
                      totalCount
                    }
                  }
                }
              }
            }
          }
        QUERY
      end

      it 'returns the number of aggregated rows independently of pagination' do
        post_graphql(query, current_user: current_user)

        expect(graphql_errors).to be_nil

        data = graphql_data.dig(query_type, 'analytics', 'deployments', 'aggregated')
        expect(data['count']).to eq(expected_ref_count)
      end
    end

    context 'when filtering by environment Global ID and grouping by environment' do
      let(:query) do
        <<~QUERY
          query {
            #{query_type}(fullPath: "#{query_path}") {
              analytics {
                deployments(
                  environmentId: ["#{environment1.to_global_id}"]
                ) {
                  aggregated {
                    nodes {
                      dimensions {
                        environment { id }
                      }
                      totalCount
                    }
                  }
                }
              }
            }
          }
        QUERY
      end

      it 'returns deployments scoped to the given environment with the resolved association' do
        post_graphql(query, current_user: current_user)

        expect(graphql_errors).to be_nil

        nodes = graphql_data.dig(query_type, 'analytics', 'deployments', 'aggregated', 'nodes')

        expect(nodes).to eq([{
          'dimensions' => { 'environment' => { 'id' => environment1.to_global_id.to_s } },
          'totalCount' => expected_environment1_count
        }])
      end
    end
  end

  context 'for group' do
    let(:query_type) { 'group' }
    let(:query_path) { group.full_path }
    # project1 has 6 deployments in the group scope (project2 is outside the group)
    let(:expected_total_count) { 6 }
    let(:expected_success_rate) { 4.0 / 6.0 }
    let(:expected_failure_rate) { 1.0 / 6.0 }
    let(:expected_ref_count) { 2 } # main and develop
    let(:expected_environment1_count) { 5 } # project1 deployments in environment1

    it_behaves_like 'deployments query'
  end

  context 'for project' do
    let(:query_type) { 'project' }
    let(:query_path) { project1.full_path }
    # project1 has 6 deployments
    let(:expected_total_count) { 6 }
    let(:expected_success_rate) { 4.0 / 6.0 }
    let(:expected_failure_rate) { 1.0 / 6.0 }
    let(:expected_ref_count) { 2 } # main and develop
    let(:expected_environment1_count) { 5 } # project1 deployments in environment1

    it_behaves_like 'deployments query'
  end
end
