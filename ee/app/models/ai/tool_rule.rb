# frozen_string_literal: true

module Ai
  class ToolRule < ApplicationRecord
    self.table_name = 'ai_tool_rules'

    belongs_to :namespace

    enum :web_access, { allow: 0, ask: 1, deny: 2 }, prefix: true
    enum :local_access, { allow: 0, ask: 1, deny: 2 }, prefix: true

    validates :tool_name,
      presence: true,
      inclusion: {
        in: ->(_) { Ai::ToolRules::Registry.all_tool_names },
        message: "%{value} is not a known tool name"
      },
      uniqueness: { scope: :namespace_id }

    validates :tool_arguments, json_schema: { filename: 'ai_tool_rule_tool_arguments', size_limit: 64.kilobytes },
      allow_nil: true

    validates :namespace, presence: true
    validate :validate_access_permissions_present

    scope :for_namespace, ->(namespace_id) { where(namespace_id: namespace_id) }

    private

    def validate_access_permissions_present
      return if web_access.present? || local_access.present?

      errors.add(:base, 'must have at least one of web_access or local_access set')
    end
  end
end
