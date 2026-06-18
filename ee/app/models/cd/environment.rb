# frozen_string_literal: true

module Cd
  class Environment < ApplicationRecord
    self.table_name = 'cd_environments'

    belongs_to :group, class_name: '::Group', inverse_of: :cd_environments, optional: true
    belongs_to :organization, class_name: '::Organizations::Organization', optional: false
    belongs_to :cluster_agent, class_name: 'Clusters::Agent', optional: false

    has_many :rollouts, class_name: 'Cd::Rollout', inverse_of: :environment
    has_many :deployments, through: :rollouts

    validates :name, presence: true, length: { maximum: 255 }, uniqueness: { scope: :organization_id },
      format: { with: Gitlab::Regex.cd_name_regex, message: Gitlab::Regex.cd_name_regex_message }
    validates :description, length: { maximum: 1024 }
    validates :region, length: { maximum: 255 }
    validate :cluster_agent_in_same_organization, if: -> { cluster_agent_id.present? }

    enum :platform_type, { kubernetes: 0 }

    scope :for_namespace, ->(namespace_id) { where(group_id: namespace_id) }
    scope :for_organization, ->(organization_id) { where(organization_id: organization_id) }
    scope :for_groups, ->(groups) { where(group: groups) }
    scope :in_organization, ->(organization) { where(organization_id: organization) }
    scope :order_by_name_asc, -> { order(name: :asc) }

    private

    def cluster_agent_in_same_organization
      parent_organization_id = group&.organization_id || organization_id
      return if cluster_agent.project.organization_id == parent_organization_id

      errors.add(:cluster_agent, 'must belong to the same organization')
    end
  end
end
