# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Gitlab::Analytics::PerformanceAnalytics::Group::Summary::CommitsPushedPerCapita do
  let_it_be(:group) { create(:group) }
  let_it_be(:project) { create(:project, :repository, namespace: group) }
  let_it_be(:start_date) { 10.days.ago }
  let_it_be(:end_date) { 1.day.since }
  let_it_be(:user) { create(:user) }
  let_it_be(:another_user) { create(:user) }

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
      another_push_event = create(:push_event, project: project, author: another_user)
      create(:push_event_payload, commit_title: "test", event: another_push_event)

      expect(subject.data).to eq(1)
    end
  end
end
