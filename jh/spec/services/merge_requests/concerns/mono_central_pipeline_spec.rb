# frozen_string_literal: true

require 'spec_helper'

RSpec.describe MergeRequests::Concerns::MonoCentralPipeline, feature_category: :code_review_workflow do
  let_it_be(:group) { create(:group) }
  let_it_be(:project) { create(:project, group: group) }
  let_it_be(:user) { create(:user) }
  let_it_be(:topic_label) { create(:group_label, group: group, name: 'topic::mono-test-feature') }
  let_it_be(:non_topic_label) { create(:group_label, group: group, name: 'mono-bug') }
  let_it_be(:merge_request, freeze: false) { create(:merge_request, source_project: project, labels: [topic_label]) }

  # Create a test class that includes the concern
  let(:test_class) do
    Class.new do
      include MergeRequests::Concerns::MonoCentralPipeline
    end
  end

  let(:test_instance) { test_class.new }

  describe '#should_skip_mono_central_pipeline?' do
    context 'when skip_mono_central_pipeline is true in merge_params as string' do
      before do
        merge_request.merge_params = { 'skip_mono_central_pipeline' => 'true' }
      end

      it 'returns true' do
        expect(test_instance.send(:should_skip_mono_central_pipeline?, merge_request)).to be true
      end
    end

    context 'when skip_mono_central_pipeline is true in merge_params as boolean' do
      before do
        merge_request.merge_params = { 'skip_mono_central_pipeline' => true }
      end

      it 'returns true' do
        expect(test_instance.send(:should_skip_mono_central_pipeline?, merge_request)).to be true
      end
    end

    context 'when skip_mono_central_pipeline is true as symbol key' do
      before do
        merge_request.merge_params = { skip_mono_central_pipeline: true }
      end

      it 'returns true' do
        expect(test_instance.send(:should_skip_mono_central_pipeline?, merge_request)).to be true
      end
    end

    context 'when skip_mono_central_pipeline is false' do
      before do
        merge_request.merge_params = { 'skip_mono_central_pipeline' => 'false' }
      end

      it 'returns false' do
        expect(test_instance.send(:should_skip_mono_central_pipeline?, merge_request)).to be false
      end
    end

    context 'when skip_mono_central_pipeline is not present' do
      before do
        merge_request.merge_params = {}
      end

      it 'returns false' do
        expect(test_instance.send(:should_skip_mono_central_pipeline?, merge_request)).to be false
      end
    end

    context 'when merge_params is nil' do
      before do
        merge_request.merge_params = nil
      end

      it 'returns false' do
        expect(test_instance.send(:should_skip_mono_central_pipeline?, merge_request)).to be false
      end
    end
  end

  describe '#mono_central_pipeline_available?' do
    context 'when monorepo feature is available and feature flag is enabled' do
      before do
        allow(::MergeRequests::MonorepoService).to receive(:monorepo_feature_available?).and_return(true)
        stub_feature_flags(ff_monorepo_topic_ci_trigger: true)
      end

      it 'returns true' do
        expect(test_instance.send(:mono_central_pipeline_available?, project)).to be true
      end
    end

    context 'when monorepo feature is not available' do
      before do
        allow(::MergeRequests::MonorepoService).to receive(:monorepo_feature_available?).and_return(false)
        stub_feature_flags(ff_monorepo_topic_ci_trigger: true)
      end

      it 'returns false' do
        expect(test_instance.send(:mono_central_pipeline_available?, project)).to be false
      end
    end

    context 'when feature flag is disabled' do
      before do
        allow(::MergeRequests::MonorepoService).to receive(:monorepo_feature_available?).and_return(true)
        stub_feature_flags(ff_monorepo_topic_ci_trigger: false)
      end

      it 'returns false' do
        expect(test_instance.send(:mono_central_pipeline_available?, project)).to be false
      end
    end

    context 'when both monorepo feature and feature flag are disabled' do
      before do
        allow(::MergeRequests::MonorepoService).to receive(:monorepo_feature_available?).and_return(false)
        stub_feature_flags(ff_monorepo_topic_ci_trigger: false)
      end

      it 'returns false' do
        expect(test_instance.send(:mono_central_pipeline_available?, project)).to be false
      end
    end
  end

  describe '#trigger_mono_central_pipeline_for_topic_label' do
    let(:monorepo_service) { instance_double(::MergeRequests::MonorepoService) }

    context 'when topic_label is nil' do
      it 'returns early without triggering pipeline' do
        expect(::MergeRequests::MonorepoService).not_to receive(:new)

        result = test_instance.send(:trigger_mono_central_pipeline_for_topic_label, merge_request, nil, user)
        expect(result).to be_nil
      end
    end

    context 'when topic_label is present' do
      before do
        allow(::MergeRequests::MonorepoService).to receive(:new)
          .with(project.root_ancestor, topic_label.title)
          .and_return(monorepo_service)
      end

      context 'when pipeline trigger succeeds' do
        before do
          allow(monorepo_service).to receive(:trigger_central_pipeline).with(user)
        end

        it 'creates monorepo service and triggers central pipeline' do
          expect(::MergeRequests::MonorepoService).to receive(:new)
            .with(project.root_ancestor, topic_label.title)
            .and_return(monorepo_service)
          expect(monorepo_service).to receive(:trigger_central_pipeline).with(user)

          test_instance.send(:trigger_mono_central_pipeline_for_topic_label, merge_request, topic_label, user)
        end
      end

      context 'when pipeline trigger raises an error' do
        let(:error) { StandardError.new('Pipeline trigger failed') }

        before do
          allow(monorepo_service).to receive(:trigger_central_pipeline).and_raise(error)
          allow(::Gitlab::ErrorTracking).to receive(:track_exception)
        end

        it 'tracks the exception and returns nil' do
          expect(::Gitlab::ErrorTracking).to receive(:track_exception)
            .with(error, merge_request_id: merge_request.id)

          result = test_instance.send(:trigger_mono_central_pipeline_for_topic_label, merge_request, topic_label, user)
          expect(result).to be_nil
        end
      end
    end
  end

  describe '#extract_topic_label' do
    let(:topic_label_1) { create(:group_label, group: group, name: 'topic::extract-test-1') }
    let(:topic_label_2) { create(:group_label, group: group, name: 'topic::extract-test-2') }
    let(:regular_label) { create(:group_label, group: group, name: 'extract-bug') }
    let(:priority_label) { create(:group_label, group: group, name: 'priority::extract-high') }

    context 'when labels contain topic labels' do
      let(:labels) { [regular_label, topic_label_1, priority_label] }

      it 'returns the first topic label' do
        result = test_instance.send(:extract_topic_label, labels)
        expect(result).to eq(topic_label_1)
      end
    end

    context 'when labels contain multiple topic labels' do
      let(:labels) { [regular_label, topic_label_1, topic_label_2, priority_label] }

      it 'returns the first topic label found' do
        result = test_instance.send(:extract_topic_label, labels)
        expect(result).to eq(topic_label_1)
      end
    end

    context 'when labels do not contain topic labels' do
      let(:labels) { [regular_label, priority_label] }

      it 'returns nil' do
        result = test_instance.send(:extract_topic_label, labels)
        expect(result).to be_nil
      end
    end

    context 'when labels array is empty' do
      let(:labels) { [] }

      it 'returns nil' do
        result = test_instance.send(:extract_topic_label, labels)
        expect(result).to be_nil
      end
    end

    context 'when labels contain topic-like but not exact topic labels' do
      let(:topic_like_label) { create(:group_label, group: group, name: 'topics::extract-feature') }
      let(:labels) { [regular_label, topic_like_label] }

      it 'returns nil' do
        result = test_instance.send(:extract_topic_label, labels)
        expect(result).to be_nil
      end
    end
  end
end
