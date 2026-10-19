# frozen_string_literal: true

module Gitlab
  module Ones
    module QueryHelper
      def project_query
        <<~QUERY
          query FetchProject($key: string) {
            project(key: $key) {
              uuid
              name
              createTime
              status {
                category
              }
            }
          }
        QUERY
      end

      def issue_query
        <<~QUERY
          query FetchIssue($key: string) {
            task(key: $key) {
              ...task
            }
          }

          #{task_fragment(details: true)}
        QUERY
      end

      def issues_query(search: '', for_cursor: false)
        # Passing null or empty string through variables is not supported
        search_argument = search.present? ? ', search: $search' : ''
        task_attributes = for_cursor ? 'uuid' : '...task'

        <<~QUERY
          query FetchIssueList {
            buckets(
                groupBy: { tasks: {} }, pagination: { first: $count, after: $cursor }) {
                tasks(
                  filterGroup: $filterGroup
                  , orderBy: $orderBy
                  #{search_argument}) {
                #{task_attributes}
              }
              pageInfo {
                count
                totalCount
                endCursor
              }
            }
          }

          #{task_fragment(for_cursor: for_cursor)}
        QUERY
      end

      def users_query
        <<~QUERY
          query FetchUsers {
            buckets(
              groupBy: { users: {} }) {
              users(filter: $filter) {
                ...user
              }
            }
          }

          #{user_fragment}
        QUERY
      end

      private

      def user_fragment
        <<~QUERY
          fragment user on User {
            name
            key
            avatar
          }
        QUERY
      end

      def task_fragment(details: false, for_cursor: false)
        return '' if for_cursor

        details_attributes = details ? "description" : ''

        <<~QUERY
          fragment task on Task {
            uuid
            key
            name
            name
            createTime
            serverUpdateStamp
            status {
              category
            }
            owner {
              ...user
            }
            assign {
              ...user
            }
            deadline
            #{details_attributes}
          }

          #{user_fragment}
        QUERY
      end
    end
  end
end
