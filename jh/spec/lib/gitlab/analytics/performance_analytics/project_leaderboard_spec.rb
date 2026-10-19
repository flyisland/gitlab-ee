# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Gitlab::Analytics::PerformanceAnalytics::ProjectLeaderboard do
  include JH::PerformanceAnalyticsHelper

  let_it_be(:group) { create(:group) }
  let_it_be(:project) { create(:project, :repository, namespace: group) }
  let_it_be(:start_date) { 1.day.ago }
  let_it_be(:end_date) { 1.day.since }
  let_it_be(:user) { create(:user) }

  let(:issue) { create(:issue, project: project) }
  let(:mr) { create(:merge_request, source_project: project) }

  subject do
    described_class.new(project, options: {
      leaderboard_type: "commits_pushed",
      from: start_date,
      to: end_date,
      current_user: user
    })
  end

  before do
    create_commit('Message', project, user, 'master')
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
  end
end
