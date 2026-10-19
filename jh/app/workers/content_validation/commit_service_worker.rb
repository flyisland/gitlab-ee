# frozen_string_literal: true

module ContentValidation
  class CommitServiceWorker
    include ApplicationWorker

    data_consistency :delayed

    sidekiq_options retry: 3

    loggable_arguments 0, 1

    feature_category :not_owned

    idempotent!

    deduplicate :until_executing

    worker_has_external_dependencies!

    queue_namespace :content_validation

    def perform(commit_id, container_identifier, user_id)
      container, project, repo_type = Gitlab::GlRepository.parse(container_identifier)

      return if container.nil?

      commit = container.repository.commit(commit_id)
      user = User.find_by_id(user_id)

      return if user.blank?

      ContentValidation::CommitService.new(
        commit: commit,
        container: container,
        project: project,
        repo_type: repo_type,
        user: user
      ).execute
    end
  end
end
