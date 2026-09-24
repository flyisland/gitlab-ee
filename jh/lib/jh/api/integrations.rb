# frozen_string_literal: true

module JH
  module API
    module Integrations
      extend ActiveSupport::Concern

      prepended do
        namespace :integrations do
          namespace :feishu do
            # since this feature is for Self management only, so don't need add rate limit
            desc "Handle robot message from Feishu"
            post 'robot' do
              status 200
              ::Gitlab::Chatops::FeishuBotHandler.new(params, headers).execute
            end
          end
        end

        namespace :integrations do
          namespace :dingtalk do
            # since this feature is for Self management only, so don't need add rate limit
            desc "Handle robot message from DingTalk"
            post 'robot' do
              status 200
              ::Gitlab::Chatops::DingtalkBotHandler.new(params, headers).execute
            end

            # get endpoint is used for dingtalk platform check
            get 'robot' do
              status 200
            end
          end
        end
      end
    end
  end
end
