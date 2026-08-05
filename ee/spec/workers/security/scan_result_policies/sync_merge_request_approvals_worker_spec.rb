# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Security::ScanResultPolicies::SyncMergeRequestApprovalsWorker, feature_category: :security_policy_management do
  let_it_be(:project) { create(:project) }
  let_it_be(:merge_request) { create(:merge_request, :with_merge_request_pipeline, source_project: project) }
  let_it_be(:pipeline) { merge_request.all_pipelines.last }

  subject(:perform) { described_class.new.perform(pipeline.id, merge_request.id) }

  describe "#perform" do
    it "updates approvals" do
      expect_next_instance_of(Security::ScanResultPolicies::UpdateApprovalsService, merge_request: merge_request,
        pipeline: pipeline) do |service|
        expect(service).to receive(:execute)
      end

      perform
    end

    describe 'policy sync state tracking' do
      include_context 'with policy sync state'

      before do
        state.start_merge_request_worker(merge_request.id)
      end

      specify do
        expect { perform }.to change { state.total_merge_request_workers_count(merge_request.id) }.from(1).to(0)
      end
    end

    context 'when pipeline does not exist' do
      subject(:perform) { described_class.new.perform(non_existing_record_id, merge_request.id) }

      it 'does not update approvals' do
        expect(Security::ScanResultPolicies::UpdateApprovalsService).not_to receive(:new)

        perform
      end

      describe 'policy sync state tracking' do
        include_context 'with policy sync state'

        before do
          state.start_merge_request_worker(merge_request.id)
        end

        it 'still decrements the worker counter' do
          expect { perform }.to change { state.total_merge_request_workers_count(merge_request.id) }.from(1).to(0)
        end
      end
    end

    context 'when merge_request does not exist' do
      subject(:perform) { described_class.new.perform(pipeline.id, non_existing_record_id) }

      it 'does not update approvals' do
        expect(Security::ScanResultPolicies::UpdateApprovalsService).not_to receive(:new)

        perform
      end

      describe 'policy sync state tracking' do
        include_context 'with policy sync state'

        before do
          state.start_merge_request_worker(non_existing_record_id)
        end

        it 'still decrements the worker counter' do
          expect { perform }
            .to change { state.total_merge_request_workers_count(non_existing_record_id) }.from(1).to(0)
        end
      end
    end
  end
end
