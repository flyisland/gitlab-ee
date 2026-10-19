# frozen_string_literal: true

module JH
  module Gitlab
    module Saas
      extend ActiveSupport::Concern

      JH_DISABLED_FEATURES = %i[google_cloud_support pipl_compliance].freeze

      class_methods do
        extend ::Gitlab::Utils::Override

        override :feature_available?
        def feature_available?(feature)
          super && JH_DISABLED_FEATURES.exclude?(feature)
        end
        override :customer_support_url
        def customer_support_url
          'https://support.gitlab.cn'
        end

        override :customer_license_support_url
        def customer_license_support_url
          'https://support.gitlab.cn/#/portal/submitticket/3'
        end

        override :gitlab_com_status_url
        def gitlab_com_status_url
          'https://status.gitlab.cn'
        end
      end
    end
  end
end
