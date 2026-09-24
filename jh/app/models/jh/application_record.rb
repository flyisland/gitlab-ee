# frozen_string_literal: true

module JH
  class ApplicationRecord < ::ApplicationRecord
    self.abstract_class = true

    connects_to database: { writing: :jh, reading: :jh } if ::Gitlab::Database.has_config?(:jh)

    def self.table_name_prefix
      'jh_'
    end

    def self.model_name
      @model_name ||= ActiveModel::Name.new(self, nil, name.demodulize)
    end
  end

  # rubocop: disable Database/AvoidUsingPluckWithoutLimit -- we need it
  class SchemaMigration < ApplicationRecord
    self.table_name = 'schema_migrations'

    class << self
      def all_versions
        order(:version).pluck(:version)
      end
    end
  end
  # rubocop: enable Database/AvoidUsingPluckWithoutLimit
end
