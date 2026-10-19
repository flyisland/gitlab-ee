# frozen_string_literal: true

module JH
  module Ai
    module SelfHostedDapBilling
      extend ActiveSupport::Concern

      class_methods do
        extend ::Gitlab::Utils::Override

        override :self_hosted_dap_billing_enabled?
        def self_hosted_dap_billing_enabled?
          return false if !::Gitlab.com? && ::Feature.enabled?(:jh_disable_billing)

          super
        end
      end
    end
  end
end
