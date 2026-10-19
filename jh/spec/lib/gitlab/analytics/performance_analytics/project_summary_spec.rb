# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Gitlab::Analytics::PerformanceAnalytics::ProjectSummary do
  include JH::PerformanceAnalyticsHelper

  let_it_be(:group) { create(:group) }
  let_it_be(:project) { create(:project, :repository, namespace: group) }

  let(:start_date) { 1.day.ago }
  let(:end_date) { 1.day.since }
  let(:user) { create(:user) }
  let(:issue) { create(:issue, project: project) }
  let(:mr) { create(:merge_request, source_project: project) }

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
    create(:event, :merged, project: project, target: mr)
  end

  describe '#data' do
    it 'return values' do
      expect(subject.data).to eq({
        commits_pushed: 1,
        commits_pushed_per_capita: 1,
        issues_closed: 1,
        merge_requests_merged: 1
      })
    end
  end
end
