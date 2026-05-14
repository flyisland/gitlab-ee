# frozen_string_literal: true

module Ai
  module ActiveContext
    class ConnectionService
      ConnectionError = Class.new(StandardError)

      def self.connect_to_advanced_search_cluster
        elastic_helper = ::Gitlab::Elastic::Helper.default

        adapter = if elastic_helper.matching_distribution?(:opensearch)
                    :opensearch
                  elsif elastic_helper.matching_distribution?(:elasticsearch)
                    :elasticsearch
                  else
                    raise ConnectionError, 'Connection invalid'
                  end

        options = { use_advanced_search_config: true }
        name = "#{adapter}_advanced_search"

        create_or_update_active_connection(adapter, options, name: name)
      end

      def self.disable_connection
        Ai::ActiveContext::DisableWorker.perform_in(1.minute)
      end

      def self.connect_to_custom_elasticsearch_cluster(url:, username: nil, password: nil)
        # The adapter type will be determined from the input or at runtime when
        # the client connects to the cluster (Elasticsearch/OpenSearch).
        # For now, default to Elasticsearch adapter.
        adapter = :elasticsearch
        password = nil if password == Ai::ActiveContext::Connection::MASKED_PASSWORD
        options = { url: url, username: username, password: password }.compact

        create_or_update_active_connection(adapter, options, name: "#{adapter}_custom")
      end

      private_class_method def self.create_or_update_active_connection(adapter, options, name:)
        adapter_class = Ai::ActiveContext::Connection::ELASTICSEARCH_COMPATIBLE_ADAPTERS[adapter]

        Ai::ActiveContext::Connection.transaction do
          existing_connection = Ai::ActiveContext::Connection.find_by_name(name)

          if existing_connection&.active?
            existing_connection.update!(options: existing_connection.options.merge(options))
          else
            Ai::ActiveContext::Connection.create!(
              name: name,
              adapter_class: adapter_class.to_s,
              options: options
            ).activate!
          end
        end
      end
    end
  end
end
