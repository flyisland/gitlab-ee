# frozen_string_literal: true

module Security
  module Ingestion
    module Tasks
      class IngestVulnerabilities < AbstractTask
        def execute
          create_new_vulnerabilities
          update_existing_vulnerabilities
          apply_severity_overrides
          mark_redetected_vulnerabilities_as_not_removed_from_code
          mark_resolved_vulnerabilities_as_detected
          create_detection_transitions_for_redetected_vulnerabilities

          finding_maps
        end

        private

        def create_new_vulnerabilities
          IngestVulnerabilities::Create.new(pipeline, new_vulnerabilities).execute
        end

        def update_existing_vulnerabilities
          IngestVulnerabilities::Update.new(pipeline, existing_vulnerabilities).execute
          IngestVulnerabilities::SetPresentOnDefaultBranch.new(pipeline, existing_vulnerabilities).execute
        end

        def apply_severity_overrides
          IngestVulnerabilities::ApplySeverityOverrides.new(pipeline, existing_vulnerabilities).execute
        end

        def mark_redetected_vulnerabilities_as_not_removed_from_code
          ::Vulnerabilities::RepresentationInformation
            .by_vulnerability(existing_vulnerabilities.map(&:vulnerability_id))
            .update_all(removed_from_code: false)
        end

        def mark_resolved_vulnerabilities_as_detected
          IngestVulnerabilities::MarkResolvedAsDetected.execute(pipeline, existing_vulnerabilities)
        end

        def create_detection_transitions_for_redetected_vulnerabilities
          actor = pipeline.nil? ? :instance : pipeline.project
          return unless Feature.enabled?(:new_security_dashboard_exclude_no_longer_detected, actor)

          findings = redetected_findings_with_stale_transition
          return if findings.empty?

          ::Vulnerabilities::DetectionTransitions::InsertService.new(findings, detected: true).execute
        end

        def redetected_findings_with_stale_transition
          ::Vulnerabilities::Finding.by_vulnerability_with_stale_detection_transition(vulnerability_ids_not_resolved)
        end

        def vulnerability_ids_not_resolved
          ::Vulnerability
            .with_states(%i[detected confirmed dismissed])
            .id_in(existing_vulnerabilities.map(&:vulnerability_id))
            .pluck_primary_key
        end

        def partitioned_maps
          @partitioned_maps ||= finding_maps.partition { |finding_map| finding_map.vulnerability_id.nil? }
        end

        def new_vulnerabilities
          partitioned_maps.first
        end

        def existing_vulnerabilities
          partitioned_maps.second
        end
      end
    end
  end
end
