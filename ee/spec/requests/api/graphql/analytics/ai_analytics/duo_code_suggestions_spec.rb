# frozen_string_literal: true

require 'spec_helper'

RSpec.describe '(Group|Project).analytics.duoCodeSuggestions', :click_house, time_travel_to: '2026-01-30', feature_category: :code_suggestions do
  include GraphqlHelpers
  include ClickHouseHelpers

  let_it_be(:group) { create(:group) }
  let_it_be(:project1) { create(:project, group: group) }
  let_it_be(:project2) { create(:project) }
  let_it_be(:current_user) { create(:user, reporter_of: group) }
  let_it_be(:guest) { create(:user, guest_of: group) }

  let_it_be(:user1) { create(:user) }
  let_it_be(:user2) { create(:user) }
  let_it_be(:user3) { create(:user) }

  let(:shown_event) { Ai::UsageEvent.events[:code_suggestion_shown_in_ide] }
  let(:accepted_event) { Ai::UsageEvent.events[:code_suggestion_accepted_in_ide] }
  let(:rejected_event) { Ai::UsageEvent.events[:code_suggestion_rejected_in_ide] }

  let(:suggestions_data) do
    [
      {
        uid: 'uid-1',
        user_id: user1.id,
        language: 'ruby',
        ide_name: 'VSCode',
        suggestion_size: 10,
        project: project1,
        shown_at: 100.days.ago,
        accepted_at: 100.days.ago + 5.seconds
      },
      {
        uid: 'uid-2',
        user_id: user1.id,
        language: 'ruby',
        ide_name: 'VSCode',
        suggestion_size: 20,
        project: project1,
        shown_at: 50.days.ago,
        accepted_at: 50.days.ago + 3.seconds
      },
      {
        uid: 'uid-3',
        user_id: user1.id,
        language: 'ruby',
        ide_name: 'VSCode',
        suggestion_size: 15,
        project: project1,
        shown_at: 15.days.ago
      },
      {
        uid: 'uid-4',
        user_id: user2.id,
        language: 'python',
        ide_name: 'JetBrains',
        suggestion_size: 30,
        project: project1,
        shown_at: 12.days.ago,
        rejected_at: 12.days.ago + 2.seconds
      },
      {
        uid: 'uid-5',
        user_id: user2.id,
        language: 'python',
        ide_name: 'JetBrains',
        suggestion_size: 25,
        project: project1,
        shown_at: 8.days.ago
      },
      {
        uid: 'uid-6',
        user_id: user3.id,
        language: 'go',
        ide_name: 'VSCode',
        suggestion_size: 50,
        project: project1,
        shown_at: 8.days.ago,
        accepted_at: 8.days.ago + 1.second
      },
      {
        uid: 'uid-7',
        user_id: user1.id,
        language: 'go',
        ide_name: 'VSCode',
        suggestion_size: 40,
        project: project1,
        shown_at: 10.days.ago,
        accepted_at: 10.days.ago + 2.seconds
      },
      {
        uid: 'uid-8',
        user_id: user1.id,
        language: 'go',
        ide_name: 'VSCode',
        suggestion_size: 35,
        project: project1,
        shown_at: 8.days.ago,
        rejected_at: 8.days.ago + 3.seconds
      },
      {
        uid: 'uid-9',
        user_id: user1.id,
        language: 'ruby',
        ide_name: 'VSCode',
        suggestion_size: 12,
        project: project2,
        shown_at: 8.days.ago,
        accepted_at: 8.days.ago + 1.second
      }
    ]
  end

  before do
    stub_licensed_features(ai_analytics: true)
    allow(Gitlab::ClickHouse).to receive(:globally_enabled_for_analytics?).and_return(true)

    events_data = suggestions_data.flat_map do |s|
      namespace_path = s[:project].project_namespace.traversal_path
      extras = {
        unique_tracking_id: s[:uid],
        language: s[:language],
        ide_name: s[:ide_name],
        suggestion_size: s[:suggestion_size]
      }.to_json

      rows = []

      if s[:shown_at]
        rows << {
          user_id: s[:user_id],
          event: shown_event,
          timestamp: s[:shown_at],
          namespace_path: namespace_path,
          extras: extras
        }
      end

      if s[:accepted_at]
        rows << {
          user_id: s[:user_id],
          event: accepted_event,
          timestamp: s[:accepted_at],
          namespace_path: namespace_path,
          extras: extras
        }
      end

      if s[:rejected_at]
        rows << {
          user_id: s[:user_id],
          event: rejected_event,
          timestamp: s[:rejected_at],
          namespace_path: namespace_path,
          extras: extras
        }
      end

      rows
    end

    clickhouse_fixture(:ai_usage_events, events_data)
  end

  shared_examples 'duoCodeSuggestions query' do
    context 'when user is not authorized' do
      let(:query) do
        <<~QUERY
          query {
            #{query_type}(fullPath: "#{query_path}") {
              analytics {
                duoCodeSuggestions {
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
        post_graphql(query, current_user: guest)

        expect(graphql_data.dig(query_type, 'analytics', 'duoCodeSuggestions')).to be_nil
      end
    end

    context 'when ai_analytics feature is not licensed' do
      let(:query) do
        <<~QUERY
          query {
            #{query_type}(fullPath: "#{query_path}") {
              analytics {
                duoCodeSuggestions {
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
        stub_licensed_features(ai_analytics: false)

        post_graphql(query, current_user: current_user)

        expect(graphql_data.dig(query_type, 'analytics', 'duoCodeSuggestions')).to be_nil
      end
    end

    context 'when querying all possible filters and fields' do
      let(:query) do
        <<~QUERY
          query {
            #{query_type}(fullPath: "#{query_path}") {
              analytics {
                duoCodeSuggestions(
                  userId: ["#{user1.to_global_id}", "#{user2.to_global_id}"]
                  language: ["ruby", "python"]
                  timestampFrom: "#{60.days.ago.iso8601}"
                  timestampTo: "#{5.days.ago.iso8601}"
                ) {
                  aggregated(
                    orderBy: [
                      { identifier: "user", direction: DESC }
                      { identifier: "timestamp", direction: ASC, parameters: { granularity: "monthly" } }
                    ]
                  ) {
                    nodes {
                      dimensions {
                        language
                        ideName
                        user {
                          id
                        }
                        timestampMonthly: timestamp(granularity: "monthly")
                      }
                      totalCount
                      usersCount
                      acceptanceRate
                      suggestionSizeSum
                      acceptedCount
                      rejectedCount
                      shownCount
                    }
                  }
                }
              }
            }
          }
        QUERY
      end

      it 'returns filtered and aggregated suggestion data with all metrics and dimensions', :aggregate_failures do
        post_graphql(query, current_user: current_user)

        expect(graphql_errors).to be_nil

        nodes = graphql_data.dig(query_type, 'analytics', 'duoCodeSuggestions', 'aggregated', 'nodes')

        expect(nodes.size).to eq(3)

        expect(nodes[0]).to eq(
          'dimensions' => {
            'language' => 'python',
            'ideName' => 'JetBrains',
            'user' => { 'id' => user2.to_global_id.to_s },
            'timestampMonthly' => '2026-01-01'
          },
          'totalCount' => 2,
          'usersCount' => 1,
          'acceptanceRate' => 0.0,
          'suggestionSizeSum' => 55,
          'acceptedCount' => 0,
          'rejectedCount' => 1,
          'shownCount' => 2
        )

        expect(nodes[1]).to eq(
          'dimensions' => {
            'language' => 'ruby',
            'ideName' => 'VSCode',
            'user' => { 'id' => user1.to_global_id.to_s },
            'timestampMonthly' => '2025-12-01'
          },
          'totalCount' => 1,
          'usersCount' => 1,
          'acceptanceRate' => 1.0,
          'suggestionSizeSum' => 20,
          'acceptedCount' => 1,
          'rejectedCount' => 0,
          'shownCount' => 1
        )

        expect(nodes[2]).to eq(
          'dimensions' => {
            'language' => 'ruby',
            'ideName' => 'VSCode',
            'user' => { 'id' => user1.to_global_id.to_s },
            'timestampMonthly' => '2026-01-01'
          },
          'totalCount' => 1,
          'usersCount' => 1,
          'acceptanceRate' => 0.0,
          'suggestionSizeSum' => 15,
          'acceptedCount' => 0,
          'rejectedCount' => 0,
          'shownCount' => 1
        )
      end
    end

    context 'when querying with single filter values' do
      let(:query) do
        <<~QUERY
          query {
            #{query_type}(fullPath: "#{query_path}") {
              analytics {
                duoCodeSuggestions(
                  userId: ["#{user1.to_global_id}"]
                  language: ["ruby"]
                ) {
                  aggregated {
                    nodes {
                      dimensions {
                        language
                        user {
                          id
                        }
                      }
                      totalCount
                      acceptedCount
                      shownCount
                    }
                  }
                }
              }
            }
          }
        QUERY
      end

      it 'returns only suggestions matching single filter values' do
        post_graphql(query, current_user: current_user)

        expect(graphql_errors).to be_nil

        nodes = graphql_data.dig(query_type, 'analytics', 'duoCodeSuggestions', 'aggregated', 'nodes')

        expect(nodes).to eq([{
          'dimensions' => {
            'language' => 'ruby',
            'user' => { 'id' => user1.to_global_id.to_s }
          },
          'totalCount' => 3,
          'acceptedCount' => 2,
          'shownCount' => 3
        }])
      end
    end

    context 'when querying without filters' do
      let(:query) do
        <<~QUERY
          query {
            #{query_type}(fullPath: "#{query_path}") {
              analytics {
                duoCodeSuggestions {
                  aggregated {
                    nodes {
                      totalCount
                      usersCount
                      acceptanceRate
                      suggestionSizeSum
                      acceptedCount
                      rejectedCount
                      shownCount
                    }
                  }
                }
              }
            }
          }
        QUERY
      end

      it 'aggregates all suggestions in scope' do
        post_graphql(query, current_user: current_user)

        expect(graphql_errors).to be_nil

        nodes = graphql_data.dig(query_type, 'analytics', 'duoCodeSuggestions', 'aggregated', 'nodes')

        expect(nodes.size).to eq(1)
        expect(nodes[0]).to match(
          'totalCount' => 8,
          'usersCount' => 3,
          'acceptanceRate' => be_within(0.01).of(0.5),
          'suggestionSizeSum' => 225,
          'acceptedCount' => 4,
          'rejectedCount' => 2,
          'shownCount' => 8
        )
      end
    end

    context 'when querying count' do
      let(:query) do
        <<~QUERY
          query {
            #{query_type}(fullPath: "#{query_path}") {
              analytics {
                duoCodeSuggestions(
                  language: ["ruby", "go"]
                ) {
                  aggregated {
                    count
                    nodes {
                      dimensions {
                        language
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

        data = graphql_data.dig(query_type, 'analytics', 'duoCodeSuggestions', 'aggregated')
        # ruby and go are 2 distinct language groups
        expect(data['count']).to eq(2)
      end
    end

    context 'when ordering by parameterized dimension with parameters' do
      let(:query) do
        <<~QUERY
          query {
            #{query_type}(fullPath: "#{query_path}") {
              analytics {
                duoCodeSuggestions(
                  userId: ["#{user1.to_global_id}"]
                  language: ["ruby"]
                ) {
                  aggregated(
                    orderBy: [
                      { identifier: "timestamp", parameters: { granularity: "monthly" }, direction: DESC }
                    ]
                  ) {
                    nodes {
                      dimensions {
                        timestamp(granularity: "monthly")
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

      it 'orders results by parameterized dimension correctly' do
        post_graphql(query, current_user: current_user)

        expect(graphql_errors).to be_nil

        nodes = graphql_data.dig(query_type, 'analytics', 'duoCodeSuggestions', 'aggregated', 'nodes')

        expect(nodes[0]['dimensions']['timestamp']).to eq('2026-01-01')
        expect(nodes[1]['dimensions']['timestamp']).to eq('2025-12-01')
        expect(nodes[2]['dimensions']['timestamp']).to eq('2025-10-01')
      end
    end

    context 'when ordering by parameterized dimension without providing parameters' do
      let(:query) do
        <<~QUERY
          query {
            #{query_type}(fullPath: "#{query_path}") {
              analytics {
                duoCodeSuggestions(
                  userId: ["#{user1.to_global_id}"]
                ) {
                  aggregated(
                    orderBy: [
                      { identifier: "timestamp", direction: DESC }
                    ]
                  ) {
                    nodes {
                      dimensions {
                        timestamp(granularity: "monthly")
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
          [hash_including('message' => "the specified identifier is not available: 'timestamp'")]
        )
        nodes = graphql_data.dig(query_type, 'analytics', 'duoCodeSuggestions', 'aggregated', 'nodes')

        expect(nodes).to be_nil
      end
    end
  end

  context 'for group' do
    let(:query_type) { 'group' }
    let(:query_path) { group.full_path }

    it_behaves_like 'duoCodeSuggestions query'
  end

  context 'for project' do
    let(:query_type) { 'project' }
    let(:query_path) { project1.full_path }

    it_behaves_like 'duoCodeSuggestions query'
  end
end
