# frozen_string_literal: true

require 'spec_helper'

RSpec.describe DependencyManagement::SecurityUpdate::SchedulerWorker,
  feature_category: :dependency_management do
  let_it_be(:project) { create(:project) }

  let(:gem_finding) do
    {
      'uuid' => SecureRandom.uuid,
      'project_id' => project.id,
      'pipeline_id' => 1,
      'vulnerability_id' => 1,
      'package_name' => 'rails',
      'package_version' => '6.0.0',
      'purl_type' => 'gem'
    }
  end

  let(:event) { Sbom::VulnerabilitiesCreatedEvent.new(data: { findings: [gem_finding] }) }

  subject(:handle_event) { consume_event(subscriber: described_class, event: event) }

  it_behaves_like 'subscribes to event'
  it_behaves_like 'worker with data consistency', described_class, data_consistency: :delayed

  context 'when findings contain no gem packages' do
    let(:event) do
      Sbom::VulnerabilitiesCreatedEvent.new(data: {
        findings: [gem_finding.merge('purl_type' => 'npm')]
      })
    end

    it_behaves_like 'ignores the published event'
  end

  describe '#handle_event' do
    before do
      stub_feature_flags(dependency_management_auto_remediation: project)
      allow(DependencyManagement::SecurityUpdate::SchedulerService).to receive(:execute)
    end

    context 'when findings are empty' do
      let(:event) { Sbom::VulnerabilitiesCreatedEvent.new(data: { findings: [] }) }

      it 'does not call SchedulerService' do
        handle_event

        expect(DependencyManagement::SecurityUpdate::SchedulerService).not_to have_received(:execute)
      end
    end

    context 'when findings are nil' do
      it 'does not call SchedulerService' do
        event = instance_double(Sbom::VulnerabilitiesCreatedEvent, data: { 'findings' => nil })
        described_class.new.handle_event(event)

        expect(DependencyManagement::SecurityUpdate::SchedulerService).not_to have_received(:execute)
      end
    end

    context 'when the project exists and feature flag is enabled' do
      it 'calls SchedulerService for the project' do
        handle_event

        expect(DependencyManagement::SecurityUpdate::SchedulerService)
          .to have_received(:execute).with(project: project).once
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

    context 'when the project does not exist' do
      let(:event) do
        Sbom::VulnerabilitiesCreatedEvent.new(data: {
          findings: [gem_finding.merge('project_id' => non_existing_record_id)]
        })
      end

      it 'does not call SchedulerService' do
        handle_event

        expect(DependencyManagement::SecurityUpdate::SchedulerService).not_to have_received(:execute)
      end
    end

    context 'when findings contain multiple project_ids' do
      let_it_be(:other_project) { create(:project) }

      let(:other_finding) do
        gem_finding.merge('project_id' => other_project.id, 'vulnerability_id' => 99)
      end

      let(:event) do
        Sbom::VulnerabilitiesCreatedEvent.new(data: { findings: [gem_finding, other_finding] })
      end

      before do
        stub_feature_flags(dependency_management_auto_remediation: [project, other_project])
      end

      it 'calls SchedulerService once per unique project' do
        handle_event

        expect(DependencyManagement::SecurityUpdate::SchedulerService)
          .to have_received(:execute).with(project: project).once
        expect(DependencyManagement::SecurityUpdate::SchedulerService)
          .to have_received(:execute).with(project: other_project).once
      end
    end

    context 'when findings contain duplicate project_ids' do
      let(:duplicate_finding) { gem_finding.merge('vulnerability_id' => 99) }

      let(:event) do
        Sbom::VulnerabilitiesCreatedEvent.new(data: { findings: [gem_finding, duplicate_finding] })
      end

      it 'calls SchedulerService only once for the deduplicated project' do
        handle_event

        expect(DependencyManagement::SecurityUpdate::SchedulerService)
          .to have_received(:execute).with(project: project).once
      end
    end
  end
end
