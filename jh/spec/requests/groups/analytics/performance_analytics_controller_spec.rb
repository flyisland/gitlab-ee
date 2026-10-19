# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Groups::Analytics::PerformanceAnalyticsController do
  let_it_be(:group) { create(:group) }
  let_it_be(:user) { create(:user) }

  shared_examples 'responds with 404 status' do
    it 'returns 404' do
      subject

      expect(response).to have_gitlab_http_status(:not_found)
    end
  end

  shared_examples 'responds with 200 status' do
    it 'renders the index template' do
      subject

      expect(response).to have_gitlab_http_status(:ok)
      expect(response).to render_template(:index)
    end
  end

  before_all do
    group.add_reporter(user)
  end

  before do
    stub_licensed_features(performance_analytics: true)
    login_as(user)
  end

  describe 'GET #index' do
    subject do
      get group_analytics_performance_analytics_path(group)
      response
    end

    context 'with performance analytics feature flag enabled' do
      it_behaves_like 'responds with 200 status'
    end

    context 'with performance analytics feature flag disabled' do
      before do
        stub_feature_flags(performance_analytics: false)
      end

      it_behaves_like 'responds with 404 status'
    end
  end

  context "for api" do
    let(:params) { { start_date: '2022-04-01', end_date: '2022-05-01', page: "1" } }
    let(:options) do
      {
        from: Date.parse(params[:start_date]).beginning_of_day,
        to: Date.parse(params[:end_date]).end_of_day
      }
    end

    shared_examples 'api endpoint' do
      it 'succeeds' do
        expect(Analytics::PerformanceAnalytics::GroupLevel).to receive(:new).with(
          group, options: hash_including(options)
        ).and_call_original

        subject

        expect(response).to be_successful
      end

      context "when auth with private token" do
        let(:access_token) { create(:personal_access_token, user: user) }
        let(:params) { { start_date: '2022-04-01', end_date: '2022-05-01', private_token: access_token.token } }

        it "succeeds" do
          logout(:user)
          subject
          expect(response).to be_successful
        end
      end

      context "when auth without private token" do
        let(:params) { { start_date: '2022-04-01', end_date: '2022-05-01', private_token: nil } }

        it "failed" do
          logout(:user)
          subject
          expect(response).to have_gitlab_http_status(:unauthorized)
        end
      end
    end

    describe 'GET "summary"' do
      subject { get summary_group_analytics_performance_analytics_path(group, format: :json, params: params) }

      it_behaves_like 'api endpoint'
    end

    describe 'GET "leaderboard"' do
      subject { get leaderboard_group_analytics_performance_analytics_path(group, format: :json, params: params) }

      it_behaves_like 'api endpoint'
    end

    describe 'GET "report"' do
      context "with json format" do
        subject { get report_group_analytics_performance_analytics_path(group, format: :json, params: params) }

        it_behaves_like 'api endpoint'
      end

      context "with csv format" do
        subject { get report_group_analytics_performance_analytics_path(group, format: :csv, params: params) }

        it_behaves_like 'api endpoint'
      end
    end

    describe 'GET "report_summary' do
      context "with json format" do
        subject { get report_summary_group_analytics_performance_analytics_path(group, format: :json, params: params) }

        it_behaves_like 'api endpoint'
      end
    end
  end
end
