# frozen_string_literal: true

module Groups
  class SecretsController < Groups::ApplicationController
    include ::SecretsManagement::EnrollmentHelper

    feature_category :secrets_management
    urgency :low, [:index]

    layout 'group'

    before_action :authorize_view_secrets!
    before_action :check_secrets_enabled!

    before_action do
      push_frontend_feature_flag(:secrets_manager_paid_experience)
    end

    private

    def authorize_view_secrets!
      render_404 unless can?(current_user, :read_secret, group)
    end

    def check_secrets_enabled!
      render_404 unless secrets_manager_available_and_active_for_group?(group)
    end
  end
end
