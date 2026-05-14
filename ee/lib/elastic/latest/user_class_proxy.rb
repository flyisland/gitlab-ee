# frozen_string_literal: true

module Elastic
  module Latest
    class UserClassProxy < ApplicationClassProxy
      SEARCH_FIELDS = %w[name username email public_email].freeze

      def elastic_search(query, options: {})
        query_hash = if simple_query_string_syntax?(query)
                       basic_query_hash(valid_fields(options), query, options)
                     else
                       fuzzy_query_hash(valid_fields(options), query, options)
                     end

        query_hash[:query][:bool][:filter] ||= []

        query_hash = ::Search::Elastic::Filters.by_user_accessible_namespaces(query_hash:, options:)

        query_hash = forbidden_states_filter(query_hash, options)

        query_hash[:size] = 0 if options[:count_only]
        query_hash = apply_sort(query_hash, options)

        search(query_hash, options)
      end

      def fuzzy_query_hash(fields, query, options)
        clause = options[:count_only] ? :filter : :must

        shoulds = fields.map do |field|
          {
            match: {
              "#{field}": {
                query: query,
                fuzziness: 'AUTO',
                _name: "#{clause}:bool:should:fuzzy:#{field}"
              }
            }
          }
        end

        {
          query: {
            bool: {
              "#{clause}": [
                {
                  bool: {
                    should: shoulds
                  }
                }
              ]
            }
          }
        }
      end

      def forbidden_states_filter(query_hash, options)
        return query_hash if admin_option_set?(options)

        query_hash[:query][:bool][:filter] << {
          term: {
            in_forbidden_state: {
              value: false,
              _name: 'filter:not_forbidden_state'
            }
          }
        }

        query_hash
      end

      # rubocop: disable CodeReuse/ActiveRecord
      def preload_indexing_data(relation)
        relation.includes(:status, :user_preference, :user_detail, members: [source: :namespace])
      end
      # rubocop: enable CodeReuse/ActiveRecord

      private

      def simple_query_string_syntax?(query)
        query.match?(/[+\-|*()~"]/)
      end

      def valid_fields(options)
        return SEARCH_FIELDS if admin_option_set?(options)

        # Searching by private email is only available to admins.
        # Non-admins can get results matching on public_email.
        SEARCH_FIELDS - ['email']
      end

      def admin_option_set?(options)
        options[:admin] == true
      end
    end
  end
end
