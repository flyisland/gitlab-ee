# frozen_string_literal: true

module JH
  module SubscriptionPortalHelper
    extend ::Gitlab::Utils::Override

    override :staging_customers_url
    def staging_customers_url
      'https://customers-stg.jihulab.com'
    end

    override :prod_customers_url
    def prod_customers_url
      'https://customers.jihulab.com'
    end
  end
end
