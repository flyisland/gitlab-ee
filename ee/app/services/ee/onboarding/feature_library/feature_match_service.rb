# frozen_string_literal: true

module EE
  module Onboarding
    module FeatureLibrary
      module FeatureMatchService
        extend ::Gitlab::Utils::Override

        private

        override :ai_gateway_ids
        def ai_gateway_ids(normalized_query)
          return [] unless ::Feature.enabled?(:feature_discovery_gemini_search, user)
          return [] unless resource
          return [] unless user
          return [] unless resource.root_ancestor.trial_active?

          catalogue = ::Onboarding::FeatureLibrary::CatalogueBuilder.new(
            panel: panel,
            user: user,
            resource: resource
          ).execute

          return [] if catalogue.empty?

          completion(catalogue, normalized_query).execute
        end

        def completion(catalogue, query)
          ::Gitlab::Llm::AiGateway::Completions::FeatureDiscoverySearch.new(
            prompt_message,
            nil,
            action: :feature_discovery_search,
            query: query,
            features: catalogue
          )
        end

        def prompt_message
          ::Gitlab::Llm::AiMessage.new(
            user: user,
            role: ::Gitlab::Llm::AiMessage::ROLE_USER,
            ai_action: :feature_discovery_search,
            context: ::Gitlab::Llm::AiMessageContext.new(resource: resource)
          )
        end
      end
    end
  end
end
