# frozen_string_literal: true

module Gitee
  class Collection < Enumerator
    def initialize(paginator)
      super() do |yielder|
        loop do
          paginator.items.each { |item| yielder << item }
        end
      end

      lazy
    end
  end
end
