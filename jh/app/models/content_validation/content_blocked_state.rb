# frozen_string_literal: true

module ContentValidation
  class ContentBlockedState < ApplicationRecord
    self.table_name = 'content_blocked_states'

    include Gitlab::Utils::StrongMemoize
    include ShaAttribute

    validates :container_identifier, presence: true
    validates :commit_sha, presence: true
    validates :blob_sha, presence: true
    validates :path, exclusion: { in: [nil] }

    sha_attribute :commit_sha
    sha_attribute :blob_sha

    delegate :full_path, to: :project, prefix: true, allow_nil: true

    def self.blocked?(container_identifier:, commit_sha:, path:)
      where(container_identifier: container_identifier, commit_sha: commit_sha, path: path).exists?
    end

    def self.find_by_container_commit_path(container, commit_sha, path)
      path = path&.gsub(%r{^/}, "")
      container_identifier = container.repository.repo_type.identifier_for_container(container)
      where(container_identifier: container_identifier, commit_sha: commit_sha, path: path).first
    end

    def self.find_by_container_file_path(container, path)
      path = path&.gsub(%r{^/}, "")
      container_identifier = container.repository.repo_type.identifier_for_container(container)
      where(container_identifier: container_identifier, path: path).first
    end

    def self.find_by_wiki_page(page, version = nil)
      container_identifier = page.wiki.repository.repo_type.identifier_for_container(page.wiki)
      commit = version || page.last_version
      where(container_identifier: container_identifier, commit_sha: commit&.id, path: page.path).first
    end

    def self.find_by_snippet_path(snippet, path)
      last_commit = Gitlab::Git::Commit.last_for_path(snippet.repository, snippet.default_branch, path)
      container_identifier = snippet.repository.repo_type.identifier_for_container(snippet)
      where(container_identifier: container_identifier, commit_sha: last_commit&.id, path: path).first
    end

    def self.find_by_snippet(snippet)
      snippet.list_files.filter_map { |file| find_by_snippet_path(snippet, file) }
    end

    def identifier
      ::Gitlab::Repositories::Identifier.parse(container_identifier)
    end
    strong_memoize_attr :identifier

    def container
      identifier.container
    end
    strong_memoize_attr :container

    def repo_type
      identifier.repo_type
    end
    strong_memoize_attr :repo_type

    def project
      repo_type.project_for(container)
    end
    strong_memoize_attr :project
  end
end
