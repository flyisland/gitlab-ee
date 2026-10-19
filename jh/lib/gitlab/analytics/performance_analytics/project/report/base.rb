# frozen_string_literal: true

module Gitlab
  module Analytics
    module PerformanceAnalytics
      module Project
        module Report
          class Base
            include ProjectHelper

            attr_reader :project, :options

            def initialize(project, options: {})
              @project = project
              @options = options
              @options[:branch_name] = @options[:branch_name].presence || project.default_branch_or_main
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
