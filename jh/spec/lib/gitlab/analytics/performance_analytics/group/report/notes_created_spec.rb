# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Gitlab::Analytics::PerformanceAnalytics::Group::Report::NotesCreated do
  let_it_be(:group) { create(:group) }
  let_it_be(:project) { create(:project, :repository, namespace: group) }
  let_it_be(:start_date) { 10.days.ago }
  let_it_be(:end_date) { 1.day.since }
  let_it_be(:user) { create(:user) }

  let_it_be(:issue) { create(:issue, project: project, created_at: 2.days.ago) }
  let_it_be(:note) { create(:note_on_issue, project: project, noteable: issue, created_at: 2.days.ago) }

  subject do
    described_class.new(group, options: {
      from: start_date,
      to: end_date,
      current_user: user
    })
  end

  before_all do
    group.add_owner(user)
    create(:event, :commented, project: project, target: note, author: user)
    create(:event, :updated, project: project, target: note, author: user)
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
