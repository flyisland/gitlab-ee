# frozen_string_literal: true

require 'spec_helper'

RSpec.describe ::MergeRequests::CreateService, feature_category: :code_review_workflow do
  include ProjectForksHelper

  let(:project) { create(:project, :repository) }
  let(:user) { create(:user) }
  let(:topic_label) { create(:label, project: project, title: 'topic::test-feature') }
  let(:regular_label) { create(:label, project: project, title: 'bug') }

  let(:opts) do
    {
      title: 'Awesome merge_request',
      description: 'please fix',
      source_branch: 'feature',
      target_branch: 'master',
      label_ids: [topic_label.id, regular_label.id]
    }
  end

  let(:service) { MergeRequests::CreateService.new(project: project, current_user: user, params: opts) }

  before do
    project.add_maintainer(user)
  end

  describe '#after_create' do
    let(:merge_request) { service.execute }

    context 'when mono central pipeline should be triggered' do
      before do
        allow(service).to receive_messages(
          should_skip_mono_central_pipeline?: false,
          mono_central_pipeline_available?: true
        )
      end

      it 'calls trigger_mono_central_pipeline_for_topic_label with correct parameters' do
        expect(service).to receive(:trigger_mono_central_pipeline_for_topic_label)
          .with(an_instance_of(MergeRequest), topic_label, user)

        merge_request
      end

      it 'extracts topic label correctly' do
        expect(service).to receive(:extract_topic_label).with(anything).and_call_original

        merge_request
      end
    end

    context 'when mono central pipeline should be skipped' do
      before do
        allow(service).to receive(:should_skip_mono_central_pipeline?).and_return(true)
      end

      it 'does not call trigger_mono_central_pipeline_for_topic_label' do
        expect(service).not_to receive(:trigger_mono_central_pipeline_for_topic_label)

        merge_request
      end
    end

    context 'when mono central pipeline is not available' do
      before do
        allow(service).to receive_messages(
          should_skip_mono_central_pipeline?: false,
          mono_central_pipeline_available?: false
        )
      end

      it 'does not call trigger_mono_central_pipeline_for_topic_label' do
        expect(service).not_to receive(:trigger_mono_central_pipeline_for_topic_label)

        merge_request
      end
    end

    context 'when merge request has no topic labels' do
      let(:opts) do
        {
          title: 'Awesome merge_request',
          description: 'please fix',
          source_branch: 'feature',
          target_branch: 'master',
          label_ids: [regular_label.id]
        }
      end

      before do
        allow(service).to receive_messages(
          should_skip_mono_central_pipeline?: false,
          mono_central_pipeline_available?: true
        )
      end

      it 'calls trigger_mono_central_pipeline_for_topic_label with nil topic_label' do
        expect(service).to receive(:trigger_mono_central_pipeline_for_topic_label)
          .with(an_instance_of(MergeRequest), nil, user)

        merge_request
      end
    end

    context 'with skip_mono_central_pipeline parameter' do
      let(:opts) do
        {
          title: 'Awesome merge_request',
          description: 'please fix',
          source_branch: 'feature',
          target_branch: 'master',
          label_ids: [topic_label.id],
          merge_params: { 'skip_mono_central_pipeline' => 'true' }
        }
      end

      before do
        allow(service).to receive(:mono_central_pipeline_available?).and_return(true)
      end

      it 'does not call trigger_mono_central_pipeline_for_topic_label when skip parameter is true' do
        expect(service).not_to receive(:trigger_mono_central_pipeline_for_topic_label)

        merge_request
      end
    end
  end
end
