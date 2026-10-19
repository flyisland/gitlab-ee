# frozen_string_literal: true

require 'fast_spec_helper'
require 'open3'
require 'rbconfig'

RSpec.describe Gitlab, 'boot', feature_category: :environment_management do
  using RSpec::Parameterized::TableSyntax

  let(:saas_job_names) do
    %w[
      block_pipl_users_worker
      cleanup_build_name_worker
      delete_pipl_users_worker
      disable_legacy_open_source_license_for_inactive_projects
      gitlab_subscriptions_schedule_refresh_seats_worker
      namespaces_schedule_dormant_member_removal_worker
      notify_seats_exceeded_batch_worker
      send_recurring_notifications_worker
    ]
  end

  let(:pipl_job_names) do
    %w[block_pipl_users_worker delete_pipl_users_worker send_recurring_notifications_worker]
  end

  where(:region, :ee_only, :foss_only, :url, :expected_com_url, :expected_saas, :expected_jh) do
    nil  | nil | nil | 'https://jihulab.com'       | 'https://jihulab.com' | true  | true
    'HK' | nil | nil | 'https://gitlab.hk'         | 'https://gitlab.hk'   | true  | true
    nil  | nil | nil | 'https://staging.jihulab.com' | 'https://jihulab.com' | true | true
    'HK' | nil | nil | 'https://staging.gitlab.hk' | 'https://gitlab.hk' | true | true
    nil  | nil | nil | 'https://gitlab.example.org' | 'https://jihulab.com' | false | true
    nil  | '1' | nil | 'https://gitlab.com' | 'https://gitlab.com' | true  | false
    nil  | nil | '1' | 'https://gitlab.example.org' | 'https://gitlab.com' | false | false
  end

  with_them do
    it 'uses the correct domain rules before any Rails initializers run', :aggregate_failures do
      script = <<~'RUBY'
        require File.join(ARGV.fetch(0), 'lib/gitlab')

        module Rails
          def self.env
            Struct.new(:development?).new(false)
          end

          def self.root
            Pathname.new(ARGV.fetch(0))
          end
        end

        Settings = Struct.new(:gitlab).new(Struct.new(:url).new(ARGV.fetch(1)))

        puts Gitlab.com_url
        puts Gitlab.com?
        puts Gitlab.jh?

        require 'bundler/setup'
        require 'active_support/all'
        require 'json'
        require 'yaml'

        settings = ActiveSupport::OrderedOptions.new
        settings.gitlab = Settings.gitlab
        settings.cron_jobs = {}
        Object.send(:remove_const, :Settings)
        Object.const_set(:Settings, settings)

        module Gitlab::CurrentSettings
          def self.sidekiq_timezone_override
            nil
          end
        end

        require Rails.root.join('lib/gitlab/sidekiq_config/cron_jobs').to_s

        puts JSON.generate(Gitlab::SidekiqConfig::CronJobs.config.jobs.transform_values { |job| job['status'] })
      RUBY

      stdout, stderr, status = Open3.capture3(
        { 'SAAS_REGION' => region, 'EE_ONLY' => ee_only, 'FOSS_ONLY' => foss_only, 'RUBYOPT' => nil },
        RbConfig.ruby,
        '-e', script, Rails.root.to_s, url
      )

      expect(status.success?).to be(true), stderr
      output = stdout.lines.map(&:chomp)
      expect(output.take(3)).to eq([expected_com_url, expected_saas.to_s, expected_jh.to_s])
      jobs = Gitlab::Json.parse(output.fetch(3))

      if expected_saas
        expect(jobs.keys).to include(*saas_job_names)
      elsif expected_jh
        expect(jobs.keys & saas_job_names).to match_array(pipl_job_names)
      else
        expect(jobs.keys & saas_job_names).to be_empty
      end

      if expected_jh
        pipl_job_names.each do |name|
          expect(jobs.fetch(name)).to eq('disabled')
        end
      end
    end
  end
end
