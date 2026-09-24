# frozen_string_literal: true

require 'spec_helper'

RSpec.describe FreeTrial::ScanFreeTrialUserWorker do
  include AfterNextHelpers

  subject(:scan_user) { described_class.new.perform }

  let(:user) { create(:user) }

  context "when not saas" do
    it "not call service if not saas" do
      allow(Gitlab).to receive(:com?).and_return(false)
      expect(FreeTrial::ScanFreeTrialUserService).not_to receive(:new)

      scan_user
    end
  end

  context "when saas" do
    let(:gauge_args) do
      [:free_trial_scan_worker_status, 'status of free trial user worker', { version: Gitlab.version_info.to_s }]
    end

    it "call ContentValidation::CommitService" do
      allow(Gitlab).to receive(:com?).and_return(true)
      expect_next(FreeTrial::ScanFreeTrialUserService).to receive(:execute)
      expect(::Gitlab::Metrics.gauge(*gauge_args)).to receive(:set).with({}, 1).once

      scan_user
    end

    it 'set failed metric when service raise error' do
      allow(Gitlab).to receive(:com?).and_return(true)
      expect_next(FreeTrial::ScanFreeTrialUserService).to receive(:execute)
        .and_raise(::Gitlab::SubscriptionPortal::Client::SubscriptionPortalRESTException)
      expect(::Gitlab::Metrics.gauge(*gauge_args)).to receive(:set).with({}, 0).once

      expect { scan_user }.to raise_error(::Gitlab::SubscriptionPortal::Client::SubscriptionPortalRESTException)
    end
  end

  it 'uses a cronjob queue' do
    expect(described_class.new.sidekiq_options_hash).to include('queue_namespace' => :cronjob)
  end
end
