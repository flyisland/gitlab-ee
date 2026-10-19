# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Gitlab::Analytics::PerformanceAnalytics::Group::Leaderboard::MergeRequestsMerged do
  let_it_be(:group) { create(:group) }
  let_it_be(:project) { create(:project, :repository, namespace: group) }
  let_it_be(:start_date) { 10.days.ago }
  let_it_be(:end_date) { 1.day.since }
  let_it_be(:user) { create(:user) }

  let(:issue) { create(:issue, project: project, created_at: 2.days.ago) }
  let(:mr) { create(:merge_request, source_project: project, created_at: 2.days.ago) }

  subject do
    described_class.new(group, options: {
      leaderboard_type: "merge_requests_merged",
      from: start_date,
      to: end_date,
      current_user: user
    })
  end

  describe '#data' do
    it "include merged mr" do
      create(:event, :merged, project: project, target: mr, author: user)
      create(:event, :created, project: project, target: mr, author: user)

      expect(subject.data.size).to eq(1)
    end
  end
end
