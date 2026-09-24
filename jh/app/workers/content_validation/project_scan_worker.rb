# frozen_string_literal: true

module ContentValidation
  class ProjectScanWorker
    include ApplicationWorker

    data_consistency :always

    sidekiq_options retry: false

    feature_category :not_owned

    idempotent!

    deduplicate :until_executed, including_scheduled: true

    worker_has_external_dependencies!

    queue_namespace :content_validation

    def perform(project_id, options = {})
      begin
        project = Project.find project_id
      rescue ActiveRecord::RecordNotFound
        return
      end
      ::ContentValidation::ProjectScanService.new(project, options).execute
    end
  end
end
