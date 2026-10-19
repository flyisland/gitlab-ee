# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Dashboard::ApplicationController do
  describe 'GET all dashboard pages' do
    it_behaves_like 'SaaS landing page redirections', :dashboard_groups_path
    it_behaves_like 'SaaS landing page redirections', :dashboard_labels_path
    it_behaves_like 'SaaS landing page redirections', :dashboard_milestones_path
    it_behaves_like 'SaaS landing page redirections', :dashboard_projects_path
    it_behaves_like 'SaaS landing page redirections', :dashboard_snippets_path
    it_behaves_like 'SaaS landing page redirections', :dashboard_todos_path
  end
end
