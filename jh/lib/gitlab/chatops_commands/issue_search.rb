# frozen_string_literal: true

module Gitlab
  module ChatopsCommands
    # rubocop:disable Search/NamespacedClass
    # TODO: refactor https://gitlab.com/gitlab-org/gitlab/-/issues/398207
    class IssueSearch < IssueCommand
      def self.match(text)
        /\Aissue\s+search\s+(?<query>.*)/.match(text)
      end

      def self.help_message
        "issue search (your query)"
      end

      # rubocop: disable CodeReuse/ActiveRecord
      def execute(match)
        issues = collection.search(match[:query]).limit(QUERY_LIMIT)

        if issues.present?
          presenter(issues).present
        else
          presenter(issues).empty_result(match[:query])
        end
      end

      # rubocop: enable CodeReuse/ActiveRecord

      def presenter(issues)
        Gitlab::ChatopsCommands::Presenters::IssueSearch.new(issues, @params[:group_message])
      end
    end
    # rubocop:enable Search/NamespacedClass
  end
end
