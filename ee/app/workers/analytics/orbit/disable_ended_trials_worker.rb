# frozen_string_literal: true

module Analytics
  module Orbit
    class DisableEndedTrialsWorker
      include ApplicationWorker

      data_consistency :sticky
      feature_category :knowledge_graph
      urgency :low
      worker_has_external_dependencies!
      deduplicate :until_executed
      idempotent!
      # Each job makes one CDot call per trial group, so this caps the load on CDot.
      concurrency_limit -> { 5 }
      defer_on_database_health_signal :gitlab_main_org,
        [:orbit_namespace_enrollments, :knowledge_graph_enabled_namespaces], 10.minutes

      def perform(start_id, end_id)
        enabled_namespaces = ::Analytics::KnowledgeGraph::EnabledNamespace.for_root_namespace_id(start_id..end_id)
        disabled_count = 0

        begin
          NamespaceEnrollment.trials_not_ended_for(enabled_namespaces).preload_namespace.each do |enrollment|
            disabled_count += 1 if DisableEndedTrialService.new(enrollment: enrollment).execute.success?
          end
        rescue ::Gitlab::SubscriptionPortal::ProductTrialResponse::Error => e
          ::Gitlab::ErrorTracking.track_exception(e)
        end

        log_extra_metadata_on_done(:disabled_count, disabled_count)
      end
    end
  end
end
