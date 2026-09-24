# frozen_string_literal: true

module ContentValidation
  class ContainerService
    include Gitlab::Utils::StrongMemoize

    def initialize(container:, user:)
      @container = container
      @repository = container.repository
      @user = user

      case container
      when Project
        @repo_type = ::Gitlab::GlRepository::PROJECT
        @project = container
      when Wiki
        @repo_type = ::Gitlab::GlRepository::WIKI
        @project = container.is_a?(ProjectWiki) ? container.project : nil
      when Snippet
        @repo_type = ::Gitlab::GlRepository::SNIPPET
        @project = container.project
        @project = container.is_a?(ProjectSnippet) ? container.project : nil
      end
    end

    def execute
      return false unless ::ContentValidation::Setting.check_enabled?(@container)

      commit = @repository.commit
      return false unless commit

      ref = "refs/heads/#{@repository.root_ref}"
      changes = [{ oldrev: ::Gitlab::Git::SHA1_BLANK_SHA, newrev: commit.id, ref: ref }]
      ContentValidation::ProcessChangesService.new(
        container: @container,
        project: @project,
        repo_type: @repo_type,
        user: @user,
        changes: changes).execute
    end
  end
end
