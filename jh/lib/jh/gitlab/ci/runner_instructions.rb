# frozen_string_literal: true

module JH
  module Gitlab
    module Ci
      module RunnerInstructions
        extend ::Gitlab::Utils::Override

        private

        override :replace_variables
        def replace_variables(expression)
          super.sub('gitlab-runner-downloads.s3.amazonaws.com', 'gitlab-runner-downloads.gitlab.cn')
        end
      end
    end
  end
end
