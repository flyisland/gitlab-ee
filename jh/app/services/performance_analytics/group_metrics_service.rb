# frozen_string_literal: true

module PerformanceAnalytics
  class GroupMetricsService < ::BaseGroupService
    include MetricsHelper

    def self.available_metrics
      %w[
        pushes
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
        when "pushes"
          base_event_query.merge(PushEvent.created_or_pushed).aggregate_for(interval)
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

    def base_event_query
      query = Event.for_group(group)
                   .created_in_time_range(from: start_date.beginning_of_day, to: end_date.end_of_day)
      query = query.for_project_ids(project_ids) if project_ids.present?
      query = query.for_author_ids(user_ids) if user_ids.present?
      query
    end
  end
end
