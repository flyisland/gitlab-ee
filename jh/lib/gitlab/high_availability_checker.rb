# frozen_string_literal: true

module Gitlab
  module HighAvailabilityChecker
    extend ActiveSupport::Concern
    include Gitlab::Utils::StrongMemoize

    def should_block_instance?
      return false if Feature.disabled?(:jh_block_free_ha)
      return false if Gitlab::Saas.feature_available?(:gitlab_com_subscriptions)

      free_version? && high_availability?
    rescue StandardError => error
      Gitlab::AppLogger.error("HighAvailabilityChecker: #{error.message}")
      false
    end

    private

    def free_version?
      current_license = ::License.current
      return true unless current_license&.paid?

      # Not deemed a "free version" until the grace period has expired
      current_license.grace_period_expired?
    end

    def high_availability?
      redis_sentinels_configured? || gitaly_cluster_configured? || postgresql_cluster_configured?
    end

    def redis_sentinels_configured?
      Gitlab::Redis::Wrapper.new.sentinels?
    rescue StandardError => error
      Gitlab::AppLogger.error("HighAvailabilityChecker for redis: #{error.message}")
      false
    end

    def gitaly_cluster_configured?
      return false if ::Prometheus::PidProvider.worker_id == 'puma_master'

      return true if Gitaly::Server.gitaly_clusters >= 1
      return true if Gitlab.config.repositories.storages.size > 1

      false
    rescue StandardError => error
      Gitlab::AppLogger.error("HighAvailabilityChecker for gitaly: #{error.message}")
      false
    end
    strong_memoize_attr :gitaly_cluster_configured?

    def postgresql_cluster_configured?
      db_config = ApplicationRecord.connection_db_config.configuration_hash
      return true if db_config.key?(:patroni) || db_config[:host]&.include?('patroni')

      pg_hosts = db_config.dig(:load_balancing, 'hosts')
      return true if pg_hosts.is_a?(Array) && pg_hosts.size > 1

      ApplicationRecord.connection.select_value("SHOW CLUSTER_NAME").present?
    rescue StandardError => error
      Gitlab::AppLogger.error("HighAvailabilityChecker for postgresql: #{error.message}")
      false
    end
  end
end
