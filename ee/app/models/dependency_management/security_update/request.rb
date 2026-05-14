# frozen_string_literal: true

module DependencyManagement
  module SecurityUpdate
    # Value object that wraps an Sbom::Occurrence and exposes
    # attributes needed for security update operations
    class Request
      attr_reader :sbom_occurrence, :vulnerability, :source_ref

      def initialize(sbom_occurrence:, vulnerability:, source_ref: nil)
        raise ArgumentError, 'sbom_occurrence is required' unless sbom_occurrence
        raise ArgumentError, 'vulnerability is required' unless vulnerability

        unless sbom_occurrence.project_id == vulnerability.project_id
          raise ArgumentError, 'vulnerability and sbom_occurrence must belong to the same project'
        end

        @sbom_occurrence = sbom_occurrence
        @vulnerability = vulnerability
        @source_ref = source_ref || sbom_occurrence.project.default_branch
      end

      def ecosystem
        sbom_occurrence.package_manager
      end

      def filepath
        sbom_occurrence.input_file_path
      end

      def dependency
        sbom_occurrence.component_name
      end

      def current_version
        sbom_occurrence.version
      end
    end
  end
end
