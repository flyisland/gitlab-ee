# frozen_string_literal: true

module Analytics
  module Orbit
    module Trial
      TRIAL_TYPE = :orbit

      # Status reads run on page loads, so a stalled CDot must not stall the page.
      STATUS_HTTP_TIMEOUT_SECONDS = 2.0

      def self.available_for?(group)
        ::Gitlab::Saas.feature_available?(:gitlab_com_subscriptions) && ::Feature.enabled?(:orbit_trial, group)
      end

      def self.status_for(group, timeout: STATUS_HTTP_TIMEOUT_SECONDS)
        ::Gitlab::SubscriptionPortal::Client.product_trial(
          trial_type: TRIAL_TYPE, namespace_id: group.id, timeout: timeout
        )
      end
    end
  end
end
