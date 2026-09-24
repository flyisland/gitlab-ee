# frozen_string_literal: true

module Commits
  class FetchEffectiveLinesCountService
    attr_reader :project, :commit, :options

    def initialize(project, commit, _options = {})
      @project = project
      @commit = commit
    end

    def execute
      Rails.cache.fetch("commit_effective_lines-#{project.full_path}-#{commit.id}") do
        effective_additions = 0
        effective_deletions = 0

        commit.diffs.diff_files.each do |file|
          lines_counter = ::Gitlab::Analytics::EffectiveLines::Counter.new(file.diff.diff)
          effective_additions += lines_counter.additions
          effective_deletions += lines_counter.deletions
        end

        commit_stats = commit.stats

        commit_info = {
          id: commit.id,
          author_name: commit.author_name,
          author_email: commit.author_email,
          date: commit.committed_date.to_date.iso8601,
          additions: commit_stats.additions,
          deletions: commit_stats.deletions,
          effective_additions: effective_additions,
          effective_deletions: effective_deletions
        }

        commit_info
      end
    end
  end
end
