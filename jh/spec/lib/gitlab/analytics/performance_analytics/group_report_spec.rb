# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Gitlab::Analytics::PerformanceAnalytics::GroupReport do
  let_it_be(:group) { create(:group) }
  let_it_be(:project) { create(:project, :repository, namespace: group) }
  let_it_be(:another_project) { create(:project, :repository, namespace: group) }
  let_it_be(:start_date) { 10.days.ago }
  let_it_be(:end_date) { 1.day.since }
  let_it_be(:user) { create(:user, name: "b_name") }
  let_it_be(:another_user) { create(:user, name: "a_name") }

  let(:issue) { create(:issue, project: project, created_at: 2.days.ago) }
  let(:mr) { create(:merge_request, source_project: project, created_at: 2.days.ago) }
  let(:note) { create(:note_on_issue, project: project, noteable: issue, created_at: 2.days.ago) }

  let(:sort) { "username" }

  subject do
    described_class.new(group, options: {
      from: start_date,
      to: end_date,
      current_user: user,
      sort: sort,
      direction: "desc"
    })
  end

  before do
    push_event = create(:push_event, project: project, author: user)
    another_push_event = create(:push_event, project: project, author: user)
    create(:push_event_payload, commit_title: "test", event: push_event)
    create(:push_event_payload, commit_title: "test", event: another_push_event)
    create(:event, :closed, project: project, target: issue, author: user)
    create(:event, :created, project: project, target: issue, author: user)
    create(:event, :created, project: project, target: mr, author: user)
    create(:event, :closed, project: project, target: mr, author: user)
    create(:event, :merged, project: project, target: mr, author: user)
    create(:event, :approved, project: project, target: mr, author: user)
    create(:event, :commented, project: project, target: note, author: user)

    another_push_event = create(:push_event, project: another_project, author: another_user)
    create(:push_event_payload, commit_title: "test", event: another_push_event)
    create(:event, :closed, project: another_project, target: issue, author: another_user)
    create(:event, :created, project: another_project, target: issue, author: another_user)
    create(:event, :created, project: another_project, target: issue, author: another_user)
    create(:event, :created, project: another_project, target: mr, author: another_user)
    create(:event, :closed, project: another_project, target: mr, author: another_user)
    create(:event, :merged, project: another_project, target: mr, author: another_user)
    create(:event, :approved, project: another_project, target: mr, author: another_user)
    create(:event, :commented, project: another_project, target: note, author: another_user)
  end

  describe '#data' do
    context "when sort by username" do
      it "return values" do
        data = subject.data
        expect(data.size).to eq(2)
        expect(data[0][:user][:username]).to eq(user.username)
        expect(data[0]).to include({
          commits_pushed: 2,
          issues_closed: 1,
          issues_created: 1,
          merge_requests_approved: 1,
          merge_requests_closed: 1,
          merge_requests_created: 1,
          merge_requests_merged: 1,
          notes_created: 1
        })
        expect(data[1][:user][:username]).to eq(another_user.username)
        expect(data[1]).to include({
          commits_pushed: 1,
          issues_closed: 1,
          issues_created: 2,
          merge_requests_approved: 1,
          merge_requests_closed: 1,
          merge_requests_created: 1,
          merge_requests_merged: 1,
          notes_created: 1
        })
      end
    end

    context "when sort by issues_created" do
      let(:sort) { "issues_created" }

      it "return values" do
        data = subject.data
        expect(data.size).to eq(2)
        expect(data[0][:user][:username]).to eq(another_user.username)
        expect(data[0]).to include({
          issues_created: 2
        })
        expect(data[1][:user][:username]).to eq(user.username)
        expect(data[1]).to include({
          notes_created: 1
        })
      end
    end
  end

  describe '#summary' do
    it "return summary" do
      data = subject.summary
      expect(data).to include({
        commits_pushed: 3,
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
