# frozen_string_literal: true

module Gitlab
  module ChatopsCommands
    module Presenters
      module Helper
        HELP_TITLE = 'Bot commands help'

        extend self

        def help(group_message)
          help_commands = Gitlab::ChatopsCommands::Command.commands.map do |command|
            "- #{group_message ? '@(bot name)' : ''} (project-path) #{command.help_message}"
          end.join("\n")

          {
            type: :markdown,
            title: HELP_TITLE,
            content: <<~CONTENT
              The following commands are available for Bot integration:\n
              #{help_commands}\n
              For more information https://docs.gitlab.cn/jh/user/project/integrations/
            CONTENT
          }.freeze
        end

        def access_denied
          { type: :text, content: s_("JH|Chatops|You are not allowed to perform bot commands.") }
        end

        def not_found_project(path)
          { type: :text, content: ::Kernel.format(s_("JH|Chatops|I cannot find the project %{path}"), path: path) }
        end

        def not_active_user
          {
            type: :text,
            content: s_("JH|Chatops|Your JiHu GitLab user account is locked. " \
              "Please unlock it before performing bot commands.")
          }
        end

        def not_found_issue(iid)
          { type: :text, content: ::Kernel.format(s_("JH|Chatops|I cannot not find the issue %{iid}"), iid: iid) }
        end

        def not_found_command(group_message)
          if group_message
            # rubocop:disable Gitlab/NoCodeCoverageComment
            # :nocov:
            { type: :text, content: s_('JH|Chatops|I cannot understand your command. ' \
              'Type "@(bot name) help" to view all commands.') }
            # :nocov:
            # rubocop:enable Gitlab/NoCodeCoverageComment
          else
            { type: :text,
              content: s_('JH|Chatops|I cannot understand your command. Type "help" to view all commands.') }
          end
        end
      end
    end
  end
end
