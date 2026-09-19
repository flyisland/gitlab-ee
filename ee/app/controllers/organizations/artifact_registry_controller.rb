# frozen_string_literal: true

module Organizations
  class ArtifactRegistryController < ApplicationController
    include ArtifactRegistryGating

    feature_category :artifact_registry

    before_action :handle_activation_state

    # The setup page mount, reached only for an org with no mapping row; every
    # other outcome is answered by the before_action.
    def index; end

    private

    def handle_activation_state
      mapping = organization.artifact_registry_namespace_mapping

      # No row: only an owner may claim a slug, so the setup mount needs the update
      # ability on top of the read ability the gating concern already checked.
      return authorize_admin_organization! unless mapping

      registry = mapping.registry

      # No resolved slug to redirect to. A bookmarked landing URL is answered as
      # unavailable rather than not-found, so a transient outage and a 404-to-unknown
      # both fold into 503 here (the repositories route splits them).
      return render_503 unless resolved_slug?(registry)

      # Non-read-serving statuses (for example disabled) redirect too and are
      # surfaced by the repositories app for now; a dedicated state is
      # https://gitlab.com/gitlab-org/gitlab/-/issues/623320.
      redirect_to_repositories(registry.slug)
    end

    def resolved_slug?(registry)
      !registry.is_a?(::ArtifactRegistry::NamespaceMapping::ResolutionFailure) && registry.slug.present?
    end

    def redirect_to_repositories(slug)
      redirect_to artifact_registry_repositories_organization_path(organization, slug)
    end
  end
end
