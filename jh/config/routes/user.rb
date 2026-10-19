# frozen_string_literal: true

post "/users/reset_password_token", to: "users#reset_password_token"

scope(controller: :users, as: :user) do
  scope(path: 'users/:email') do
    get :email_exists, constraints: { email: %r{[^/]+} }
  end
end
