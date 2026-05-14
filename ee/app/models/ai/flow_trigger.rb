# frozen_string_literal: true

module Ai
  class FlowTrigger < ApplicationRecord
    include FromUnion

    self.table_name = :ai_flow_triggers

    # Values match FLOW_TRIGGER_TYPES in ee/app/assets/javascripts/ai/duo_agents_platform/constants.js:
    # https://gitlab.com/gitlab-org/gitlab/-/blob/9271ef8def87566d81f1e7047d8495c99b18ede7/ee/app/assets/javascripts/ai/duo_agents_platform/constants.js#L50
    EVENT_TYPES = {
      mention: 0,
      assign: 1,
      assign_reviewer: 2,
      pipeline_hooks: 3
    }.freeze

    belongs_to :project, optional: false
    belongs_to :user
    belongs_to :ai_catalog_item_consumer, class_name: 'Ai::Catalog::ItemConsumer'

    has_one :parent_item_consumer, through: :ai_catalog_item_consumer

    scope :triggered_on, ->(event_type) { where("event_types @> ('{?}')", EVENT_TYPES[event_type]) }
    scope :by_users, ->(users) { where(user: users) }
    scope :by_service_accounts, ->(service_accounts) {
      service_accounts = service_accounts.compact if service_accounts.is_a?(Array)

      from_union(
        [
          where(user_id: service_accounts),
          joins(:parent_item_consumer).where(parent_item_consumer: { service_account_id: service_accounts })
        ]
      )
    }
    scope :by_item_consumer_ids, ->(item_ids) { where(ai_catalog_item_consumer_id: item_ids) }
    scope :for_projects, ->(project_ids) { where(project_id: project_ids) }

    validates :project, presence: true
    validates :user, presence: true
    validates :event_types, presence: true

    validates :description, length: { maximum: 255 }, presence: true
    validates :config_path, length: { maximum: 255 }, presence: true, unless: -> { ai_catalog_item_consumer.present? }

    validates :filter,
      json_schema: { filename: 'filter', size_limit: 8.kilobytes }

    validates :ai_catalog_item_consumer, presence: true, unless: :config_path?

    validate :event_types_are_valid
    validate :user_is_service_account, if: :user
    validates_with ExactlyOnePresentValidator, fields: [:config_path, :ai_catalog_item_consumer]
    validate :catalog_item_valid, if: -> { ai_catalog_item_consumer.present? }
    validate :supported_events_match_foundational_flow, if: -> { ai_catalog_item_consumer.present? }
    validate :consumer_must_have_active_service_account, if: :ai_catalog_item_consumer

    scope :with_ids, ->(ids) { where(id: ids) }

    def service_account
      user || ai_catalog_item_consumer.active_service_account
    end

    private

    def consumer_must_have_active_service_account
      return if ai_catalog_item_consumer.active_service_account.present?

      errors.add(:ai_catalog_item_consumer_id, "must have an active service account")
    end

    def event_types_are_valid
      return if event_types.blank?

      invalid_types = event_types - EVENT_TYPES.values
      return if invalid_types.empty?

      errors.add(:event_types, "contains invalid event types: #{invalid_types.join(', ')}")
    end

    def user_is_service_account
      return if user.service_account?

      errors.add(:user, 'user must be a service account')
    end

    def catalog_item_valid
      if ai_catalog_item_consumer.project != project
        errors.add(:base, 'ai_catalog_item_consumer project does not match project')
      end

      return if ai_catalog_item_consumer.item.flow? || ai_catalog_item_consumer.item.third_party_flow?

      errors.add(:base, 'ai_catalog_item_consumer is not a flow')
    end

    def supported_events_match_foundational_flow
      return unless ai_catalog_item_consumer.item.foundational_flow?

      supported = ai_catalog_item_consumer.item.foundational_flow&.supported_events
      return unless supported&.any?

      unsupported_event_types = event_types - supported
      if unsupported_event_types.any?
        errors.add(:event_types, "contains event types not supported by this foundational flow")
      end

      supported_keys = supported.map { |e| EVENT_TYPES.key(e).to_s }
      unsupported_filter_keys = filter.keys - supported_keys

      return unless unsupported_filter_keys.any?

      errors.add(:filter, "contains filters for unsupported event types: #{unsupported_filter_keys.join(', ')}")
    end
  end
end
