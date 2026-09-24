# frozen_string_literal: true

require 'spec_helper'

RSpec.describe PerformanceAnalytics::GroupMetricsService, feature_category: :plan_provisioning do
  using RSpec::Parameterized::TableSyntax

  let_it_be(:group) { create(:group) }
  let_it_be(:project) { create(:project, group: group) }
  let_it_be(:user)  { create(:user) }
  let_it_be(:issue) { create(:issue) }
  let_it_be(:mr) { create(:merge_request) }
  let_it_be(:note) { create(:note) }

  let(:date) { "2022-10-01" }
  let(:params) { { metric: "issues_closed", start_date: date, end_date: date } }

  subject { described_class.new(group: group, current_user: user, params: params) }

  before_all do
    group.add_maintainer(user)
  end

  before do
    stub_licensed_features(performance_analytics: true)
  end

  it_behaves_like 'performance analytics metrics service validate'

  describe "#execute" do
    context "with metric" do
      before do
        event = create(:push_event, project: project, created_at: date)
        create(:push_event_payload, event: event)
        create(:event, :created, target: issue, project: project, created_at: date)
        create(:event, :closed, target: issue, project: project, created_at: date)
        create(:event, :created, target: mr, project: project, created_at: date)
        create(:event, :approved, target: mr, project: project, created_at: date)
        create(:event, :merged, target: mr, project: project, created_at: date)
        create(:event, :closed, target: mr, project: project, created_at: date)
        create(:event, :commented, target: note, project: project, created_at: date)
      end

      where(:metric, :value) do
        "pushes" | 1
        "issues_created" | 1
        "issues_closed" | 1
        "merge_requests_created" | 1
        "merge_requests_approved" | 1
        "merge_requests_merged" | 1
        "merge_requests_closed" | 1
        "notes_created" | 1
      end

      with_them do
        let(:params) { { metric: metric, start_date: date, end_date: date } }

        it "return data" do
          expect(subject.execute).to eq({ data: [{ "date" => date, "value" => 1 }], status: :success })
        end
      end
    end

    context "with all interval" do
      let(:params) do
        { metric: "issues_created", interval: "all", start_date: "2022-09-01", end_date: "2022-09-02" }
      end

      before do
        create(:event, :created, target: issue, project: project, created_at: "2022-09-01")
        create(:event, :created, target: issue, project: project, created_at: "2022-09-02")
      end

      it "return currect data" do
        expect(subject.execute).to eq({ data: { "value" => 2 }, status: :success })
      end
    end

    context "with monthly interval" do
      let(:params) do
        { metric: "issues_created", interval: "monthly", start_date: "2022-09-01", end_date: "2022-10-01" }
      end

      before do
        create(:event, :created, target: issue, project: project, created_at: "2022-09-01")
        create(:event, :created, target: issue, project: project, created_at: "2022-10-01")
      end

      it "return currect data" do
        expect(subject.execute).to eq(
          {
            data: [
              { "date" => "2022-09", "value" => 1 },
              { "date" => "2022-10", "value" => 1 }
            ], status: :success
          })
      end
    end

    context "with daily interval" do
      let(:params) { { metric: "issues_created", interval: "daily", start_date: "2022-09-01", end_date: "2022-09-02" } }

      before do
        create(:event, :created, target: issue, project: project, created_at: "2022-09-01")
        create(:event, :created, target: issue, project: project, created_at: "2022-09-02")
      end

      it "return currect data" do
        expect(subject.execute).to eq(
          {
            data: [
              { "date" => "2022-09-01", "value" => 1 },
              { "date" => "2022-09-02", "value" => 1 }
            ], status: :success
          })
      end
    end

    context "with date range" do
      let(:params) { { metric: "issues_created", start_date: "2022-09-01", end_date: "2022-09-02" } }

      before do
        create(:event, :created, target: issue, project: project, created_at: "2022-09-01")
        create(:event, :created, target: issue, project: project, created_at: "2022-010-01")
      end

      it "return correct data" do
        expect(subject.execute).to eq(
          {
            data: [
              { "date" => "2022-09-01", "value" => 1 },
              { "date" => "2022-09-02", "value" => 0 }
            ], status: :success
          })
      end
    end

    context "with project_ids" do
      let(:another_project) { create(:project, group: group) }
      let(:params) { { metric: "issues_created", project_ids: [another_project.id], start_date: date, end_date: date } }

      before do
        create(:event, :created, target: issue, project: another_project, created_at: date)
        create(:event, :created, target: issue, project: project, created_at: date)
      end

      it "return correct data" do
        expect(subject.execute).to eq({ data: [{ "date" => date, "value" => 1 }], status: :success })
      end
    end

    context "with user_ids" do
      let(:another_user) { create(:user) }
      let(:params) { { metric: "issues_created", user_ids: [another_user.id], start_date: date, end_date: date } }

      before do
        create(:event, :created, target: issue, project: project, author: another_user, created_at: date)
        create(:event, :created, target: issue, project: project, author: user, created_at: date)
      end

      it "return correct data" do
        expect(subject.execute).to eq({ data: [{ "date" => date, "value" => 1 }], status: :success })
      end
    end
  end
end
