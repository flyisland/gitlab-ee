# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Gitlab::Ones::Query do
  include OnesClientHelper

  let_it_be(:integration) { create(:ones_integration) }

  let(:graphql_url) { ones_url "team/#{integration.namespace}/items/graphql" }
  let(:params) { {} }
  let(:query) { described_class.new(integration, ActionController::Parameters.new(params)) }

  describe '#issues' do
    let(:response_body) { issues_response }

    before do
      mock_fetch_issues(url: graphql_url, response_body: response_body)
    end

    subject(:issues) { query.issues }

    # expect_query_params { |request_body_json| checking }
    def expect_query_params(repeat = 1)
      issues
      expect(a_request(:post, graphql_url).with do |req|
        yield(Gitlab::Json.parse(req.body))
      end).to have_been_made.times(repeat)
    end

    context 'with default params' do
      it 'shows issues with pagination' do
        expected_per_page = Gitlab::Ones::Query::ISSUES_DEFAULT_LIMIT
        expected_total_page = (1.0 * issues_total_account / expected_per_page).ceil

        expect(issues.is_a?(Kaminari::PaginatableArray)).to be true
        expect(issues.page.limit_value).to eq expected_per_page
        expect(issues.page.total_pages).to eq expected_total_page
      end
    end

    context 'with pagination params' do
      let(:params) { { page: 3, limit: 10 } }

      it 'queries issues with pagination' do
        expect_query_params(2) do |body|
          body.dig('variables', 'count') == params[:limit]
        end
      end
    end

    context 'with search params' do
      let(:params) { { search: 'search keyword' } }

      it 'queries issues with search' do
        expect_query_params do |body|
          body.dig('variables', 'search', 'keyword') == params[:search]
        end
      end
    end

    context 'with order params' do
      where(:sort_params, :ones_key, :ones_order) do
        [
          %w[CREATED_ASC createTime ASC],
          %w[CREATED_DESC createTime DESC],
          %w[UPDATED_ASC serverUpdateStamp ASC],
          %w[UPDATED_DESC serverUpdateStamp DESC]
        ]
      end

      with_them do
        let(:params) { { sort: sort_params } }

        it 'queries issues with order' do
          expect_query_params do |body|
            body.dig('variables', 'orderBy', ones_key) == ones_order
          end
        end
      end
    end

    Gitlab::Ones::Query::STATUSES.each do |status_params, ones_status|
      context 'with status params' do
        let(:params) { { state: status_params } }

        it "queries issues with #{status_params} status" do
          expect_query_params do |body|
            body.dig('variables', 'filterGroup', 0, 'statusCategory_in').sort == ones_status.sort
          end
        end
      end
    end
  end

  describe '#issue' do
    let(:task_uuid) { SecureRandom.hex(8) }
    let(:message_url) { ones_url "team/#{integration.namespace}/task/#{task_uuid}/messages" }
    let(:params) { { id: "task-#{task_uuid}" } }
    let(:response_body) { issue_details_response(task_uuid: task_uuid) }
    let(:user_uuid_list) { Array.new(2) { SecureRandom.hex(4) } }

    before do
      mock_fetch_issue(url: graphql_url, response_body: response_body)
      mock_fetch_message(
        url: message_url,
        team_uuid: integration.namespace,
        project_uuid: integration.project_key,
        task_uuid: task_uuid)
      mock_fetch_users(url: graphql_url, response_body: users_response(user_uuid_list))
    end

    subject(:issue) { query.issue }

    it 'shows issue details' do
      expect(issue).to have_key('description')
      expect(issue).to have_key('comments')
    end
  end
end
