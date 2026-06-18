# frozen_string_literal: true

module DependencyManagement
  module SecurityUpdate
    class JobBuilder
      # Builds a job configuration hash compatible with the dependency-management orchestrator.
      # See: https://gitlab.com/gitlab-org/security-products/dependency-management/orchestrator/-/blob/main/schema.json

      # Maps GitLab package manager names to orchestrator ecosystem names.
      PACKAGE_MANAGER_MAPPING = {
        'bundler' => 'bundler',
        'maven' => 'maven',
        'gradle' => 'gradle'
      }.freeze

      # Ecosystems whose components GitLab stores as "group/artifact" but the
      # updater identifies as "group:artifact".
      COLON_SEPARATED_ECOSYSTEMS = %w[maven gradle].freeze

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
          'dependencies' => [dependency_name]
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

      def dependency_name
        return request.dependency unless COLON_SEPARATED_ECOSYSTEMS.include?(request.ecosystem)

        # GitLab stores the component as "namespace/name" (see Sbom::Occurrence), but the
        # updater identifies Maven/Gradle dependencies as "group:artifact". Convert the
        # namespace/name boundary (the last slash) so the updater matches the dependency.
        namespace, separator, name = request.dependency.rpartition('/')
        separator.empty? ? request.dependency : "#{namespace}:#{name}"
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
