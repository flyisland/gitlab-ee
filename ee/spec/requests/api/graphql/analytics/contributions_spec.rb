# frozen_string_literal: true

require 'spec_helper'

RSpec.describe '(Group|Project).analytics.contributions (aggregation engine)',
  :click_house, time_travel_to: '2026-01-30',
  feature_category: :product_analytics do
  include GraphqlHelpers
  include ClickHouseHelpers

  let_it_be(:group) { create(:group) }
  let_it_be(:project1) { create(:project, group: group) }
  let_it_be(:project2) { create(:project) }
  let_it_be(:current_user) { create(:user, reporter_of: group) }
  let_it_be(:non_member) { create(:user) }

  let_it_be(:user1) { create(:user) }
  let_it_be(:user2) { create(:user) }
  let_it_be(:user3) { create(:user) }

  let(:contributions_data) do
    [
      { id: 1, author_id: user1.id, project: project1, created_at: 100.days.ago },
      { id: 2, author_id: user1.id, project: project1, created_at: 50.days.ago },
      { id: 3, author_id: user1.id, project: project1, created_at: 15.days.ago },
      { id: 4, author_id: user2.id, project: project1, created_at: 12.days.ago },
      { id: 5, author_id: user2.id, project: project1, created_at: 8.days.ago },
      { id: 6, author_id: user3.id, project: project1, created_at: 8.days.ago },
      { id: 7, author_id: user3.id, project: project1, created_at: 10.days.ago },
      { id: 8, author_id: user3.id, project: project1, created_at: 8.days.ago },
      { id: 9, author_id: user1.id, project: project2, created_at: 8.days.ago }
    ]
  end

  before do
    stub_licensed_features(contribution_analytics: true)
    allow(Gitlab::ClickHouse).to receive(:globally_enabled_for_analytics?).and_return(true)

    rows = contributions_data.map do |c|
      {
        id: c[:id],
        path: c[:project].project_namespace.traversal_path,
        author_id: c[:author_id],
        created_at: c[:created_at],
        updated_at: c[:created_at],
        version: c[:created_at],
        target_type: '',
        action: 5,
        deleted: false
      }
    end

    clickhouse_fixture(:contributions_new, rows)
  end

  shared_examples 'contributions query' do
    context 'when user does not have access' do
      let(:query) do
        <<~QUERY
          query {
            #{query_type}(fullPath: "#{query_path}") {
              analytics {
                contributions {
                  aggregated {
                    nodes { totalCount }
                  }
                }
              }
            }
          }
        QUERY
      end

      it 'returns no data for non-member' do
        post_graphql(query, current_user: non_member)

        expect(graphql_data.dig(query_type, 'analytics', 'contributions')).to be_nil
      end
    end

    context 'when contribution_analytics feature is not licensed' do
      let(:query) do
        <<~QUERY
          query {
            #{query_type}(fullPath: "#{query_path}") {
              analytics {
                contributions {
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
        stub_licensed_features(contribution_analytics: false)

        post_graphql(query, current_user: current_user)

        expect(graphql_data.dig(query_type, 'analytics', 'contributions')).to be_nil
      end
    end

    context 'when querying with filters' do
      let(:query) do
        <<~QUERY
          query {
            #{query_type}(fullPath: "#{query_path}") {
              analytics {
                contributions(
                  authorId: ["#{user1.to_global_id}", "#{user2.to_global_id}"]
                  createdAtFrom: "#{30.days.ago.iso8601}"
                  createdAtTo: "#{5.days.ago.iso8601}"
                ) {
                  aggregated {
                    nodes {
                      totalCount
                      usersCount
                    }
                  }
                }
              }
            }
          }
        QUERY
      end

      it 'returns filtered and aggregated contribution data', :aggregate_failures do
        post_graphql(query, current_user: current_user)

        expect(graphql_errors).to be_nil

        nodes = graphql_data.dig(query_type, 'analytics', 'contributions', 'aggregated', 'nodes')

        expect(nodes.size).to eq(1)
        expect(nodes[0]).to eq(
          'totalCount' => 3,
          'usersCount' => 2
        )
      end
    end

    context 'when querying without filters' do
      let(:query) do
        <<~QUERY
          query {
            #{query_type}(fullPath: "#{query_path}") {
              analytics {
                contributions {
                  aggregated {
                    nodes {
                      totalCount
                      usersCount
                    }
                  }
                }
              }
            }
          }
        QUERY
      end

      it 'aggregates all contributions in scope' do
        post_graphql(query, current_user: current_user)

        expect(graphql_errors).to be_nil

        nodes = graphql_data.dig(query_type, 'analytics', 'contributions', 'aggregated', 'nodes')

        expect(nodes.size).to eq(1)
        expect(nodes[0]).to match(
          'totalCount' => expected_total_count,
          'usersCount' => expected_users_count
        )
      end
    end

    context 'when querying count' do
      let(:query) do
        <<~QUERY
          query {
            #{query_type}(fullPath: "#{query_path}") {
              analytics {
                contributions(
                  authorId: ["#{user1.to_global_id}", "#{user2.to_global_id}"]
                ) {
                  aggregated {
                    count
                    nodes {
                      totalCount
                      usersCount
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

        data = graphql_data.dig(query_type, 'analytics', 'contributions', 'aggregated')
        expect(data['count']).to eq(1)
      end
    end
  end

  context 'for group' do
    let(:query_type) { 'group' }
    let(:query_path) { group.full_path }
    let(:expected_total_count) { 8 }
    let(:expected_users_count) { 3 }

    it_behaves_like 'contributions query'
  end

  context 'for project' do
    let(:query_type) { 'project' }
    let(:query_path) { project1.full_path }
    # project1 has contributions from user1, user2, user3 but not project2's contribution (id: 9)
    let(:expected_total_count) { 8 }
    let(:expected_users_count) { 3 }

    it_behaves_like 'contributions query'
  end
end
