# frozen_string_literal: true

module Organizations
  class ArtifactRegistryRepositoriesController < ApplicationController
    include ArtifactRegistryGating

    feature_category :artifact_registry

    before_action :ensure_resolved_slug!

    def index; end

    private

    # A slug that does not match, and one the viewer may not see, both reach
    # render_404 by the same path, so the responses are byte-identical and cannot
    # enumerate an organization's slugs.
    #
    # A slug flip (rename, or delete-and-re-provision) stays a dead-end 404 with
    # no redirect: a redirect Location would leak the resolved slug to a probing
    # non-member. Slug discovery lands in #602638.
    def ensure_resolved_slug!
      registry = resolved_registry
      return render_404 if registry.nil?

      # Any client failure is unavailability: 503, so a bookmark is not reported
      # as a wrong URL. An AR 404 resolves to a slug-less Registry (a permanently
      # absent namespace), so it answers 404 like any other missing resource.
      return render_503 if registry.is_a?(::ArtifactRegistry::NamespaceMapping::ResolutionFailure)
      return render_404 if registry.slug.nil?

      render_404 unless requested_slug == registry.slug
    end

    # One resolution per request, shared by the gate and the view's mount data;
    # memoizing drops redundant model-cache lookups. Nil when there is no mapping
    # row (strong_memoize_attr caches nil too).
    def resolved_registry
      organization.artifact_registry_namespace_mapping&.registry
    end
    strong_memoize_attr :resolved_registry

    def requested_slug
      params.permit(:slug)[:slug]
    end

    # The mount anchors on the resolved slug, not the request path, so a
    # catch-all sub-path serves the same app as the base route. Reached only
    # after ensure_resolved_slug! confirms a slug resolved.
    def resolved_slug
      resolved_registry.slug
    end
    helper_method :resolved_slug
  end
end
