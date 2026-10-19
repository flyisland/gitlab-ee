# frozen_string_literal: true

require 'spec_helper'

RSpec.describe FreeTrial::BlockFreeTrialUserWorker do
  include AfterNextHelpers

  subject(:worker) { described_class.new.perform(user.id) }

  let(:user) { create(:user) }

  context "when not saas" do
    it "not call service if not saas" do
      allow(Gitlab).to receive(:com?).and_return(false)
      expect(FreeTrial::BlockFreeTrialUserService).not_to receive(:new)

      worker
    end
  end

  context "when saas" do
    it "call FreeTrial::BlockFreeTrialUserService" do
      allow(Gitlab).to receive(:com?).and_return(true)
      expect_next(FreeTrial::BlockFreeTrialUserService).to receive(:execute)

      worker
    end
  end
end
