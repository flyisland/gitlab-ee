# frozen_string_literal: true

module Groups
  module Settings
    class ServiceAccountsController < Groups::ApplicationController
      include ::GitlabSubscriptions::SubscriptionHelper

      feature_category :user_management

      before_action :authorize_read_service_accounts!, only: [:index, :show]

      before_action do
        push_frontend_feature_flag(:edit_service_account_email, group)
      end

      private

      def authorize_read_service_accounts!
        render_404 unless can?(current_user, :read_service_account, group)
      end
    end
  end
end
