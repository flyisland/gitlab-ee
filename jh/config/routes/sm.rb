# frozen_string_literal: true

resources :sms, only: [:verification_code] do
  collection do
    post :verification_code
  end
end

scope 'users', module: :users do
  resource :phone, only: [:show] do
    post :verify
    get :exists
  end
end
