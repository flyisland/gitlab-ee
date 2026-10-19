# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Gitlab::GithubImport::Stage::EnableContinuousSyncWorker, feature_category: :importers do
  let_it_be_with_reload(:project) { create(:project, :import_started) }

  let(:client) { instance_double(Gitlab::GithubImport::Client) }

  subject(:worker) { described_class.new }

  it_behaves_like Gitlab::GithubImport::StageMethods do
    let(:fail_import_on_exhaustion) { false }
  end

  it_behaves_like Import::ResumableImportJob

  describe '#import' do
    context 'when the sync repository is still provisioning' do
      let!(:sync_repository) { create(:import_sync_repository, :oauth, project: project) }

      it 'hands authority to GitHub and enqueues the finish stage' do
        expect(Gitlab::GithubImport::Stage::FinishImportWorker).to receive(:perform_async).with(project.id)

        worker.import(client, project)

        expect(sync_repository.reload).to be_provider_canonical
      end
    end

    context 'when the sync repository has already left provisioning' do
      let!(:sync_repository) do
        create(:import_sync_repository, :oauth, project: project, authority_state: :bootstrap_canceled)
      end

      it 'logs it, leaves the authority state untouched and enqueues the finish stage' do
        expect(Gitlab::GithubImport::Stage::FinishImportWorker).to receive(:perform_async).with(project.id)
        expect(Gitlab::GithubImport::Logger).to receive(:info).with(
          hash_including(
            message: 'sync repository is bootstrap_canceled, finishing without continuous sync',
            project_id: project.id
          )
        )

        worker.import(client, project)

        expect(sync_repository.reload).to be_bootstrap_canceled
      end
    end

    context 'when the project has no sync repository' do
      it 'logs it and enqueues the finish stage without creating one' do
        expect(Gitlab::GithubImport::Stage::FinishImportWorker).to receive(:perform_async).with(project.id)
        expect(Gitlab::GithubImport::Logger).to receive(:info).with(
          hash_including(
            message: 'no sync repository found, finishing without continuous sync',
            project_id: project.id,
            import_stage: described_class.name
          )
        )

        expect { worker.import(client, project) }.not_to change { Import::Sync::Repository.count }
      end
    end
  end

  describe '.sidekiq_retries_exhausted' do
    it 'records a non-fatal failure and enqueues the finish stage' do
      expect(Gitlab::GithubImport::Stage::FinishImportWorker).to receive(:perform_async).with(project.id)

      described_class.sidekiq_retries_exhausted_block.call({ 'args' => [project.id] }, StandardError.new('boom'))

      expect(project.import_state.reload.status).to eq('started')
      expect(project.import_failures.last).to have_attributes(
        exception_class: 'StandardError',
        source: described_class.name,
        retry_count: nil
      )
    end
  end
end
