# frozen_string_literal: true

module ContentValidation
  class ProjectScanService
    include Gitlab::Utils::StrongMemoize

    FILE_MAX_SIZE = 2.megabytes
    BINARY_FILE_MAX_SIZE = 10.megabytes
    TREE_COMMITS_LIMIT = 100

    attr_reader :project, :ref, :scan_path, :recursive, :include_binary

    def initialize(project, options = {})
      @project = project
      @ref = options.fetch(:ref, project.default_branch)
      @scan_path = options.fetch(:scan_path, "")
      @recursive = options.fetch(:recursive, true)
      @include_binary = options.fetch(:include_binary, false)
    end

    def execute
      return unless ::ContentValidation::Setting.check_enabled?(@project)
      return if pre_check_skip_validate?

      recent_commit = repository.commit(ref)

      return unless recent_commit

      data = fetch_tree_commits(recent_commit)

      data.each do |path, row|
        type = row[:type]
        commit = row[:commit]

        next if commit.nil?

        if type == :tree
          tree = repository.tree(commit.id, path)
          validate_tree(commit, tree)
        elsif type == :blob
          blob = repository.blob_at(commit.id, path)
          validate_blob(commit, blob)
        end
      end
    end

    private

    def fetch_tree_commits(recent_commit)
      root_tree = repository.tree(recent_commit.id, scan_path, recursive: recursive)
      tree_paths = [scan_path]
      tree_paths += root_tree.entries.select(&:dir?).map(&:path) if recursive

      data = root_tree.entries.to_h { |entry| [entry.path, { type: entry.type }] }

      tree_paths.map do |path|
        commits = repository.list_last_commits_for_tree(
          recent_commit.id,
          File.join(path, ""),
          offset: 0, limit: TREE_COMMITS_LIMIT
        )
        commits.each do |path, path_commit|
          encoded_path = Gitlab::EncodingHelper.encode_utf8_safe_path(path)
          data[encoded_path][:commit] = path_commit
        end
      end

      data
    end

    def repository
      project.repository
    end
    strong_memoize_attr :repository

    def pre_check_skip_validate?
      pre_check_params = {
        group_full_path: @project&.group&.full_path,
        project_full_path: @project&.full_path
      }
      response = client.pre_check(pre_check_params)
      response&.success? && response.parsed_response["skip_validate"]
    end

    def validate_tree(commit, tree)
      content = tree.entries.map(&:name).join("\n")
      data = base_data.merge({
        commit_sha: commit.id,
        blob_sha: tree.sha,
        path: tree.path.gsub(%r{/^//}, ""),
        content_type: "tree",
        text: Base64.encode64(content)
      })
      client.blob_validate(data)
    end

    def validate_blob(commit, blob)
      if blob.binary?
        validate_binary_blob(commit, blob) if include_binary
      else
        validate_text_blob(commit, blob)
      end
    end

    def validate_binary_blob(commit, blob)
      file_type, _ = file_extensions.detect { |_type, extensions| extensions.include?(blob.extension) }

      return unless file_type.present?

      return if blob.size > BINARY_FILE_MAX_SIZE

      data = base_data.merge({
        commit_sha: commit.id,
        blob_sha: blob.id,
        path: blob.path,
        content_type: file_type.to_s,
        file_type.to_sym => Base64.strict_encode64(blob.data)
      })
      client.blob_validate(data)
    end

    def validate_text_blob(commit, blob)
      return if blob.size > FILE_MAX_SIZE

      content = [blob.name, blob.data].join("\n")

      data = base_data.merge({
        commit_sha: commit.id,
        blob_sha: blob.id,
        path: blob.path,
        content_type: "text",
        text: Base64.encode64(content)
      })
      client.blob_validate(data)
    end

    def client
      ::Gitlab::ContentValidation::Client.new
    end
    strong_memoize_attr :client

    def file_extensions
      {
        image: %w[png jpg jpeg gif bmp webp],
        audio: %w[mp3 ogg wav],
        video: %w[mp4 mov]
      }
    end
    strong_memoize_attr :file_extensions

    def base_data
      user = @project.first_owner
      {
        container_identifier: ::Gitlab::GlRepository::PROJECT.identifier_for_container(@project),
        project_id: @project.id,
        project_full_path: @project.full_path,
        group_id: @project.group&.id,
        group_full_path: @project.group&.full_path,
        repo_type: "project",
        user_id: user&.id,
        user_username: user&.username,
        user_email: user&.email,
        is_private: @project.private?,
        incremental: false
      }
    end
    strong_memoize_attr :base_data
  end
end
