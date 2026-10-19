# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Gitlab::SidekiqConfig::CronJobs, feature_category: :build do
  around do |example|
    described_class.reset!
    example.run
    described_class.reset!
  end

  context 'when on JH SaaS', :saas do
    it 'disables the PIPL cron jobs while keeping their worker classes', :aggregate_failures do
      jobs = described_class.config.jobs

      %w[block_pipl_users_worker delete_pipl_users_worker send_recurring_notifications_worker].each do |name|
        expect(jobs[name]['status']).to eq('disabled')
        expect(jobs[name]['class']).to be_present
      end
    end

    it 'keeps the seats refresh worker enabled' do
      job = described_class.config.jobs['gitlab_subscriptions_schedule_refresh_seats_worker']

      expect(job).to be_present
      expect(job['status']).not_to eq('disabled')
    end
  end

  context 'when on JH but not SaaS' do
    it 'defines the PIPL cron jobs as disabled with valid class and cron', :aggregate_failures do
      jobs = described_class.config.jobs

      %w[block_pipl_users_worker delete_pipl_users_worker send_recurring_notifications_worker].each do |name|
        expect(jobs[name]['status']).to eq('disabled')
        expect(jobs[name]['class']).to be_present
        expect(jobs[name]['cron']).to be_present
      end
    end
  end
end
