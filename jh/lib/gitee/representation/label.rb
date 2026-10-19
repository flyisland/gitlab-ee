# frozen_string_literal: true

module Gitee
  module Representation
    class Label < Representation::Base
      def color
        "##{raw['color']}"
      end

      def title
        raw['name']
      end

      def url
        raw['url']
      end

      def created_at
        raw['created_at']
      end

      def updated_at
        raw['updated_at']
      end
    end
  end
end
