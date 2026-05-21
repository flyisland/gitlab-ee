# frozen_string_literal: true

require 'spec_helper'

RSpec.describe DependencyManagement::SecurityUpdate::SchedulerWorker,
  feature_category: :dependency_management do
  let_it_be(:pipeline) { create(:ci_pipeline) }

  let(:event) { Sbom::SbomIngestedEvent.new(data: { pipeline_id: pipeline.id }) }

  subject(:handle_event) { consume_event(subscriber: described_class, event: event) }

  it_behaves_like 'subscribes to event'
  it_behaves_like 'worker with data consistency', described_class, data_consistency: :delayed

  describe '#handle_event' do
    before do
      stub_feature_flags(dependency_management_auto_remediation: pipeline.project)
      allow(DependencyManagement::SecurityUpdate::SchedulerService).to receive(:execute)
    end

    context 'when the pipeline exists and feature flag is enabled' do
      it 'calls SchedulerService with the pipeline project' do
        handle_event

        expect(DependencyManagement::SecurityUpdate::SchedulerService)
          .to have_received(:execute).with(project: pipeline.project).once
      end
    end

    context 'when the pipeline does not exist' do
      let(:event) { Sbom::SbomIngestedEvent.new(data: { pipeline_id: non_existing_record_id }) }

      it 'does not call SchedulerService' do
        handle_event

        expect(DependencyManagement::SecurityUpdate::SchedulerService).not_to have_received(:execute)
      end
    end

    context 'when the feature flag is disabled' do
      before do
        stub_feature_flags(dependency_management_auto_remediation: false)
      end

      it 'does not call SchedulerService' do
        handle_event

        expect(DependencyManagement::SecurityUpdate::SchedulerService).not_to have_received(:execute)
      end
    end
  end
end
