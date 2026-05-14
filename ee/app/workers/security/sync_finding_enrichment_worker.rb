# frozen_string_literal: true

# This worker synchronizes security finding enrichments when CVE metadata is updated.
# It queries recently updated CVE enrichments, updates corresponding finding enrichments,
# and triggers MR approval updates for policies with enrichment filters.

module Security
  class SyncFindingEnrichmentWorker # rubocop:disable Scalability/IdempotentWorker -- Not guaranteed to be idempotent
    include ApplicationWorker

    data_consistency :sticky
    feature_category :security_policy_management
    urgency :low

    defer_on_database_health_signal :gitlab_main

    BATCH_SIZE = 100
    RECENTLY_UPDATED_PERIOD = 1.hour

    def perform
      return unless should_run?

      affected_projects = Set.new

      scope = PackageMetadata::CveEnrichment.updated_after(RECENTLY_UPDATED_PERIOD.ago)
      iterator = Gitlab::Pagination::Keyset::Iterator.new(scope: scope)

      iterator.each_batch(of: BATCH_SIZE) do |recently_updated_cves|
        process_cve_enrichment_batch(recently_updated_cves.pluck_id, affected_projects)
      end

      affected_projects.each { |project| update_mr_approvals_for(project) }
    end

    private

    def should_run?
      return false unless ::License.feature_available?(:security_orchestration_policies)
      return false if Rails.env.development? && ENV.fetch('PM_SYNC_IN_DEV', 'false') != 'true'

      true
    end

    def process_cve_enrichment_batch(recently_updated_cve_ids, affected_projects)
      recently_updated_cve_ids.each do |cve_enrichment_id|
        Security::FindingEnrichment.by_cve_enrichment_id(cve_enrichment_id)
                                   .including_project
                                   .each_batch(of: BATCH_SIZE) do |finding_enrichments|
          process_batch(finding_enrichments, affected_projects)
        end
      end
    end

    def process_batch(finding_enrichments, affected_projects)
      enrichment_attributes_by_project(finding_enrichments).each do |project, cve_enrichments|
        affected_count = upsert_finding_enrichments(cve_enrichments)
        affected_projects.add(project) if affected_count > 0
      end
    end

    def enrichment_attributes_by_project(finding_enrichments)
      cve_enrichments_by_id = cve_enrichments_by_id(finding_enrichments)

      finding_enrichments.group_by(&:project).transform_values do |enrichments|
        enrichments.map { |finding| enrichment_attributes(finding, cve_enrichments_by_id) }
      end
    end

    def cve_enrichments_by_id(finding_enrichments)
      PackageMetadata::CveEnrichment
        .id_in(finding_enrichments.map(&:cve_enrichment_id))
        .index_by(&:id)
    end

    def enrichment_attributes(finding, cve_enrichments_map)
      enrichment = cve_enrichments_map[finding.cve_enrichment_id]
      security_findings_attributes(finding.project.id, finding.finding_uuid, enrichment)
    end

    def security_findings_attributes(project_id, finding_uuid, enrichment)
      {
        project_id: project_id,
        finding_uuid: finding_uuid,
        cve_enrichment_id: enrichment.id,
        cve: enrichment.cve,
        epss_score: enrichment.epss_score,
        is_known_exploit: enrichment.is_known_exploit
      }
    end

    def upsert_finding_enrichments(enrichments)
      result = Security::FindingEnrichment.upsert_all(
        enrichments,
        unique_by: %i[finding_uuid cve],
        returning: [:project_id]
      )
      result.rows.count
    end

    def update_mr_approvals_for(project)
      policies_with_enrichment_filters_for(project).each do |policy|
        Security::SyncMergeRequestsWorker.perform_async(project.id, policy.id)
      end
    end

    def policies_with_enrichment_filters_for(project)
      project.security_policies.with_enrichment_filters.enabled
    end
  end
end
