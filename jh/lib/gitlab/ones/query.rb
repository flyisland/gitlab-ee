# frozen_string_literal: true

module Gitlab
  module Ones
    class Query
      include QueryHelper

      # STATUSES = %w[all opened closed].freeze
      STATUSES = {
        'all' => %w[to_do in_progress done],
        'opened' => %w[to_do in_progress],
        'closed' => %w[done]
      }.freeze

      ISSUES_DEFAULT_LIMIT = 20
      ISSUES_MAX_LIMIT = 50

      def initialize(integration, params)
        @client = Client.new(integration)
        @params = params
      end

      def issues
        response = client.graphql_query(issues_query(search: search_params), issues_variables) \
                         .dig('data', 'buckets').first

        Kaminari.paginate_array(response['tasks'], **paginate_options(response['pageInfo']))
      end

      def issue
        return {} if task_uuid_params.blank?

        response = client.graphql_query(issue_query, { key: "task-#{task_uuid_params}" })
        task = response.dig('data', 'task')
        task.merge({ 'comments' => comments })
      end

      private

      attr_reader :client, :params

      def issues_variables
        variables = {
          count: limit_params,
          cursor: '',
          orderBy: order_params,
          filterGroup: [{
            project_in: [client.project_uuid],
            statusCategory_in: status_params
          }],
          search: { keyword: search_params }
        }
        variables[:cursor] = end_cursor(variables) if page_params != 1
        variables
      end

      def end_cursor(variables)
        response = client.graphql_query(
          issues_query(search: search_params, for_cursor: true),
          { count: limit_params * page_params }.merge(variables))
        response.dig('data', 'buckets').first.dig('pageInfo', 'endCursor')
      end

      def page_params
        (params[:page].presence || 1).to_i
      end

      def limit_params
        limit = params[:limit].presence || ISSUES_DEFAULT_LIMIT
        [limit.to_i, ISSUES_MAX_LIMIT].min
      end

      def search_params
        params[:search].to_s.strip
      end

      # CREATED_ASC
      # CREATED_DESC
      # UPDATED_ASC
      # UPDATED_DESC
      def order_params
        key, order = params['sort'].to_s.downcase.split('_', 2)
        ones_key = (key == 'created' ? 'createTime' : 'serverUpdateStamp')
        ones_order = (order == 'asc' ? 'ASC' : 'DESC')

        { ones_key => ones_order }
      end

      def status_params
        if params[:state].in?(STATUSES.keys)
          STATUSES[params[:state]]
        else
          STATUSES['opened']
        end
      end

      def paginate_options(page_info)
        total_count = page_info['totalCount'].to_i
        limit = page_info['count'].to_i
        {
          limit: limit == 0 ? ISSUES_DEFAULT_LIMIT : limit,
          total_count: total_count
        }
      end

      def task_uuid_params
        params[:id].match(/\Atask-(\w+)\z/)&.captures&.first
      end

      def comments
        return [] if task_uuid_params.blank?

        user_keys = []
        comments = client.message_query(task_uuid_params)['messages'].filter do |comment|
          next if comment['type'] != 'discussion' || comment['ref_type'] != 'task'

          user_keys << "user-#{comment['from']}"
        end

        users = users(user_keys)
        comments.each { |comment| comment['user'] = users["user-#{comment['from']}"] }
        comments
      end

      def users(user_keys)
        response = client.graphql_query(users_query, { filter: { key_in: user_keys } }) \
                         .dig('data', 'buckets').first
        response['users'].index_by { |user| user['key'] }
      end
    end
  end
end
