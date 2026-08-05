# frozen_string_literal: true

module Ai
  module Catalog
    module GoalTemplates
      class Developer
        class Mention
          class Adapter < Mention
            TEMPLATE = <<~GOAL.strip
              @%{triggered_by_username} is talking to you in a conversation on this %{resource_name}.

              <gitlab_context>
              %{source_context}
              </gitlab_context>

              <conversation>
              %{user_input}
              </conversation>

              Read the conversation and do what's being asked. Use tools for the work — reading the MR, running commands, pushing commits, or writing elsewhere when the task asks.

              Reply to @%{triggered_by_username} in your response, not by posting a comment — your response reaches them automatically, so a comment would duplicate it.

              If you change code, verify it, and assign @%{triggered_by_username} to any merge request you open.
            GOAL

            def self.template
              TEMPLATE
            end

            def self.vars(resource:, params:)
              base_vars(resource: resource, params: params)
            end
          end
        end
      end
    end
  end
end
