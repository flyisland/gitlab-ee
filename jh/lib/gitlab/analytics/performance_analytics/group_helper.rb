# frozen_string_literal: true

module Gitlab
  module Analytics
    module PerformanceAnalytics
      module GroupHelper
        extend ActiveSupport::Concern

        # rubocop: disable CodeReuse/ActiveRecord
        def base_push_event_payload_query
          query =
            PushEventPayload
              .where(action: %w[created pushed])
              .joins(event: :project)
              .where(events: { created_at: time_filter_range })
              .merge(::Project.for_group_and_its_subgroups(group))

          query = query.where(events: { project_id: options[:project_ids] }) if options[:project_ids].present?
          query
        end
        # rubocop: enable CodeReuse/ActiveRecord

        def time_filter_range
          options[:from]..(options[:to].end_of_day)
        end

        def user_data(user)
          {
            fullname: user.name,
            username: user.username,
            user_web_url: "/#{user.username}",
            avatar: user.avatar_url
          }
        end
      end
    end
  end
end
