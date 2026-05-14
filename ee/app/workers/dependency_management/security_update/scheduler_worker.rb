# frozen_string_literal: true

module DependencyManagement
  module SecurityUpdate
    class SchedulerWorker
      include Gitlab::EventStore::Subscriber

      data_consistency :delayed
      feature_category :dependency_management
      urgency :low
      deduplicate :until_executed
      idempotent!

      defer_on_database_health_signal :gitlab_sec, [:sbom_occurrences], 1.minute

      def handle_event(event)
        findings = event.data['findings']
        return if findings.blank?

        project_ids = findings.filter_map { |f| f['project_id'] }.uniq

        Project.id_in(project_ids).each do |project|
          next unless Feature.enabled?(:dependency_management_auto_remediation, project)

          DependencyManagement::SecurityUpdate::SchedulerService.execute(project: project)
        end
      end
    end
  end
end
