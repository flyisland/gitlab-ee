# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'ONES integration' do
  include OnesClientHelper

  let_it_be(:project) { create(:project, :private, has_external_issue_tracker: true) }
  let_it_be(:integration) { create(:ones_integration, project: project) }
  let_it_be(:user) { create(:user) }

  subject(:visit_issues) { visit project_integrations_ones_issues_path(project) }

  context 'with sign in' do
    before do
      sign_in(user)
    end

    context 'with project authority' do
      before_all do
        project.add_maintainer(user)
      end

      context 'with license', :js do
        let(:task_uuid) { SecureRandom.hex(8) }
        let(:graphql_url) { ones_url "team/#{integration.namespace}/items/graphql" }
        let(:message_url) { ones_url "team/#{integration.namespace}/task/#{task_uuid}/messages" }

        before do
          stub_licensed_features(ones_issues_integration: true)
        end

        context 'with successful request' do
          before do
            mock_fetch_issues(url: graphql_url, response_body: issues_response)
            mock_fetch_issue(url: graphql_url, response_body: issue_details_response)
            mock_fetch_message(
              url: message_url,
              team_uuid: integration.namespace,
              project_uuid: integration.project_key,
              task_uuid: task_uuid)
            mock_fetch_users(url: graphql_url, response_body: users_response)
          end

          it 'renders issues list page' do
            visit_issues
            expect(page).to have_title('ONES issues')
          end

          it 'renders issue details page' do
            visit project_integrations_ones_issue_path(project, "task-#{task_uuid}")
            expect(page).to \
              have_content(format(s_('ExternalIssueIntegration|This issue is synchronized with %{trackerName}'),
                trackerName: 'Ones'))
          end
        end

        context 'with request error' do
          before do
            WebMock.stub_request(:post, graphql_url).to_return(status: 500)
          end

          it 'shows friendly error message' do
            visit_issues
            page.within('#content-body') do
              expect(page).to have_content(
                s_('JH|Integration|An error occurred while requesting data from the third party service.'))
            end
          end
        end
      end

      context 'without license' do
        it 'redirects to not found' do
          stub_licensed_features(ones_issues_integration: false)
          visit_issues
          expect(page).to have_title('Not Found')
        end
      end
    end

    context 'without project authority' do
      it 'redirects to not found' do
        visit_issues
        expect(page).to have_title('Not Found')
      end
    end
  end

  context 'without sign in' do
    it 'redirects to login page' do
      visit_issues
      expect(page).to have_current_path(new_user_session_path)
    end
  end
end
