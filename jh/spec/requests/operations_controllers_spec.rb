# frozen_string_literal: true

require 'spec_helper'

RSpec.describe OperationsController do
  describe 'GET #index' do
    it_behaves_like 'SaaS landing page redirections', :operations_path
  end

  describe 'GET #environments' do
    it_behaves_like 'SaaS landing page redirections', :operations_environments_path
  end
end
