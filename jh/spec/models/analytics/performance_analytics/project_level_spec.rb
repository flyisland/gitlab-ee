# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Analytics::PerformanceAnalytics::ProjectLevel do
  include JH::PerformanceAnalyticsHelper

  let(:group) { create(:group) }
  let(:project) { create(:project, :repository, namespace: group) }
  let(:user) { create(:user) }
  let(:start_date) { 1.day.ago }
  let(:end_date) { 1.day.since }
  let(:issue) { create(:issue, project: project) }
  let(:mr) { create(:merge_request, source_project: project) }
  let(:note) { create(:note_on_issue, project: project, noteable: issue) }

  subject do
    described_class.new(project, options: {
      from: start_date,
      to: end_date,
      current_user: user
    })
  end

  before do
    create_commit('Message', project, user, 'master')
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
        commits_pushed_per_capita: 1,
        issues_closed: 1,
        merge_requests_merged: 1
      })
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
      keys = Gitlab::Analytics::PerformanceAnalytics::ProjectReport::COLUMN_KEYS
      csv_headers = Gitlab::Analytics::PerformanceAnalytics::ProjectReport.new(project).send(:csv_headers)
      expect(headers).to include(csv_headers.values.join(","))
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
