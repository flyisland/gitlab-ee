# frozen_string_literal: true

module Gitlab
  module Analytics
    module PerformanceAnalytics
      class ProjectReport
        include ::Gitlab::Utils::StrongMemoize
        include ProjectHelper

        attr_reader :project, :options

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

        def initialize(project, options: {})
          @project = project
          @options = options
        end

        def data
          sorted_users_data = sort_users_data(users_data)
          Kaminari.paginate_array(sorted_users_data).page(page).per(PER_PAGE)
        end

        def summary
          COLUMN_KEYS.to_h do |key|
            [key.to_sym, report_column(key).query_summary]
          end
        end

        def csv
          summary_row = summary.with_defaults(user: { fullname: "Total" })
          rows = [summary_row, *users_data]

          header_to_value_hash = TOTAL_KEYS.to_h { |key| [csv_headers[key], key.to_sym] }
          rows.each { |row| row[:username] = row.dig(:user, :fullname) }

          CsvBuilder::SingleBatch.new(rows, header_to_value_hash).render
        end

        def pagination
          total = users_data.count
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

        def users_data
          query_data = COLUMN_KEYS.index_with do |key|
            report_column(key).query_count.to_h
          end

          result_data =
            query_data.each_with_object({}) do |(column_key, data), result|
              data.each do |user_key, value|
                result[user_key] ||= empty_row
                result[user_key][column_key.to_sym] = value
              end
            end

          map_to_users_data(result_data)
        end
        strong_memoize_attr :users_data

        def csv_headers
          { "username" => "Name" }.merge(COLUMN_KEYS.index_with { |key| column_class(key).header })
        end
        strong_memoize_attr :csv_headers

        def sort_users_data(users_data)
          case sort
          when "username"
            data = users_data.sort_by { |row| row[:user][:fullname] }
            direction == "asc" ? data : data.reverse
          when *COLUMN_KEYS
            users_data.sort_by { |row| row[sort.to_sym] * direction_int }
          else
            []
          end
        end

        def column_class(key)
          Project::Report.const_get(key.to_s.classify, false)
        end

        def report_column(key)
          column_class(key).new(project, options: options)
        end

        def page
          @page ||= options[:page] || 1
        end

        def sort
          @sort ||= options[:sort]
        end

        def direction
          @direction ||= options[:direction] || "asc"
        end

        def direction_int
          @direction_int ||= direction == "asc" ? 1 : -1
        end

        def empty_row
          COLUMN_KEYS.to_h { |key| [key.to_sym, 0] }
        end

        def map_to_users_data(result_data)
          user_ids = result_data.keys.select { |key| key.is_a?(Integer) }
          users = User.find(user_ids)
          user_hash = users.index_by(&:id)
          result_data.map do |key, row|
            if key.is_a?(Integer)
              user = user_hash[key]
              user_info = user_data(user)
            else
              user_info = commit_author_data(key)
            end

            row.merge({ user: user_info })
          end
        end
      end
    end
  end
end
