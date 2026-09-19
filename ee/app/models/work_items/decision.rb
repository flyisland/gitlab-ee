# frozen_string_literal: true

module WorkItems
  class Decision < ApplicationRecord
    self.table_name = 'work_item_decisions'

    TITLE_LENGTH_MAX = 255
    SOURCE_LINK_LENGTH_MAX = 2048
    MAX_OPTIONS_PER_DECISION = 5

    # Soft limits, deliberately below the DB check constraints (3000) so they
    # can be raised without a migration
    DESCRIPTION_LENGTH_MAX = 1000
    RESOLUTION_RATIONALE_LENGTH_MAX = 800

    belongs_to :work_item, inverse_of: :decisions
    belongs_to :namespace
    belongs_to :author, class_name: 'User'
    belongs_to :resolved_by, class_name: 'User', optional: true
    belongs_to :resolving_note, class_name: 'Note', optional: true
    belongs_to :workflow, class_name: 'Ai::DuoWorkflows::Workflow', optional: true

    has_many :options,
      -> { order(:id) },
      class_name: 'WorkItems::DecisionOption',
      foreign_key: :work_item_decision_id,
      inverse_of: :decision

    validates :work_item, presence: true
    validates :namespace, presence: true
    validates :author, presence: true, on: :create
    validates :title, length: { maximum: TITLE_LENGTH_MAX }
    # Open decisions need the question; resolved-at-create decisions record
    # only the outcome (resolved_at is set before validation on that path)
    validates :title, presence: true, unless: :resolved_at?
    validates :description, length: { maximum: DESCRIPTION_LENGTH_MAX }
    validates :resolution_rationale, length: { maximum: RESOLUTION_RATIONALE_LENGTH_MAX }
    validates :source_link, length: { maximum: SOURCE_LINK_LENGTH_MAX }, addressable_url: true, allow_nil: true
    validates :discussion_id, format: { with: /\A\h{40}\z/ }, allow_nil: true
    # Only on the resolving transition: the FK is SET NULL on user deletion,
    # so persisted rows may legitimately have resolved_at without resolved_by
    validates :resolved_by, presence: true, if: -> { resolved_at? && resolved_at_changed? }

    before_validation :set_namespace

    # Used by GraphQL granular-token boundary extraction
    delegate :resource_parent, to: :work_item, allow_nil: true

    private

    def set_namespace
      return if work_item.nil?
      return if work_item.namespace_id == namespace_id

      self.namespace_id = work_item.namespace_id
    end
  end
end
