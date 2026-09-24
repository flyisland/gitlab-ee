# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Gitlab::SidekiqConfig::CronJobInitializer, feature_category: :build do
  describe 'SaaS cron registration', :allow_unrouted_sidekiq_calls, :clean_gitlab_redis_queues do
    using RSpec::Parameterized::TableSyntax

    let(:saas_jobs) do
      YAML.safe_load_file(Rails.root.join('ee/config/schedule_saas.yml'))
        .select { |_name, config| config.key?('class') }
    end

    let(:pipl_jobs) do
      %w[block_pipl_users_worker delete_pipl_users_worker send_recurring_notifications_worker]
    end

    around do |example|
      Gitlab::SidekiqConfig::CronJobs.reset!
      example.run
    ensure
      Gitlab::SidekiqConfig::CronJobs.reset!
    end

    before do
      stub_env('SAAS_REGION', region)
      allow(Gitlab.config.gitlab).to receive(:url).and_return(url)
      allow(Gitlab).to receive(:simulate_com?).and_return(false)
      allow(Gitlab::CurrentSettings).to receive_messages(
        uuid: 'd9e2f4e8-db1f-4e51-b03d-f427e1965c4a',
        sidekiq_timezone_override: nil
      )
      allow(Gitlab::Mirror).to receive(:configure_cron_job!)
      allow(Gitlab::Geo).to receive(:configure_cron_jobs!)
      Sidekiq::Cron::Job.load_from_hash!({}, source: 'schedule')
    end

    after do
      Sidekiq::Cron::Job.load_from_hash!({}, source: 'schedule')
    end

    where(:region, :url, :saas) do
      nil  | 'https://jihulab.com'         | true
      'HK' | 'https://gitlab.hk'           | true
      nil  | 'https://staging.jihulab.com' | true
      'HK' | 'https://staging.gitlab.hk'   | true
      nil  | 'https://gitlab.example.org'  | false
    end

    with_them do
      it 'registers cron jobs with JH PIPL overrides on the first execution', :aggregate_failures do
        expect(Gitlab.com?).to eq(saas)
        expect(Sidekiq::Cron::Job.all.map(&:name) & saas_jobs.keys).to be_empty

        described_class.execute

        saas_jobs.each do |name, config|
          job = Sidekiq::Cron::Job.find(name)

          if saas || pipl_jobs.include?(name)
            expect(job).not_to be_nil, "#{name} was not registered"
            expect(job&.klass).to eq(config.fetch('class'))
            expect(job&.cron).to eq(config.fetch('cron'))
            expect(job&.status).to eq(pipl_jobs.include?(name) ? 'disabled' : 'enabled')
          else
            expect(job).to be_nil, "#{name} should not be registered on self-managed instances"
          end
        end
      end
    end
  end

  describe '.execute', :allow_unrouted_sidekiq_calls do
    subject(:execute) { described_class.execute }

    around do |example|
      Gitlab::SidekiqConfig::CronJobs.reset!
      example.run
      Gitlab::SidekiqConfig::CronJobs.reset!
    end

    before do
      Sidekiq::Cron::Job.load_from_hash!({}, source: 'schedule')
      allow(Gitlab::CurrentSettings).to receive(:uuid).and_return('d9e2f4e8-db1f-4e51-b03d-f427e1965c4a')
    end

    after do
      Sidekiq::Cron::Job.load_from_hash!({}, source: 'schedule')
    end

    context 'when on JH SaaS', :saas do
      it 'reloads a previously enabled PIPL cron job as disabled' do
        Sidekiq::Cron::Job.load_from_hash!(
          {
            'block_pipl_users_worker' => {
              'cron' => '0 8 * * *',
              'class' => 'ComplianceManagement::Pipl::BlockPiplUsersWorker'
            }
          },
          source: 'schedule'
        )
        expect(Sidekiq::Cron::Job.find('block_pipl_users_worker').status).to eq('enabled')

        execute

        expect(Sidekiq::Cron::Job.find('block_pipl_users_worker').status).to eq('disabled')
      end

      it 'registers the remaining PIPL cron jobs as disabled', :aggregate_failures do
        execute

        expect(Sidekiq::Cron::Job.find('delete_pipl_users_worker').status).to eq('disabled')
        expect(Sidekiq::Cron::Job.find('send_recurring_notifications_worker').status).to eq('disabled')
      end

      it 'keeps the seats refresh cron job enabled' do
        execute

        expect(Sidekiq::Cron::Job.find('gitlab_subscriptions_schedule_refresh_seats_worker').status).to eq('enabled')
      end
    end

    context 'when on JH but not SaaS' do
      it 'registers the PIPL cron jobs as valid disabled entries without errors', :aggregate_failures do
        expect { execute }.not_to raise_error

        %w[block_pipl_users_worker delete_pipl_users_worker send_recurring_notifications_worker].each do |name|
          expect(Sidekiq::Cron::Job.find(name).status).to eq('disabled')
        end
      end
    end
  end
end
