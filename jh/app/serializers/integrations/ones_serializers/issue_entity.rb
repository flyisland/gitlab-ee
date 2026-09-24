# frozen_string_literal: true

module Integrations
  module OnesSerializers
    class IssueEntity < Grape::Entity
      include ActionView::Helpers::SanitizeHelper
      include RequestAwareEntity

      expose :id do |item|
        sanitize(item['key'])
      end

      expose :project_id do |_item|
        project.id
      end

      expose :title do |item|
        sanitize(item['name'])
      end

      expose :created_at do |item|
        date_time_at(item['createTime'])
      end

      expose :updated_at do |item|
        date_time_at(item['serverUpdateStamp'])
      end

      expose :closed_at do |item|
        date_time_at(item['serverUpdateStamp']) if status(item['status']) == "closed"
      end

      expose :status do |item|
        status(item['status'])
      end

      expose :state do |item|
        status(item['status'])
      end

      expose :labels do |_item|
        []
      end

      expose :author do |item|
        user_info(item['owner'])
      end

      expose :assignees do |item|
        [user_info(item['assign'])]
      end

      expose :web_url do |_item|
        project.external_issue_tracker.url
      end

      expose :gitlab_web_url do |item|
        project_integrations_ones_issue_path(project, sanitize(item['key']))
      end

      private

      def status(values)
        mapping = {
          'to_do' => 'open',
          'in_progress' => 'open',
          'done' => 'closed'
        }.freeze
        mapping[values['category']]
      end

      def date_time_at(nanosecond)
        Time.at(nanosecond.to_i / 1000_000).to_datetime.utc
      end

      def project
        @project ||= options[:project]
      end

      def user_info(user)
        return {} unless user.present?

        {
          id: user['key'],
          name: sanitize(user['name']),
          web_url: '',
          avatar_url: user['avatar']
        }
      end
    end
  end
end
