# frozen_string_literal: true

module Projects
  class SecretsController < Projects::ApplicationController
    include ::SecretsManagement::EnrollmentHelper

    feature_category :secrets_management
    urgency :low, [:index]

    layout 'project'

    before_action :authorize_view_secrets!
    before_action :check_secrets_enabled!

    before_action do
      push_frontend_feature_flag(:secrets_manager_paid_experience)
    end

    private

    def authorize_view_secrets!
      render_404 unless can?(current_user, :read_project_secrets, project)
    end

    def check_secrets_enabled!
      render_404 unless secrets_manager_available_and_active_for_project?(project)
    end
  end
end
