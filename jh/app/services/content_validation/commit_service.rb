# frozen_string_literal: true

module ContentValidation
  class CommitService
    include Gitlab::Utils::StrongMemoize

    # Size limit of the file need to validate.
    FILE_MAX_SIZE = 2.megabytes
    BINARY_FILE_MAX_SIZE = 10.megabytes

    def initialize(commit:, container:, project:, repo_type:, user:)
      @commit = commit
      @container = container
      @project = project
      @repo_type = repo_type
      @user = user
      @is_private = container.is_a?(Wiki) ? container.container.private? : container.private?
    end

    def execute
      return false unless ::ContentValidation::Setting.check_enabled?(@container)

      validate_trees
      validate_blobs
    end

    def validate_trees
      tree_paths = diffs.diff_paths.flat_map { |diff_path| get_parent_dirnames(diff_path) }.uniq

      tree_paths.each do |tree_path|
        tree = repository.tree(@commit.id, tree_path)
        tree_validate(tree)
      end
    end

    def validate_blobs
      diffs.diff_files.each do |diff_file|
        blob = diff_file.blob

        next if ContentBlockedState.blocked?(
          container_identifier: container_identifier,
          commit_sha: @commit.id,
          path: blob.path)

        if blob.binary?
          validate_binary_blob(blob)
        else
          validate_text_blob(blob, diff_file)
        end
      end
    end

    private

    def validate_binary_blob(blob)
      file_type, _ = file_extensions.detect { |_type, extensions| extensions.include?(blob.extension) }

      return unless file_type.present?

      return if blob.size > BINARY_FILE_MAX_SIZE

      binary_file_validate(file_type, blob, Base64.strict_encode64(blob.data))
    end

    def validate_text_blob(blob, diff_file)
      if diff_file.new_file? || last_for_path_commit_blocked?(blob.path)
        return if blob.size > FILE_MAX_SIZE

        content = [blob.name, blob.data].join("\n")
        incremental = false
      else
        return if diff_file.diff.diff_bytesize > FILE_MAX_SIZE

        content = diff_file.diff.diff.split("\n").grep(/^\+/).map { |line| line[1..] }.join("\n")
        incremental = true
      end

      blob_validate(blob, content, incremental) if content.present?
    end

    def client
      @client ||= ::Gitlab::ContentValidation::Client.new
    end

    def repository
      @container.repository
    end
    strong_memoize_attr :repository

    def parent_commit
      @commit.parent
    end
    strong_memoize_attr :parent_commit

    def container_identifier
      @repo_type.identifier_for_container(@container)
    end
    strong_memoize_attr :container_identifier

    def diffs
      # TODO: Uncouple diffing from projects, so we can just do `commit.diffs(opts)` here.
      # https://gitlab.com/gitlab-org/gitlab/-/issues/217752
      Gitlab::Diff::FileCollection::Base.new(
        @commit,
        project: @container,
        diff_refs: @commit.diff_refs
      )
    end

    def last_for_path_commit_blocked?(path)
      last_for_path_commit = ::Gitlab::Git::Commit.last_for_path(repository, parent_commit&.id, path)

      last_for_path_commit.present? &&
        ContentBlockedState.blocked?(
          container_identifier: container_identifier,
          commit_sha: last_for_path_commit.id,
          path: path)
    end

    def tree_validate(tree)
      content = tree.entries.map(&:name).join("\n")
      data = base_data.merge({
        is_private: @is_private,
        blob_sha: tree.sha,
        path: tree.path.gsub(%r{/^//}, ""),
        incremental: false,
        content_type: "tree",
        text: Base64.encode64(content)
      })
      client.blob_validate(data)
    end

    def blob_validate(blob, content, incremental)
      data = base_data.merge({
        is_private: @is_private,
        blob_sha: blob.id,
        path: blob.path,
        incremental: incremental,
        content_type: "text",
        text: Base64.encode64(content)
      })
      client.blob_validate(data)
    end

    def binary_file_validate(file_type, blob, data)
      data = base_data.merge({
        is_private: @is_private,
        blob_sha: blob.id,
        path: blob.path,
        incremental: false,
        content_type: file_type.to_s
      }).merge({ file_type.to_sym => data })
      client.blob_validate(data)
    end

    def base_data
      {
          container_identifier: container_identifier,
          project_id: @project&.id,
          project_full_path: @project&.full_path,
          group_id: @project&.group&.id,
          group_full_path: @project&.group&.full_path,
          repo_type: @repo_type.name,
          commit_sha: @commit.id,
          user_id: @user.id,
          user_username: @user.username,
          user_email: @user.email
        }
    end
    strong_memoize_attr :base_data

    def get_parent_dirnames(path)
      return [] if path == ""

      dirname = File.dirname(path)
      dirname = "" if dirname == "."
      get_parent_dirnames(dirname).push(dirname)
    end

    def file_extensions
      @file_extensions ||= {
        image: %w[png jpg jpeg gif bmp webp],
        audio: %w[mp3 ogg wav],
        video: %w[mp4 mov]
      }
    end
  end
end
