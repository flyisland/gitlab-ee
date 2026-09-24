# frozen_string_literal: true

module JH
  module Gitlab
    module Source
      extend ActiveSupport::Concern

      class_methods do
        extend ::Gitlab::Utils::Override

        private

        override :group
        def group
          'gitlab-cn'
        end
      end
    end
  end
end
