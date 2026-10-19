# frozen_string_literal: true

module Gitlab
  module Analytics
    module PerformanceAnalytics
      module Group
        module Summary
          class Base
            include GroupHelper

            attr_reader :group, :options

            def initialize(group, options: {})
              @group = group
              @options = options
            end
          end
        end
      end
    end
  end
end
