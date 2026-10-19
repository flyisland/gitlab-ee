# frozen_string_literal: true

require 'spec_helper'

RSpec.describe FreeTrial::RemoveFreeTrialUserWorker, time_travel_to: '2027-01-03' do
  include AfterNextHelpers

  subject(:worker) { described_class.new.perform }

  let(:user) { create(:user) }

  context "when not saas" do
    it "not call service if not saas" do
      allow(Gitlab).to receive(:com?).and_return(false)
      expect(FreeTrial::RemoveFreeTrialUserService).not_to receive(:new)

      worker
    end
  end

  context "when saas" do
    it "call service if after remove date and not dry run" do
      allow(Gitlab).to receive(:com?).and_return(true)
      expect_next(FreeTrial::RemoveFreeTrialUserService).to receive(:execute)

      worker
    end

    it "call service if dry run even before remove date" do
      allow(Gitlab).to receive(:com?).and_return(true)
      expect_next(FreeTrial::RemoveFreeTrialUserService, dry_run: true).to receive(:execute)

      described_class.new.perform(true)
    end

    it "not call service if before remove date and not dry run", time_travel_to: '2024-01-03' do
      allow(Gitlab).to receive(:com?).and_return(true)
      expect(FreeTrial::RemoveFreeTrialUserService).not_to receive(:new)

      worker
    end
  end

  it 'uses a cronjob queue' do
    expect(described_class.new.sidekiq_options_hash).to include('queue_namespace' => :cronjob)
  end
end
