# frozen_string_literal: true

module Gitlab
  module ChatopsCommands
    class IssueClose < IssueCommand
      def self.match(text)
        /\Aissue\s+close\s+#{Issue.reference_prefix}?(?<iid>\d+)/.match(text)
      end

      def self.help_message
        "issue close (id)"
      end

      def self.allowed?(project, user)
        can?(user, :update_issue, project)
      end

      def execute(match)
        issue = find_by_iid(match[:iid])

        presenter = presenter(issue)
        return ::Gitlab::ChatopsCommands::Presenters::Helper.not_found_issue(match[:iid]) unless issue
        return presenter.already_closed if issue.closed?

        close_issue(issue: issue)

        presenter.present
      end

      private

      def close_issue(issue:)
        ::Issues::CloseService.new(container: project, current_user: current_user).execute(issue)
      end

      def presenter(issue)
        Gitlab::ChatopsCommands::Presenters::IssueClose.new(issue, params[:group_message])
      end
    end
  end
end
