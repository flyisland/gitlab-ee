# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Duo Pipelines Rate (GraphQL fixtures)', :click_house,
  feature_category: :value_stream_management do
  include ApiHelpers
  include JavaScriptFixturesHelpers
  include GraphqlHelpers
  include ClickHouseHelpers

  let_it_be(:group) { create(:group, name: 'cool-group') }
  let_it_be(:project) { create(:project, group: group) }
  let_it_be(:current_user) { create(:user, reporter_of: group) }

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
    query_path = 'analytics/dashboards/ai_impact/graphql/duo_pipelines_rate.query.graphql'

    def post_duo_pipelines_rate_query(query_path, group, current_user, start_date, end_date)
      query = get_graphql_query_as_string(query_path)
      post_graphql(query, current_user: current_user,
        variables: {
          fullPath: group.full_path,
          startDate: start_date,
          endDate: end_date
        })
    end

    def insert_pipelines(project, sources)
      clickhouse_fixture(:ci_finished_pipelines, sources.map.with_index(1) do |source, id|
        started_at = Time.utc(2020, 2, 6)
        {
          id: id,
          path: project.project_namespace.traversal_path,
          source: source,
          status: 'success',
          duration: 60,
          started_at: started_at,
          committed_at: started_at,
          created_at: started_at,
          finished_at: started_at + 60.seconds
        }
      end)
    end

    context 'with pipelines data' do
      before do
        # 2 Duo pipelines out of 10 total (mixed sources) => 20%
        insert_pipelines(project, %w[duo_workflow duo_workflow push web api schedule trigger push web api])
      end

      it "ee/graphql/#{query_path}.json" do
        post_duo_pipelines_rate_query(query_path, group, current_user, start_date, end_date)
        expect_graphql_errors_to_be_empty
      end
    end

    context 'with previous period pipelines data' do
      before do
        # 1 Duo pipeline out of 10 total (mixed sources) => 10%
        insert_pipelines(project, %w[duo_workflow push web api schedule trigger push web api web])
      end

      it "ee/graphql/#{query_path}.previous.json" do
        post_duo_pipelines_rate_query(query_path, group, current_user, start_date, end_date)
        expect_graphql_errors_to_be_empty
      end
    end

    context 'with no pipelines data' do
      it "ee/graphql/#{query_path}.empty.json" do
        post_duo_pipelines_rate_query(query_path, group, current_user, start_date, end_date)
        expect_graphql_errors_to_be_empty
      end
    end
  end
end
