# frozen_string_literal: true

module Gitlab
  module Analytics
    module PerformanceAnalytics
      class GroupReport
        include ::Gitlab::Utils::StrongMemoize
        include GroupHelper

        attr_reader :group, :options

        COLUMN_KEYS = %w[
          commits_pushed
          issues_created
          issues_closed
          merge_requests_created
          merge_requests_approved
          merge_requests_merged
          merge_requests_closed
          notes_created
        ].freeze

        TOTAL_KEYS = (["username"] + COLUMN_KEYS).freeze
        PER_PAGE = 20

        def initialize(group, options: {})
          @group = group
          @options = options
        end

        def data
          users = get_page_users

          column_data = COLUMN_KEYS.index_with do |key|
            report_column(key).query_count.to_h
          end

          users.map do |user|
            row = { user: user_data(user) }

            COLUMN_KEYS.each do |column_key|
              row[column_key.to_sym] = column_data[column_key][user.id].to_i
            end

            row
          end
        end

        def summary
          COLUMN_KEYS.to_h do |key|
            [key.to_sym, report_column(key).query_summary]
          end
        end

        def csv
          users = contribution_users

          column_data = COLUMN_KEYS.index_with do |key|
            report_column(key).query_count.to_h
          end

          users_data = users.map do |user|
            row = { username: user.name }

            COLUMN_KEYS.each do |column_key|
              row[column_key.to_sym] = column_data[column_key][user.id].to_i
            end

            row
          end

          summary_row = summary.with_defaults(username: "Total")
          rows = [summary_row, *users_data]

          CsvBuilder::SingleBatch.new(
            rows,
            TOTAL_KEYS.to_h { |key| [csv_headers[key], key.to_sym] }
          ).render
        end

        def csv_headers
          { "username" => "Name" }.merge(COLUMN_KEYS.index_with { |key| column_class(key).header })
        end
        strong_memoize_attr :csv_headers

        def pagination
          total = members_count
          next_page = page * PER_PAGE < total ? page + 1 : nil
          prev_page = page == 1 ? nil : page - 1
          total_pages = (total * 1.0 / PER_PAGE).ceil

          {
            per_page: PER_PAGE,
            page: page,
            next_page: next_page,
            prev_page: prev_page,
            total: total,
            total_pages: total_pages
          }
        end

        private

        def members_count
          @members_count ||= empty_list_data.size
        end

        def get_page_users
          return contribution_users.page(page).per(PER_PAGE) if options[:sort].blank?

          case options[:sort].to_s
          when "username"
            sort = direction == "asc" ? "name_asc" : "name_desc"
            collection = contribution_users.sort_by_attribute(sort)
            collection.page(page).per(PER_PAGE)
          when *COLUMN_KEYS
            result = report_column(options[:sort]).query_count
            get_page_users_from_query_result(result)
          else
            []
          end
        end

        def column_class(key)
          Group::Report.const_get(key.to_s.classify, false)
        end

        def report_column(key)
          column_class(key).new(group, options: options)
        end

        def page
          @page ||= options[:page]&.to_i || 1
        end

        def direction
          @direction ||= options[:direction] || "asc"
        end

        def direction_int
          @direction_int ||= direction == "asc" ? 1 : -1
        end

        def empty_list_data
          @empty_list_data ||= contribution_users.to_h { |user| [user.id, 0] }
        end

        def get_page_users_from_query_result(result)
          array = empty_list_data.merge(result.to_h).sort_by { |_, value| value * direction_int }
          member_ids = Kaminari.paginate_array(array).page(page).per(PER_PAGE).map(&:first)
          User.find(member_ids).to_a.sort_by { |user| member_ids.index(user.id) }
        end

        def contribution_users
          # rubocop: disable CodeReuse/ActiveRecord -- requires ActiveRecord query
          query = Event.where(events: { created_at: time_filter_range })
                       .joins(:project)
                       .merge(::Project.for_group_and_its_subgroups(group))
          query = query.where(projects: { id: options[:project_ids] }) if options[:project_ids].present?

          query_sql = query.select("distinct author_id").to_sql
          user_ids = ApplicationRecord.connection.query(query_sql).flatten
          User.where(id: user_ids)
          # rubocop: enable CodeReuse/ActiveRecord
        end
        strong_memoize_attr :contribution_users
      end
    end
  end
end
