# frozen_string_literal: true

module Ai
  module Messaging
    module Adapters
      class Slack < Base
        InstallationNotFoundError = Class.new(StandardError)

        # Slack-assembled goals are kept under this many characters, leaving
        # headroom below the model's hard Ai::DuoWorkflows::Workflow::GOAL_MAX_LENGTH
        # so the goal never fails validation. Referencing the model constant keeps
        # the two from drifting. Also surfaced to users in the message_too_long error.
        GOAL_CHARACTER_LIMIT = ::Ai::DuoWorkflows::Workflow::GOAL_MAX_LENGTH - 384 # ~16_000

        def self.adapter_key
          'slack'
        end

        # Async path: reconstructed from persisted callback context by CallbackWorker.
        # Only deliver_result, deliver_error, and lifecycle hooks are called on this instance.
        def self.from_callback_context(ctx)
          new(
            team_id: ctx['team_id'],
            channel_id: ctx['channel_id'],
            thread_ts: ctx['thread_ts'],
            message_ts: ctx['message_ts'],
            user_id: ctx['user_id']
          )
        end

        # Sync path: constructed by the caller (AppMentionedService) with full event state.
        def initialize(team_id:, channel_id:, thread_ts:, message_ts:, user_id:)
          @team_id = team_id
          @channel_id = channel_id
          @thread_ts = thread_ts
          @message_ts = message_ts
          @user_id = user_id
        end

        def build_callback_context
          {
            'team_id' => @team_id,
            'channel_id' => @channel_id,
            'thread_ts' => @thread_ts,
            'message_ts' => @message_ts,
            'user_id' => @user_id
          }
        end

        # Earliest user-visible acknowledgement -- the reaction shows we received
        # the request and the rotating status indicator shows we're working on it
        # while the flow is provisioned and the CI container sets up. The status
        # is replaced by the posted message in on_flow_started, once the agent
        # actually starts. on_flow_enqueued is intentionally left as the Base
        # no-op: there is nothing extra to surface between receipt and start.
        def on_request_received
          slack_api.add_reaction(channel: @channel_id, name: 'eyes', timestamp: @message_ts)
          slack_api.set_status(
            channel: @channel_id,
            thread_ts: @thread_ts,
            status: status_loading_messages.first,
            loading_messages: status_loading_messages
          )
        rescue StandardError => e
          track_slack_exception(e, build_callback_context)
        end

        # Fires when the agent actually begins (workflow created -> running),
        # driven asynchronously by WorkflowStartedEvent -> CallbackWorker.
        # We post one message here and edit it in place later (deliver_result),
        # so the whole run reads as a single message. status_ts and the session
        # link are persisted because the terminal hooks run in a separate process
        # (CallbackWorker) and have only the callback context to work from.
        # Posting also clears the setStatus indicator -- the intended handoff
        # from the "working" status to the live message.
        #
        # Idempotent: CallbackWorker runs in an at-least-once worker, so guard on
        # the persisted status_ts (set only by a successful post below) to avoid
        # posting a duplicate acknowledgement on redelivery/retry.
        def on_flow_started(callback_context:, workflow:)
          return if callback_context['status_ts'].present?

          callback_context['session_url'] = workflow.web_url

          response = slack_api.post_message(
            channel: callback_context['channel_id'],
            thread_ts: callback_context['thread_ts'],
            text: ack_message,
            blocks: body_with_session_footer(ack_message, callback_context)
          )
          callback_context['status_ts'] = response['ts'] if response['ok']

          # Persist the session link unconditionally (and status_ts when the post
          # succeeded) so the async terminal hooks can still render the link even
          # if this acknowledgement post failed.
          persist_progress_state(workflow, callback_context)
        rescue StandardError => e
          track_slack_exception(e, callback_context)
        end

        def on_flow_completed(callback_context:, workflow:) # rubocop:disable Lint/UnusedMethodArgument -- interface contract
          slack_api.remove_reaction(channel: callback_context['channel_id'], name: 'eyes',
            timestamp: callback_context['message_ts'])
          slack_api.add_reaction(channel: callback_context['channel_id'], name: 'white_check_mark',
            timestamp: callback_context['message_ts'])
        rescue StandardError => e
          track_slack_exception(e, callback_context)
        end

        # workflow: nil -- sync failure before a workflow exists, eyes was already added via on_request_received.
        # workflow: present -- async failure, either before on_flow_started (no message posted yet) or after it.
        # In both cases eyes was added, so we always attempt to remove it.
        def on_flow_failed(callback_context:, error:, workflow: nil)
          slack_api.remove_reaction(channel: callback_context['channel_id'], name: 'eyes',
            timestamp: callback_context['message_ts'])
          slack_api.add_reaction(channel: callback_context['channel_id'], name: 'x',
            timestamp: callback_context['message_ts'])

          # On failure the GitLab session is where the user investigates what
          # went wrong, so we surface the session link whenever a workflow exists:
          #   * status_ts present -- we already posted a message; edit it in place,
          #     keeping the link.
          #   * no status_ts but workflow present -- the flow failed before
          #     on_flow_started ran (e.g. container/runner setup failed), so no
          #     message was posted yet. Clear the status and post a threaded reply
          #     with the error and the session link so the run is still traceable.
          #   * no workflow (sync failure before a workflow exists) -- nothing to
          #     link; clear the status and send an ephemeral error.
          if callback_context['status_ts']
            slack_api.update_message(
              channel: callback_context['channel_id'],
              ts: callback_context['status_ts'],
              text: with_session_link(callback_context, error_text(error)),
              blocks: body_with_session_footer(error_text(error), callback_context)
            )
          elsif workflow
            callback_context['session_url'] = workflow.web_url
            clear_status_indicator(callback_context)
            post_threaded_reply(
              callback_context,
              with_session_link(callback_context, error_text(error)),
              blocks: body_with_session_footer(error_text(error), callback_context)
            )
          else
            clear_status_indicator(callback_context)
            deliver_error(callback_context: callback_context, error: error)
          end
        rescue StandardError => e
          track_slack_exception(e, callback_context)
        end

        # Edits the acknowledgement message in place so the whole run reads as a
        # single message: the answer in a markdown block with a subtle
        # context-block footer linking the session. If Slack rejects the blocks
        # (e.g. the answer exceeds the markdown block's 12k limit) we re-edit
        # with plain text (link inline) so long answers are never lost.
        # Best-effort delivery: errors are tracked but never raised to the
        # caller (CallbackWorker) to avoid retries for non-critical failures.
        def deliver_result(callback_context:, message:)
          fallback_text = with_session_link(callback_context, message)
          return post_threaded_reply(callback_context, fallback_text) unless callback_context['status_ts']

          response = slack_api.update_message(
            channel: callback_context['channel_id'],
            ts: callback_context['status_ts'],
            text: fallback_text,
            blocks: body_with_session_footer(message, callback_context)
          )
          return if response['ok']

          slack_api.update_message(
            channel: callback_context['channel_id'],
            ts: callback_context['status_ts'],
            text: fallback_text,
            blocks: []
          )
        rescue StandardError => e
          track_slack_exception(e, callback_context)
        end

        # Posts an ephemeral error message visible only to the requesting user.
        # Best-effort: same rationale as deliver_result above (errors are tracked,
        # never raised, to avoid CallbackWorker retries for non-critical failures).
        # Threads the error into an existing thread; a top-level mention gets
        # channel-root placement to maximise visibility of the private ephemeral.
        def deliver_error(callback_context:, error:)
          in_existing_thread = callback_context['thread_ts'].present? &&
            callback_context['thread_ts'] != callback_context['message_ts']
          thread_ts = in_existing_thread ? callback_context['thread_ts'] : nil

          slack_api.post_ephemeral(
            channel: callback_context['channel_id'],
            user: callback_context['user_id'],
            text: error_text(error),
            thread_ts: thread_ts
          )
        rescue StandardError => e
          track_slack_exception(e, callback_context)
        end

        private

        def post_threaded_reply(callback_context, text, blocks: [])
          slack_api.post_message(
            channel: callback_context['channel_id'],
            thread_ts: callback_context['thread_ts'],
            text: text,
            blocks: blocks
          )
        end

        # Clears a setStatus indicator that is still showing because we never
        # posted a message (a failure before on_flow_started). An ephemeral error
        # and reactions do not clear it on their own.
        def clear_status_indicator(callback_context)
          slack_api.set_status(
            channel: callback_context['channel_id'],
            thread_ts: callback_context['thread_ts'],
            status: ''
          )
        end

        # Renders the message as a markdown block (standard Markdown, ~12k char
        # limit, translated natively by Slack) with a subtle context-block
        # footer linking the GitLab session.
        def body_with_session_footer(message, callback_context)
          blocks = [{ type: 'markdown', text: message }]
          url = callback_context['session_url']
          if url.present?
            link_text = s_('DuoSlack|View session in GitLab')
            blocks << { type: 'context', elements: [{ type: 'mrkdwn', text: "<#{url}|#{link_text}>" }] }
          end

          blocks
        end

        # Slack shows `text` only when a message has no blocks, so this inline-link
        # form is the notification text and the fallback when blocks are rejected.
        def with_session_link(callback_context, message)
          url = callback_context['session_url']
          return message if url.blank?

          "#{message}\n\n_<#{url}|#{s_('DuoSlack|View session in GitLab')}>_"
        end

        def persist_progress_state(workflow, callback_context)
          workflow.merge_messaging_callback_context!(
            callback_context.slice('status_ts', 'session_url').compact
          )
        end

        def ack_message
          s_("DuoSlack|On it! Working on your request.")
        end

        def status_loading_messages
          [
            s_("DuoSlack|is getting started…"),
            s_("DuoSlack|is reviewing your request…"),
            s_("DuoSlack|is spinning up the agent…")
          ]
        end

        def error_text(error)
          case error
          when :namespace_not_configured
            preferences_url = ::Gitlab::Routing.url_helpers.profile_preferences_url

            format(
              s_("DuoSlack|Set your default Duo namespace in your " \
                "GitLab preferences (%{preferences_url}) to use Duo from Slack."),
              preferences_url: preferences_url
            )
          when :flow_not_enabled
            s_("DuoSlack|The Duo Developer flow is not enabled for your namespace. " \
              "Ask a group owner to enable it in the Duo Agent Platform settings.")
          when :service_account_error
            s_("DuoSlack|Could not set up the service account for the Duo Developer flow. " \
              "Contact your group owner.")
          when :workspace_project_error
            s_("DuoSlack|Could not set up the workspace project. " \
              "Check that you have access to the namespace and permission to create projects.")
          when :execute_workflow_failed
            s_("DuoSlack|Failed to start the Duo Developer workflow. Try again.")
          when :flow_failed
            s_("DuoSlack|Something went wrong while running the task. Try again.")
          when :no_response
            s_("DuoSlack|The task completed but the agent didn't produce a response. " \
              "Check the CI job logs for details.")
          when :message_too_long
            format(
              s_("DuoSlack|Your message is too long for me to process " \
                "(the limit is about %{limit} characters). Shorten it and mention me again."),
              limit: GOAL_CHARACTER_LIMIT
            )
          else
            s_("DuoSlack|Something went wrong. Try again.")
          end
        end

        def slack_api
          @slack_api ||= begin
            installation = SlackIntegration.with_bot.find_by_team_id(@team_id)
            raise InstallationNotFoundError, "No Slack installation found for team #{@team_id}" unless installation

            ::Slack::API.new(installation)
          end
        end

        def track_slack_exception(exception, callback_context)
          Gitlab::ErrorTracking.track_exception(exception,
            slack_team_id: callback_context['team_id'],
            channel_id: callback_context['channel_id']
          )
        end
      end
    end
  end
end
