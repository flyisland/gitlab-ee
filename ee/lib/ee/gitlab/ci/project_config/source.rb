# frozen_string_literal: true

module EE
  module Gitlab
    module Ci
      module ProjectConfig
        module Source
          extend ::Gitlab::Utils::Override

          override :initialize
          def initialize(scan_profile_eligibility_service: nil, **args)
            super(**args)
            @scan_profile_eligibility_service = scan_profile_eligibility_service
          end

          attr_reader :scan_profile_eligibility_service
        end
      end
    end
  end
end
