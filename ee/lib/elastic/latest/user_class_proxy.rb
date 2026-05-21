# frozen_string_literal: true

module Elastic
  module Latest
    class UserClassProxy < ApplicationClassProxy
      # rubocop: disable CodeReuse/ActiveRecord -- preload needs AR .includes
      def preload_indexing_data(relation)
        relation.includes(:status, :user_preference, :user_detail, members: [source: :namespace])
      end
      # rubocop: enable CodeReuse/ActiveRecord

      def elastic_search(query, options: {})
        query_hash = ::Search::Elastic::UserQueryBuilder.build(query: query, options: options)

        search(query_hash, options)
      end
    end
  end
end
