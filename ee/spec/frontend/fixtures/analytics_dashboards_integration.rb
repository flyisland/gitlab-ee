# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Explore analytics dashboards Integration (GraphQL fixtures)', type: :request,
  feature_category: :custom_dashboards_foundation do
  include ApiHelpers
  include GraphqlHelpers
  include JavaScriptFixturesHelpers

  let_it_be(:organization) { create(:organization) }
  let_it_be(:user) { create(:user, organizations: [organization]) }
  let_it_be(:other_user) { create(:user, organizations: [organization]) }
  let_it_be(:group) { create(:group, organization: organization, reporters: user) }

  let(:graphql_path) { 'explore/analytics_dashboards/graphql/' }
  let(:dashboard_slug) { 'dap_impact' }

  base_output_path = 'graphql/explore/analytics_dashboards/integration/'

  before do
    stub_current_organization(organization)
  end

  def post_system_dashboard_query
    query = get_graphql_query_as_string("#{graphql_path}get_system_dashboard.query.graphql")

    post_graphql(query, current_user: user, variables: { slug: dashboard_slug })
  end

  def system_dashboard
    graphql_data_at(:custom_system_dashboard)
  end

  def expect_dashboard_not_available
    expect(system_dashboard).to be_nil
    expect_graphql_errors_to_include(Gitlab::Graphql::Authorize::AuthorizeResource::RESOURCE_ACCESS_ERROR)
  end

  describe GraphQL::Query do
    it "#{base_output_path}get_system_dashboard.query.graphql.json" do
      post_system_dashboard_query

      expect_graphql_errors_to_be_empty
      expect(system_dashboard).to include('slug' => dashboard_slug)
    end

    it "#{base_output_path}get_system_dashboard_feature_flag_disabled.query.graphql.json" do
      stub_feature_flags(dap_impact_v1: false)

      post_system_dashboard_query

      expect_dashboard_not_available
    end

    # The flag is user-actored, so a percentage rollout hides the dashboard from the users it
    # has not reached while everyone else on the instance can see it.
    it "#{base_output_path}get_system_dashboard_not_in_rollout.query.graphql.json" do
      stub_feature_flags(dap_impact_v1: other_user)

      post_system_dashboard_query

      expect_dashboard_not_available
    end

    # A user with no visit history, so the scope picker derives no default scope and the
    # dashboard waits for a group or project to be picked.
    it "#{base_output_path}get_analytics_dashboard_frecent_groups.query.graphql.json" do
      query = get_graphql_query_as_string("#{graphql_path}get_frecent_groups.query.graphql")

      post_graphql(query, current_user: user)

      expect_graphql_errors_to_be_empty
      expect(graphql_data_at(:frecent_groups)).to be_empty
    end

    it "#{base_output_path}get_analytics_dashboard_top_level_groups.query.graphql.json" do
      query = get_graphql_query_as_string("#{graphql_path}get_top_level_groups.query.graphql")

      post_graphql(query, current_user: user, variables: { after: nil })

      expect_graphql_errors_to_be_empty
      expect(graphql_data_at(:groups, :nodes)).to contain_exactly(a_hash_including('fullPath' => group.full_path))
    end
  end
end
