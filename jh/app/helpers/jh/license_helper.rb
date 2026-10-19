# frozen_string_literal: true

module JH
  module LicenseHelper
    extend ::Gitlab::Utils::Override

    override :self_managed_new_trial_url
    def self_managed_new_trial_url
      return super if ::Gitlab.com?

      ::Gitlab::SubscriptionPortal.free_trial_url
    end
  end
end
