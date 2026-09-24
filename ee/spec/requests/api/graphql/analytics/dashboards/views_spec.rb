# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Query.project(id).customizableDashboards.views', feature_category: :product_analytics do
  include GraphqlHelpers

  let(:query) do
    <<~GRAPHQL
      query {
        project(fullPath: "#{project.full_path}") {
          customizableDashboards(slug: "#{slug}") {
            nodes {
              slug
              errors
              views {
                title
                panels {
                  nodes {
                    title
                    visualization {
                      slug
                      type
                    }
                  }
                }
              }
            }
          }
        }
      }
    GRAPHQL
  end

  before do
    stub_licensed_features(product_analytics: true, project_merge_request_analytics: false)
  end

  context 'when the dashboard defines views' do
    let_it_be(:project) { create(:project, :with_product_analytics_dashboard_with_views) }

    let(:slug) { 'dashboard_example_with_views' }

    context 'when current user is a developer' do
      let_it_be(:user) { create(:user, developer_of: project) }

      it 'returns each view with its own panels' do
        post_graphql(query, current_user: user)

        dashboard = graphql_data_at(:project, :customizable_dashboards, :nodes, 0)

        expect(dashboard['errors']).to be_nil
        expect(dashboard['views']).to eq([
          {
            'title' => 'Conversions',
            'panels' => { 'nodes' => [
              { 'title' => 'Overall Conversion Rate',
                'visualization' => { 'slug' => 'dora_line_chart', 'type' => 'LineChart' } }
            ] }
          },
          {
            'title' => 'Audience',
            'panels' => { 'nodes' => [
              { 'title' => 'Visitors by month',
                'visualization' => { 'slug' => 'dora_bar_chart', 'type' => 'BarChart' } },
              { 'title' => 'Visitors over time',
                'visualization' => { 'slug' => 'dora_line_chart', 'type' => 'LineChart' } }
            ] }
          }
        ])
      end
    end

    context 'when current user is a guest' do
      let_it_be(:user) { create(:user, guest_of: project) }

      it 'returns no dashboards' do
        post_graphql(query, current_user: user)

        expect(graphql_data_at(:project, :customizable_dashboards, :nodes)).to be_nil
      end
    end
  end

  context 'when the dashboard does not define views' do
    let_it_be(:project) { create(:project, :with_product_analytics_dashboard) }
    let_it_be(:user) { create(:user, developer_of: project) }

    let(:slug) { 'dashboard_example_1' }

    it 'returns no views' do
      post_graphql(query, current_user: user)

      expect(graphql_data_at(:project, :customizable_dashboards, :nodes, 0, :views)).to eq([])
    end
  end
end
