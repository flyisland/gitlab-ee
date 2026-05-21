# frozen_string_literal: true

require 'spec_helper'

RSpec.describe API::Glql, feature_category: :custom_dashboards_foundation do
  let_it_be(:user) { create(:user) }
  let_it_be(:group) { create(:group, name: 'test-group-ee', developers: user) }
  let_it_be(:project) { create(:project, name: 'test-project', path: 'test-project', namespace: group) }

  let(:endpoint) { '/glql' }

  subject(:glql_request) { post api(endpoint, user), params: params }

  before do
    stub_licensed_features(ai_workflows: true)
  end

  describe 'POST /glql' do
    context 'with analytics mode for code suggestions' do
      let(:glql_yaml) do
        <<~YAML
          query: type = CodeSuggestion and language = "ruby"
          mode: "analytics"
          dimensions: "language"
          metrics: "totalCount, acceptanceRate"
          project: "#{project.full_path}"
        YAML
      end

      let(:params) { { glql_yaml: glql_yaml } }
      let(:analytics_scope_key) { 'project' }
      let(:analytics_nodes) { [] }
      let(:analytics_response) do
        {
          'data' => {
            analytics_scope_key => {
              'analytics' => {
                'duoCodeSuggestions' => {
                  'aggregated' => {
                    'nodes' => analytics_nodes,
                    'pageInfo' => { 'hasNextPage' => false, 'endCursor' => nil }
                  }
                }
              }
            }
          }
        }
      end

      context 'when feature flag is enabled' do
        let(:analytics_nodes) do
          [
            {
              'dimensions' => { 'language' => 'ruby' },
              'totalCount' => 20,
              'acceptanceRate' => 0.85
            }
          ]
        end

        before do
          stub_feature_flags(glql_code_suggestion_analytics_aggregation: true)
        end

        it 'returns analytics data in the correct format', :aggregate_failures do
          allow_next_instance_of(Analytics::Glql::QueryService) do |service|
            allow(service).to receive(:execute).and_return(
              data: analytics_response['data'],
              errors: nil,
              complexity_score: 15,
              duration_s: 0.5,
              timeout_occurred: false,
              rate_limited: false
            )
          end

          glql_request

          expect(response).to have_gitlab_http_status(:ok)
          expect(json_response['success']).to be(true)
          expect(json_response['data']['nodes']).to be_an(Array)
          expect(json_response['data']['nodes'].first).to include(
            'language' => 'ruby',
            'totalCount' => 20,
            'acceptanceRate' => 0.85
          )
          expect(json_response['data']['pageInfo']).to include('hasNextPage' => false)
        end
      end

      context 'when feature flag is disabled' do
        before do
          stub_feature_flags(glql_code_suggestion_analytics_aggregation: false)
        end

        it 'returns an error' do
          glql_request

          expect(response).to have_gitlab_http_status(:bad_request)
        end
      end

      context 'when feature flag is enabled for project' do
        before do
          stub_feature_flags(glql_code_suggestion_analytics_aggregation: project)
        end

        it 'allows the query for that project' do
          allow_next_instance_of(Analytics::Glql::QueryService) do |service|
            allow(service).to receive(:execute).and_return(
              data: analytics_response['data'],
              errors: nil,
              complexity_score: 10,
              duration_s: 0.3,
              timeout_occurred: false,
              rate_limited: false
            )
          end

          glql_request

          expect(response).to have_gitlab_http_status(:ok)
          expect(json_response['success']).to be(true)
        end
      end

      context 'when feature flag is enabled for group' do
        let(:analytics_scope_key) { 'group' }
        let(:glql_yaml) do
          <<~YAML
            query: type = CodeSuggestion and language = "ruby"
            mode: "analytics"
            dimensions: "language"
            metrics: "totalCount, acceptanceRate"
            group: "#{group.full_path}"
          YAML
        end

        before do
          stub_feature_flags(glql_code_suggestion_analytics_aggregation: group)
        end

        it 'allows the query for that group' do
          allow_next_instance_of(Analytics::Glql::QueryService) do |service|
            allow(service).to receive(:execute).and_return(
              data: analytics_response['data'],
              errors: nil,
              complexity_score: 10,
              duration_s: 0.3,
              timeout_occurred: false,
              rate_limited: false
            )
          end

          glql_request

          expect(response).to have_gitlab_http_status(:ok)
          expect(json_response['success']).to be(true)
        end
      end
    end
  end
end
