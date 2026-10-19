# frozen_string_literal: true

module JH
  module Gitlab
    module WebHooks
      module RateLimiter
        module ::EE
          module Gitlab
            module WebHooks
              module RateLimiter
                temp_limit_map = LIMIT_MAP
                remove_const :LIMIT_MAP
                LIMIT_MAP = temp_limit_map.merge(
                  ::Plan::TEAM => PREMIUM_MID_RANGE
                ).freeze
              end
            end
          end
        end
      end
    end
  end
end
