# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Integrations::OnesSerializers::IssueDetailSerializer do
  include Gitlab::Routing.url_helpers
  include OnesClientHelper

  let_it_be(:project) { create(:project, :private, has_external_issue_tracker: true) }
  let_it_be(:integration) { create(:ones_integration, project: project) }

  let(:graphql_url) { ones_url "team/#{integration.namespace}/items/graphql" }
  let(:task_uuid) { SecureRandom.hex(8) }
  let(:message_url) { ones_url "team/#{integration.namespace}/task/#{task_uuid}/messages" }
  let(:params) { { id: "task-#{task_uuid}" } }
  let(:query) { ::Gitlab::Ones::Query.new(integration, ActionController::Parameters.new(params)) }
  let(:response_body) { issue_details_response(task_uuid: task_uuid) }
  let(:user_uuid_list) { Array.new(2) { SecureRandom.hex(4) } }
  let(:resource) { query.issue }

  before do
    stub_licensed_features(ones_issues_integration: true)

    mock_fetch_issue(url: graphql_url, response_body: response_body)
    mock_fetch_message(
      url: message_url,
      team_uuid: integration.namespace,
      project_uuid: integration.project_key,
      task_uuid: task_uuid)
    mock_fetch_users(url: graphql_url, response_body: users_response(user_uuid_list))
  end

  subject(:entity) { described_class.new.represent(resource, project: integration.project) }

  it_behaves_like 'renders ones basic issue fields'

  it 'renders details' do
    expect(entity[:due_date]).to eq(Time.at(1600000000).strftime("%F"))
    expect(entity[:description_html]).to eq('<h1>issue description details</h1>')
    expect(entity[:comments]).to be_an_instance_of(Array)
  end
end
