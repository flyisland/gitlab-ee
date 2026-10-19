# frozen_string_literal: true

module Gitee
  module Representation
    class User < Representation::Base
      def username
        raw['login']
      end
    end
  end
end
