# frozen_string_literal: true

module PerformanceAnalytics
  class ProjectMetricsService < ::BaseProjectService
    include MetricsHelper

    COMMITS_LIMIT = ::Gitlab::Analytics::PerformanceAnalytics::ProjectHelper::COMMITS_LIMIT

    def self.available_metrics
      %w[
        commits
        issues_created
        issues_closed
        merge_requests_created
        merge_requests_approved
        merge_requests_merged
        merge_requests_closed
        notes_created
      ]
    end

    def execute
      error = validate

      return error if error
      return authorization_error unless authorized?

      query_result =
        case metric
        when "commits"
          commits_query
        when "issues_created"
          base_event_query.for_issue.for_action(:created).aggregate_for(interval)
        when "issues_closed"
          base_event_query.for_issue.for_action(:closed).aggregate_for(interval)
        when "merge_requests_created"
          base_event_query.for_merge_request.for_action(:created).aggregate_for(interval)
        when "merge_requests_approved"
          base_event_query.for_merge_request.for_action(:approved).aggregate_for(interval)
        when "merge_requests_merged"
          base_event_query.for_merge_request.for_action(:merged).aggregate_for(interval)
        when "merge_requests_closed"
          base_event_query.for_merge_request.for_action(:closed).aggregate_for(interval)
        when "notes_created"
          base_event_query.for_note.for_action(:commented).aggregate_for(interval)
        end

      data = data_wrapper(query_result)

      success(data: data)
    end

    delegate :available_metrics, to: :class

    private

    def commits_query
      commits = project.repository.commits(
        project.default_branch,
        limit: COMMITS_LIMIT,
        before: end_date.end_of_day,
        after: start_date.beginning_of_day,
        skip_merges: true
      )

      if user_ids.present?
        users = User.id_in(user_ids)
        commits = commits.select do |commit|
          users.any? { |user| user.any_email?(commit.author_email) }
        end
      end

      case interval
      when INTERVAL_ALL
        commits.count
      when INTERVAL_MONTHLY
        commits.group_by { |commit| commit.created_at.strftime("%Y-%m") }
               .transform_values(&:count)
      when INTERVAL_DAILY
        commits.group_by { |commit| commit.created_at.strftime("%F") }
               .transform_values(&:count)
      end
    end

    def base_event_query
      query = Event.for_single_project(project)
                   .created_in_time_range(from: start_date.beginning_of_day, to: end_date.end_of_day)
      query = query.for_author_ids(user_ids) if user_ids.present?
      query
    end
  end
end
