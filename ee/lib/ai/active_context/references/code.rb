# frozen_string_literal: true

module Ai
  module ActiveContext
    module References
      class Code < ::ActiveContext::Reference
        add_preprocessor :get_content do |refs, skip_missing_content: false, **|
          identifiers = refs.map(&:identifier)
          query = ::ActiveContext::Query.filter(id: identifiers).limit(identifiers.count)

          fetch_content(
            refs: refs,
            query: query,
            collection: Collections::Code,
            skip_missing_content: skip_missing_content
          )
        end

        add_preprocessor :embeddings do |refs, next_model_only: false, **|
          apply_embeddings(
            refs: refs,
            remove_content: false,
            next_model_only: next_model_only
          )
        end

        def self.serialize_data(data)
          { identifier: data[:id] }
        end

        attr_accessor :identifier

        def init
          @identifier = serialized_args.first
        end

        def serialized_attributes
          [identifier]
        end

        def unique_identifier(_)
          identifier
        end

        def operation
          :update
        end

        def as_indexed_json
          {}
        end
      end
    end
  end
end
