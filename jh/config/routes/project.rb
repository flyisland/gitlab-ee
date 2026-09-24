# frozen_string_literal: true

scope(path: '*namespace_id',
  as: :namespace,
  namespace_id: Gitlab::PathRegex.full_namespace_route_regex) do
  scope(path: ':project_id',
    constraints: { project_id: Gitlab::PathRegex.project_route_regex },
    module: :projects,
    as: :project) do
    scope '-' do
      resource :wiki_agent, only: :create

      namespace :analytics do
        resources :performance_analytics, only: [:index] do
          collection do
            get :summary
            get :leaderboard
            get :report
            get :report_summary
          end
        end
      end

      namespace :integrations do
        namespace :ones do
          resources :issues, only: [:index, :show]
        end
        namespace :ligaai do
          resources :issues, only: [:index, :show]
        end
        resource :shimo, only: [:show]
      end
    end
  end
end
