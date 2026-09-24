# frozen_string_literal: true

module Gitlab
  module Analytics
    module PerformanceAnalytics
      module Group
        module Report
          class Base
            include GroupHelper

            attr_reader :group, :options

            def initialize(group, options: {})
              @group = group
              @options = options
            end

            def query_count
              raise NotImplementedError, "Expected #{self.class} to implement query_count"
            end

            def query_summary
              raise NotImplementedError, "Expected #{self.class} to implement query_summary"
            end
          end
        end
      end
    end
  end
end
