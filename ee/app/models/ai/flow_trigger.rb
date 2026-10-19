# frozen_string_literal: true

module Ai
  class FlowTrigger < ApplicationRecord
    include FromUnion
    include Gitlab::Utils::StrongMemoize

    self.table_name = :ai_flow_triggers

    # Values match FLOW_TRIGGER_TYPES in ee/app/assets/javascripts/ai/duo_agents_platform/constants.js:
    # https://gitlab.com/gitlab-org/gitlab/-/blob/master/ee/app/assets/javascripts/ai/duo_agents_platform/constants.js#L186
    EVENT_TYPES = {
      mention: 0,
      assign: 1,
      assign_reviewer: 2,
      pipeline_hooks: 3,
      merge_request_ready: 4,
      merge_request_code_conflict: 5,
      merge_request: 6,
      work_item: 7,
      commit_to_default_branch: 8,
      scheduled: 9
    }.freeze

    EVENT_TYPES_BY_ID = EVENT_TYPES.invert.freeze

    # Event types where every run is initiator-less, so the service account acts
    # alone. Only add a type if no run of it can have a human behind it
    AUTONOMOUS_EVENT_TYPE_IDS = [
      EVENT_TYPES[:scheduled]
    ].freeze

    ALLOWED_FILTER_ACTIONS = {
      'merge_request' => %w[approved created merged].freeze,
      'work_item' => %w[created status_changed].freeze
    }.freeze

    # Allowed rule fields per event type, and allowed values per field.
    # A nil value list means any value is allowed for that field.
    # Status values match PIPELINE_HOOK_STATUSES in ee/app/assets/javascripts/ai/duo_agents_platform/constants.js
    ALLOWED_FILTER_FIELDS = {
      'pipeline_hooks' => {
        'object_attributes.status' => %w[running success failed canceled].freeze,
        'object_attributes.source' => ::Enums::Ci::Pipeline.sources.keys.map(&:to_s).freeze,
        'object_attributes.ref' => nil,
        'object_attributes.default_branch' => [true, false].freeze,
        'merge_request.title' => nil
      }.freeze,
      'work_item' => {
        # action values are validated separately by filter_action_values_allowed.
        'action' => nil,
        # Key path must match filter_data_extras in ExecuteWorkItemStatusChangedWorkflowTriggersWorker.
        'status.name' => nil
      }.freeze,
      'merge_request' => {
        # action values are validated separately by filter_action_values_allowed.
        'action' => nil
      }.freeze
    }.freeze

    belongs_to :project, optional: true
    belongs_to :group, optional: true
    belongs_to :user
    belongs_to :ai_catalog_item_consumer, class_name: 'Ai::Catalog::ItemConsumer'
    # Held only by autonomous triggers. Separate from user_id so a catalog
    # trigger keeps the consumer's shared account untouched.
    belongs_to :autonomous_service_account, class_name: 'User', optional: true

    has_one :parent_item_consumer, through: :ai_catalog_item_consumer
    has_many :flow_schedules, class_name: 'Ai::FlowSchedule', foreign_key: :ai_flow_trigger_id,
      inverse_of: :flow_trigger

    scope :triggered_on, ->(event_type) { where("event_types @> ('{?}')", EVENT_TYPES[event_type]) }
    # Skips autonomous triggers on purpose. Their dedicated account answers no
    # interactive event, so it must not surface in mention or assignment paths.
    scope :by_service_accounts, ->(service_accounts) {
      service_accounts = service_accounts.compact if service_accounts.is_a?(Array)

      from_union(
        [
          unscoped.where(user_id: service_accounts),
          unscoped.joins(:parent_item_consumer).where(parent_item_consumer: { service_account_id: service_accounts })
        ]
      )
    }
    scope :by_item_consumer_ids, ->(item_ids) { where(ai_catalog_item_consumer_id: item_ids) }
    scope :ordered_by_id, -> { order(:id) }
    scope :for_projects, ->(project_ids) { where(project_id: project_ids) }
    scope :active, -> { where(active: true) }

    # Firing-path guard: only active triggers count as registered.
    def self.registered_for?(project_id, event_type)
      return false unless project_id

      base = active.triggered_on(event_type)

      matched_project_id, matched_group_id = base.for_projects(project_id)
        .or(base.where(arel_table[:group_id].eq(root_group_id_subquery(project_id))))
        .order(arel_table[:project_id].asc.nulls_last)
        .pick(:project_id, :group_id)

      return true if matched_project_id
      return false unless matched_group_id

      Feature.enabled?(:ai_catalog_group_inherited_consumers, ::Group.actor_from_id(matched_group_id))
    end

    def self.applicable_to_container(container, by_service_accounts: nil, project_ids: nil)
      case container
      when ::Project
        applicable_to_project(container, by_service_accounts: by_service_accounts)
      when ::Namespace
        applicable_to_namespace(container, by_service_accounts: by_service_accounts, project_ids: project_ids)
      else
        none
      end
    end

    def self.applicable_to_project(project, triggered_on: nil, by_service_accounts: nil)
      return none unless project.is_a?(::Project)

      root_ancestor = project.root_ancestor
      base = apply_trigger_filters(for_projects(project.id), triggered_on: triggered_on)
      base = base.by_service_accounts(by_service_accounts) if by_service_accounts

      union_with_inherited(base, root_ancestor, triggered_on: triggered_on, by_service_accounts: by_service_accounts)
    end

    def self.applicable_to_namespace(namespace, by_service_accounts: nil, project_ids: nil)
      project_ids ||= namespace.project_ids
      root_ancestor = namespace.root_ancestor
      base = apply_trigger_filters(for_projects(project_ids))
      base = base.by_service_accounts(by_service_accounts) if by_service_accounts

      union_with_inherited(base, root_ancestor, triggered_on: nil, by_service_accounts: by_service_accounts)
    end

    def self.inherited_for_group(group)
      joins(:ai_catalog_item_consumer)
        .where(ai_catalog_item_consumers: { group_id: group.id, kind: :inheritance })
    end

    def self.union_with_inherited(base, root_ancestor, triggered_on:, by_service_accounts:)
      return base unless root_ancestor.is_a?(Group) &&
        Feature.enabled?(:ai_catalog_group_inherited_consumers, root_ancestor)

      inherited = apply_trigger_filters(inherited_for_group(root_ancestor), triggered_on: triggered_on)
      if by_service_accounts
        inherited = inherited.where(ai_catalog_item_consumers: { service_account_id: by_service_accounts })
      end

      from_union([base, inherited], remove_duplicates: false)
    end
    private_class_method :union_with_inherited

    private_class_method def self.root_group_id_subquery(project_id)
      root_group_query = ::Namespace
        .where(id: ::Project.where(id: project_id).select(:namespace_id))
        .select(Arel.sql('traversal_ids[1]'))

      Arel::Nodes::Grouping.new(root_group_query.arel)
    end

    def self.apply_trigger_filters(relation, triggered_on: nil)
      relation = relation.active
      relation = relation.triggered_on(triggered_on) if triggered_on
      relation
    end
    private_class_method :apply_trigger_filters

    validates :user, presence: true, unless: :ai_catalog_item_consumer
    validates :user, absence: true, if: :ai_catalog_item_consumer
    validates :autonomous_service_account, absence: true, unless: -> { event_types.blank? || autonomous_only? }
    # ItemConsumer builds triggers through nested attributes, bypassing the service
    # that assigns the account. Without this the trigger goes autonomous and
    # #service_account falls back to the consumer's shared, composite one.
    validates :autonomous_service_account, presence: true,
      if: -> { autonomous_only? && ai_catalog_item_consumer.present? }

    validates :event_types, presence: true
    validates :active, inclusion: { in: [true, false] }

    validates :description, length: { maximum: 255 }, presence: true
    validates :config_path, length: { maximum: 255 }, presence: true, unless: -> { ai_catalog_item_consumer.present? }

    validates :filter,
      json_schema: { filename: 'filter', size_limit: 8.kilobytes }

    before_validation :normalize_goals
    validates :goals,
      json_schema: { filename: 'ai_flow_trigger_goals', size_limit: 64.kilobytes, detail_errors: true }

    validates :ai_catalog_item_consumer, presence: true, unless: :config_path?

    validate :event_types_are_valid
    validate :scheduled_event_type_available
    validate :filter_keys_match_event_types
    validate :filter_action_values_allowed
    validate :filter_fields_and_values_allowed
    validate :user_is_service_account, if: :user
    validates_with ExactlyOnePresentValidator, fields: [:config_path, :ai_catalog_item_consumer]
    validates_with ExactlyOnePresentValidator, fields: [:project, :group]
    validate :catalog_item_valid, if: -> { ai_catalog_item_consumer.present? }
    validate :supported_events_match_foundational_flow, if: -> { ai_catalog_item_consumer.present? }
    validate :consumer_must_have_active_service_account, if: :ai_catalog_item_consumer
    validate :event_types_not_mixed_with_autonomous
    validate :autonomous_account_not_composite, if: :autonomous_only?
    validate :group_trigger_belongs_to_inheritance_consumer, if: -> { group_id.present? }
    validate :autonomous_account_is_provisioned, if: :autonomous_only?
    validate :goals_available, if: -> { goals.present? }
    validate :goal_keys_match_event_types
    validate :goals_supported_by_target, if: -> { goals.present? }

    scope :with_ids, ->(ids) { where(id: ids) }

    scope :include_parent_item_consumer, -> {
      includes(:parent_item_consumer)
    }

    def self.event_type_from_id(id)
      EVENT_TYPES_BY_ID[id]
    end

    # Triggers backed by this account in this project. Project-scoped because
    # entitlement must not carry across projects. Callers add `.active`
    # themselves, and revocation deliberately does not: pausing is reversible
    # and nothing re-adds the membership on resume, while
    # AutonomousServiceAccountEligibilityValidator refuses to run without it.
    # Entitlement does chain `.active`, so a paused account keeps a membership
    # row and no Duo access.
    def self.for_autonomous_service_account(service_account, project)
      return none unless service_account && project

      where(autonomous_service_account_id: service_account.id).for_projects(project.id)
    end

    # Callable before a trigger exists, so services deciding whether to
    # provision a dedicated account share one definition with the model.
    def self.autonomous_only?(event_types)
      ids = Array(event_types).map(&:to_i)

      ids.present? && (ids - AUTONOMOUS_EVENT_TYPE_IDS).empty?
    end

    # A trigger's own service account wins over the consumer's shared one, so an
    # autonomous trigger and an interactive trigger can sit on the same flow.
    def service_account_id
      return autonomous_service_account_id if autonomous_service_account_id.present?

      if for_ai_catalog_item_consumer?
        ai_catalog_item_consumer&.active_service_account_id
      else
        user_id
      end
    end

    def service_account
      return autonomous_service_account if autonomous_service_account.present?

      if for_ai_catalog_item_consumer?
        ai_catalog_item_consumer.active_service_account
      else
        user
      end
    end

    def container
      project || group
    end

    # Returns true when every event type on the trigger runs without
    # a human user, so the service account acts alone. Later MRs in this
    # stack use this to skip composite-identity enforcement; `BaseService`
    # currently enforces it for every trigger.
    def autonomous_only?
      self.class.autonomous_only?(event_types)
    end

    def foundational_flow
      ai_catalog_item_consumer&.item&.foundational_flow
    end
    strong_memoize_attr :foundational_flow

    def foundational_flow_precondition
      foundational_flow&.precondition.presence
    end
    strong_memoize_attr :foundational_flow_precondition

    def goal_supported?
      item = ai_catalog_item_consumer&.item

      item.nil? || item.accepts_trigger_goal?
    end
    strong_memoize_attr :goal_supported?

    # The stored goal, not the composed one dispatch sends.
    def stored_goal_for(event_type)
      goals[event_type.to_s].presence
    end

    private

    def for_ai_catalog_item_consumer?
      ai_catalog_item_consumer_id.present? || ai_catalog_item_consumer.present?
    end

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

    def scheduled_event_type_available
      return unless event_types&.include?(EVENT_TYPES[:scheduled])
      return unless newly_added_scheduled_event_type?
      return if Feature.enabled?(:autonomous_service_account_execution, project)

      errors.add(:event_types, 'scheduled events are not available')
    end

    # A flag rollback must not break saves (e.g. deactivation) on triggers that already
    # have scheduled, only block creating new ones or adding it to existing triggers.
    # Method should be removed during autonomous_service_account_execution
    # FF clean up
    def newly_added_scheduled_event_type?
      return true if new_record?

      event_types_was.to_a.exclude?(EVENT_TYPES[:scheduled])
    end

    # Composite identity is a per-account flag, so a single trigger still cannot
    # serve both modes. Two triggers on one flow can, because each autonomous
    # trigger holds its own account. Per-execution account selection would lift
    # this too.
    def event_types_not_mixed_with_autonomous
      return if event_types.blank?

      autonomous = event_types & AUTONOMOUS_EVENT_TYPE_IDS
      return if autonomous.empty? || autonomous_only?

      names = autonomous.filter_map { |id| EVENT_TYPES_BY_ID[id] }.join(', ')
      errors.add(:event_types, "cannot combine autonomous event types (#{names}) with other event types. " \
        "Create a separate trigger for them.")
    end

    # An autonomous run has no human to intersect permissions against, so its account
    # must be one provisioning created, never one the caller named.
    def autonomous_account_is_provisioned
      return if ai_catalog_item_consumer.present?

      errors.add(:event_types, 'autonomous event types require a flow, not a configuration file')
    end

    # Acting alone needs composite identity off, whichever account the trigger
    # runs as: its own for a catalog flow, user for a config_path trigger.
    def autonomous_account_not_composite
      return unless (autonomous_service_account || user)&.composite_identity_enforced?

      errors.add(:base, 'The service account for an autonomous trigger must not have composite identity enforced')
    end

    def goals_available
      return if Feature.enabled?(:ai_flow_trigger_goals, container)
      return unless goals.is_a?(Hash)
      return unless goals_added_or_changed?

      errors.add(:goals, 'are not available')
    end

    # A flag rollback must leave existing goals removable.
    def goals_added_or_changed?
      goals.any? { |event_type, goal| goals_was[event_type] != goal }
    end

    # The column is NOT NULL with a '{}' default, so nil means "no goals".
    # Blank values would otherwise persist as a second, meaningless "unset" state.
    def normalize_goals
      self.goals = {} if goals.nil?
      return unless goals.is_a?(Hash)

      self.goals = goals.transform_values { |goal| goal.is_a?(String) ? goal.strip : goal }
                        .reject { |_, goal| goal == '' }
    end

    def goals_supported_by_target
      return if goal_supported?
      # An item that is not a flow has no name to report, and catalog_item_valid
      # already refuses it.
      return unless foundational_flow

      errors.add(
        :base,
        format(
          s_('AICatalog|A goal cannot be set for the %{flow_name} flow.'),
          flow_name: foundational_flow.translated_display_name
        )
      )
    end

    def goal_keys_match_event_types
      return if goals.blank?
      return unless goals.is_a?(Hash)

      unsupported_keys = goals.keys - active_event_type_keys

      return if unsupported_keys.empty?

      errors.add(
        :base,
        format(
          s_('AICatalog|A goal cannot be set for an event type the trigger does not use: %{event_types}.'),
          event_types: unsupported_keys.join(', ')
        )
      )
    end

    def active_event_type_keys
      (event_types || []).filter_map { |id| EVENT_TYPES_BY_ID[id]&.to_s }
    end

    # Checks filter top-level keys against event_types; nested rule shape and the object type are covered by the JSON
    # schema validator, so non-hash values fall through to that error rather than getting a duplicate one here.
    def filter_keys_match_event_types
      return if filter.blank?
      return unless filter.is_a?(Hash)

      unsupported_filter_keys = filter.keys - active_event_type_keys

      return if unsupported_filter_keys.empty?

      errors.add(:filter, "contains filters for event types not in event_types: #{unsupported_filter_keys.join(', ')}")
    end

    def filter_action_values_allowed
      return if filter.blank?
      return unless filter.is_a?(Hash)

      filter.each do |event_type_key, group|
        allowed = ALLOWED_FILTER_ACTIONS[event_type_key]
        next unless allowed

        blank_values, action_values = collect_action_values(group).partition(&:blank?)

        errors.add(:filter, "action values for #{event_type_key} can't be blank") unless blank_values.empty?

        invalid_values = action_values - allowed
        next if invalid_values.empty?

        errors.add(:filter,
          "contains invalid action values for #{event_type_key}: #{invalid_values.join(', ')}. " \
            "Allowed values are: #{allowed.join(', ')}")
      end
    end

    def collect_action_values(group)
      collect_leaf_rules(group)
        .select { |rule| rule['field'] == 'action' }
        .flat_map { |rule| rule_values(rule) }
    end

    def filter_fields_and_values_allowed
      return if filter.blank?
      return unless filter.is_a?(Hash)

      filter.each do |event_type_key, group|
        allowed_fields = ALLOWED_FILTER_FIELDS[event_type_key]
        next unless allowed_fields

        rules = collect_leaf_rules(group)

        validate_rule_fields(event_type_key, rules, allowed_fields)

        known_rules = rules.select { |rule| allowed_fields.key?(rule['field']) }
        validate_rule_value_presence(event_type_key, known_rules.reject { |rule| action_rule?(event_type_key, rule) })
        validate_rule_values(event_type_key, known_rules, allowed_fields)
      end
    end

    def validate_rule_fields(event_type_key, rules, allowed_fields)
      invalid_fields = rules.filter_map { |rule| rule['field'] unless allowed_fields.key?(rule['field']) }.uniq
      return if invalid_fields.empty?

      errors.add(:filter,
        "contains invalid fields for #{event_type_key}: #{invalid_fields.join(', ')}. " \
          "Allowed fields are: #{allowed_fields.keys.join(', ')}")
    end

    # Blank values (nil, empty strings, empty arrays) pass the JSON schema but
    # can never match an event, so reject them explicitly.
    def validate_rule_value_presence(event_type_key, rules)
      blank_fields = rules.filter_map { |rule| rule['field'] if blank_rule_value?(rule) }.uniq
      blank_fields.each do |field|
        errors.add(:filter, "#{field} values for #{event_type_key} can't be blank")
      end
    end

    # Blank action values are already reported by filter_action_values_allowed.
    def action_rule?(event_type_key, rule)
      ALLOWED_FILTER_ACTIONS.key?(event_type_key) && rule['field'] == 'action'
    end

    def validate_rule_values(event_type_key, rules, allowed_fields)
      allowed_fields.each do |field, allowed_values|
        next if allowed_values.nil? # any value is allowed for this field

        values = rules.select { |rule| rule['field'] == field }.flat_map { |rule| rule_values(rule) }
        invalid_values = values.reject { |value| blank_value?(value) }.uniq - allowed_values
        next if invalid_values.empty?

        errors.add(:filter,
          "contains invalid #{field} values for #{event_type_key}: #{invalid_values.join(', ')}. " \
            "Allowed values are: #{allowed_values.join(', ')}")
      end
    end

    def rule_values(rule)
      rule['value'].nil? ? [nil] : Array(rule['value'])
    end

    def blank_rule_value?(rule)
      blank_value?(rule['value']) || Array(rule['value']).any? { |value| blank_value?(value) }
    end

    # false is a meaningful filter value (object_attributes.default_branch), not a blank.
    def blank_value?(value)
      value != false && value.blank?
    end

    # Returns the leaf rule hashes of a filter group, descending into nested
    # groups up to Gitlab::FilterEvaluator::MAX_DEPTH.
    def collect_leaf_rules(group, depth = 1)
      return [] unless group.is_a?(Hash)
      return [] if depth > Gitlab::FilterEvaluator::MAX_DEPTH

      Array(group['rules']).flat_map do |rule|
        next [] unless rule.is_a?(Hash)

        rule['type'] == 'group' ? collect_leaf_rules(rule, depth + 1) : [rule]
      end
    end

    def user_is_service_account
      return if user.service_account?

      errors.add(:user, 'user must be a service account')
    end

    def catalog_item_valid
      if ai_catalog_item_consumer.container != container
        errors.add(:base, 'ai_catalog_item_consumer container does not match container')
      end

      return if ai_catalog_item_consumer.item.flow? || ai_catalog_item_consumer.item.third_party_flow?

      errors.add(:base, 'ai_catalog_item_consumer is not a flow')
    end

    def group_trigger_belongs_to_inheritance_consumer
      consumer = ai_catalog_item_consumer

      return if consumer.present? && consumer.inheritance? && consumer.group_id == group_id

      errors.add(:base, _('A group trigger must belong to an inheritance consumer of the same group'))
    end

    def supported_events_match_foundational_flow
      supported = foundational_flow&.supported_events
      # A nil value means the flow has no event restrictions (any event is allowed). An empty array means the
      # flow explicitly supports no trigger events.
      return unless supported

      unsupported_event_types = event_types - supported
      if unsupported_event_types.any?
        errors.add(:event_types, "contains event types not supported by this foundational flow")
        return
      end

      return unless filter.is_a?(Hash)

      supported_keys = supported.map { |e| EVENT_TYPES.key(e).to_s }
      unsupported_filter_keys = filter.keys - supported_keys

      return unless unsupported_filter_keys.any?

      errors.add(:filter, "contains filters for unsupported event types: #{unsupported_filter_keys.join(', ')}")
    end
  end
end
