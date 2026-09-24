# frozen_string_literal: true

module Gitlab
  module ChatopsCommands
    class Command < BaseCommand
      def self.commands
        [
          Gitlab::ChatopsCommands::IssueShow,
          Gitlab::ChatopsCommands::IssueNew,
          Gitlab::ChatopsCommands::IssueSearch,
          Gitlab::ChatopsCommands::IssueMove,
          Gitlab::ChatopsCommands::IssueClose,
          Gitlab::ChatopsCommands::IssueComment,
          Gitlab::ChatopsCommands::Deploy,
          Gitlab::ChatopsCommands::Run
        ]
      end

      def execute
        command, match = match_command

        if command
          if command.allowed?(project, current_user)
            command.new(project, chat_name, params).execute(match)
          else
            ::Gitlab::ChatopsCommands::Presenters::Helper.access_denied
          end
        else
          ::Gitlab::ChatopsCommands::Presenters::Helper.not_found_command(params[:group_message])
        end
      end

      def match_command
        match = nil
        service =
          available_commands.find do |klass|
            match = klass.match(params[:text])
          end

        [service, match]
      end

      private

      def available_commands
        self.class.commands.keep_if do |klass|
          klass.available?(project)
        end
      end
    end
  end
end
