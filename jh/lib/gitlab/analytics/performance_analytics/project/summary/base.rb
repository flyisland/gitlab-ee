# frozen_string_literal: true

module Gitlab
  module Analytics
    module PerformanceAnalytics
      module Project
        module Summary
          class Base
            include ProjectHelper

            attr_reader :project, :options

            def initialize(project, options: {})
              @project = project
              @options = options
              @options[:branch_name] = @options[:branch_name].presence || project.default_branch_or_main
            end
          end
        end
      end
    end
  end
end
