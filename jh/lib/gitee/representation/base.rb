# frozen_string_literal: true

module Gitee
  module Representation
    class Base
      attr_reader :raw

      def self.decorate(entries)
        entries.map { |entry| new(entry) }
      end

      def initialize(raw)
        @raw = raw
      end
    end
  end
end
