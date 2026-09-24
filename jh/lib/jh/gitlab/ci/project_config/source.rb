# frozen_string_literal: true

module JH
  module Gitlab
    module Ci
      module ProjectConfig
        module Source
          def initialize(ci_config_path: nil, **args)
            super(**args)

            @ci_config_path = ci_config_path
          end
        end
      end
    end
  end
end
