# frozen_string_literal: true

module JH
  module Gitlab
    module QueryLimiting
      module Transaction
        extend ActiveSupport::Concern
        extend ::Gitlab::Utils::Override

        # JH does extra work inside upstream requests: its three extra foundational flows
        # take CascadeSyncFoundationalFlowsWorker to 202 queries against the 190 allowed
        # by https://gitlab.com/gitlab-org/gitlab/-/issues/598945. Added to the threshold
        # in one place only, so the default of 100 keeps its own 15 and not twice that.
        JH_QUERY_LIMITING_PLUS = ENV['JH_QUERY_LIMITING_PLUS'] || '15'

        override :threshold
        def threshold
          super + JH_QUERY_LIMITING_PLUS.to_i
        end
      end
    end
  end
end
