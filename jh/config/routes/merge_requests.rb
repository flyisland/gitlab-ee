# frozen_string_literal: true

resources :merge_requests, only: [:bulk_merge], constraints: { id: /\d+/ } do
  member do
    post :bulk_merge
  end
end
