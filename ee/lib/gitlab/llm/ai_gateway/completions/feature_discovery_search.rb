# frozen_string_literal: true

module Gitlab
  module Llm
    module AiGateway
      module Completions
        # This caller sends the query plus a feature catalogue to the AI Gateway
        # (Gemini by default) and returns the ordered list of matching feature IDs.
        # Unlike most completions this runs synchronously and returns the parsed IDs
        class FeatureDiscoverySearch < Base # rubocop:disable Search/NamespacedClass -- "Search" means feature discovery
          extend ::Gitlab::Utils::Override

          PROMPT_VERSION = '^1.0.0'

          # Returns the ordered Array of feature IDs the model matched, intersected
          # with the catalogue we sent (defends against hallucinated IDs). Returns []
          # on any error so the caller degrades to "no results", never an exception.
          override :execute
          def execute
            return [] unless valid?

            response = request!
            parse_feature_ids(response)
          end

          override :inputs
          def inputs
            { query: query, features: features }
          end

          # Drives namespace feature-setting (model routing) selection. The pin itself
          # is owned by a later work item; this establishes the seam.
          override :root_namespace
          def root_namespace
            resource.try(:root_ancestor)
          end

          private

          override :prompt_version
          def prompt_version
            PROMPT_VERSION
          end

          override :valid?
          def valid?
            super && query.present? && features.present?
          end

          def query
            options[:query]
          end

          def features
            options[:features]
          end

          def parse_feature_ids(response)
            ids = extract_ids(response)
            return [] if ids.empty?

            # Preserve the model-provided order, keep only IDs we actually offered.
            known_ids = features.map { |feature| feature[:id].to_s }
            ids.map(&:to_s).uniq.select { |id| known_ids.include?(id) }
          rescue StandardError => e
            Gitlab::ErrorTracking.track_exception(e, ai_action: prompt_message.ai_action)
            []
          end

          def extract_ids(response)
            parsed = response.is_a?(String) ? Gitlab::Json.safe_parse(response) : response

            case parsed
            when Array
              parsed
            when Hash
              parsed['feature_ids'] || parsed['features'] || []
            else
              []
            end
          end
        end
      end
    end
  end
end
