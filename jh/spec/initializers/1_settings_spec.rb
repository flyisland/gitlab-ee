# frozen_string_literal: true

require 'spec_helper'

RSpec.describe '1_settings', feature_category: :shared do
  include_context 'when loading 1_settings initializer'

  def load_jh_settings
    load Rails.root.join('jh/config/initializers/1_settings.rb')
  end

  # rubocop:disable RSpec/EnvAssignment -- This spec verifies ENV assignment; stub_env cannot observe ENV#[]=.
  describe 'cloud connector URL' do
    around do |example|
      original_base_url = Settings.cloud_connector['base_url']
      original_env = ENV['CLOUD_CONNECTOR_BASE_URL']

      ENV.delete('CLOUD_CONNECTOR_BASE_URL')
      example.run
    ensure
      original_env.nil? ? ENV.delete('CLOUD_CONNECTOR_BASE_URL') : ENV['CLOUD_CONNECTOR_BASE_URL'] = original_env
      Settings.cloud_connector['base_url'] = original_base_url
    end

    before do
      Settings.cloud_connector['base_url'] = 'https://cloud.gitlab.com'
    end

    it 'does not set the default URL in test environment', :aggregate_failures do
      load_jh_settings

      expect(ENV['CLOUD_CONNECTOR_BASE_URL']).to be_nil
      expect(Settings.cloud_connector['base_url']).to eq('https://cloud.gitlab.com')
    end

    context 'when in production environment' do
      before do
        stub_rails_env('production')
      end

      it 'sets the default URL as environment variable', :aggregate_failures do
        load_jh_settings

        expect(ENV['CLOUD_CONNECTOR_BASE_URL']).to eq('https://cloud.jihulab.com')
        expect(Settings.cloud_connector['base_url']).to eq('https://cloud.jihulab.com')
      end

      it 'keeps explicit environment variable', :aggregate_failures do
        ENV['CLOUD_CONNECTOR_BASE_URL'] = 'https://example.com'

        load_jh_settings

        expect(ENV['CLOUD_CONNECTOR_BASE_URL']).to eq('https://example.com')
        expect(Settings.cloud_connector['base_url']).to eq('https://example.com')
      end
    end
  end
  # rubocop:enable RSpec/EnvAssignment

  describe 'cron jobs' do
    let(:expected_jh_jobs) do
      %w[
        expire_password_worker
        remove_free_trial_user_worker
        scan_free_trial_user_worker
        subscriptions_storage_expired_notice_worker
      ]
    end

    subject(:cron_jobs) { Gitlab::SidekiqConfig.cron_jobs }

    around do |example|
      Gitlab::SidekiqConfig::CronJobs.reset!
      example.run
      Gitlab::SidekiqConfig::CronJobs.reset!
    end

    it 'configures the expected jobs' do
      expect(cron_jobs.keys).to include(*expected_jh_jobs)
    end

    context 'for saas', :saas do
      it 'configures the expected jobs' do
        expect(cron_jobs.keys).to include(*expected_jh_jobs)
      end
    end
  end
end
