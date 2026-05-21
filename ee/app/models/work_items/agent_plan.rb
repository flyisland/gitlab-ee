# frozen_string_literal: true

module WorkItems
  class AgentPlan < ApplicationRecord
    include CacheMarkdownField

    self.table_name = 'work_item_agent_plans'

    CONTENT_LENGTH_MAX = 128.kilobytes

    cache_markdown_field :content, storage: :external, issuable_reference_expansion_enabled: true
    self.external_storage_uploader_class = ::WorkItems::AgentPlanContentUploader

    belongs_to :work_item, inverse_of: :agent_plan
    belongs_to :namespace

    validates :namespace, presence: true
    validates :work_item, presence: true
    validates :content, length: { maximum: CONTENT_LENGTH_MAX }

    before_validation :set_namespace

    private

    def set_namespace
      return if work_item.nil?
      return if work_item.namespace == namespace

      self.namespace = work_item.namespace
    end
  end
end
