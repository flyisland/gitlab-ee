# frozen_string_literal: true

module Ai
  module Catalog
    module GoalTemplates
      class Developer
        class Mention
          # Legacy self-post path; removed once ai_use_messaging_adapter_for_mentions
          # is fully enabled and Adapter is the only mode.
          class Default < Mention
            TEMPLATE = <<~GOAL.strip
              @%{triggered_by_username} mentioned you in a note on this %{resource_name}: %{note_url}

              <gitlab_context>
              %{source_context}
              </gitlab_context>

              <conversation>
              %{user_input}
              </conversation>

              Read the conversation thread to fully understand what is being asked. Then determine the appropriate course of action — this could be implementing code changes, researching a topic, creating an issue, answering a question, posting a status update, or any other task.

              Reply in the same discussion thread where you were mentioned (discussion ID `%{discussion_id}`) and @mention @%{triggered_by_username} so they are notified. See the glab skill for the right command to post a threaded reply for this resource type. Only post a new top-level comment if the task explicitly calls for a standalone update (e.g. a status update posted to an issue, not a reply to the mention).

              If the task involves code changes, verify they work. Use your judgment on whether to push to an existing branch (e.g. if asked to fix something on the current MR) or create a new merge request — the task context should make this clear. If you create a merge request, assign @%{triggered_by_username} as the assignee unless told differently.
            GOAL

            def self.template
              TEMPLATE
            end

            def self.vars(resource:, params:)
              base_vars(resource: resource, params: params).merge(discussion_id: params[:discussion_id].to_s)
            end
          end
        end
      end
    end
  end
end
