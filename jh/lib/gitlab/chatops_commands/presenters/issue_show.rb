# frozen_string_literal: true

module Gitlab
  module ChatopsCommands
    module Presenters
      class IssueShow < Presenters::Base
        include Presenters::IssueBase

        def present
          pretext = if need_hide?(resource)
                      "[Confidential issue #{issue_iid}](#{resource_url})"
                    else
                      "Issue [#{issue_iid}(#{status_text(resource)})](#{resource_url}) from #{project_link}"
                    end

          issue_info(pretext)
        end
      end
    end
  end
end
