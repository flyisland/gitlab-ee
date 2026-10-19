# frozen_string_literal: true

module JH
  module GitlabSubscriptions
    module SubscriptionsController
      extend ActiveSupport::Concern
      extend ::Gitlab::Utils::Override

      override :purchase_url

      def purchase_url(plan_id:, namespace:, **params)
        if namespace.present?
          callback_url = ::Gitlab::Utils.append_path(::Gitlab.config.gitlab.url, group_billings_path(namespace))
          params = params.merge({ redirect_after_success: callback_url })
        end

        super
      end
    end
  end
end
