# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Gitlab::SidekiqConfig::CronJobInitializer, feature_category: :build do
  describe '.execute', :allow_unrouted_sidekiq_calls do
    subject(:execute) { described_class.execute }

    let(:cron_jobs_hash) do
      {
        'gitlab_service_ping_worker' => {
          'cron' => nil,
          'class' => 'GitlabServicePingWorker'
        },
        'import_export_project_cleanup_worker' => {
          'cron' => '0 * * * *',
          'class' => 'ImportExportProjectCleanupWorker'
        }
      }
    end

    around do |example|
      Gitlab::SidekiqConfig::CronJobs.reset!
      example.run
      Gitlab::SidekiqConfig::CronJobs.reset!
    end

    before do
      allow(Gitlab::SidekiqConfig).to receive(:cron_jobs).and_return(cron_jobs_hash)
      allow(Gitlab::CurrentSettings).to receive(:uuid).and_return('d9e2f4e8-db1f-4e51-b03d-f427e1965c4a')
    end

    it 'configures mirror and geo cron jobs' do
      expect(Gitlab::Mirror).to receive(:configure_cron_job!)
      expect(Gitlab::Geo).to receive(:configure_cron_jobs!)

      execute
    end

    context 'for FOSS' do
      before do
        allow(GitlabEdition).to receive(:ee?).and_return(false)
      end

      it 'does not configure mirror and geo cron jobs' do
        expect(Gitlab::Mirror).not_to receive(:configure_cron_job!)
        expect(Gitlab::Geo).not_to receive(:configure_cron_jobs!)

        execute
      end
    end

    context 'as integration tests', :allow_unrouted_sidekiq_calls do
      before do
        Sidekiq::Cron::Job.load_from_hash!({}, source: 'schedule')
        allow(Gitlab::SidekiqConfig).to receive(:cron_jobs).and_call_original
        allow(Gitlab::CurrentSettings).to receive(:uuid).and_return('d9e2f4e8-db1f-4e51-b03d-f427e1965c4a')
        allow(Gitlab::Mirror).to receive(:configure_cron_job!)
        allow(Gitlab::Geo).to receive(:configure_cron_jobs!)
      end

      after do
        Sidekiq::Cron::Job.load_from_hash!({}, source: 'schedule')
      end

      context 'with EE schedule' do
        it 'provisions EE-only cron jobs into the registry' do
          described_class.execute

          job_names = Sidekiq::Cron::Job.all.map(&:name)
          expect(job_names).to include('active_user_count_threshold_worker', 'geo_registry_sync_worker')
        end

        context 'for FOSS' do
          before do
            allow(GitlabEdition).to receive(:ee?).and_return(false)
          end

          it 'does not provision EE-only jobs' do
            described_class.execute

            expect(Sidekiq::Cron::Job.all.map(&:name)).not_to include('active_user_count_threshold_worker')
          end
        end
      end

      context 'with SaaS schedule' do
        before do
          allow(Gitlab).to receive(:com?).and_return(true)
        end

        it 'provisions SaaS-only cron jobs into the registry' do
          described_class.execute

          job_names = Sidekiq::Cron::Job.all.map(&:name)
          expect(job_names).to include('block_pipl_users_worker',
            'namespaces_schedule_dormant_member_removal_worker')
        end

        context 'when not on SaaS' do
          before do
            allow(Gitlab).to receive(:com?).and_return(false)
          end

          it 'does not provision SaaS-only jobs' do
            described_class.execute

            expect(Sidekiq::Cron::Job.find('block_pipl_users_worker')).to be_nil
          end
        end
      end
    end
  end
end
