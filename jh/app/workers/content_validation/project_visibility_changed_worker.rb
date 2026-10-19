# frozen_string_literal: true

module ContentValidation
  class ProjectVisibilityChangedWorker
    include ApplicationWorker

    data_consistency :delayed

    sidekiq_options retry: true

    loggable_arguments 0, 1

    feature_category :not_owned

    idempotent!

    deduplicate :until_executing

    worker_has_external_dependencies!

    queue_namespace :content_validation

    def perform(project_id, user_id)
      project = Project.find project_id
      user = User.find user_id
      ::ContentValidation::ProjectVisibilityChangedService.new(project, user).execute
    end
  end
end
