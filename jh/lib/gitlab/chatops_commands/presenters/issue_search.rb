# frozen_string_literal: true

module Gitlab
  module ChatopsCommands
    module Presenters
      # rubocop:disable Search/NamespacedClass
      # TODO: refactor https://gitlab.com/gitlab-org/gitlab/-/issues/398207
      class IssueSearch < Presenters::Base
        include Presenters::IssueBase

        def present
          summary = if resource.count >= 5
                      "Here are the first 5 issues I found:"
                    elsif resource.one?
                      "Here is the only issue I found:"
                    else
                      "Here are the #{resource.count} issues I found:"
                    end

          {
            type: :markdown,
            title: "Issue search result",
            content: <<~CONTENT
              ### #{summary} \n
              #{issues_list}
            CONTENT
          }
        end

        def empty_result(query)
          { type: :text, content: ::Kernel.format(s_("JH|Chatops|I cannot find any issue related to %{query}"),
            query: query) }
        end

        private

        def issues_list
          resource.map do |issue|
            url = issue_link(issue)
            if need_hide?(issue)
              "- #{url} · Confidential Issue"
            else
              "- #{url} · #{limit(issue.title)} (#{status_text(issue)})"
            end
          end.join(" \n")
        end

        def project
          @project ||= resource.first.project
        end
      end
      # rubocop:enable Search/NamespacedClass
    end
  end
end
