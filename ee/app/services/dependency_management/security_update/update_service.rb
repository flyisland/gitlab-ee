# frozen_string_literal: true

module DependencyManagement
  module SecurityUpdate
    class UpdateService < BaseService
      include Gitlab::Utils::StrongMemoize

      ORCHESTRATOR_IMAGE = 'registry.gitlab.com/security-products/dependency-management/orchestrator:0'

      # Written inside the orchestrator container's /tmp dir - safe because
      # the container is single-use and discarded after the job completes.
      JOB_FILE_PATH = '/tmp/dependency-update-job.json'

      BRANCH_PREFIX = 'dependency-management'

      # @param request [DependencyManagement::SecurityUpdate::Request]
      # @return [ServiceResponse]
      def execute(request)
        return error_response(message: 'Automated dependency security updates not enabled') unless valid?
        return error_response(message: 'Security Update Request not found') unless request

        @request = request
        create_workload
      end

      private

      attr_reader :request

      def valid?
        project.can_store_security_reports?
      end

      def create_workload
        return error_response(message: 'Failed to retrieve or create bot user') unless bot_user

        service = Ci::Workloads::RunWorkloadService.new(
          project: project,
          current_user: bot_user,
          source: :dependency_management_security_update,
          workload_definition: build_workload_definition,
          ref: request.source_ref
        )

        response = service.execute
        return error_response(message: response.message) unless response.success?

        success_response(payload: { pipeline: response.payload.pipeline })
      end

      def build_workload_definition
        job_json = JobBuilder.new(request: request, project: project).to_json

        Ci::Workloads::WorkloadDefinition.new do |definition|
          definition.image = ORCHESTRATOR_IMAGE
          definition.commands = build_commands(job_json)
          definition.variables = build_variables
          # Expose output.json so CreateMergeRequestService can read
          # the updated file contents and dependency version changes.
          definition.artifacts_paths = ['output.json']
        end
      end

      def build_commands(job_json)
        [
          "echo #{Shellwords.shellescape(job_json)} > #{JOB_FILE_PATH}",
          "dependency-management-orchestrator update --job-file #{JOB_FILE_PATH}"
        ]
      end

      def build_variables
        {
          'DEPENDENCY_MANAGEMENT_PROJECT_PATH' => project.full_path,
          'DEPENDENCY_MANAGEMENT_SOURCE_REF' => request.source_ref,
          'DEPENDENCY_MANAGEMENT_TARGET_BRANCH' => target_branch,
          'DEPENDENCY_MANAGEMENT_VULNERABILITY_ID' => request.vulnerability.id.to_s
        }
      end

      # Generates a deterministic branch name for the security update.
      # Format: {prefix}/{depNameSanitized}-{major}.x
      #
      # Examples:
      #   - dependency-management/rails-6.x
      #   - dependency-management/nokogiri-1.x
      def target_branch
        "#{BRANCH_PREFIX}/#{dep_name_sanitized}-#{major_version}.x"
      end
      strong_memoize_attr :target_branch

      # Sanitizes dependency name for use in branch names.
      # Replaces non-alphanumeric characters with hyphens and lowercases.
      def dep_name_sanitized
        request.dependency
          .downcase
          .gsub(/[^a-z0-9]/, '-').squeeze('-')
          .gsub(/^-|-$/, '')
      end

      # Extracts the major version from the current version.
      def major_version
        version = request.current_version.to_s
        match = version.match(/^(\d+)/)
        match ? match[1] : '0'
      end

      def bot_user
        return project.security_policy_bot if project.security_policy_bot.present?

        response = Security::Orchestration::CreateBotService
          .new(project, nil, skip_authorization: true)
          .execute

        raise StandardError, "Security Orchestration Bot was not created." unless response.user&.persisted?

        response.user
      rescue StandardError => error
        log_error(error)
        nil
      end

      strong_memoize_attr :bot_user
    end
  end
end
