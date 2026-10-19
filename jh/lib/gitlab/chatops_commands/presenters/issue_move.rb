# frozen_string_literal: true

module Gitlab
  module ChatopsCommands
    module Presenters
      class IssueMove < Presenters::Base
        include Presenters::IssueBase

        def present(old_issue)
          issue_info("Moved issue *#{issue_link(old_issue)}* to *#{issue_link(issue)}*")
        end

        def display_move_error(error)
          {
            type: :markdown,
            content: header_with_list("Failed to move the issue:", [error]),
            title: "Move issue error"
          }
        end

        def display_text_error(error)
          { type: :text, content: error }
        end
      end
    end
  end
end
