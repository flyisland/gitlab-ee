# frozen_string_literal: true

module JH
  module Gitlab
    module SubscriptionPortal
      extend ActiveSupport::Concern

      class_methods do
        extend ::Gitlab::Utils::Override

        def free_trial_url
          "https://gitlab.cn/free-trial/?utm_source=self-managed"
        end

        override :default_staging_customer_portal_url
        def default_staging_customer_portal_url
          'https://customers-stg.jihulab.com'
        end

        override :default_production_customer_portal_url
        def default_production_customer_portal_url
          'https://customers.jihulab.com'
        end
      end
    end
  end
end
