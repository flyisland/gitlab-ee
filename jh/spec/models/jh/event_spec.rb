# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Event do
  describe 'scopes' do
    describe "created_in_time_range" do
      it 'can find the right event' do
        event = create(:event, created_at: 2.days.ago)

        found = described_class.created_in_time_range(from: 3.days.ago, to: 1.day.ago)

        expect(found).to include(event)
      end
    end

    describe "for_group" do
      it 'can find the right event' do
        group = create(:group)
        project = create(:project, group: group)
        event = create(:event, project: project)

        found = described_class.for_group(group)

        expect(found).to include(event)
      end
    end

    describe "for_project_ids" do
      it 'can find the right event' do
        project = create(:project)
        event = create(:event, project: project)

        found = described_class.for_project_ids([project.id])

        expect(found).to include(event)
      end
    end

    describe "for_user_ids" do
      it 'can find the right event' do
        user = create(:user)
        event = create(:event, author: user)

        found = described_class.for_author_ids([user.id])

        expect(found).to include(event)
      end
    end
  end

  describe "aggregate_for" do
    before do
      create(:event, created_at: "2022-10-01")
      create(:event, created_at: "2022-10-02")
      create(:event, created_at: "2022-11-01")
      create(:event, created_at: "2022-11-02")
    end

    context "when all" do
      it "return all count" do
        data = described_class.aggregate_for(::PerformanceAnalytics::MetricsHelper::INTERVAL_ALL)
        expect(data).to eq(4)
      end
    end

    context "when monthly" do
      it "return monthly count" do
        data = described_class.aggregate_for(::PerformanceAnalytics::MetricsHelper::INTERVAL_MONTHLY)
        expect(data).to eq(
          {
            "2022-10" => 2,
            "2022-11" => 2
          })
      end
    end

    context "when daily" do
      it "return daily count" do
        data = described_class.aggregate_for(::PerformanceAnalytics::MetricsHelper::INTERVAL_DAILY)
        expect(data).to eq(
          {
            "2022-10-01" => 1,
            "2022-10-02" => 1,
            "2022-11-01" => 1,
            "2022-11-02" => 1
          })
      end
    end
  end
end
