# frozen_string_literal: true

module DependencyManagement
  module SecurityUpdate
    class JobBuilder
      # Builds a job configuration hash compatible with the dependency-management orchestrator.
      # See: https://gitlab.com/gitlab-org/security-products/dependency-management/orchestrator/-/blob/main/schema.json

      # Maps GitLab package manager names to orchestrator ecosystem names.
      # Currently only bundler is supported. Additional package managers will be added in future iterations.
      PACKAGE_MANAGER_MAPPING = {
        'bundler' => 'bundler'
      }.freeze

      # @param request [DependencyManagement::SecurityUpdate::Request]
      # @param project [Project]
      def initialize(request:, project:)
        @request = request
        @project = project
      end

      def build
        {
          'package-manager' => package_manager,
          'source' => source_config,
          'dependencies' => [request.dependency]
        }
      end

      def to_json(*_args)
        build.to_json
      end

      private

      attr_reader :request, :project

      def package_manager
        PACKAGE_MANAGER_MAPPING.fetch(request.ecosystem, request.ecosystem)
      end

      def source_config
        {
          'repo' => project.full_path,
          'directories' => [directory_from_filepath]
        }
      end

      def directory_from_filepath
        return '/' if request.filepath.blank?

        dir = File.dirname(request.filepath)
        dir == '.' ? '/' : "/#{dir}"
      end
    end
  end
end
