# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Gitlab::Analytics::PerformanceAnalytics::Project::Summary::CommitsPushed do
  include JH::PerformanceAnalyticsHelper

  let_it_be(:group) { create(:group) }
  let_it_be(:project) { create(:project, :repository, namespace: group) }

  let(:start_date) { 1.day.ago }
  let(:end_date) { 1.day.since }
  let(:user) { create(:user) }

  subject do
    described_class.new(project, options: {
      from: start_date,
      to: end_date,
      current_user: user
    })
  end

  before do
    create_commit('Message', project, user, 'master', commit_time: 2.days.ago)
    create_commit('Message', project, user, 'master')
  end

  describe '#data' do
    it "include pushed commits" do
      expect(subject.data).to eq(1)
    end
  end
end
