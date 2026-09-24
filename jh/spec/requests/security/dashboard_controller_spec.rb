# frozen_string_literal: true

require 'spec_helper'

RSpec.describe DashboardController do
  describe 'GET #index' do
    it_behaves_like 'SaaS landing page redirections', :security_dashboard_path
  end
end
