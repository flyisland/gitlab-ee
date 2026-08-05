# frozen_string_literal: true

# Skip creating organization scoped versions of these
# See https://gitlab.com/gitlab-org/gitlab/-/blob/d2272513eabc62b1342e4d9f0d775f7c1764eae0/config/routes.rb#L412
unless @organization_scoped_routes
  resources(
    :organizations,
    path: 'o',
    param: :organization_path,
    constraints: {
      organization_path: Gitlab::PathRegex.organization_route_regex
    },
    only: [],
    module: :organizations
  ) do
    member do
      scope(path: '-') do
        resources :artifact_registry, only: [:index], as: :artifact_registry_organization

        get 'artifact_registry/:slug/repositories(/*vueroute)',
          to: 'artifact_registry_repositories#index',
          as: :artifact_registry_repositories,
          format: false

        scope :deploy do
          get '/(*vueroute)' => 'continuous_deployment#show', as: :deploy, format: false
          get 'applications', to: 'continuous_deployment#show', as: :deploy_applications, format: false
          get 'environments', to: 'continuous_deployment#show', as: :deploy_environments, format: false
        end
      end
    end
  end
end
