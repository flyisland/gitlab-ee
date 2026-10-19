# frozen_string_literal: true

module Security
  module ProjectTrackedContexts
    # FindOrCreateService encapsulates the logic to find or create `Security::ProjectTrackedContext` records.
    # If the tracked context does not exist, it will be created, but only if it's for the default branch.
    # Otherwise, it expects the context to already exist.
    class FindOrCreateService
      include Gitlab::Utils::StrongMemoize
      include Gitlab::ExclusiveLeaseHelpers
      include LoggableCreation

      LOCK_TTL = 10.seconds
      LOCK_RETRIES = 3
      LOCK_SLEEP_SEC = 0.2.seconds

      def self.from_pipeline(pipeline, allow_untracked: false)
        # Agentic analyzer: a duo_workflow workload that scanned the default branch (its
        # HEAD now, or at dispatch) binds to the default-branch context (its synthetic ref
        # is ephemeral).
        default_workload = Security::AgenticAnalyzer.default_branch_scan?(pipeline)
        context_ref = pipeline.tracked_context_ref

        new(
          project: pipeline.project,
          context_name: default_workload ? pipeline.project.default_branch_or_main : context_ref,
          # Workload pipelines are always branch-scoped; tag? is always false for them.
          context_type: pipeline.tag? ? :tag : :branch,
          is_default: default_workload || context_ref == pipeline.project.default_branch_or_main,
          allow_untracked: allow_untracked
        )
      end

      def self.project_default_branch(project)
        new(
          project: project,
          context_name: project.default_branch_or_main,
          context_type: :branch,
          is_default: true
        )
      end

      def initialize(**params)
        @project = params[:project]
        @context_name = params[:context_name]
        @context_type = params[:context_type]
        @is_default = params[:is_default]
        @allow_untracked = params[:allow_untracked] || false
        @current_user = params[:current_user]
      end

      attr_reader :project, :context_name, :context_type, :is_default, :allow_untracked, :current_user

      def execute
        return permission_error unless can_manage_contexts?
        return validation_error unless valid_params?
        return ref_not_found_error if current_user && !ref_exists_in_repository?

        # Fast path: most calls (including the GraphQL mutation path reachable from web
        # request threads) find an existing context and can return without ever touching
        # the lock.
        fast_path_response = existing_context_response
        return fast_path_response if fast_path_response

        # A lease inside an open transaction risks idle transactions (and raises in dev/test), so
        # these callers skip it. They stay unprotected against differently named defaults until
        # the unique index on default contexts lands.
        return create_or_update_context if inside_transaction?

        # `security_project_tracked_contexts` lives on the `sec` database, so we can't use
        # `project.with_lock` (it opens a `main`-database transaction and would create a
        # forbidden cross-database transaction). Use a Redis exclusive lease instead, scoped
        # narrowly to avoid serializing unrelated refs, and only around the mutating section
        # so web threads stay lock-free in the common case above.
        in_lock(lock_key, ttl: LOCK_TTL, retries: LOCK_RETRIES, sleep_sec: LOCK_SLEEP_SEC) do
          # Re-check on the primary: another process may have created the context since the
          # fast path, and a replica can lag behind that commit.
          ::Gitlab::Database::LoadBalancing::SessionMap.current(::SecApplicationRecord.load_balancer).use_primary do
            clear_memoization(:existing_context)
            clear_memoization(:existing_default_branch_context)

            locked_response = existing_context_response
            next locked_response if locked_response

            create_or_update_context
          end
        end
      rescue Gitlab::ExclusiveLeaseHelpers::FailedToObtainLockError
        ServiceResponse.error(message: 'Failed to obtain lock for tracked context creation')
      end

      private

      def create_or_update_context
        return success(updated_default_branch_context) if update_default_branch_context?
        return cant_create_non_default_error unless is_default || allow_untracked

        create_context
      end

      # Mirrors Gitlab::ExclusiveLease#report_lock_attempt_inside_transaction; keep them in sync.
      def inside_transaction?
        ::ApplicationRecord.inside_transaction? ||
          ::Gitlab::Database.database_base_models.values
            .reject { |model| model == ActiveRecord::Base }.any?(&:inside_transaction?)
      end

      def can_manage_contexts?
        return true unless current_user

        Ability.allowed?(current_user, :create_security_project_tracked_ref, project)
      end

      def valid_params?
        context_name.present? &&
          context_type.present? &&
          %w[branch tag].include?(context_type.to_s)
      end

      def ref_exists_in_repository?
        return false unless project.repository_exists?

        case context_type.to_s
        when 'branch'
          project.repository.branch_exists?(context_name)
        when 'tag'
          project.repository.tag_exists?(context_name)
        else
          false
        end
      end

      def permission_error
        ServiceResponse.error(message: 'Permission denied')
      end

      def validation_error
        ServiceResponse.error(message: 'Invalid ref name or type specified')
      end

      def ref_not_found_error
        ServiceResponse.error(message: 'Ref does not exist in repository')
      end

      def lock_key
        return "security:project_tracked_contexts:#{project.id}:default" if is_default

        "security:project_tracked_contexts:#{project.id}:#{context_type}:#{context_name}"
      end

      # Returns a ServiceResponse when a context already exists, or nil when the caller
      # should continue with the create/update logic.
      def existing_context_response
        return unless existing_context.present?

        return success(existing_context) if existing_context.tracked? || allow_untracked

        ServiceResponse.error(message: 'Context is not tracked')
      end

      def existing_context
        Security::ProjectTrackedContext.for_project(project).for_context_name(context_name)
        .for_context_type(context_type).first
      end
      strong_memoize_attr :existing_context

      def create_context
        state = if !is_default && @allow_untracked
                  Security::ProjectTrackedContext::STATES[:untracked]
                else
                  Security::ProjectTrackedContext::STATES[:tracked]
                end

        tracked_context = Security::ProjectTrackedContext.create(
          project: project,
          context_name: context_name,
          context_type: context_type,
          is_default: is_default,
          state: state,
          uuid_version: Security::ProjectTrackedContext::CONTEXT_AWARE_UUID_VERSION
        )

        return error(tracked_context) unless tracked_context.persisted?

        log_created(tracked_context)

        success(tracked_context)
      end

      def success(tracked_context)
        ServiceResponse.success(payload: { tracked_context: tracked_context })
      end

      def error(tracked_context)
        ServiceResponse.error(message: tracked_context.errors.full_messages)
      end

      def cant_create_non_default_error
        ServiceResponse.error(message: 'Expected context to already exist for non-default branches')
      end

      def branch_context?
        context_type == :branch
      end

      def update_default_branch_context?
        branch_context? && is_default && existing_default_branch_context.present?
      end

      def existing_default_branch_context
        project.security_project_tracked_contexts
          .default_branch
          .last
      end
      strong_memoize_attr :existing_default_branch_context

      def updated_default_branch_context
        existing_default_branch_context.tap { |context| context.update!(context_name: project.default_branch) }
      end
    end
  end
end
