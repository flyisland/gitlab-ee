# frozen_string_literal: true

module Gitlab
  module ChatopsCommands
    module Presenters
      class IssueNew < Presenters::Base
        include Presenters::IssueBase

        def present
          { type: :markdown, content: pretext, title: "issue #{issue_iid} created" }
        end

        private

        def pretext
          "I created an issue on #{author_profile_link}'s behalf: *#{issue_link(resource)}* in #{project_link}"
        end
      end
    end
  end
end
