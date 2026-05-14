# frozen_string_literal: true

module Groups
  class SecretsController < Groups::ApplicationController
    feature_category :secrets_management
    urgency :low, [:index]

    layout 'group'

    before_action :authorize_view_secrets!
    before_action :check_secrets_enabled!

    private

    def authorize_view_secrets!
      render_404 unless can?(current_user, :read_secret, group)
    end

    def check_secrets_enabled!
      return render_404 unless Feature.enabled?(:group_secrets_manager, group)
      return render_404 unless group.licensed_feature_available?(:native_secrets_management)

      secrets_manager = SecretsManagement::GroupSecretsManager.find_by_group_id(group.id)
      render_404 unless secrets_manager&.active?
    end
  end
end
