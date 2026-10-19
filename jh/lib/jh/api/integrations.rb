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
              request.body.rewind
              ::Gitlab::Chatops::FeishuBotHandler.new(params, headers, request.body.read).execute
            rescue ::Gitlab::Chatops::FeishuBotHandler::AuthenticationError => e
              ::Gitlab::AppLogger.warn(
                Labkit::Fields::LOG_MESSAGE => 'Rejected Feishu bot callback',
                Labkit::Fields::ERROR_MESSAGE => e.message
              )
              unauthorized!
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

            desc "Handle a Duo approval card button click from DingTalk"
            post 'card_callback' do
              status 200
              callback = ::Gitlab::Dingtalk::CardCallback.new(params, headers).verify!
              ::Ai::Messaging::DingtalkApprovalActionService.new(callback).execute
            rescue ::Gitlab::Dingtalk::CardCallback::AuthenticationError => e
              ::Gitlab::AppLogger.warn(
                Labkit::Fields::LOG_MESSAGE => 'Rejected DingTalk card callback',
                Labkit::Fields::ERROR_MESSAGE => e.message
              )
              unauthorized!
            end
          end
        end
      end
    end
  end
end
