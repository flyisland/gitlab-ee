# frozen_string_literal: true

module JH
  module Gitlab
    module SidekiqConfig
      extend ActiveSupport::Concern

      class_methods do
        extend ::Gitlab::Utils::Override

        override :config_queues
        def config_queues
          @jh_config_queues ||=
            if File.exist?(::Gitlab::SidekiqConfig::JH_SIDEKIQ_QUEUES_PATH)
              config = YAML.load_file(Rails.root.join(::Gitlab::SidekiqConfig::JH_SIDEKIQ_QUEUES_PATH))
              config[:queues].map(&:first)
            else
              []
            end

          super + @jh_config_queues
        end

        override :jh_queues_for_sidekiq_queues_yml
        def jh_queues_for_sidekiq_queues_yml
          namespaces_with_equal_weights =
            workers
              .select(&:jh?)
              .group_by(&:queue_namespace)
              .map(&:last)
              .select { |workers| workers.map(&:get_weight).uniq.count == 1 }
              .map(&:first)

          namespaces = namespaces_with_equal_weights.map(&:queue_namespace).to_set
          remaining_queues = workers.select(&:jh?)
                                    .reject { |worker| namespaces.include?(worker.queue_namespace) }

          (namespaces_with_equal_weights.map(&:namespace_and_weight) +
           remaining_queues.map(&:queue_and_weight)).sort
        end

        override :sidekiq_queues_yml_outdated?
        def sidekiq_queues_yml_outdated?
          if ::Gitlab.jh? && File.exist?(::Gitlab::SidekiqConfig::JH_SIDEKIQ_QUEUES_PATH)
            jh_config_queues = YAML.load_file(::Gitlab::SidekiqConfig::JH_SIDEKIQ_QUEUES_PATH)[:queues]
            jh_queues_for_sidekiq_queues_yml != jh_config_queues || super
          else
            super
          end
        end
      end

      prepended do
        ::Gitlab.jh do
          %w[scan_free_trial_user_worker remove_free_trial_user_worker].each do |job_name|
            Settings.cron_jobs[job_name] ||= {}
            Settings.cron_jobs[job_name]['cron'] ||= ENV.fetch("JH_FREE_TRIAL_JOB_CRON", "0 4 * * *")
          end
        end
      end
    end
  end
end
