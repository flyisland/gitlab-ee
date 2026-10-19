# frozen_string_literal: true

module Gitlab
  module Llm
    class ClientFactory
      DEFAULT_PROVIDER = :chat_glm
      JH_PROVIDERS = [:chat_glm, :mini_max].freeze

      # In order to achieve the most basic functions, they should implement these interfaces:
      # def initialize(user, request_timeout: nil); end
      # def chat(content:, moderated: nil, **options); end
      CLIENTS = {
        chat_glm: ::Gitlab::Llm::ChatGlm::Query,
        mini_max: ::Gitlab::Llm::MiniMax::Client
      }.freeze

      def self.client(provider: ai_provider)
        CLIENTS.fetch(provider)
      end

      def self.ai_provider
        (ENV['JH_AI_PROVIDER'] || DEFAULT_PROVIDER).to_sym
      end

      def self.response_modifier
        "::Gitlab::Llm::#{ai_provider.to_s.classify}::ResponseModifiers::Chat".constantize
      end

      def self.jh_provider?
        ai_provider.in?(JH_PROVIDERS)
      end
    end
  end
end
