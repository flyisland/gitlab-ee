# frozen_string_literal: true

module Gitlab
  module ChatopsCommands
    class IssueMove < IssueCommand
      include LocateProject

      def self.match(text)
        # rubocop: disable Lint/MixedRegexpCaptureTypes
        %r{
          \A                                 # the beginning of a string
          issue\s+move\s+                    # the command
          \#?(?<iid>\d+)\s+                  # the issue id, may preceded by hash sign
          (to\s+)?                           # aid the command to be much more human-ly
          (?<project_path>[^\s]+)            # named group for id of dest. project
        }x.match(text)
        # rubocop: enable Lint/MixedRegexpCaptureTypes
      end

      def self.help_message
        'issue move (issue_id) to (project_path)'
      end

      def self.allowed?(project, user)
        can?(user, :admin_issue, project) # rubocop:disable Gitlab/Authz/PermissionCheck -- there is no more specific permission check for this.
      end

      def execute(match)
        old_issue = find_by_iid(match[:iid])
        target_project = locate_project(match[:project_path])

        return ::Gitlab::ChatopsCommands::Presenters::Helper.not_found_issue(match[:iid]) unless old_issue

        if old_issue.closed?
          return presenter(old_issue).display_text_error(::Kernel.format(
            s_("JH|Chatops|I cannot move closed issue %{iid}"), iid: match[:iid]))
        end

        unless current_user.can?(:read_project, target_project) && target_project
          return presenter(old_issue).display_text_error(::Kernel.format(
            s_("JH|Chatops|I cannot found target project %{path}"), path: match[:project_path]))
        end

        response = ::WorkItems::DataSync::MoveService.new(
          work_item: old_issue, current_user: current_user,
          target_namespace: target_project.project_namespace
        ).execute

        return presenter(old_issue).display_move_error(response.message) if response.error?

        new_issue = response[:work_item]

        presenter(new_issue).present(old_issue)
      end

      private

      def presenter(issue)
        Gitlab::ChatopsCommands::Presenters::IssueMove.new(issue, @params[:group_message])
      end
    end
  end
end
