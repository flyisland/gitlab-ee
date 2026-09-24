# frozen_string_literal: true

require 'spec_helper'

RSpec.describe MergeRequests::Mergeability::CheckCiStatusService, feature_category: :code_review_workflow do
  subject(:check_ci_status) { described_class.new(merge_request: merge_request, params: {}) }

  describe '#mergeable_ci_state?' do
    let(:mono_central_pipeline) { build(:ci_empty_pipeline) }
    let(:merge_request) { build(:merge_request, source_project: project) }
    let(:project) { build(:project, :repository, only_allow_merge_if_pipeline_succeeds: true) }

    context 'when monorepo is enabled' do
      before do
        allow(::MergeRequests::MonorepoService).to receive(:monorepo_enabled?).and_return(true)
      end

      context 'when no diff_head_pipeline is associated' do
        before do
          allow_any_instance_of(::MergeRequests::MonorepoService)
            .to receive(:central_pipeline)
            .and_return(mono_central_pipeline)
        end

        context 'and has no mono_central_pipeline associated' do
          let(:mono_central_pipeline) { nil }

          it { expect(check_ci_status.mergeable_ci_state?).to be_falsey }
        end

        context 'and a failed mono_central_pipeline is associated' do
          before do
            mono_central_pipeline.status = 'failed'
          end

          it { expect(check_ci_status.mergeable_ci_state?).to be_falsey }
        end

        context 'and a successful mono_central_pipeline is associated' do
          before do
            mono_central_pipeline.status = 'success'
          end

          it { expect(check_ci_status.mergeable_ci_state?).to be_truthy }
        end

        context 'and a skipped mono_central_pipeline is associated' do
          before do
            mono_central_pipeline.status = 'skipped'
          end

          it { expect(check_ci_status.mergeable_ci_state?).to be_falsey }
        end
      end
    end
  end
end
