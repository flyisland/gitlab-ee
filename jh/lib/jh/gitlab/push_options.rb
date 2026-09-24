# frozen_string_literal: true

module JH
  module Gitlab
    module PushOptions
      module ::Gitlab
        class PushOptions
          ORIGINAL_VALID_OPTIONS = VALID_OPTIONS.dup
          remove_const :VALID_OPTIONS
          VALID_OPTIONS = ORIGINAL_VALID_OPTIONS.deep_merge({
            merge_request: {
              keys: ORIGINAL_VALID_OPTIONS[:merge_request][:keys] + [:skip_mono_central_pipeline]
            }
          }).freeze
        end
      end
    end
  end
end
