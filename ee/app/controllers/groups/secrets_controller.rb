# frozen_string_literal: true

module Groups
  class SecretsController < Groups::ApplicationController
    include ::SecretsManagement::DismissesNavBadge

    feature_category :secrets_management
    urgency :low, [:index]

    layout 'group'

    before_action :authorize_view_secrets!
    before_action :check_read_capability!

    before_action :dismiss_secrets_manager_badge, only: [:index]

    private

    def authorize_view_secrets!
      render_404 unless can?(current_user, :read_secret, group)
    end

    # Enforce the effective OpenBao READ capability so that users who have a
    # GitLab role (Reporter+) but no OpenBao grant cannot list secrets. Only
    # gate when the SM is actually active: while provisioning is in flight, the
    # user auth mount does not yet exist in OpenBao and capabilities-self would
    # fail closed and 404 the setup/progress page. For unprovisioned or
    # deprovisioning states, we let the page render its empty/setup state.
    def check_read_capability!
      secrets_manager = group.secrets_manager
      return unless secrets_manager&.active?

      capabilities = ::SecretsManagement::UserPermissions::GroupEffectiveCapabilitiesService.new(
        secrets_manager: secrets_manager,
        current_user: current_user,
        resource: group
      ).execute

      render_404 unless capabilities['read_metadata']
    end
  end
end
