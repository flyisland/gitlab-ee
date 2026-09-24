# frozen_string_literal: true

module Gitlab
  module ChatopsCommands
    module Presenters
      class IssueComment < Presenters::Base
        def present
          {
            type: :markdown,
            title: "New comment on #{issue.to_reference}",
            content: <<~CONTENT
              ### #{pretext}\n
              Comment\n
              #{resource.note&.split("\n")&.join("\n\n")}
            CONTENT
          }
        end

        def present_quick_actions
          # commands_only will contains message like  ["Set time estimate to 1d. Added 1h spent time."]
          actions = resource.errors[:commands_only].first.split('.').map do |message|
            "- #{message.strip}"
          end
          {
            type: :markdown,
            title: "Quick actions on #{issue.to_reference}",
            content: <<~CONTENT
              ### Quick actions on *[#{issue.to_reference}](#{url_for([issue.project, issue])})* in #{project_link} \n
              #{actions.join("\n")}
            CONTENT
          }
        end

        private

        def pretext
          "I commented on an issue on #{author_profile_link}'s behalf: " \
            "*[#{issue.to_reference}](#{url_for([issue.project, issue])})* in #{project_link}"
        end

        def issue
          resource.noteable
        end

        def project
          issue.project
        end

        def author
          resource.author
        end
      end
    end
  end
end
