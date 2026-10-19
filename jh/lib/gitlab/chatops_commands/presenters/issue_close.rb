# frozen_string_literal: true

module Gitlab
  module ChatopsCommands
    module Presenters
      class IssueClose < Presenters::Base
        include Presenters::IssueBase

        def present
          issue_info(pretext)
        end

        def pretext
          "I closed an issue on #{author_profile_link}'s behalf: *#{issue_link(issue)}* in #{project_link}"
        end
      end
    end
  end
end
