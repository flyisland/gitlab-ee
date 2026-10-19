# frozen_string_literal: true

module Gitee
  module Representation
    class Issue < Representation::Base
      def number
        raw['number']
      end

      def author
        user['name']
      end

      def description
        raw['body']
      end

      def state
        closed? ? 'closed' : 'opened'
      end

      def title
        raw['title']
      end

      def labels
        raw['labels'].map { |label| label['name'] }
      end

      def milestone
        raw['milestone']['title'] if raw['milestone'].present?
      end

      def created_at
        raw['created_at']
      end

      def updated_at
        raw['updated_at']
      end

      def to_s
        number
      end

      def due_date
        raw['deadline']
      end

      private

      def closed?
        %w[closed rejected].include?(raw['state'])
      end

      def user
        raw.fetch('user', {})
      end
    end
  end
end
