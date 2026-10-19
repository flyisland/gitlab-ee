# frozen_string_literal: true

module Gitlab
  module Analytics
    module PerformanceAnalytics
      module Project
        module Leaderboard
          class Base
            include ProjectHelper

            attr_reader :project, :options

            LIMIT_COUNT = 20

            def initialize(project, options: {})
              @project = project
              @options = options
              @options[:branch_name] = @options[:branch_name].presence || project.default_branch_or_main
            end

            def data
              transfer_query_result(query_result)
            end

            def query_result
              raise NotImplementedError, "Expected #{name} to implement query_result"
            end

            private

            def transfer_query_result(query_result)
              result = query_result.to_h

              users_hash = User.find(result.keys).index_by(&:id)

              result.map.with_index do |(user_id, value), index|
                user = users_hash[user_id]
                {
                  user: user_data(user),
                  rank: index + 1,
                  value: value.to_i
                }
              end
            end
          end
        end
      end
    end
  end
end
