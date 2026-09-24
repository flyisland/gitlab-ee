# frozen_string_literal: true

module JH
  module MigrationsHelpers
    extend ::Gitlab::Utils::Override

    override :active_record_base
    def active_record_base(database: nil)
      return db_base_model if custom_migration?

      database_name = database || self.class.metadata[:database] || :main

      unless ::Gitlab::Database.all_database_connections.include?(database_name)
        raise ArgumentError, "#{database_name} is not a valid argument"
      end

      ::Gitlab::Database.database_base_models[database_name] || ::Gitlab::Database.database_base_models[:main]
    end
  end
end
