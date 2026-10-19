# frozen_string_literal: true

module Gitee
  module Representation
    class Milestone < Representation::Base
      def title
        raw['title']
      end

      def description
        raw['description']
      end

      def due_date
        raw['due_on']&.to_date
      end

      def state
        case raw['state']
        when 'open'
          'active'
        else
          'closed'
        end
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
