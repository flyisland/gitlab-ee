# frozen_string_literal: true

module OmniAuth
  module Strategies
    class Dingtalk
      uid do
        if ::Feature.enabled?(:ff_dingtalk_oauth_use_userid)
          user_info['userid']
        else
          user_info['openid']
        end
      end
    end
  end
end
