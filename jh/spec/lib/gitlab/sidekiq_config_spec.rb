# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Gitlab::SidekiqConfig, feature_category: :build do
  describe '.workers' do
    it 'includes JH workers' do
      worker_classes = described_class.workers.map(&:klass)

      expect(worker_classes).to include(ContentValidation::CommitServiceWorker)
    end
  end

  describe '.worker_queues' do
    it 'includes JH queues' do
      queues = described_class.worker_queues

      expect(queues).to include('content_validation:content_validation_commit_service')
    end
  end

  describe '.workers_for_all_queues_yml' do
    it 'returns a tuple with JH workers third' do
      expect(described_class.workers_for_all_queues_yml.third)
        .to include(
          an_object_having_attributes(generated_queue_name: 'content_validation:content_validation_commit_service'))
    end
  end

  describe '.all_queues_yml_outdated?' do
    let(:workers) do
      [
        ContentValidation::CommitServiceWorker
      ].map { |worker| described_class::Worker.new(worker, ee: false, jh: true) }
    end

    before do
      allow(described_class).to receive(:workers).and_return(workers)

      allow(YAML).to receive(:load_file)
                       .with(described_class::FOSS_QUEUE_CONFIG_PATH)
                       .and_return([])
      allow(YAML).to receive(:load_file)
                       .with(described_class::EE_QUEUE_CONFIG_PATH)
                       .and_return([])
    end

    it 'returns true if the YAML file does not match the application code' do
      allow(YAML).to receive(:load_file)
                       .with(described_class::JH_QUEUE_CONFIG_PATH)
                       .and_return([])

      expect(described_class.all_queues_yml_outdated?).to be(true)
    end

    it 'returns false if the YAML file matches the application code' do
      allow(YAML).to receive(:load_file)
                       .with(described_class::JH_QUEUE_CONFIG_PATH)
                       .and_return(workers.map(&:to_yaml))

      expect(described_class.all_queues_yml_outdated?).to be(false)
    end
  end

  describe '.cron_jobs' do
    around do |example|
      Gitlab::SidekiqConfig::CronJobs.reset!
      example.run
      Gitlab::SidekiqConfig::CronJobs.reset!
    end

    it 'includes JH cron job' do
      expect(described_class.cron_jobs.keys).to include(
        'expire_password_worker',
        'scan_free_trial_user_worker',
        'remove_free_trial_user_worker',
        'subscriptions_storage_expired_notice_worker'
      )
    end
  end
end
