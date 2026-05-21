# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Finished Pipelines Using DAP (GraphQL fixtures)', :click_house,
  feature_category: :value_stream_management do
  include ApiHelpers
  include JavaScriptFixturesHelpers
  include GraphqlHelpers
  include ClickHouseHelpers

  let_it_be(:group) { create(:group, name: 'cool-group') }
  let_it_be(:project) { create(:project, group: group) }
  let_it_be(:current_user) { create(:user, reporter_of: group) }

  # Dates are fixed to match the globally pinned Jest fake date (2020-07-06).
  let(:start_date) { '2020-01-06T00:00:00Z' }
  let(:end_date) { '2020-07-06T00:00:00Z' }

  before do
    stub_licensed_features(ai_analytics: true)
    allow(Gitlab::ClickHouse).to receive(:globally_enabled_for_analytics?).and_return(true)
    allow(Ability).to receive(:allowed?).and_call_original
    allow(Ability).to receive(:allowed?)
      .with(current_user, :read_ci_cd_analytics, anything)
      .and_return(true)
  end

  describe GraphQL::Query, type: :request do
    query_path = 'analytics/dashboards/ai_impact/graphql/finished_pipelines_using_dap.query.graphql'

    def post_finished_pipelines_query(query_path, group, current_user, start_date, end_date)
      query = get_graphql_query_as_string(query_path, ee: true)
      post_graphql(query, current_user: current_user,
        variables: {
          fullPath: group.full_path,
          startDate: start_date,
          endDate: end_date
        })
    end

    def pipeline_at(source, month)
      { source: source, started_at: Time.utc(2020, month, 6) }
    end

    def insert_pipelines(project, pipelines)
      clickhouse_fixture(:ci_finished_pipelines, pipelines.map.with_index(1) do |p, id|
        {
          id: id,
          path: project.project_namespace.traversal_path,
          source: p[:source],
          status: 'success',
          duration: 60,
          started_at: p[:started_at],
          committed_at: p[:started_at],
          created_at: p[:started_at],
          finished_at: p[:started_at] + 60.seconds
        }
      end)
    end

    context 'with pipelines data' do
      before do
        insert_pipelines(project, [
          pipeline_at('duo_workflow', 2),
          pipeline_at('push',         2),
          pipeline_at('push',         2),
          pipeline_at('duo_workflow', 3),
          pipeline_at('push',         3),
          pipeline_at('duo_workflow', 4),
          pipeline_at('duo_workflow', 4),
          pipeline_at('push',         4),
          pipeline_at('duo_workflow', 5),
          pipeline_at('push',         5),
          pipeline_at('push',         5),
          pipeline_at('duo_workflow', 6),
          pipeline_at('duo_workflow', 6),
          pipeline_at('push',         6),
          pipeline_at('duo_workflow', 7),
          pipeline_at('push',         7)
        ])
      end

      it "ee/graphql/#{query_path}.json" do
        post_finished_pipelines_query(query_path, group, current_user, start_date, end_date)
        expect_graphql_errors_to_be_empty
      end
    end

    context 'with gaps in data' do
      before do
        insert_pipelines(project, [
          pipeline_at('push',         2),
          # Mar 2020 intentionally has no pipelines
          pipeline_at('duo_workflow', 4),
          pipeline_at('duo_workflow', 5),
          pipeline_at('push',         5),
          pipeline_at('push',         6),
          pipeline_at('push',         7)
        ])
      end

      it "ee/graphql/#{query_path}.gaps.json" do
        post_finished_pipelines_query(query_path, group, current_user, start_date, end_date)
        expect_graphql_errors_to_be_empty
      end
    end

    context 'with no pipelines data' do
      it "ee/graphql/#{query_path}.empty.json" do
        post_finished_pipelines_query(query_path, group, current_user, start_date, end_date)
        expect_graphql_errors_to_be_empty
      end
    end
  end
end
