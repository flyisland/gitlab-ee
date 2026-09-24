# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Gitlab::Analytics::PerformanceAnalytics::Project::Leaderboard::CommitsPushed do
  include JH::PerformanceAnalyticsHelper

  let_it_be(:group) { create(:group) }
  let_it_be(:project) { create(:project, :repository, namespace: group) }
  let_it_be(:start_date) { 1.day.ago }
  let_it_be(:end_date) { 1.day.since }

  let(:user) { create(:user) }
  let(:another_user) { create(:user) }

  subject do
    described_class.new(project, options: {
      leaderboard_type: "commits_pushed",
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
      expect(subject.data.size).to eq(1)
      expect(subject.data[0][:user][:user_web_url]).to be_present
      expect(subject.data[0][:user][:username]).to eq(user.username)
      expect(subject.data[0][:value]).to eq(1)
    end

    it "include commit author data" do
      create_commit('Message', project, another_user, 'master')
      create_commit('Message', project, another_user, 'master')
      another_user.destroy

      expect(subject.data.size).to eq(2)
      expect(subject.data[0][:user][:user_web_url]).to be_nil
      expect(subject.data[0][:user][:username]).to eq(another_user.name)
      expect(subject.data[0][:value]).to eq(2)
    end

    it "include different emails pushed commits" do
      create_commit('Message', project, another_user, 'master')
      another_user.destroy
      create(:email, :confirmed, user: user, email: another_user.email)

      expect(subject.data.size).to eq(1)
      expect(subject.data[0][:user][:user_web_url]).to be_present
      expect(subject.data[0][:user][:username]).to eq(user.username)
      expect(subject.data[0][:value]).to eq(2)
    end
  end
end
