# frozen_string_literal: true

module JH
  module Gitlab
    module Ci
      module Pipeline
        module Chain
          module Command
            extend ::Gitlab::Utils::Override

            attr_reader :ci_config_path

            override :initialize
            def initialize(ci_config_path: nil, **kwargs)
              super(**kwargs)

              @ci_config_path = ci_config_path
            end
          end
        end
      end
    end
  end
end
