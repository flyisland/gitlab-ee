# frozen_string_literal: true

module JH
  module Gitlab
    module SubscriptionPortal
      module Client
        extend ActiveSupport::Concern

        class_methods do
          def subscriptions(plan_code = 'only_ci_minutes')
            http_get("manage/api/v1/subscriptions.json?plan_code=#{plan_code}", admin_headers)
          end
        end
      end
    end
  end
end
