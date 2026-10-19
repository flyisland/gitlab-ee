# frozen_string_literal: true

require 'spec_helper'

RSpec.describe API::PerformanceAnalytics::Metrics, feature_category: :team_planning do
  include JH::PerformanceAnalyticsHelper
  using RSpec::Parameterized::TableSyntax

  let_it_be(:group) { create(:group) }
  let_it_be(:project) { create(:project, :repository, group: group) }
  let_it_be(:maintainer) { create(:user) }
  let_it_be(:project_reporter) { create(:user) }
  let_it_be(:group_reporter) { create(:user) }
  let_it_be(:guest) { create(:user) }
  let_it_be(:date) { "2022-10-01" }
  let_it_be(:issue) { create(:issue) }
  let_it_be(:mr) { create(:merge_request) }
  let_it_be(:note) { create(:note) }

  let(:user) { maintainer }

  before_all do
    event = create(:push_event, project: project, created_at: date)
    create(:push_event_payload, event: event)
    create(:event, :created, target: issue, project: project, created_at: date)
    create(:event, :closed, target: issue, project: project, created_at: date)
    create(:event, :created, target: mr, project: project, created_at: date)
    create(:event, :approved, target: mr, project: project, created_at: date)
    create(:event, :merged, target: mr, project: project, created_at: date)
    create(:event, :closed, target: mr, project: project, created_at: date)
    create(:event, :commented, target: note, project: project, created_at: date)
    project.add_maintainer(maintainer)
    project.add_reporter(project_reporter)
    project.add_guest(guest)
    group.add_maintainer(maintainer)
    group.add_reporter(group_reporter)
    group.add_guest(guest)
  end

  before do
    stub_licensed_features(performance_analytics: true)
  end

  describe 'GET /projects/:id/performance_analytics/metrics' do
    subject { get api("/projects/#{project.id}/performance_analytics/metrics", user), params: params }

    before do
      create_commit('Message', project, user, 'master', commit_time: Date.parse(date).at_middle_of_day, count: 1)
    end

    context "with metrics" do
      where(:metric, :value) do
        :commits | 1
        :issues_created | 1
        :issues_closed | 1
        :merge_requests_created | 1
        :merge_requests_approved | 1
        :merge_requests_merged | 1
        :merge_requests_closed | 1
        :notes_created | 1
      end

      with_them do
        let(:params) { { metric: metric, start_date: date, end_date: date } }

        it 'returns data' do
          subject

          expect(response).to have_gitlab_http_status(:ok)
          expect(json_response).to match_array([{ 'date' => date, 'value' => value }])
        end
      end
    end

    context 'when user is guest' do
      let(:user) { guest }
      let(:params) { { metric: :issues_created } }

      it 'returns authorization error' do
        subject

        expect(response).to have_gitlab_http_status(:unauthorized)
        expect(json_response['message']).to eq('You do not have permission to access performance analytics metrics.')
      end
    end

    context 'when user is reporter' do
      let(:user) { project_reporter }
      let(:params) { { metric: :issues_created, start_date: date, end_date: date } }

      it 'returns data' do
        subject

        expect(response).to have_gitlab_http_status(:ok)
        expect(json_response).to match_array([{ 'date' => date, 'value' => 1 }])
      end
    end
  end

  describe 'GET /groups/:id/performance_analytics/metrics' do
    subject { get api("/groups/#{group.id}/performance_analytics/metrics", user), params: params }

    context "with metrics" do
      where(:metric, :value) do
        :pushes | 1
        :issues_created | 1
        :issues_closed | 1
        :merge_requests_created | 1
        :merge_requests_approved | 1
        :merge_requests_merged | 1
        :merge_requests_closed | 1
        :notes_created | 1
      end

      with_them do
        let(:params) { { metric: metric, start_date: date, end_date: date } }

        it 'returns data' do
          subject

          expect(response).to have_gitlab_http_status(:ok)
          expect(json_response).to match_array([{ 'date' => date, 'value' => value }])
        end
      end
    end

    context 'when user is guest' do
      let(:user) { guest }
      let(:params) { { metric: :issues_created } }

      it 'returns authorization error' do
        subject

        expect(response).to have_gitlab_http_status(:unauthorized)
        expect(json_response['message']).to eq('You do not have permission to access performance analytics metrics.')
      end
    end

    context 'when user is reporter' do
      let(:user) { group_reporter }
      let(:params) { { metric: :issues_created, start_date: date, end_date: date } }

      it 'returns data' do
        subject

        expect(response).to have_gitlab_http_status(:ok)
        expect(json_response).to match_array([{ 'date' => date, 'value' => 1 }])
      end
    end
  end
end
