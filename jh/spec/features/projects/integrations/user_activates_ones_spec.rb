# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'User activates ones' do
  include OnesClientHelper
  include_context 'project integration activation'

  let(:integration) { build(:ones_integration) }
  let(:graphql_url) { ones_url "team/#{integration.namespace}/items/graphql" }

  before do
    stub_licensed_features(ones_issues_integration: true)
    mock_fetch_project(url: graphql_url, project_uuid: integration.project_key, success: true)
  end

  it 'activates integration', :js do
    visit_project_integration('ONES')

    fill_in('ONES web URL', with: integration.url)
    fill_in('ONES team ID', with: integration.namespace)
    fill_in('ONES project ID', with: integration.project_key)
    fill_in('ONES user ID', with: integration.user_key)
    fill_in('ONES API token', with: integration.api_token)

    click_test_then_save_integration(expect_test_to_fail: false)

    expect(page).to have_content('ONES settings saved and active.')
  end
end
