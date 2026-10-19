# frozen_string_literal: true

module Ai
  module Messaging
    module Adapters
      # DingTalk surface for Duo Agent Platform. Robot messages arrive through
      # the ChatOps webhook; answers go back through the robot message APIs
      # (single-chat for direct conversations, group message otherwise).
      class Dingtalk < Base
        include ChatAssistant
        include ::Gitlab::Utils::StrongMemoize

        FlowNotRegisteredError = Class.new(StandardError)

        MESSAGE_TITLE_MAX_LENGTH = 20
        GROUP_CONVERSATION_TYPE = '2'
        # The streaming variable the card template binds its rich text to.
        CARD_CONTENT_KEY = 'content'
        CARD_SESSION_LINK_KEY = 'session_link'
        DEFAULT_CARD_TEMPLATE_ID = '7780797d-ee6c-4856-bba4-0b8cf5cd5e3e.schema'
        # DingTalk language keys for the card's conversation-list preview, mapped
        # to our locales; the reader's client picks the matching one.
        CARD_PREVIEW_LOCALES = { 'ZH_CN' => 'zh_CN', 'EN_US' => 'en' }.freeze
        # The ordinary variable the template's approve and reject buttons send
        # back, and show themselves only while it is set.
        APPROVAL_TOKEN_KEY = 'approval_token'

        def self.adapter_key
          'dingtalk'
        end

        # DingTalk signs a button callback's timestamp, not its body, so this
        # token is what ties a click to the session, call and card it was for.
        #
        # @return [String]
        def self.approval_token(workflow_id, fingerprint, card_id)
          approval_token_verifier.generate([workflow_id, fingerprint, card_id])
        end

        # @return [Array(Integer, String, String), nil] what approval_token was
        #   given, or nil for a token it did not make
        def self.approval_token_values(token)
          values = approval_token_verifier.verified(token.to_s)
          values if values.is_a?(Array) && values.size == 3
        end

        def self.approval_token_verifier
          Rails.application.message_verifier(:jh_dingtalk_duo_approval)
        end
        private_class_method :approval_token_verifier

        def self.private_to_invoker?
          true
        end

        # The run renders into one interactive card that rewrites itself, so a
        # turn reads as a single evolving message instead of arriving all at
        # once after a silent minute.
        def self.supports_live_progress?
          true
        end

        # Async path: reconstructed from persisted callback context by workers.
        def self.from_callback_context(ctx)
          new(
            corp_id: ctx['corp_id'],
            conversation_id: ctx['conversation_id'],
            conversation_type: ctx['conversation_type'],
            sender_staff_id: ctx['sender_staff_id'],
            turn_token: ctx['turn_token']
          )
        end

        def initialize(corp_id:, conversation_id:, conversation_type:, sender_staff_id:, turn_token: nil)
          @corp_id = corp_id
          @conversation_id = conversation_id
          @conversation_type = conversation_type
          @sender_staff_id = sender_staff_id
          @turn_token = turn_token
        end

        def build_callback_context
          context = {
            'corp_id' => @corp_id,
            'conversation_id' => @conversation_id,
            'conversation_type' => @conversation_type,
            'sender_staff_id' => @sender_staff_id
          }
          context['status_ts'] = @status_ts if @status_ts.present?
          context['turn_token'] = @turn_token if @turn_token.present?
          context
        end

        # The card is the acknowledgement, so it is opened at the first hook of the
        # turn rather than once the flow is enqueued: everything between the two --
        # creating the workflow, persisting it, enqueueing the worker -- is time the
        # invoker would spend looking at nothing. The id goes into the context built
        # right after this, which is what the workers deliver into later.
        def on_request_received
          @status_ts = open_card(build_callback_context)
          @card_opened = @status_ts.present?

          nil
        end

        # MUST return truthy only when the answer actually reached DingTalk:
        # the return value is the delivery workers' only signal to re-attempt.
        # The client swallows network errors (returning the logger's truthy
        # result), so only an HTTP success counts as delivered.
        def deliver_result(callback_context:, message:, workflow:)
          text = result_text(message, workflow)
          card_id = callback_context['status_ts']

          delivered = if card_id.present?
                        card_delivered?(finalize_card(card_id, text))
                      else
                        delivered?(deliver_markdown(callback_context, text))
                      end

          remember_answer(callback_context, message, workflow) if delivered
          delivered
        rescue StandardError => e
          track_delivery_exception(e, callback_context)
          false
        end

        # Streams the agent's latest words into the card this turn owns, opening
        # one on the first tick; raw tool calls never reach the card. A full
        # rewrite each time, so the at-least-once worker replaying a frame changes nothing.
        # workflow: defaults to nil until the upstream worker that passes it is synced in.
        def on_progress(delta:, callback_context:, workflow: nil)
          # The checkpoint that parks the flow on an approval schedules a tick of
          # its own. Rendering it would wipe the request the user is answering
          # off the card, so while one is pending the card belongs to it.
          return if pending_approval?(delta.messages)

          card_id = ensure_card(callback_context, workflow)
          return unless card_id

          monologue = latest_monologue(current_turn(delta.messages))
          stream_card(card_id, monologue, finalize: false) if monologue.present?
        end

        # Best-effort: errors are tracked, never raised, and nothing re-attempts
        # this delivery -- unlike deliver_result, there is no answer at stake.
        def deliver_error(callback_context:, error:)
          card_id = callback_context['status_ts']
          text = error_text(error)

          # Settles the card the run was writing into: left open it would spin
          # forever next to an error the user never sees. Settled as a failure,
          # so the template renders it as one rather than as a finished answer.
          if card_id.present?
            stream_card(card_id, text, finalize: true, error: true)
          else
            deliver_markdown(callback_context, text)
          end

          nil
        rescue StandardError => e
          track_delivery_exception(e, callback_context)
          nil
        end

        # Second chance at the card for a turn whose first attempt (on_request_received)
        # was refused by DingTalk: without one the answer has no bubble to grow in.
        def on_flow_enqueued(callback_context:, workflow:)
          return if workflow.blank?
          return if workflow.messaging_callback_context&.dig('status_ts').present?

          out_track_id = open_card(callback_context)
          return unless out_track_id

          workflow.merge_messaging_callback_context!('status_ts' => out_track_id)
          @card_opened = true
        end

        # Whether this turn has a card standing in for the acknowledgement, so
        # the caller can leave the webhook response empty rather than say the
        # same thing twice.
        def card_opened?
          @card_opened.present?
        end

        # Settles the card the turn parked on and opens a fresh one for what
        # happens next. A card rewrites itself where it was delivered, so
        # answering a decision into the same card would put the answer above the
        # reply that gave it -- backwards for anyone reading the chat downwards.
        #
        # Returns whether the new card is open, so the caller knows whether the
        # decision still needs an acknowledgement of its own.
        def roll_card_for_decision(workflow:, note: nil)
          context = workflow.messaging_callback_context || {}
          return false if context['status_ts'].blank?

          pending = pending_tool_call(workflow)
          settled = pending ? settled_approval_text(pending['content'], workflow, note) : note.to_s
          hide_approval_buttons(context['status_ts']) if take_approval_request(context['status_ts'])
          finalize_card(context['status_ts'], settled)

          # Persisted before the turn is enqueued, so its first progress tick
          # cannot write into the card just settled.
          out_track_id = open_card(context)
          workflow.merge_messaging_callback_context!('status_ts' => out_track_id)

          out_track_id.present?
        end

        # Public so the webhook entrypoint can answer pre-flight failures with
        # the synchronous response instead of an extra DingTalk API call.
        def error_message(error)
          error_text(error)
        end

        # What the settled request card says the decision did.
        def decision_note(approved)
          approved ? s_('JH|DuoDingtalk|Approved. Duo is continuing.') : s_('JH|DuoDingtalk|Cancelled that action.')
        end

        # Takes the buttons off an approval card whose request can no longer be
        # answered, keeping what it asked. The buttons go in any case: a token
        # written after the card was settled would otherwise keep them for good.
        # Only a card still holding its request is rewritten.
        def expire_approval_card(card_id, workflow, note: nil)
          return if card_id.blank?

          request = take_approval_request(card_id)
          hide_approval_buttons(card_id)
          return unless request

          note ||= ::Gitlab::I18n.with_user_locale(workflow.user) { error_text(:approval_not_pending) }
          finalize_card(card_id, settled_approval_text(request, workflow, note))
        end

        private

        # A missing registry entry means the JH prepend chain did not load.
        # Failing loudly beats silently running with no flow definition:
        # retrying cannot help, so there is no useful message for the user and
        # the exception is what gets an operator to look.
        def assistant_flow
          ::Ai::Catalog::FoundationalFlow.dingtalk_assistant_v1 ||
            raise(FlowNotRegisteredError, 'dingtalk_assistant/v1 foundational flow is not registered')
        end

        # The card this turn writes into, opened on first use. A new session gets
        # one of its own per turn -- so the next message opens a card of its own
        # instead of rewriting this answer.
        def ensure_card(callback_context, workflow)
          existing = callback_context['status_ts']
          return existing if existing.present?

          out_track_id = open_card(callback_context)
          return unless out_track_id

          # Persisted here: upstream's ProgressDeliveryWorker no longer writes status_ts back.
          workflow&.merge_messaging_callback_context!('status_ts' => out_track_id)
          callback_context['status_ts'] = out_track_id
        end

        # Delivers an empty card, which the template renders as its processing
        # state. Returns its id, or nil when DingTalk refused it -- the caller
        # then carries on without a card rather than losing the turn.
        def open_card(callback_context)
          out_track_id = "duo-#{SecureRandom.hex(8)}"
          return unless card_delivered?(dingtalk_client.create_card(card_body(callback_context, out_track_id)))

          out_track_id
        end

        # Into the turn's own card when it has one, and only otherwise as a
        # message of its own. A card sits in the conversation where it was
        # delivered, so a separate message would appear below the answer the
        # card later grows into -- asking for a decision that, on screen, looks
        # as though it came after the thing it was gating.
        def deliver_approval_request_to_chat(callback_context, pending, workflow, **)
          card_id = callback_context['status_ts']
          return delivered?(deliver_markdown(callback_context, approval_text(pending, workflow))) if card_id.blank?

          fingerprint = ::Ai::DuoWorkflows::PendingToolApproval.for(workflow)&.fingerprint
          return deliver_approval_card(card_id, pending, workflow, fingerprint) if fingerprint && approval_buttons?

          card_delivered?(stream_card(card_id, approval_text(pending, workflow), finalize: false))
        end

        # The template shows the buttons only on a finished card, so the request
        # finishes the card before the token turns them on. The action is kept
        # so expire_approval_card can show it again without them.
        def deliver_approval_card(card_id, pending, workflow, fingerprint)
          text = approval_text(pending, workflow, buttons: true)
          link = ::Gitlab::I18n.with_user_locale(workflow.user) { session_link(workflow) }
          Gitlab::Redis::SharedState.with do |redis|
            redis.set(approval_request_key(card_id), pending['content'].to_s, ex: APPROVAL_NOTICE_TTL)
          end

          token = self.class.approval_token(workflow.id, fingerprint, card_id)
          card_delivered?(finalize_card(card_id, text)) &&
            card_delivered?(dingtalk_client.update_card(card_id,
              APPROVAL_TOKEN_KEY => token, CARD_SESSION_LINK_KEY => link))
        end

        def hide_approval_buttons(card_id)
          dingtalk_client.update_card(card_id, APPROVAL_TOKEN_KEY => '')
        end

        def take_approval_request(card_id)
          Gitlab::Redis::SharedState.with { |redis| redis.getdel(approval_request_key(card_id)) }
        end

        def approval_request_key(card_id)
          "dingtalk:duo:approval_request:#{card_id}"
        end

        # Buttons need DingTalk to know where to post a click, which the corp's
        # integration says once it has a callback secret.
        def approval_buttons?
          ::Gitlab::Dingtalk::CardCallback.integration_for(@corp_id).present?
        end
        strong_memoize_attr :approval_buttons?

        def stream_card(out_track_id, content, finalize:, error: false)
          dingtalk_client.stream_card(
            outTrackId: out_track_id,
            guid: SecureRandom.uuid,
            key: CARD_CONTENT_KEY,
            content: content,
            # A full rewrite rather than an append: the worker can replay a frame,
            # and appending it twice would duplicate the text.
            isFull: true,
            isFinalize: finalize,
            isError: error
          )
        end

        def finalize_card(out_track_id, content)
          stream_card(out_track_id, content, finalize: true)
        end

        def card_body(callback_context, out_track_id)
          body = {
            cardTemplateId: card_template_id,
            outTrackId: out_track_id,
            cardData: { cardParamMap: { CARD_CONTENT_KEY => '' } },
            userIdType: 1,
            **card_callback
          }
          space_model = { supportForward: true, lastMessageI18n: card_preview }

          if group_conversation?(callback_context)
            conversation_id = callback_context['conversation_id']
            body[:openSpaceId] = "dtv1.card//im_group.#{conversation_id}"
            body[:imGroupOpenSpaceModel] = space_model
            body[:imGroupOpenDeliverModel] = { robotCode: ::Gitlab::CurrentSettings.dingtalk_app_key }
          else
            staff_id = callback_context['sender_staff_id']
            body[:userId] = staff_id
            body[:openSpaceId] = "dtv1.card//im_robot.#{staff_id}"
            body[:imRobotOpenSpaceModel] = space_model
            body[:imRobotOpenDeliverModel] = {
              spaceType: 'IM_ROBOT',
              robotCode: ::Gitlab::CurrentSettings.dingtalk_app_key
            }
          end

          body
        end

        # Where DingTalk posts a button click. Fixed at delivery: clicks on a card
        # opened before the corp had a callback secret go nowhere; replies still work.
        def card_callback
          return { callbackType: 'STREAM' } unless approval_buttons?

          { callbackType: 'HTTP', callbackRouteKey: ::Gitlab::Dingtalk::CardCallback::ROUTE_KEY }
        end

        # Set once at delivery and never rewritten, so it has to fit every state
        # the card goes through: progress, approval request, answer, or error.
        def card_preview
          CARD_PREVIEW_LOCALES.transform_values do |locale|
            ::Gitlab::I18n.with_locale(locale) { s_('JH|DuoDingtalk|Message from Duo') }
          end
        end

        # Instance-level configuration once the DingTalk credentials are read
        # through one place; overridable meanwhile so a local app can point at
        # its own template.
        def card_template_id
          ENV.fetch('JH_DINGTALK_DUO_CARD_TEMPLATE_ID', DEFAULT_CARD_TEMPLATE_ID)
        end

        # The card APIs report failure in the body as well as the status, and
        # createAndDeliver reports it per delivery target.
        def card_delivered?(response)
          return false unless response.respond_to?(:success?) && response.success?

          parsed = Gitlab::Json.parse(response.body.to_s)
          return false unless parsed.is_a?(Hash) && parsed['success']

          # createAndDeliver reports per target under result; streaming answers
          # with a bare `"result": true`, so only the former has anything to read.
          result = parsed['result']
          return true unless result.is_a?(Hash)

          results = result['deliverResults']
          return true unless results.is_a?(Array)

          results.all? { |entry| entry['success'] }
        rescue JSON::ParserError
          false
        end

        def deliver_markdown(callback_context, text)
          dingtalk_client.send_message(
            Gitlab::Json.generate(message_body(callback_context, text)),
            type: group_conversation?(callback_context) ? :group : :user
          )
        end

        # The robot endpoints can answer 200 while reporting per-recipient
        # failures in the body (e.g. an invalid staff id), so a bare 2xx is
        # not enough to call the answer delivered.
        def delivered?(response)
          return false unless response.respond_to?(:success?) && response.success?

          body = response.body.to_s
          return true if body.empty?

          parsed = Gitlab::Json.parse(body)
          return true unless parsed.is_a?(Hash)

          parsed['invalidStaffIdList'].blank? &&
            parsed['flowControlledStaffIdList'].blank? &&
            parsed['noPermissionStaffIdList'].blank?
        rescue JSON::ParserError
          true
        end

        def message_body(callback_context, text)
          body = {
            robotCode: ::Gitlab::CurrentSettings.dingtalk_app_key,
            msgKey: 'sampleMarkdown',
            msgParam: Gitlab::Json.generate(
              title: text.truncate(MESSAGE_TITLE_MAX_LENGTH, separator: ' '),
              text: text
            )
          }

          if group_conversation?(callback_context)
            body[:openConversationId] = callback_context['conversation_id']
          else
            body[:userIds] = [callback_context['sender_staff_id']]
          end

          body
        end

        def group_conversation?(callback_context)
          callback_context['conversation_type'] == GROUP_CONVERSATION_TYPE
        end

        def approval_text(pending, workflow, buttons: false)
          ::Gitlab::I18n.with_user_locale(workflow.user) do
            instruction =
              if buttons
                s_('JH|DuoDingtalk|Use the buttons below to approve or reject it, ' \
                  'or reply with what to change instead.')
              else
                s_('JH|DuoDingtalk|Reply "approve" to let it go ahead, "reject" to cancel, ' \
                  'or tell me what to change instead.')
              end

            approval_request_text(pending['content'], workflow, instruction, include_session_link: !buttons)
          end
        end

        # A decided request: what it asked and what came of it, with no
        # instruction left to act on.
        def settled_approval_text(action, workflow, note)
          ::Gitlab::I18n.with_user_locale(workflow.user) { approval_request_text(action, workflow, note) }
        end

        def approval_request_text(action, workflow, line, include_session_link: true)
          [
            s_('JH|DuoDingtalk|Duo needs your approval before it can do this:'),
            "> #{action}",
            line,
            (session_link(workflow) if include_session_link)
          ].compact.join("\n\n")
        end

        # Runs in a worker, which has no session locale of its own -- see the
        # same fallback in Gitlab::Chatops::DingtalkBotHandler#duo_trigger_message.
        def result_text(message, workflow)
          return message unless workflow

          ::Gitlab::I18n.with_user_locale(workflow.user) do
            "#{message}\n\n#{session_link(workflow)}"
          end
        end

        def session_link(workflow)
          "[#{s_('JH|DuoDingtalk|View your session in JiHu GitLab')}](#{workflow.web_url})"
        end

        def error_text(error) # rubocop:disable Metrics/CyclomaticComplexity -- one branch per error, kept parallel to the Slack adapter
          case error
          when :namespace_not_configured
            preferences_url = ::Gitlab::Routing.url_helpers.profile_preferences_url

            format(
              s_("JH|DuoDingtalk|Set your default Duo namespace in your " \
                "JiHu GitLab preferences (%{preferences_url}) to use Duo from DingTalk."),
              preferences_url: preferences_url
            )
          when :flow_not_enabled
            s_("JH|DuoDingtalk|The Duo flow is not enabled for your namespace. " \
              "Ask a group owner to enable it in the Duo Agent Platform settings.")
          when :service_account_error
            s_("JH|DuoDingtalk|Could not set up the service account for the Duo flow. " \
              "Contact your group owner.")
          when :workspace_project_error
            s_("JH|DuoDingtalk|Could not set up the workspace project. " \
              "Check that you have access to the namespace and permission to create projects.")
          when :execute_workflow_failed
            s_("JH|DuoDingtalk|Failed to start the Duo session. Try again.")
          when :flow_failed
            s_("JH|DuoDingtalk|Something went wrong while running the task. Try again.")
          when :flow_stopped
            s_("JH|DuoDingtalk|The session was stopped before it finished.")
          when :approval_not_pending
            s_("JH|DuoDingtalk|That action is no longer waiting for your decision. " \
              "Send me your next message instead.")
          when :workflow_locked
            s_("JH|DuoDingtalk|I'm still working on an earlier message. " \
              "Wait for that to finish, then send your message again.")
          when :forbidden
            s_("JH|DuoDingtalk|You don't have access to Duo in this namespace, or it has run out of " \
              "GitLab Duo credits. Ask a group owner to check the Duo Agent Platform settings.")
          when :no_response
            s_("JH|DuoDingtalk|The task completed but the agent didn't produce a response. " \
              "Check the session in JiHu GitLab for details.")
          when :delivery_failed
            s_("JH|DuoDingtalk|The task completed, but I couldn't post the answer here. " \
              "Check the session in JiHu GitLab for the full response.")
          when :message_too_long
            format(
              s_("JH|DuoDingtalk|Your message is too long for me to process " \
                "(the limit is about %{limit} characters). Shorten it and send it again."),
              limit: ActiveSupport::NumberHelper.number_to_delimited(::Ai::DuoWorkflows::Workflow::GOAL_MAX_LENGTH)
            )
          else
            s_("JH|DuoDingtalk|Something went wrong. Try again.")
          end
        end

        def dingtalk_client
          @dingtalk_client ||= ::Gitlab::Dingtalk::Client.new(
            corpid: ::Gitlab::CurrentSettings.dingtalk_corpid,
            app_key: ::Gitlab::CurrentSettings.dingtalk_app_key,
            app_secret: ::Gitlab::CurrentSettings.dingtalk_app_secret
          )
        end

        # The next session reads this as background, but only while the turn that
        # asked is still the one the conversation is on: after /new or a newer
        # message, a late answer or a delivery retry would put a stale exchange
        # back. The store settles that against the turn token. A failure here must
        # not turn a delivered answer into a retried one, which would post it twice.
        def remember_answer(callback_context, message, workflow)
          return unless workflow

          ::Gitlab::Dingtalk::DuoSessionStore.new(
            corp_id: callback_context['corp_id'],
            conversation_id: callback_context['conversation_id'],
            sender_staff_id: callback_context['sender_staff_id'],
            user_id: workflow.user_id
          ).record_answer!(callback_context['turn_token'], message)
        rescue ::Redis::BaseError, ::RedisClient::Error => e
          track_delivery_exception(e, callback_context)
        end

        def track_delivery_exception(exception, callback_context)
          Gitlab::ErrorTracking.track_exception(exception,
            dingtalk_corp_id: callback_context['corp_id'],
            conversation_id: callback_context['conversation_id']
          )
        end
      end
    end
  end
end
