# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Gitlab::Analytics::PerformanceAnalytics::ProjectReport do
  include JH::PerformanceAnalyticsHelper

  let(:group) { create(:group) }
  let(:project) { create(:project, :repository, namespace: group) }
  let(:start_date) { 1.day.ago }
  let(:end_date) { 1.day.since }
  let(:user) { create(:user) }
  let(:another_user) { create(:user) }
  let(:issue) { create(:issue, project: project) }
  let(:mr) { create(:merge_request, source_project: project) }
  let(:note) { create(:note_on_issue, project: project, noteable: issue) }

  subject do
    described_class.new(project, options: {
      from: start_date,
      to: end_date,
      current_user: user,
      sort: "issues_created",
      direction: "desc"
    })
  end

  before do
    create_commit('Message', project, user, 'master', count: 1)
    create(:event, :closed, project: project, target: issue, author: user)
    create(:event, :created, project: project, target: issue, author: user)
    create(:event, :created, project: project, target: mr, author: user)
    create(:event, :closed, project: project, target: mr, author: user)
    create(:event, :merged, project: project, target: mr, author: user)
    create(:event, :approved, project: project, target: mr, author: user)
    create(:event, :commented, project: project, target: note, author: user)

    create_commit('Message', project, another_user, 'master', count: 1)
    create(:event, :closed, project: project, target: issue, author: another_user)
    create(:event, :created, project: project, target: issue, author: another_user)
    create(:event, :created, project: project, target: issue, author: another_user)
    create(:event, :created, project: project, target: mr, author: another_user)
    create(:event, :closed, project: project, target: mr, author: another_user)
    create(:event, :merged, project: project, target: mr, author: another_user)
    create(:event, :approved, project: project, target: mr, author: another_user)
    create(:event, :commented, project: project, target: note, author: another_user)
  end

  describe '#data' do
    it 'return values' do
      data = subject.data
      expect(data.size).to eq(2)
      expect(data[0][:user][:username]).to eq(another_user.username)
      expect(data[0]).to include({
        commits_pushed: 1,
        issues_closed: 1,
        issues_created: 2,
        merge_requests_approved: 1,
        merge_requests_closed: 1,
        merge_requests_created: 1,
        merge_requests_merged: 1,
        notes_created: 1
      })
      expect(data[1][:user][:username]).to eq(user.username)
      expect(data[1]).to include({
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

  describe '#summary' do
    it "return summary" do
      data = subject.summary
      expect(data).to include({
        commits_pushed: 2,
        issues_closed: 2,
        issues_created: 3,
        merge_requests_approved: 2,
        merge_requests_closed: 2,
        merge_requests_created: 2,
        merge_requests_merged: 2,
        notes_created: 2
      })
    end
  end
end
