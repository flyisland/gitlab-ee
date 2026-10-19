# frozen_string_literal: true

module Gitlab
  module ChatopsCommands
    class IssueNew < IssueCommand
      def self.match(text)
        # we can not match \n with the dot by passing the m modifier as than
        # the title and description are not separated
        # rubocop: disable Lint/MixedRegexpCaptureTypes
        /\Aissue\s+(new|create)\s+(?<title>[^\n]*)\n*(?<description>(.|\n)*)/.match(text)
        # rubocop: enable Lint/MixedRegexpCaptureTypes
      end

      def self.help_message
        'issue new (title) *`⇧ Shift`*+*`↵ Enter`* (description)'
      end

      def self.allowed?(project, user)
        can?(user, :create_issue, project)
      end

      def execute(match)
        title = match[:title]
        description = match[:description].to_s.rstrip

        result = create_issue(title: title, description: description)

        if result.success?
          presenter(result[:issue]).present
        else
          presenter(result[:issue]).display_errors("Failed to create the issue:")
        end
      end

      private

      def create_issue(title:, description:)
        ::Issues::CreateService.new(container: project,
          current_user: current_user,
          params: { title: title, description: description }).execute
      end

      def presenter(issue)
        Gitlab::ChatopsCommands::Presenters::IssueNew.new(issue)
      end
    end
  end
end
