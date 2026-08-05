# frozen_string_literal: true

# SPIKE (gitlab-org/gitlab#602803): thin CLI over Gitlab::Geo::Tools. `cleanup_check` is
# read-only; `resolve` is dry-run unless DRY_RUN=false. The logic lives in Gitlab::Geo::Tools
# so it can also be run from a Rails console without invoking rake.
namespace :geo do
  namespace :tools do
    desc 'GitLab | Geo | Tools | Scan for known Geo replication errors and recommend fixes'
    task cleanup_check: :gitlab_environment do
      Gitlab::Geo::Tools.cleanup_check
    end

    desc 'GitLab | Geo | Tools | Resolve a known Geo error by key (DRY_RUN=true by default)'
    task :resolve, [:key] => :gitlab_environment do |_task, args|
      key = args[:key]
      known_error = Geo::Tools::KnownErrors.find(key)

      abort "Unknown error key: #{key}" unless known_error

      limit = ENV['LIMIT'].presence
      if limit
        limit = Integer(limit, exception: false)
        abort "LIMIT must be a positive integer, got: #{ENV['LIMIT'].inspect}" unless limit&.positive?
      end

      Gitlab::Geo::Tools.resolve(
        known_error,
        dry_run: ENV['DRY_RUN'] != 'false',
        limit: limit
      )
    end
  end
end
