# frozen_string_literal: true

module Organizations
  module ArtifactRegistryHelper
    def artifact_registry_repositories_app_data(organization, slug)
      {
        organization_gid: organization.to_global_id,
        slug: slug,
        base_path: artifact_registry_repositories_organization_path(organization, slug)
      }.to_json
    end
  end
end
