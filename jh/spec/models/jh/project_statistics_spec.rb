# frozen_string_literal: true

require 'spec_helper'

RSpec.describe ProjectStatistics, feature_category: :consumables_cost_management do
  describe '#notify_storage_usage' do
    let_it_be_with_reload(:project) { create(:project) }

    let(:statistics) { project.statistics }

    context 'when repository storage size components have changed' do
      it 'calls the upstream service and the JH repository limit notification' do
        expect(::Namespaces::Storage::RepositoryLimit::EmailNotificationService)
          .to receive(:execute).with(project).ordered
        expect(::JH::Namespaces::Storage::RepoLimit::EmailNotificationService)
          .to receive(:execute).with(project).ordered

        statistics.update!(repository_size: statistics.repository_size + 1)
      end
    end

    context 'when repository storage size components have not changed' do
      it 'does not call the JH repository limit notification' do
        expect(::JH::Namespaces::Storage::RepoLimit::EmailNotificationService).not_to receive(:execute)

        statistics.update!(build_artifacts_size: statistics.build_artifacts_size + 1)
      end
    end
  end
end
