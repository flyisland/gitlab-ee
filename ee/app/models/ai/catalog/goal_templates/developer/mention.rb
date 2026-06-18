# frozen_string_literal: true

module Ai
  module Catalog
    module GoalTemplates
      class Developer
        class Mention
          TEMPLATE = <<~GOAL.strip
            @%{triggered_by_username} mentioned you in a note on this %{resource_name}: %{note_url}

            <gitlab_context>
            %{source_context}
            </gitlab_context>

            <conversation>
            %{user_input}
            </conversation>

            Read the conversation thread to fully understand what is being asked. Then determine the appropriate course of action — this could be implementing code changes, researching a topic, creating an issue, answering a question, posting a status update, or any other task.

            %{delivery_instructions}

            If the task involves code changes, verify they work. Use your judgment on whether to push to an existing branch (e.g. if asked to fix something on the current MR) or create a new merge request — the task context should make this clear. If you create a merge request, assign @%{triggered_by_username} as the assignee unless told differently.
          GOAL

          DELIVERY_INSTRUCTIONS = {
            adapter: <<~TEXT.strip,
              Your final response will be posted automatically as a reply in the discussion thread. @mention @%{triggered_by_username} in your reply so they are notified. Do not post notes or comments yourself unless the task explicitly requires creating a separate resource (e.g. an issue or merge request).
            TEXT
            default: <<~TEXT.strip
              When responding, reply in the same discussion thread where you were mentioned. @mention @%{triggered_by_username} in your reply so they are notified. Only post a new top-level comment if the task explicitly calls for a standalone update (e.g. a status update posted to an issue, not a reply to the mention).

              To reply in the discussion thread, use the GitLab discussions API via `glab api` with discussion ID `%{discussion_id}`. Do NOT use `glab issue note` or `glab mr note` as they only create top-level comments, not thread replies.
            TEXT
          }.freeze

          def self.template
            TEMPLATE
          end

          def self.vars(resource:, params:)
            resource_url = Gitlab::UrlBuilder.build(resource)
            triggered_by_username = params[:triggered_by_username].to_s
            note_id = params[:note_id]
            note_url = note_id ? "#{resource_url}#note_#{note_id}" : resource_url

            default_context = "#{Developer.resource_display_name(resource).capitalize}: #{note_url}"
            source_context = params[:source_context] || default_context

            delivery_mode = params[:delivery_mode] || :default
            delivery_template = DELIVERY_INSTRUCTIONS.fetch(delivery_mode, DELIVERY_INSTRUCTIONS[:default])
            delivery_text = delivery_template
              .gsub('%{triggered_by_username}', triggered_by_username)
              .gsub('%{discussion_id}', params[:discussion_id].to_s)

            {
              resource_name: Developer.resource_display_name(resource),
              triggered_by_username: triggered_by_username,
              note_url: note_url,
              source_context: source_context,
              delivery_instructions: delivery_text
            }
          end
        end
      end
    end
  end
end
