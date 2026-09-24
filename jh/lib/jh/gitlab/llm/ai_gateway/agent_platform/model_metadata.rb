# frozen_string_literal: true

module JH
  module Gitlab
    module Llm
      module AiGateway
        module AgentPlatform
          module ModelMetadata
            extend ActiveSupport::Concern
            extend ::Gitlab::Utils::Override

            override :execute
            def execute
              return super unless ::Gitlab.com?

              endpoint = ENV['SAAS_LLM_ENDPOINT']
              return super unless endpoint.present?

              header_key = ::Gitlab::Llm::AiGateway::AgentPlatform::ModelMetadata::HEADER_KEY
              default_model_metadata = ::Gitlab::Llm::AiGateway::ModelMetadata.new(
                feature_setting: feature_setting).to_params || {}

              custom_model_metadata = {
                endpoint: endpoint,
                api_key: ENV['SAAS_LLM_API_KEY'],
                provider: ENV['SAAS_LLM_PROVIDER'] || 'openai',
                name: ENV['SAAS_LLM_NAME'] || 'gpt',
                identifier: ENV['SAAS_LLM_IDENTIFIER'] || 'pro-deepseek-v3'
              }

              { header_key => default_model_metadata.merge(custom_model_metadata).to_json }
            end
          end
        end
      end
    end
  end
end
