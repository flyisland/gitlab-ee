# frozen_string_literal: true

module JH
  module Sms
    class << self
      def configure
        yield config
      end

      def config
        @_config ||= Config.new
      end
    end
  end
end
