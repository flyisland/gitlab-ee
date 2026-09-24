# frozen_string_literal: true

module ContentValidation
  class ProcessChangesService
    def initialize(container:, project:, repo_type:, user:, changes:)
      @container = container
      @project = project
      @repo_type = repo_type
      @user = user
      @changes = changes
      @repository = container.repository
    end

    def execute
      return false unless ::ContentValidation::Setting.check_enabled?(@container)
      return false unless @user
      return false if pre_check_skip_validate?

      @changes.each do |change|
        commits = []
        if creating_default_branch?(change)
          commits = @repository.commits(change[:newrev], limit: process_commit_limit_count).reverse!
        elsif creating_ref?(change)
          commits = @repository.commits_between(
            @container.default_branch,
            change[:newrev],
            limit: process_commit_limit_count)
        elsif updating_ref?(change)
          commits = @repository.commits_between(change[:oldrev], change[:newrev], limit: process_commit_limit_count)
        end

        commits.each do |commit|
          ContentValidation::CommitServiceWorker.perform_async(commit.id, container_identifier, @user.id)
        end
      end
    end

    private

    def client
      @client ||= ::Gitlab::ContentValidation::Client.new
    end

    def pre_check_skip_validate?
      pre_check_params = {
        user_username: @user.username,
        group_full_path: @project&.group&.full_path,
        project_full_path: @project&.full_path
      }
      response = client.pre_check(pre_check_params)
      response&.success? && response.parsed_response["skip_validate"]
    end

    def container_identifier
      @container_identifier ||= @repo_type.identifier_for_container(@container)
    end

    def creating_ref?(change)
      Gitlab::Git.blank_ref?(change[:oldrev]) || !@repository.ref_exists?(change[:ref])
    end

    def creating_default_branch?(change)
      creating_ref?(change) && default_branch?(change)
    end

    def default_branch?(change)
      return false unless Gitlab::Git.branch_ref?(change[:ref])

      Gitlab::Git.branch_name(change[:ref]) == @container.default_branch
    end

    def updating_ref?(change)
      !creating_ref?(change) && !removing_ref?(change)
    end

    def removing_ref?(change)
      Gitlab::Git.blank_ref?(change[:newrev])
    end

    # The N most recent commits to process in a single change payload.
    def process_commit_limit_count
      ENV["CVS_PROCESS_COMMIT_LIMIT"]&.to_i || 5
    end
  end
end
