# frozen_string_literal: true

module JH
  module DiffFileEntity
    extend ActiveSupport::Concern

    prepended do
      expose :content_blocked_state,
        if: ->(_diff_file, options) { options[:commit] },
        using: ::API::Entities::ContentBlockedState do |diff_file|
        commit = options[:commit]
        project = commit.project

        next unless project && ::ContentValidation::Setting.block_enabled?(project)

        ::ContentValidation::ContentBlockedState.find_by_container_commit_path(project, commit.id, diff_file.file_path)
      end
    end
  end
end
