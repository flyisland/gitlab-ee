# frozen_string_literal: true

module Organizations
  module Transfer
    class SbomWorker
      include ApplicationWorker

      data_consistency :sticky
      deduplicate :until_executed
      idempotent!
      feature_category :dependency_management
      urgency :low
      loggable_arguments 0, 1, 2

      concurrency_limit -> { 1 }

      defer_on_database_health_signal :gitlab_sec,
        [:sbom_components, :sbom_component_versions, :sbom_source_packages, :sbom_sources, :sbom_occurrences],
        1.minute

      def perform(group_id, old_organization_id, new_organization_id)
        group = ::Group.find_by_id(group_id)
        unless group
          logger.info(structured_payload(message: 'Group not found.', group_id: group_id))
          return
        end

        old_organization = ::Organizations::Organization.find_by_id(old_organization_id)
        unless old_organization
          logger.info(structured_payload(message: 'Old organization not found.', organization_id: old_organization_id))
          return
        end

        new_organization = ::Organizations::Organization.find_by_id(new_organization_id)
        unless new_organization
          logger.info(structured_payload(message: 'New organization not found.', organization_id: new_organization_id))
          return
        end

        ::Organizations::Transfer::SbomService.new(
          group: group,
          old_organization: old_organization,
          new_organization: new_organization
        ).execute
      end
    end
  end
end
