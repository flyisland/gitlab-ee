# frozen_string_literal: true

module Gitlab
  module Llm
    module Embeddings
      class Client
        include ::Gitlab::Llm::Concerns::ExponentialBackoff
        include ::Gitlab::Llm::Concerns::Logger

        def initialize(user)
          @user = user
        end

        def code_embeddings(contents:, model_definition:, search: false)
          operation = search ? "search" : "index"
          type = "code_embeddings/#{operation}"

          request(
            type: type,
            model_definition: model_definition,
            contents: contents
          )
        end

        private

        attr_reader :user

        def request(type:, contents:, model_definition:)
          url = "#{model_definition.aigw_base_url}/v1/embeddings/#{type}"

          # this payload matches the payload defined in the AIGW file
          # ai_gateway/api/v1/embeddings/typing.py (EmbeddingsRequest)
          payload = {
            contents: contents,
            model_metadata: model_definition.model_params
          }

          log_request(type: type, model_definition: model_definition, url: url) do
            response = retry_with_exponential_backoff do
              Gitlab::HTTP.post(
                url,
                headers: headers(model_definition),
                body: payload.to_json
              )
            end

            Gitlab::Llm::Embeddings::Response.new(response)
          end
        end

        def headers(model_definition)
          Gitlab::AiGateway.headers(
            user: user,
            unit_primitive_name: model_definition.unit_primitive,
            ai_feature_name: model_definition.feature_name
          ).merge(
            "Accept" => "application/json"
          )
        end

        def log_request(type:, model_definition:, url:)
          ai_component = ai_component_for_logging(type)

          log_info(
            message: 'Performing embeddings request',
            event_name: 'performing_request',
            ai_component: ai_component,
            unit_primitive: model_definition.unit_primitive,
            url: url,
            params: { model_metadata: model_definition.model_params }.to_json
          )

          response = yield

          response_log_params = {
            message: 'Received embeddings response',
            event_name: 'response_received',
            ai_component: ai_component,
            unit_primitive: model_definition.unit_primitive,
            url: url
          }

          response_log_params[:error] = response.error.truncate(100) if response.error.present?

          log_info(**response_log_params)

          response
        end

        def ai_component_for_logging(type)
          type.tr('/', '_')
        end
      end
    end
  end
end
