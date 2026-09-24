# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Query.vulnerabilities.issueLinks', feature_category: :vulnerability_management do
  include GraphqlHelpers

  let_it_be(:project) { create(:project) }
  let_it_be(:user) { create(:user, security_dashboard_projects: [project]) }
  let_it_be(:vulnerability) { create(:vulnerability, :with_finding, project: project) }

  before_all do
    project.add_developer(user)
  end

  before do
    stub_licensed_features(security_dashboard: true)
  end

  describe 'loading issue links in batch' do
    before do
      create(:organization)
      create(:vulnerability, :with_finding, project: project)
    end

    it 'does not cause N+1 query issue' do
      query_issue_links
      expect { query_issue_links }.not_to exceed_query_limit(36)
    end
  end

  def query_issue_links(link_type = nil)
    query = graphql_query_for('vulnerabilities', {}, query_graphql_field('nodes', {}, create_fields(link_type)))
    post_graphql(query, current_user: user)
  end

  def create_fields(link_type)
    if link_type.nil?
      <<~QUERY
        issueLinks {
          nodes {
            id
          }
        }
      QUERY
    else
      <<~QUERY
        issueLinks (linkType: #{link_type}) {
          nodes {
            id
          }
        }
      QUERY
    end
  end
end
