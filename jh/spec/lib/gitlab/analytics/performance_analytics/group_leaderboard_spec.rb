# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Gitlab::Analytics::PerformanceAnalytics::GroupLeaderboard do
  let_it_be(:group) { create(:group) }
  let_it_be(:project) { create(:project, :repository, namespace: group) }
  let_it_be(:start_date) { 10.days.ago }
  let_it_be(:end_date) { 1.day.since }
  let_it_be(:user) { create(:user) }

  let(:issue) { create(:issue, project: project, created_at: 2.days.ago) }
  let(:mr) { create(:merge_request, source_project: project, created_at: 2.days.ago) }

  subject do
    described_class.new(group, options: {
      leaderboard_type: "commits_pushed",
      from: start_date,
      to: end_date,
      current_user: user
    })
  end

  before do
    push_event = create(:push_event, project: project, author: user)
    create(:push_event_payload, commit_title: "test", event: push_event)
    create(:event, :closed, project: project, target: issue, author: user)
    create(:event, :merged, project: project, target: mr, author: user)
  end

  describe '#data' do
    it 'return values' do
      data = subject.data
      expect(data.size).to eq(1)
      expect(data[0][:user][:username]).to eq(user.username)
      expect(data[0][:rank]).to eq(1)
      expect(data[0][:value]).to eq(1)
    end

    it 'return limited count' do
      users = create_list(:user, 30) # rubocop:disable FactoryBot/ExcessiveCreateList -- we need it
      users.each do |user|
        push_event = create(:push_event, project: project, author: user)
        create(:push_event_payload, commit_title: "test", event: push_event)
      end

      data = subject.data
      expect(data.size).to eq(Gitlab::Analytics::PerformanceAnalytics::Group::Leaderboard::Base::LIMIT_COUNT)
    end
  end
end
