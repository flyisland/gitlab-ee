# frozen_string_literal: true

module JH
  module Gitlab
    module Tracking
      module EventEligibilityChecker
        extend ::Gitlab::Utils::Override

        private

        override :eligible_duo_event?
        def eligible_duo_event?(_event_name, _app_id)
          false
        end
      end
    end
  end
end
