# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Analytics::PerformanceAnalytics::GroupLevel do
  let_it_be(:group) { create(:group) }
  let_it_be(:project) { create(:project, :repository, namespace: group) }
  let_it_be(:start_date) { 10.days.ago }
  let_it_be(:end_date) { 1.day.since }
  let_it_be(:user) { create(:user) }

  let(:issue) { create(:issue, project: project, created_at: 2.days.ago) }
  let(:note) { create(:note_on_issue, project: project, noteable: issue, created_at: 2.days.ago) }
  let(:mr) { create(:merge_request, source_project: project, created_at: 2.days.ago) }

  subject do
    described_class.new(group, options: {
      from: start_date,
      to: end_date,
      current_user: user
    })
  end

  before do
    push_event = create(:push_event, project: project, author: user)
    create(:push_event_payload, commit_title: "test", event: push_event)
    create(:event, :closed, project: project, target: issue, author: user)
    create(:event, :created, project: project, target: issue, author: user)
    create(:event, :created, project: project, target: mr, author: user)
    create(:event, :closed, project: project, target: mr, author: user)
    create(:event, :merged, project: project, target: mr, author: user)
    create(:event, :approved, project: project, target: mr, author: user)
    create(:event, :commented, project: project, target: note, author: user)
  end

  describe '#summary_data' do
    it 'return values' do
      expect(subject.summary_data).to eq({
        commits_pushed: 1,
        issues_closed: 1,
        merge_requests_merged: 1,
        commits_pushed_per_capita: 1
      })
    end
  end

  describe "#report_data" do
    it "return values" do
      data = subject.report_data
      expect(data.size).to eq(1)
      expect(data[0][:user][:username]).to eq(user.username)
      expect(data[0]).to include({
        commits_pushed: 1,
        issues_closed: 1,
        issues_created: 1,
        merge_requests_approved: 1,
        merge_requests_closed: 1,
        merge_requests_created: 1,
        merge_requests_merged: 1,
        notes_created: 1
      })
    end
  end

  describe '#leaderboard_data' do
    it "return values" do
      data = subject.leaderboard_data
      expect(data.size).to eq(1)
      expect(data[0][:user][:username]).to eq(user.username)
      expect(data[0][:rank]).to eq(1)
      expect(data[0][:value]).to eq(1)
    end
  end

  describe "#report_pagination" do
    it "return values" do
      data = subject.report_pagination
      expect(data[:per_page]).to eq(20)
      expect(data[:page]).to eq(1)
      expect(data[:next_page]).to be_nil
      expect(data[:prev_page]).to be_nil
      expect(data[:total]).to eq(1)
      expect(data[:total_pages]).to eq(1)
    end
  end

  describe "#report_csv" do
    it "return values" do
      data = subject.report_csv
      headers, rows = data.split("\n", 2)
      keys = Gitlab::Analytics::PerformanceAnalytics::GroupReport::COLUMN_KEYS
      expected_headers = Gitlab::Analytics::PerformanceAnalytics::GroupReport.new(group).csv_headers.values.join(",")
      expect(headers).to include(expected_headers)
      expect(rows).to include([["Total"] + ([1] * keys.length)].join(","))
      expect(rows).to include([[user.name] + ([1] * keys.length)].join(","))
    end
  end

  describe "#report_summary" do
    it "return values" do
      data = subject.report_summary
      expect(data).to include({
        commits_pushed: 1,
        issues_closed: 1,
        issues_created: 1,
        merge_requests_approved: 1,
        merge_requests_closed: 1,
        merge_requests_created: 1,
        merge_requests_merged: 1,
        notes_created: 1
      })
    end
  end
end
