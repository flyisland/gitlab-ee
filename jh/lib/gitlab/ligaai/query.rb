# frozen_string_literal: true

module Gitlab
  module Ligaai
    class Query
      # 2: Not starting, 3: In process, 4: Done
      STATUSES = {
        'all' => [2, 3, 4],
        'opened' => [2, 3],
        'closed' => [4]
      }.freeze
      ISSUES_DEFAULT_LIMIT = 20
      ISSUES_MAX_LIMIT = 50

      def initialize(integration, params)
        @client = Client.new(integration)
        @params = params
      end

      def issues
        _code, issues = client.fetch_issues(query_options)
        return [] if issues.blank?

        Kaminari.paginate_array(
          issues['list'],
          limit: query_limit,
          total_count: issues['total']
        )
      end

      def issue
        _code, issue = client.fetch_issue(params[:id])
        issue['data']
      end

      private

      attr_reader :client, :params

      def query_options
        order_by, sort = query_order
        {
          summary: query_search,
          statusTypes: query_status,
          orderBy: order_by,
          sort: sort,
          pageNumber: query_page,
          pageSize: query_limit
        }
      end

      def query_page
        params[:page].presence || 1
      end

      def query_limit
        limit = params[:limit].presence || ISSUES_DEFAULT_LIMIT
        [limit.to_i, ISSUES_MAX_LIMIT].min
      end

      def query_search
        params[:search] || ''
      end

      def query_status
        return STATUSES[params[:state]] if params[:state]&.in?(STATUSES.keys)

        STATUSES['opened']
      end

      def query_order
        key, order = params['sort'].to_s.split('_', 2)
        ligaai_order_by = (key == 'created' ? 'createTime' : 'updateTime')
        ligaai_sort = (order == 'asc' ? 'ASC' : 'DESC')

        [ligaai_order_by, ligaai_sort]
      end
    end
  end
end
