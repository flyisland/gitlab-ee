# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Approvals::Context, feature_category: :code_review_workflow do
  let_it_be(:project) { create(:project, :repository) }
  let_it_be(:merge_request) { create(:merge_request, source_project: project, target_project: project) }
  let_it_be(:approver1) { create(:user) }
  let_it_be(:approver2) { create(:user) }

  subject(:context) { described_class.new(merge_request) }

  describe '#overall_approver_ids' do
    context 'when there are no approvals' do
      it 'returns an empty set' do
        expect(context.overall_approver_ids).to eq(Set.new)
      end
    end

    context 'when there are approvals' do
      let!(:approval1) { create(:approval, merge_request: merge_request, user: approver1) }
      let!(:approval2) { create(:approval, merge_request: merge_request, user: approver2) }

      it 'returns a set of approver user IDs' do
        expect(context.overall_approver_ids).to eq(Set.new([approver1.id, approver2.id]))
      end

      it 'is memoized' do
        expect(merge_request).to receive(:approvals).once.and_call_original

        2.times { context.overall_approver_ids }
      end
    end

    context 'when approvals relation is already loaded' do
      let!(:approval1) { create(:approval, merge_request: merge_request, user: approver1) }

      it 'uses loaded data without additional approval queries' do
        merge_request.approvals.load # Pre-load the relation

        expect do
          context.overall_approver_ids
        end.not_to exceed_query_limit(0).for_model(Approval)
      end
    end
  end

  describe '#optimization_enabled?' do
    it 'returns true' do
      expect(context.optimization_enabled?).to be true
    end

    context 'when feature flag is disabled' do
      before do
        stub_feature_flags(overall_approver_ids_optimization: false)
      end

      it 'returns false' do
        expect(context.optimization_enabled?).to be false
      end
    end
  end
end
