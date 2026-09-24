# frozen_string_literal: true

require 'spec_helper'

RSpec.describe GitlabSubscriptions::StorageExpiredNoticeWorker, feature_category: :plan_provisioning do
  include AfterNextHelpers

  subject(:worker) { described_class.new }

  describe '#perform' do
    context 'when not running on GitLab.com' do
      before do
        allow(Gitlab).to receive(:com?).and_return(false)
      end

      it 'does not call the expired storage notice service' do
        expect(GitlabSubscriptions::ExpiredStorageNotice).not_to receive(:execute)

        worker.perform
      end
    end

    context 'when running on GitLab.com' do
      before do
        allow(Gitlab).to receive(:com?).and_return(true)
      end

      it 'calls the expired storage notice service' do
        expect(GitlabSubscriptions::ExpiredStorageNotice).to receive(:execute)

        worker.perform
      end

      it 'executes successfully without errors' do
        allow(GitlabSubscriptions::ExpiredStorageNotice).to receive(:execute)

        expect { worker.perform }.not_to raise_error
      end
    end
  end
end
