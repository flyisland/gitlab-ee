# frozen_string_literal: true

module JH
  module Gitlab
    module Database
      extend ActiveSupport::Concern

      JH_DATABASE_NAME = 'jh'
      JH_DATABASE_DIR = 'jh/db'
      JH_IGNORE_TABLES_IN_TRANSACTION = [].freeze

      class_methods do
        extend ::Gitlab::Utils::Override

        override :all_database_connection_files
        def all_database_connection_files
          super + Dir.glob(Rails.root.join("jh/db/database_connections/*.yaml"))
        end

        override :all_gitlab_schema_files
        def all_gitlab_schema_files
          super + Dir.glob(Rails.root.join("jh/db/gitlab_schemas/*.yaml"))
        end

        def jh_database_configured?
          ::Gitlab::Database.has_config?(:jh)
        end
      end
    end
  end
end
