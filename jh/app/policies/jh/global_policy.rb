# frozen_string_literal: true

module JH
  module GlobalPolicy
    extend ActiveSupport::Concern
    extend ::Gitlab::Utils::Override

    prepended do
      condition(:phone_not_verified, scope: :user, score: 0) do
        @user.phone_required? && !@user.phone_present? if @user.is_a?(User)
      end

      rule { phone_not_verified }.policy do
        prevent :access_api
        prevent :access_git
      end
    end

    private

    override :dap_self_hosted?
    def dap_self_hosted?
      super || ::GitlabSubscriptions::AddOnPurchase.for_self_managed.for_duo_enterprise.active.exists?
    end
  end
end
