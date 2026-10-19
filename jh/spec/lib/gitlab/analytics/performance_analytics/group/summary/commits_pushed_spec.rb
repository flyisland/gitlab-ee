# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Gitlab::Analytics::PerformanceAnalytics::Group::Summary::CommitsPushed do
  let_it_be(:group) { create(:group) }
  let_it_be(:project) { create(:project, :repository, namespace: group) }
  let_it_be(:start_date) { 10.days.ago }
  let_it_be(:end_date) { 1.day.since }

  let(:user) { create(:user) }
  let(:another_user) { create(:user) }

  subject do
    described_class.new(group, options: {
      from: start_date,
      to: end_date,
      current_user: user
    })
  end

  describe '#data' do
    it "include push commit" do
      push_event = create(:push_event, project: project, author: user)
      create(:push_event_payload, commit_title: "test", event: push_event)

      expect(subject.data).to eq(1)
    end

    it "include user outside group" do
      group.add_developer(user)
      push_event = create(:push_event, project: project, author: user)
      create(:push_event_payload, commit_title: "Message", event: push_event)
      another_push_event = create(:push_event, project: project, author: another_user)
      create(:push_event_payload, commit_title: "Message", event: another_push_event)

      expect(subject.data).to eq(2)
    end
  end
end
