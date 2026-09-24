# frozen_string_literal: true

Gitlab.jh do
  if ::Gitlab::Database.jh_database_configured?
    # Make sure connects_to for JH::ApplicationRecord gets called outside of config/routes.rb first
    # See InitializerConnections.raise_if_new_database_connection
    JH::ApplicationRecord
  end
end
