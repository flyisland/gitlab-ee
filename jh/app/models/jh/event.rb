# frozen_string_literal: true

module JH
  module Event
    extend ActiveSupport::Concern
    extend ::Gitlab::Utils::Override

    prepended do
      scope :for_single_project, ->(project) { where(project: project) }
      scope :for_merge_request, -> { where(target_type: 'MergeRequest') }
      scope :for_note, -> { where(target_type: %w[Note DiscussionNote DiffNote]) }
      scope :created_in_time_range, ->(from: nil, to: nil) { where(created_at: from..to) }
      scope :for_group, ->(group) { joins(:project).merge(::Project.for_group_and_its_subgroups(group)) }
      scope :for_project_ids, ->(project_ids) { where(project_id: project_ids) }
      scope :for_author_ids, ->(user_ids) { where(author_id: user_ids) }
    end

    class_methods do
      def aggregate_for(interval)
        case interval
        when ::PerformanceAnalytics::MetricsHelper::INTERVAL_ALL
          count
        when ::PerformanceAnalytics::MetricsHelper::INTERVAL_MONTHLY
          group("TO_CHAR(events.created_at, 'YYYY-mm')").count
        when ::PerformanceAnalytics::MetricsHelper::INTERVAL_DAILY
          group("TO_CHAR(events.created_at, 'YYYY-mm-dd')").count
        end
      end
    end
  end
end
