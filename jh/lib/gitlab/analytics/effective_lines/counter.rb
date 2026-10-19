# frozen_string_literal: true

module Gitlab
  module Analytics
    module EffectiveLines
      class Counter
        attr_reader :file_content

        def initialize(file_content)
          @file_content = file_content.gsub(/\+[ \t]*\n/, "")
                                      .gsub(/-[ \t]*\n/, "")
        end

        def additions
          count = 0
          file_content.each_line do |line|
            count += 1 if line.start_with?('+')
          end
          count
        end

        def deletions
          count = 0
          file_content.each_line do |line|
            count += 1 if line.start_with?('-')
          end
          count
        end
      end
    end
  end
end
