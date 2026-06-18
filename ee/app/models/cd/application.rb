# frozen_string_literal: true

module Cd
  class Application < ApplicationRecord
    self.table_name = 'cd_applications'

    belongs_to :group, class_name: '::Group', inverse_of: :cd_applications, optional: true
    belongs_to :organization, class_name: '::Organizations::Organization', optional: false
    has_many :services, class_name: 'Cd::Service', inverse_of: :application
    has_many :version_sets, class_name: 'Cd::VersionSet', inverse_of: :application
    has_many :application_flow_definitions, class_name: 'Cd::ApplicationFlowDefinition', inverse_of: :application

    validates :name, presence: true, length: { maximum: 255 }, uniqueness: { scope: :organization_id },
      format: { with: Gitlab::Regex.cd_name_regex, message: Gitlab::Regex.cd_name_regex_message }
    validates :description, length: { maximum: 2000 }

    scope :for_groups, ->(groups) { where(group: groups) }
    scope :for_organization, ->(organization_id) { where(organization_id: organization_id) }
    scope :in_organization, ->(organization) { where(organization_id: organization) }
  end
end
