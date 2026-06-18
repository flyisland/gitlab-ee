# frozen_string_literal: true

module Cd
  class Service < ApplicationRecord
    self.table_name = 'cd_services'

    ignore_column :group_id, remove_with: '19.2', remove_after: '2026-07-15'

    belongs_to :application, class_name: 'Cd::Application', inverse_of: :services, optional: false
    belongs_to :organization, class_name: '::Organizations::Organization', optional: false
    has_one :artifact_source, class_name: 'Cd::ArtifactSource', inverse_of: :service

    populate_sharding_key :organization_id, source: :application

    validates :name, presence: true, length: { maximum: 255 }, uniqueness: { scope: :application_id },
      format: { with: Gitlab::Regex.cd_name_regex, message: Gitlab::Regex.cd_name_regex_message }
    validates :description, length: { maximum: 2000 }
  end
end
