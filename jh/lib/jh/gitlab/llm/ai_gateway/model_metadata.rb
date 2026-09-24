# frozen_string_literal: true

module JH
  module Gitlab
    module Llm
      module AiGateway
        module ModelMetadata
          extend ActiveSupport::Concern
          extend ::Gitlab::Utils::Override

          override :to_params
          def to_params
            return super unless ::Gitlab.com?

            endpoint = ENV['SAAS_LLM_ENDPOINT']
            return super unless endpoint.present?

            default_model_info = super || {}

            custom_model_info = {
              endpoint: endpoint,
              api_key: ENV['SAAS_LLM_API_KEY'],
              provider: ENV['SAAS_LLM_PROVIDER'] || 'openai',
              name: ENV['SAAS_LLM_NAME'] || 'gpt',
              identifier: ENV['SAAS_LLM_IDENTIFIER'] || 'gpt-mini-4o',
              raw_metadata: default_model_info
            }
            default_model_info.merge(custom_model_info)
          end
        end
      end
    end
  end
end
