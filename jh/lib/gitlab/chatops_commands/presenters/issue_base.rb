# frozen_string_literal: true

module Gitlab
  module ChatopsCommands
    module Presenters
      module IssueBase
        def need_hide?(issue)
          issue.confidential? && is_group_message
        end

        def status_text(issuable)
          issuable.open? ? s_('JH|Chatops|Open') : s_('JH|Chatops|Closed')
        end

        def issue_link(issue)
          "[#{issue.to_reference}](#{url_for([issue.project, issue])})"
        end

        def project
          resource.project
        end

        def author
          resource.author
        end

        def issue_iid
          resource.to_reference
        end

        def issue_info(pretext)
          if need_hide?(resource)
            {
              type: :markdown,
              title: "Confidential issue #{issue_iid}",
              content: pretext
            }
          else
            {
              type: :markdown,
              title: "Issue #{issue_iid}(#{status_text(resource)})",
              content: <<~CONTENT
                ### #{pretext}\n
                - Title: #{limit(resource.title)}\n
                - Author: #{limit(author.name)}\n
                - Assignee: #{limit(resource.assignees.any? ? resource.assignees.first.name : 'None')}\n
                - Milestone: #{limit(resource.milestone ? resource.milestone.title : 'None')}\n
                - Labels: #{limit(resource.labels.any? ? resource.label_names.join(', ') : 'None')}
              CONTENT
            }
          end
        end

        def already_closed
          { type: :text, content: ::Kernel.format(s_("JH|Chatops|Issue %{iid} is already closed."),
            iid: resource.to_reference) }
        end

        private

        attr_reader :resource

        alias_method :issue, :resource
      end
    end
  end
end
