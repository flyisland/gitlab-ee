# frozen_string_literal: true

require 'spec_helper'

RSpec.describe '(Group|Project).analytics.finishedPipelines', :click_house, time_travel_to: '2026-01-30',
  feature_category: :pipeline_composition do
  include GraphqlHelpers
  include ClickHouseHelpers

  let_it_be(:group) { create(:group) }
  let_it_be(:project1) { create(:project, group: group) }
  let_it_be(:project2) { create(:project) }
  let_it_be(:current_user) { create(:user, reporter_of: group) }
  let_it_be(:guest) { create(:user, guest_of: group) }

  let(:pipelines_data) do
    [
      { id: 1, ref: 'main', source: 'push', status: 'success', duration: 60,
        started_at: 100.days.ago, project: project1 },
      { id: 2, ref: 'main', source: 'push', status: 'success', duration: 120,
        started_at: 50.days.ago, project: project1 },
      { id: 3, ref: 'main', source: 'push', status: 'failed', duration: 30,
        started_at: 15.days.ago, project: project1 },
      { id: 4, ref: 'main', source: 'schedule', status: 'success', duration: 90,
        started_at: 12.days.ago, project: project1 },
      { id: 5, ref: 'develop', source: 'push', status: 'canceled', duration: 20,
        started_at: 8.days.ago, project: project1 },
      { id: 6, ref: 'develop', source: 'push', status: 'skipped', duration: 0,
        started_at: 8.days.ago, project: project1 },
      { id: 7, ref: 'main', source: 'push', status: 'success', duration: 45,
        started_at: 8.days.ago, project: project1 },
      { id: 8, ref: 'main', source: 'push', status: 'success', duration: 75,
        started_at: 10.days.ago, project: project1 },
      { id: 9, ref: 'main', source: 'push', status: 'success', duration: 55,
        started_at: 8.days.ago, project: project2 }
    ]
  end

  before do
    allow(Gitlab::ClickHouse).to receive(:globally_enabled_for_analytics?).and_return(true)

    rows = pipelines_data.map do |p|
      {
        id: p[:id],
        path: p[:project].project_namespace.traversal_path,
        ref: p[:ref],
        source: p[:source],
        status: p[:status],
        duration: p[:duration],
        started_at: p[:started_at],
        committed_at: p[:started_at],
        created_at: p[:started_at],
        finished_at: p[:started_at] + p[:duration].seconds
      }
    end

    clickhouse_fixture(:ci_finished_pipelines, rows)
  end

  shared_examples 'finishedPipelines query' do
    context 'when user does not have access' do
      let(:query) do
        <<~QUERY
          query {
            #{query_type}(fullPath: "#{query_path}") {
              analytics {
                finishedPipelines {
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

        expect(graphql_data.dig(query_type, 'analytics', 'finishedPipelines')).to be_nil
      end
    end

    context 'when querying with all filters and dimensions' do
      let(:query) do
        <<~QUERY
          query {
            #{query_type}(fullPath: "#{query_path}") {
              analytics {
                finishedPipelines(
                  ref: ["main"]
                  source: ["push"]
                  startedAtFrom: "#{30.days.ago.iso8601}"
                  startedAtTo: "#{5.days.ago.iso8601}"
                ) {
                  aggregated(
                    orderBy: [
                      { identifier: "status", direction: ASC }
                      { identifier: "startedAt", direction: ASC, parameters: { granularity: "monthly" } }
                    ]
                  ) {
                    nodes {
                      dimensions {
                        status
                        ref
                        source
                        startedAtMonthly: startedAt(granularity: "monthly")
                      }
                      totalCount
                      successRate
                      failureRate
                      canceledRate
                      skippedRate
                    }
                  }
                }
              }
            }
          }
        QUERY
      end

      it 'returns filtered and aggregated pipeline data with all metrics and dimensions', :aggregate_failures do
        post_graphql(query, current_user: current_user)

        expect(graphql_errors).to be_nil

        nodes = graphql_data.dig(query_type, 'analytics', 'finishedPipelines', 'aggregated', 'nodes')

        expect(nodes.size).to eq(2)

        expect(nodes[0]).to eq(
          'dimensions' => {
            'status' => 'failed',
            'ref' => 'main',
            'source' => 'push',
            'startedAtMonthly' => '2026-01-01'
          },
          'totalCount' => 1,
          'successRate' => 0.0,
          'failureRate' => 1.0,
          'canceledRate' => 0.0,
          'skippedRate' => 0.0
        )

        expect(nodes[1]).to eq(
          'dimensions' => {
            'status' => 'success',
            'ref' => 'main',
            'source' => 'push',
            'startedAtMonthly' => '2026-01-01'
          },
          'totalCount' => 2,
          'successRate' => 1.0,
          'failureRate' => 0.0,
          'canceledRate' => 0.0,
          'skippedRate' => 0.0
        )
      end
    end

    context 'when querying without filters' do
      let(:query) do
        <<~QUERY
          query {
            #{query_type}(fullPath: "#{query_path}") {
              analytics {
                finishedPipelines {
                  aggregated {
                    nodes {
                      totalCount
                      successRate
                      failureRate
                      canceledRate
                      skippedRate
                    }
                  }
                }
              }
            }
          }
        QUERY
      end

      it 'aggregates all pipelines in scope' do
        post_graphql(query, current_user: current_user)

        expect(graphql_errors).to be_nil

        nodes = graphql_data.dig(query_type, 'analytics', 'finishedPipelines', 'aggregated', 'nodes')

        expect(nodes.size).to eq(1)
        expect(nodes[0]).to match(
          'totalCount' => 8,
          'successRate' => be_within(0.01).of(0.625),
          'failureRate' => be_within(0.01).of(0.125),
          'canceledRate' => be_within(0.01).of(0.125),
          'skippedRate' => be_within(0.01).of(0.125)
        )
      end
    end

    context 'when querying count' do
      let(:query) do
        <<~QUERY
          query {
            #{query_type}(fullPath: "#{query_path}") {
              analytics {
                finishedPipelines(
                  status: ["success", "failed"]
                ) {
                  aggregated {
                    count
                    nodes {
                      dimensions {
                        status
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

        data = graphql_data.dig(query_type, 'analytics', 'finishedPipelines', 'aggregated')
        # success and failed are 2 distinct status groups
        expect(data['count']).to eq(2)
      end
    end

    context 'when ordering by parameterized dimension without providing parameters' do
      let(:query) do
        <<~QUERY
          query {
            #{query_type}(fullPath: "#{query_path}") {
              analytics {
                finishedPipelines {
                  aggregated(
                    orderBy: [
                      { identifier: "startedAt", direction: DESC }
                    ]
                  ) {
                    nodes {
                      dimensions {
                        startedAt(granularity: "monthly")
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

      it 'returns an error indicating the identifier is not available' do
        post_graphql(query, current_user: current_user)

        expect(graphql_errors).to match(
          [hash_including('message' => "the specified identifier is not available: 'started_at'")]
        )
        expect(graphql_data.dig(query_type, 'analytics', 'finishedPipelines', 'aggregated', 'nodes')).to be_nil
      end
    end
  end

  context 'for group' do
    let(:query_type) { 'group' }
    let(:query_path) { group.full_path }

    it_behaves_like 'finishedPipelines query'
  end

  context 'for project' do
    let(:query_type) { 'project' }
    let(:query_path) { project1.full_path }

    it_behaves_like 'finishedPipelines query'
  end
end
