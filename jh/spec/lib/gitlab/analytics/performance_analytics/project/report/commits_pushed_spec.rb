# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Gitlab::Analytics::PerformanceAnalytics::Project::Report::CommitsPushed do
  include JH::PerformanceAnalyticsHelper

  let(:group) { create(:group) }
  let(:project) { create(:project, :repository, namespace: group) }
  let(:start_date) { 1.day.ago }
  let(:end_date) { 1.day.since }
  let(:user) { create(:user) }
  let(:another_user) { create(:user) }

  subject do
    described_class.new(project, options: {
      from: start_date,
      to: end_date,
      current_user: user
    })
  end

  before do
    create_commit('Message', project, user, 'master')
  end

  describe '#query_count' do
    context "when commit author user exist" do
      it 'return user_id data' do
        data = subject.query_count
        expect(data).to include([user.id, 1])
      end
    end

    context "when commit author user not exist" do
      it "return commit author data" do
        commit_author = Gitlab::Analytics::PerformanceAnalytics::ProjectHelper::CommitAuthor.new(user.name, user.email)
        user.destroy

        data = subject.query_count
        expect(data).to include([commit_author, 1])
      end
    end

    context "when different emails pushed commits" do
      it "ok" do
        create_commit('Message', project, another_user, 'master')
        another_user.destroy
        create(:email, :confirmed, user: user, email: another_user.email)

        data = subject.query_count
        expect(data).to include([user.id, 2])
      end
    end
  end

  describe '#query_summary' do
    it 'return values' do
      data = subject.query_summary
      expect(data).to eq(1)
    end
  end
end
