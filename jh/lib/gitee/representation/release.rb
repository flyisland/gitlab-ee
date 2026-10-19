# frozen_string_literal: true

module Gitee
  module Representation
    class Release < Representation::Base
      def tag_name
        raw['tag_name']
      end

      def name
        raw['name']
      end

      def body
        raw['body']
      end

      def author_name
        author['name']
      end

      def created_at
        raw['created_at']
      end

      private

      def author
        raw.fetch('author', {})
      end
    end
  end
end
