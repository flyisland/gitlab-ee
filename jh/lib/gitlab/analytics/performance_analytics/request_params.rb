# frozen_string_literal: true

module Gitlab
  module Analytics
    module PerformanceAnalytics
      class RequestParams
        include ActiveModel::Model
        include ActiveModel::Validations
        include ActiveModel::Attributes
        include Gitlab::Utils::StrongMemoize

        MAX_RANGE_DAYS = 180.days.freeze
        DEFAULT_DATE_RANGE = 29.days # 30 including Date.today

        STRONG_PARAMS_DEFINITION = [
          :start_date,
          :end_date,
          :leaderboard_type,
          :sort,
          :direction,
          :page,
          :branch_name,
          { project_ids: [].freeze }
        ].freeze

        attr_writer :project_ids

        attribute :start_date, :datetime
        attribute :end_date, :datetime
        attribute :leaderboard_type
        attribute :sort
        attribute :direction
        attribute :page
        attribute :branch_name

        attribute :current_user

        validates :start_date, presence: true
        validates :end_date, presence: true
        validates :leaderboard_type, inclusion: GroupLeaderboard::LEADERBOARD_TYPES, allow_blank: true
        validates :sort, inclusion: GroupReport::TOTAL_KEYS, allow_blank: true
        validates :direction, inclusion: %w[asc desc], allow_blank: true
        validates :page, numericality: { greater_than: 0 }, allow_blank: true

        validate :validate_end_date
        validate :validate_date_range

        def initialize(params = {})
          super

          self.start_date = to_time(start_date || default_start_date).beginning_of_day
          self.end_date = to_time(end_date || Time.current).end_of_day
          self.leaderboard_type ||= "commits_pushed"
          self.page ||= 1
          self.sort ||= "username"
          self.direction ||= "asc"
        end

        def project_ids
          Array(@project_ids)
        end

        def to_options
          {
            current_user: current_user,
            from: start_date,
            to: end_date,
            project_ids: project_ids,
            leaderboard_type: leaderboard_type.to_s,
            sort: sort.to_s,
            direction: direction.to_s,
            page: page.to_i,
            branch_name: branch_name
          }
        end

        private

        def validate_end_date
          return if start_date.nil? || end_date.nil?

          errors.add(:end_date, :invalid) if start_date > end_date
        end

        def validate_date_range
          return if start_date.nil? || end_date.nil?

          return unless (end_date - start_date) > MAX_RANGE_DAYS

          errors.add(:end_date, s_('JH|PerformanceAnalytics|The given date range is larger than 180 days'))
        end

        def default_start_date
          if end_date
            (end_date - DEFAULT_DATE_RANGE)
          else
            DEFAULT_DATE_RANGE.ago
          end
        end

        def to_time(field)
          date = field.is_a?(Date) || field.is_a?(Time) ? field : Date.parse(field)
          date.to_time
        end
      end
    end
  end
end
