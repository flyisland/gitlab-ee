# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Gitlab::Analytics::PerformanceAnalytics::Group::Report::CommitsPushed do
  let_it_be(:group) { create(:group) }
  let_it_be(:project) { create(:project, :repository, namespace: group) }
  let_it_be(:start_date) { 10.days.ago }
  let_it_be(:end_date) { 1.day.since }
  let_it_be(:user) { create(:user) }

  subject do
    described_class.new(group, options: {
      from: start_date,
      to: end_date,
      current_user: user
    })
  end

  before_all do
    group.add_owner(user)
    push_event = create(:push_event, project: project, author: user)
    create(:push_event_payload, commit_title: "test", event: push_event)
  end

  describe '#query_count' do
    it 'return values' do
      data = subject.query_count
      expect(data).to eq([[user.id, 1]])
    end
  end

  describe '#query_summary' do
    it 'return values' do
      data = subject.query_summary
      expect(data).to eq(1)
    end
  end
end
