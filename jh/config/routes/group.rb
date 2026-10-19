# frozen_string_literal: true

scope(path: 'groups/*group_id/-',
  module: :groups,
  as: :group,
  constraints: { group_id: Gitlab::PathRegex.full_namespace_route_regex }) do
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
end

namespace :import do
  resource :gitee, only: [:create, :new], controller: :gitee do
    post :personal_access_token
    post :reset_access_token
    get :status
    get :realtime_changes
  end
end
