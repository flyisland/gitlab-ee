# frozen_string_literal: true

module Cd
  class EnvironmentDriverBinding < ApplicationRecord
    self.table_name = 'cd_environment_driver_bindings'

    belongs_to :environment, class_name: 'Cd::Environment', inverse_of: :environment_driver_bindings,
      optional: false
    belongs_to :organization, class_name: '::Organizations::Organization', optional: false
    has_many :rollout_environments, class_name: 'Cd::RolloutEnvironment', inverse_of: :driver_binding

    populate_sharding_key :organization_id, source: :environment

    before_update :prevent_modification

    scope :ordered, -> { order(version: :desc) }

    validates :driver_ref, presence: true, length: { maximum: 255 }
    validates :version, presence: true, uniqueness: { scope: :environment_id }
    validates :driver_config, json_schema: { filename: 'cd_environment_driver_config', size_limit: 64.kilobytes }

    private

    def prevent_modification
      raise ActiveRecord::ReadOnlyRecord, "#{self.class.name} is append-only and cannot be modified"
    end
  end
end
