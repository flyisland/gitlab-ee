# frozen_string_literal: true

module Integrations
  module LigaaiSerializers
    class IssueEntity < Grape::Entity
      include ActionView::Helpers::SanitizeHelper
      include RequestAwareEntity

      expose :id do |item|
        item['id']
      end

      expose :project_id do |_item|
        project.id
      end

      expose :title do |item|
        sanitize(item['summary'])
      end

      expose :created_at do |item|
        parsed_date(item['createTime'])
      end

      expose :updated_at do |item|
        parsed_date(item['updateTime'])
      end

      expose :closed_at do |item|
        parsed_date(item['updateTime']) if item['statusType'] == 4 || item.dig('statusVO', 'stateCategory') == 4
      end

      expose :due_date do |item|
        parsed_date(item['dueDate'])
      end

      expose :status do |item|
        sanitize(item['statusName'] || item.dig('statusVO', 'name'))
      end

      expose :state do |item|
        sanitize(item['statusName'] || item.dig('statusVO', 'name'))
      end

      expose :labels do |item|
        labels = item['labelVO'] || item['tags'] || []

        labels.compact.map do |label|
          name = sanitize(label['labelName'] || label['tagName'])
          {
            id: label['id'],
            title: name,
            name: name,
            color: '#0052CC',
            text_color: '#FFFFFF'
          }
        end
      end

      expose :author do |item|
        user_info(item['createByVO'])
      end

      expose :assignees do |item|
        [user_info(item['assigneeVO'])]
      end

      expose :web_url do |_item|
        ''
      end

      expose :gitlab_web_url do |item|
        project_integrations_ligaai_issue_path(project, item['id'])
      end

      private

      def project
        @project ||= options[:project]
      end

      def parsed_date(date)
        date ? Time.at((date / 1000).to_i, in: "UTC") : ''
      end

      def user_info(user)
        return {} unless user.present?

        {
          id: user['userId'] || user['id'],
          name: sanitize(user['userName'] || user['name']),
          web_url: '',
          avatar_url: sanitize(user['profilePicture'] || user['avatar'])
        }
      end
    end
  end
end
