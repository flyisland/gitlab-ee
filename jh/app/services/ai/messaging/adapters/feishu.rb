# frozen_string_literal: true

module Ai
  module Messaging
    module Adapters
      # Feishu surface for Duo Agent Platform. Robot messages arrive through the
      # ChatOps event callback; every answer is a reply to the message that asked,
      # written into a CardKit card that streams the turn, or posted as rich text
      # when Feishu refuses the card.
      class Feishu < Base
        include ChatAssistant

        FlowNotRegisteredError = Class.new(StandardError)

        CARD_ELEMENT_ID = 'duo_content'
        # Marks the button value of an approval card, so the card callback can
        # tell it from any other button the app may send.
        APPROVAL_ACTION = 'duo_approval'
        APPROVE = 'approve'
        REJECT = 'reject'
        # Feishu caps a card, and a rich text message, at 30 KB; this leaves room
        # for the JSON around the text.
        TEXT_MAX_BYTES = 24_000
        # Card ids live for 14 days, and what is kept about them with them.
        CARD_STATE_TTL = 14.days
        # An animated ellipsis drawn on the text's middle line, shown while a card
        # waits for the agent's first words.
        WAITING_IMAGE_PATH = Rails.root.join('jh/lib/gitlab/feishu/images/duo_waiting.gif')
        WAITING_IMAGE_DIGEST = OpenSSL::Digest::SHA256.file(WAITING_IMAGE_PATH).hexdigest.first(12)
        WAITING_IMAGE_TTL = 30.days
        # After a refused upload, so every card does not wait on another one.
        WAITING_IMAGE_RETRY_AFTER = 1.hour

        def self.adapter_key
          'feishu'
        end

        def self.private_to_invoker?
          true
        end

        # The run renders into one card that rewrites itself, so a turn reads as
        # a single evolving message instead of arriving all at once.
        def self.supports_live_progress?
          true
        end

        # A rich text reply body. Feishu caps one at 30 KB.
        def self.rich_text_content(text)
          { zh_cn: { content: [[{ tag: 'md', text: text.to_s.truncate_bytes(TEXT_MAX_BYTES) }]] } }
        end

        # Async path: reconstructed from persisted callback context by workers.
        def self.from_callback_context(ctx)
          new(
            app_id: ctx['app_id'],
            chat_id: ctx['chat_id'],
            thread_id: ctx['thread_id'],
            sender_id: ctx['sender_id'],
            message_id: ctx['message_id'],
            turn_token: ctx['turn_token']
          )
        end

        def initialize(app_id:, chat_id:, sender_id:, message_id:, thread_id: nil, turn_token: nil)
          @app_id = app_id
          @chat_id = chat_id
          @thread_id = thread_id
          @sender_id = sender_id
          @message_id = message_id
          @turn_token = turn_token
        end

        def build_callback_context
          context = {
            'app_id' => @app_id,
            'chat_id' => @chat_id,
            'thread_id' => @thread_id,
            'sender_id' => @sender_id,
            'message_id' => @message_id
          }.compact
          context['status_ts'] = @status_ts if @status_ts.present?
          context['turn_token'] = @turn_token if @turn_token.present?
          context
        end

        # The card is the acknowledgement, so it is opened at the first hook of
        # the turn rather than once the flow is enqueued. The id goes into the
        # context built right after this, which is what the workers deliver into.
        def on_request_received
          @status_ts = open_card(build_callback_context)
          @card_opened = @status_ts.present?

          nil
        end

        # Second chance at the card for a turn whose first attempt was refused.
        def on_flow_enqueued(callback_context:, workflow:)
          return if workflow.blank?
          return if workflow.messaging_callback_context&.dig('status_ts').present?

          card_id = open_card(callback_context)
          return unless card_id

          workflow.merge_messaging_callback_context!('status_ts' => card_id)
          @card_opened = true
        end

        # MUST return truthy only when the answer actually reached Feishu: the
        # return value is the delivery workers' only signal to re-attempt. Falls
        # back to rich text when the card cannot be settled; that reply's uuid is
        # fixed per turn, so a retried delivery cannot post the answer twice.
        def deliver_result(callback_context:, message:, workflow:)
          text = result_text(message, workflow)
          uuid = "duo-result-#{workflow&.id}-#{turn_token(callback_context)}"

          delivered = settle_or_reply(callback_context, text, uuid: uuid, footer: session_footer(workflow))

          remember_answer(callback_context, message, workflow) if delivered
          delivered
        rescue StandardError => e
          track_delivery_exception(e, callback_context)
          false
        end

        # Streams the agent's latest words into the card this turn owns, opening
        # one on the first tick; raw tool calls never reach the card. A full
        # rewrite each time, so the at-least-once worker replaying a frame changes
        # nothing, and the strictly increasing sequence makes a frame that lost a
        # race to the final answer bounce off it.
        def on_progress(delta:, callback_context:, workflow: nil)
          # While a decision is pending the card belongs to the request the user
          # is answering.
          return if pending_approval?(delta.messages)

          card_id = ensure_card(callback_context, workflow)
          return unless card_id

          monologue = latest_monologue(current_turn(delta.messages))
          stream_card(card_id, monologue) if monologue.present?
        end

        # Best-effort: errors are tracked, never raised, and nothing re-attempts
        # this delivery -- unlike deliver_result, there is no answer at stake.
        def deliver_error(callback_context:, error:)
          text = error_text(error)

          # Settles the card the run was writing into: left streaming it would
          # spin next to an error the user never sees.
          settle_or_reply(callback_context, text, uuid: "duo-error-#{SecureRandom.hex(8)}")

          nil
        rescue StandardError => e
          track_delivery_exception(e, callback_context)
          nil
        end

        # Whether this turn has a card standing in for the acknowledgement, so
        # the caller can leave the reply out rather than say the same thing twice.
        def card_opened?
          @card_opened.present?
        end

        # Settles the card the turn parked on and opens a fresh one under the
        # message that carried the decision, so the answer reads after it.
        #
        # Returns whether the new card is open, so the caller knows whether the
        # decision still needs an acknowledgement of its own.
        def roll_card_for_decision(workflow:, note: nil)
          context = workflow.messaging_callback_context || {}
          return false if context['status_ts'].blank?

          pending = pending_tool_call(workflow)
          settled = pending ? settled_approval_text(pending['content'], workflow, note) : note.to_s
          take_approval_request(context['status_ts'])
          settle_card(context['status_ts'], settled, footer: session_footer(workflow))

          # Persisted before the turn is enqueued, so its first progress tick
          # cannot write into the card just settled.
          next_context = context.merge('message_id' => @message_id)
          card_id = open_card(next_context)
          workflow.merge_messaging_callback_context!('message_id' => @message_id, 'status_ts' => card_id)

          card_id.present?
        end

        # Public so the trigger service can answer pre-flight failures directly.
        def error_message(error)
          error_text(error)
        end

        # What the settled request card says the decision did.
        def decision_note(approved)
          approved ? s_('JH|DuoFeishu|Approved. Duo is continuing.') : s_('JH|DuoFeishu|Cancelled that action.')
        end

        # Takes the buttons off an approval card whose request can no longer be
        # answered, keeping what it asked. Only a card still showing its buttons
        # is touched, so a card a decision already settled stays as it is.
        def expire_approval_card(card_id, workflow, note: nil)
          return if card_id.blank?

          request = take_approval_request(card_id)
          return unless request

          note ||= ::Gitlab::I18n.with_user_locale(workflow.user) { error_text(:approval_not_pending) }
          settle_card(card_id, settled_approval_text(request, workflow, note), footer: session_footer(workflow))
        end

        private

        # A missing registry entry means the JH prepend chain did not load.
        def assistant_flow
          ::Ai::Catalog::FoundationalFlow.feishu_assistant_v1 ||
            raise(FlowNotRegisteredError, 'feishu_assistant/v1 foundational flow is not registered')
        end

        def ensure_card(callback_context, workflow)
          existing = callback_context['status_ts']
          return existing if existing.present?

          card_id = open_card(callback_context)
          return unless card_id

          workflow&.merge_messaging_callback_context!('status_ts' => card_id)
          callback_context['status_ts'] = card_id
        end

        # Creates a streaming card and replies with it. Returns its id, or nil
        # when Feishu refused either step -- the caller then carries on without
        # a card rather than losing the turn. The reply's uuid is the card's, so
        # a retried step cannot post the same card twice.
        def open_card(callback_context)
          image_key = waiting_image_key
          card_id = feishu_client.create_card(waiting_card(image_key))
          mark_card(card_id, 'waiting') if image_key
          feishu_client.reply(
            callback_context['message_id'],
            msg_type: 'interactive',
            content: { type: 'card', data: { card_id: card_id } },
            uuid: "duo-card-#{card_id}"
          )

          card_id
        rescue StandardError => e
          track_delivery_exception(e, callback_context)
          nil
        end

        def waiting_card(image_key)
          return card(s_('JH|DuoFeishu|Duo is working on it…'), streaming: true) unless image_key

          card(s_('JH|DuoFeishu|Duo is working on it'), streaming: true, waiting_image: image_key)
        end

        # Uploaded once per app and file. Nil when Feishu refuses it, and the
        # card then says it in words; a blank cached key marks the refusal.
        def waiting_image_key
          key = "feishu:duo:waiting_image:#{::Gitlab::CurrentSettings.feishu_app_key}:#{WAITING_IMAGE_DIGEST}"
          cached = Rails.cache.read(key)
          return cached.presence unless cached.nil?

          image_key = File.open(WAITING_IMAGE_PATH, 'rb') { |file| feishu_client.upload_image(file) }
          Rails.cache.write(key, image_key, expires_in: WAITING_IMAGE_TTL)
          image_key
        rescue ::Gitlab::Feishu::AppResponse::Error => e
          Rails.cache.write(key, '', expires_in: WAITING_IMAGE_RETRY_AFTER)
          track_delivery_exception(e, {})
          nil
        end

        # Settles the turn's card into the request, with buttons: streaming
        # closes after ten minutes, and a decision can take longer. Without a
        # card it is a reply, which would land below the answer otherwise.
        def deliver_approval_request_to_chat(callback_context, pending, workflow, notice_key:)
          card_id = callback_context['status_ts']
          fingerprint = ::Ai::DuoWorkflows::PendingToolApproval.for(workflow)&.fingerprint
          buttons = card_id.present? && fingerprint
          return true if buttons && settle_approval_card(card_id, pending, workflow, fingerprint)

          # Derived from the pending call, not the text: a retry of this send
          # reuses it, while a later call with identical text must not be deduplicated.
          uuid = "duo-approval-#{OpenSSL::Digest::SHA256.hexdigest(notice_key).first(32)}"

          settle_or_reply(callback_context, approval_text(pending, workflow), uuid: uuid,
            footer: session_footer(workflow))
        end

        # The action is kept with the card so expire_approval_card can show it
        # again without the buttons.
        def settle_approval_card(card_id, pending, workflow, fingerprint)
          text = approval_text(pending, workflow, buttons: true)
          Gitlab::Redis::SharedState.with do |redis|
            redis.set(card_key(card_id, 'approval_request'), pending['content'].to_s, ex: CARD_STATE_TTL)
          end

          settle_card(card_id, text, actions: approval_buttons(workflow, card_id, fingerprint),
            footer: session_footer(workflow))
        end

        # Feishu signs the callback, so the value comes back as it was sent; the
        # fingerprint ties the click to the call the card was rendered for.
        def approval_buttons(workflow, card_id, fingerprint)
          value = { APPROVAL_ACTION => nil, 'workflow_id' => workflow.id, 'card_id' => card_id,
                    'fingerprint' => fingerprint }

          ::Gitlab::I18n.with_user_locale(workflow.user) do
            [
              approval_button('duo_approve', s_('JH|DuoFeishu|Approve'), 'primary',
                value.merge(APPROVAL_ACTION => APPROVE)),
              approval_button('duo_reject', s_('JH|DuoFeishu|Reject'), 'danger',
                value.merge(APPROVAL_ACTION => REJECT))
            ]
          end
        end

        def approval_button(element_id, label, type, value)
          {
            tag: 'button',
            element_id: element_id,
            type: type,
            text: { tag: 'plain_text', content: label },
            behaviors: [{ type: 'callback', value: value }]
          }
        end

        def take_approval_request(card_id)
          Gitlab::Redis::SharedState.with { |redis| redis.getdel(card_key(card_id, 'approval_request')) }
        end

        # The footer is a smaller last line on a card, and a plain last line of
        # a rich text reply.
        def settle_or_reply(callback_context, text, uuid:, footer: nil)
          card_id = callback_context['status_ts']
          return true if card_id.present? && settle_card(card_id, text, footer: footer)

          reply_text(callback_context, [text, footer].compact.join("\n\n"), uuid: uuid)
        end

        # Best-effort: a frame that misses only leaves the card a frame behind.
        def stream_card(card_id, text)
          return if card_settled?(card_id)

          # The first words replace the whole waiting card, animation included;
          # a text update would leave it next to them.
          return replace_waiting_card(card_id, text) if take_card_mark(card_id, 'waiting')

          feishu_client.stream_card_text(card_id, CARD_ELEMENT_ID, text, sequence: next_sequence(card_id))
        rescue ::Gitlab::Feishu::BotClient::StreamingClosedError
          # Settling closes streaming too, and a frame that lost that race must
          # not put the card back to work over the final answer.
          return if card_settled?(card_id)

          # Feishu also closes streaming ten minutes after it opened; a full
          # update reopens it so the frames after this one type out again. The
          # sequence is taken before looking for the mark again, and
          # settle_card marks before taking its own: a frame that wins the race
          # carries the lower sequence and is overwritten, one that loses it
          # sees the mark.
          sequence = next_sequence(card_id)
          return if card_settled?(card_id)

          feishu_client.update_card(card_id, card(text, streaming: true), sequence: sequence)
        end

        # Replaces the card with its final text and ends streaming. Works
        # whatever the streaming state, which a text update does not.
        def settle_card(card_id, text, actions: nil, footer: nil)
          Gitlab::Redis::SharedState.with do |redis|
            redis.set(card_key(card_id, 'settled'), 1, ex: CARD_STATE_TTL)
          end

          feishu_client.update_card(
            card_id, card(text, streaming: false, actions: actions, footer: footer), sequence: next_sequence(card_id)
          )
          true
        rescue ::Gitlab::Feishu::AppResponse::Error => e
          track_delivery_exception(e, { 'status_ts' => card_id })
          false
        end

        # CardKit rejects an update whose sequence does not exceed the card's
        # last one, and the progress and callback workers update the same card.
        def next_sequence(card_id)
          key = card_key(card_id, 'sequence')

          Gitlab::Redis::SharedState.with do |redis|
            sequence, = redis.multi do |transaction|
              transaction.incr(key)
              transaction.expire(key, CARD_STATE_TTL)
            end

            sequence
          end
        end

        def card_settled?(card_id)
          Gitlab::Redis::SharedState.with { |redis| redis.get(card_key(card_id, 'settled')).present? }
        end

        # The mark goes back on failure, so the next frame tries again.
        def replace_waiting_card(card_id, text)
          feishu_client.update_card(card_id, card(text, streaming: true), sequence: next_sequence(card_id))
        rescue ::Gitlab::Feishu::AppResponse::Error
          mark_card(card_id, 'waiting')
          nil
        end

        def mark_card(card_id, name)
          Gitlab::Redis::SharedState.with { |redis| redis.set(card_key(card_id, name), 1, ex: CARD_STATE_TTL) }
        end

        def take_card_mark(card_id, name)
          Gitlab::Redis::SharedState.with { |redis| redis.getdel(card_key(card_id, name)) }.present?
        end

        def card_key(card_id, name)
          "feishu:duo_card:{#{card_id}}:#{name}"
        end

        # Card JSON 2.0 with one markdown element, the one streaming rewrites,
        # the buttons in a row below it and a smaller footer line, when there
        # are any.
        def card(text, streaming:, actions: nil, footer: nil, waiting_image: nil)
          content = { tag: 'markdown', element_id: CARD_ELEMENT_ID, content: text.to_s.truncate_bytes(TEXT_MAX_BYTES) }
          elements = [waiting_image ? waiting_row(content, waiting_image) : content]

          if actions.present?
            elements << {
              tag: 'column_set',
              columns: actions.map { |action| { tag: 'column', width: 'auto', elements: [action] } }
            }
          end

          elements << { tag: 'markdown', text_size: 'notation', content: footer } if footer.present?

          {
            schema: '2.0',
            config: {
              streaming_mode: streaming,
              update_multi: true,
              summary: { content: s_('JH|DuoFeishu|Message from Duo') }
            },
            body: { elements: elements }
          }
        end

        # The image is as tall as a line of text with the dots on its middle,
        # so centering both columns lines them up.
        def waiting_row(content, image_key)
          {
            tag: 'column_set',
            horizontal_spacing: '0px',
            columns: [
              { tag: 'column', width: 'auto', vertical_align: 'center', elements: [content] },
              {
                tag: 'column', width: 'auto', vertical_align: 'center',
                elements: [{ tag: 'img', img_key: image_key, size: '22px 22px', scale_type: 'crop_center',
                             transparent: true, preview: false }]
              }
            ]
          }
        end

        def reply_text(callback_context, text, uuid:)
          feishu_client.reply(
            callback_context['message_id'],
            msg_type: 'post',
            content: self.class.rich_text_content(text),
            uuid: uuid
          )

          true
        rescue ::Gitlab::Feishu::AppResponse::Error => e
          track_delivery_exception(e, callback_context)
          false
        end

        def turn_token(callback_context)
          callback_context['turn_token'] || @turn_token
        end

        def approval_text(pending, workflow, buttons: false)
          ::Gitlab::I18n.with_user_locale(workflow.user) do
            instruction =
              if buttons
                s_('JH|DuoFeishu|Approve to let it go ahead, Reject to cancel, ' \
                  'or reply with what to change instead.')
              else
                s_('JH|DuoFeishu|Reply "approve" to let it go ahead, "reject" to cancel, ' \
                  'or tell me what to change instead.')
              end

            approval_request_text(pending['content'], instruction)
          end
        end

        # A decided request: what it asked and what came of it, with no
        # instruction left to act on.
        def settled_approval_text(action, workflow, note)
          ::Gitlab::I18n.with_user_locale(workflow.user) { approval_request_text(action, note) }
        end

        def approval_request_text(action, line)
          [
            s_('JH|DuoFeishu|Duo needs your approval before it can do this:'),
            "> #{action}",
            line
          ].compact.join("\n\n")
        end

        # Runs in a worker, which has no session locale of its own.
        def result_text(message, workflow)
          return message unless workflow

          # The footer survives a long answer: the answer is what gets cut.
          message.to_s.truncate_bytes(TEXT_MAX_BYTES - 1_000)
        end

        # Runs in workers too, which have no session locale of their own.
        def session_footer(workflow)
          return unless workflow

          ::Gitlab::I18n.with_user_locale(workflow.user) do
            "[#{s_('JH|DuoFeishu|View your session in JiHu GitLab')}](#{workflow.web_url})"
          end
        end

        def error_text(error) # rubocop:disable Metrics/CyclomaticComplexity -- one branch per error, kept parallel to the DingTalk adapter
          case error
          when :namespace_not_configured
            preferences_url = ::Gitlab::Routing.url_helpers.profile_preferences_url

            format(
              s_("JH|DuoFeishu|Set your default Duo namespace in your " \
                "JiHu GitLab preferences (%{preferences_url}) to use Duo from Feishu."),
              preferences_url: preferences_url
            )
          when :flow_not_enabled
            s_("JH|DuoFeishu|The Duo flow is not enabled for your namespace. " \
              "Ask a group owner to enable it in the Duo Agent Platform settings.")
          when :service_account_error
            s_("JH|DuoFeishu|Could not set up the service account for the Duo flow. " \
              "Contact your group owner.")
          when :workspace_project_error
            s_("JH|DuoFeishu|Could not set up the workspace project. " \
              "Check that you have access to the namespace and permission to create projects.")
          when :execute_workflow_failed
            s_("JH|DuoFeishu|Failed to start the Duo session. Try again.")
          when :flow_failed
            s_("JH|DuoFeishu|Something went wrong while running the task. Try again.")
          when :flow_stopped
            s_("JH|DuoFeishu|The session was stopped before it finished.")
          when :approval_not_pending
            s_("JH|DuoFeishu|That action is no longer waiting for your decision. " \
              "Send me your next message instead.")
          when :workflow_locked
            s_("JH|DuoFeishu|I'm still working on an earlier message. " \
              "Wait for that to finish, then send your message again.")
          when :forbidden
            s_("JH|DuoFeishu|You don't have access to Duo in this namespace, or it has run out of " \
              "GitLab Duo credits. Ask a group owner to check the Duo Agent Platform settings.")
          when :no_response
            s_("JH|DuoFeishu|The task completed but the agent didn't produce a response. " \
              "Check the session in JiHu GitLab for details.")
          when :delivery_failed
            s_("JH|DuoFeishu|The task completed, but I couldn't post the answer here. " \
              "Check the session in JiHu GitLab for the full response.")
          when :message_too_long
            format(
              s_("JH|DuoFeishu|Your message is too long for me to process " \
                "(the limit is about %{limit} characters). Shorten it and send it again."),
              limit: ActiveSupport::NumberHelper.number_to_delimited(::Ai::DuoWorkflows::Workflow::GOAL_MAX_LENGTH)
            )
          else
            s_("JH|DuoFeishu|Something went wrong. Try again.")
          end
        end

        def feishu_client
          @feishu_client ||= ::Gitlab::Feishu::BotClient.new
        end

        # The next session reads this as background, but only while the turn that
        # asked is still the one the conversation is on (see
        # ChatSessionStore#record_answer!). A failure here must not turn a
        # delivered answer into a retried one, which would post it twice.
        def remember_answer(callback_context, message, workflow)
          return unless workflow

          ::Gitlab::Feishu::DuoSessionStore.new(
            app_id: callback_context['app_id'],
            chat_id: callback_context['chat_id'],
            thread_id: callback_context['thread_id'],
            sender_id: callback_context['sender_id'],
            user_id: workflow.user_id
          ).record_answer!(callback_context['turn_token'], message)
        rescue ::Redis::BaseError, ::RedisClient::Error => e
          track_delivery_exception(e, callback_context)
        end

        def track_delivery_exception(exception, callback_context)
          Gitlab::ErrorTracking.track_exception(exception,
            feishu_app_id: callback_context['app_id'],
            feishu_chat_id: callback_context['chat_id'],
            feishu_card_id: callback_context['status_ts']
          )
        end
      end
    end
  end
end
