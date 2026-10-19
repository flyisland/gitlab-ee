# frozen_string_literal: true

module Gitlab
  module ChatopsCommands
    class IssueShow < IssueCommand
      def self.match(text)
        /\Aissue\s+show\s+#{Issue.reference_prefix}?(?<iid>\d+)/.match(text)
      end

      def self.help_message
        "issue show (id)"
      end

      def execute(match)
        issue = find_by_iid(match[:iid])

        if issue
          presenter(issue).present
        else
          ::Gitlab::ChatopsCommands::Presenters::Helper.not_found_issue(match[:iid])
        end
      end

      private

      def presenter(issue)
        Gitlab::ChatopsCommands::Presenters::IssueShow.new(issue, params[:group_message])
      end
    end
  end
end
