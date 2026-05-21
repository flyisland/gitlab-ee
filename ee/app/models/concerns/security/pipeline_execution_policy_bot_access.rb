# frozen_string_literal: true

module Security
  module PipelineExecutionPolicyBotAccess
    extend ActiveSupport::Concern

    # Strip leading './' to normalize relative paths for consistent comparison
    LEADING_RELATIVE_PATH_PATTERN = %r{^\./}
    MAX_FILE_PATTERNS = 20
    MAX_FILE_PATTERN_LENGTH = 255

    included do
      belongs_to :pipeline_execution_policy_bot_access_group,
        class_name: 'Group',
        optional: true

      before_validation :normalize_pipeline_execution_policy_bot_access_file_patterns,
        if: :pipeline_execution_policy_bot_access_enabled?
      validate :validate_pipeline_execution_policy_bot_access_file_patterns_length,
        if: :pipeline_execution_policy_bot_access_enabled?
      validate :validate_pipeline_execution_policy_bot_access_file_patterns_format,
        if: :pipeline_execution_policy_bot_access_enabled?
      validate :validate_pipeline_execution_policy_bot_access_group,
        if: :pipeline_execution_policy_bot_access_group_id?
    end

    def allows_pipeline_execution_policy_bot_access?(file_path:, bot_project:)
      return false unless pipeline_execution_policy_bot_access_enabled?
      return false unless pipeline_execution_policy_bot_access_experiment_enabled?
      return false unless bot_project_in_allowed_group?(bot_project)

      file_pattern_matches?(file_path)
    end

    def pipeline_execution_policy_bot_access_experiment_enabled?
      project.all_security_orchestration_policy_configurations.any? do |config|
        config.experiment_enabled?(:pipeline_execution_policy_bot_access)
      end
    end

    private

    def resolved_pipeline_execution_policy_bot_access_group
      return pipeline_execution_policy_bot_access_group if pipeline_execution_policy_bot_access_group_id.present?

      root = project.root_ancestor
      return unless root.is_a?(Group)

      root
    end

    def file_pattern_matches?(file_path)
      return false if pipeline_execution_policy_bot_access_file_patterns.empty?

      normalized_path = normalize_file_path(file_path)
      return false if normalized_path.nil?

      pipeline_execution_policy_bot_access_file_patterns.any? do |pattern|
        # Matches file path against glob pattern with:
        # - FNM_PATHNAME: wildcards don't match directory separators
        # - FNM_EXTGLOB: enables brace expansion (e.g. *.{rb,js})
        File.fnmatch?(pattern, normalized_path, File::FNM_PATHNAME | File::FNM_EXTGLOB)
      end
    end

    def bot_project_in_allowed_group?(bot_project)
      return false unless bot_project

      allowed_group = resolved_pipeline_execution_policy_bot_access_group
      return false unless allowed_group

      bot_project_namespace = bot_project.namespace
      return false unless bot_project_namespace

      bot_project_namespace.self_and_ancestors.exists?(id: allowed_group.id)
    end

    def normalize_file_path(file_path)
      return if file_path.blank?

      normalized = file_path.sub(LEADING_RELATIVE_PATH_PATTERN, '')

      return if Gitlab::PathTraversal.path_traversal?(normalized)
      return if normalized.start_with?('/')

      normalized
    end

    def normalize_pipeline_execution_policy_bot_access_file_patterns
      self.pipeline_execution_policy_bot_access_file_patterns =
        pipeline_execution_policy_bot_access_file_patterns.map do |pattern|
          pattern.sub(LEADING_RELATIVE_PATH_PATTERN, '')
        end
    end

    def validate_pipeline_execution_policy_bot_access_file_patterns_length
      return unless pipeline_execution_policy_bot_access_file_patterns.length > MAX_FILE_PATTERNS

      errors.add(
        :pipeline_execution_policy_bot_access_file_patterns,
        format(_('cannot have more than %{max} file patterns'), max: MAX_FILE_PATTERNS)
      )
    end

    def validate_pipeline_execution_policy_bot_access_file_patterns_format
      pipeline_execution_policy_bot_access_file_patterns.each do |pattern|
        if pattern.blank?
          errors.add(:pipeline_execution_policy_bot_access_file_patterns, _('cannot contain empty patterns'))
        elsif pattern.length > MAX_FILE_PATTERN_LENGTH
          errors.add(
            :pipeline_execution_policy_bot_access_file_patterns,
            format(_('individual patterns cannot exceed %{max} characters'), max: MAX_FILE_PATTERN_LENGTH)
          )
        elsif pattern.start_with?('/')
          errors.add(:pipeline_execution_policy_bot_access_file_patterns, _('cannot start with /'))
        elsif Gitlab::PathTraversal.path_traversal?(pattern)
          errors.add(:pipeline_execution_policy_bot_access_file_patterns, _('cannot contain path traversal'))
        end
      end
    end

    def validate_pipeline_execution_policy_bot_access_group
      return if pipeline_execution_policy_bot_access_group_id.nil?

      unless Group.exists?(id: pipeline_execution_policy_bot_access_group_id)
        errors.add(:pipeline_execution_policy_bot_access_group, _('must be a valid group'))
        return
      end

      root = project.root_ancestor
      return unless root.is_a?(Group)

      return if root.self_and_descendants.exists?(id: pipeline_execution_policy_bot_access_group_id)

      errors.add(:pipeline_execution_policy_bot_access_group, _('must be within the project hierarchy'))
    end
  end
end
