# frozen_string_literal: true

module Gitlab
  module ChatopsCommands
    class Run < BaseCommand
      def self.match(text)
        # rubocop: disable Lint/MixedRegexpCaptureTypes
        /\Arun\s+(?<command>\S+)(\s+(?<arguments>.+))?\z/m.match(text)
        # rubocop: enable Lint/MixedRegexpCaptureTypes
      end

      def self.help_message
        'run (command) (arguments)'
      end

      def self.available?(project)
        project.builds_enabled?
      end

      def self.allowed?(project, user)
        can?(user, :create_pipeline, project)
      end

      def execute(match)
        command = Chat::Command.new(
          project: project,
          chat_name: chat_name,
          name: match[:command],
          arguments: match[:arguments],
          channel: params[:responder_channel],
          response_url: params[:responder_response_url]
        )

        presenter = Gitlab::ChatopsCommands::Presenters::Run.new
        pipeline = command.try_create_pipeline

        if pipeline&.persisted?
          presenter.present(pipeline)
        else
          presenter.failed_to_schedule(command.name)
        end
      end
    end
  end
end
