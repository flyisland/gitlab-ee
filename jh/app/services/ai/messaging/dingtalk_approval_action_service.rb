# frozen_string_literal: true

module Ai
  module Messaging
    # Applies a click on a DingTalk approval card button (Adapters::Dingtalk)
    # and returns the body DingTalk answers the click with. The callback is
    # verified (Gitlab::Dingtalk::CardCallback), but DingTalk signs only its
    # timestamp, so the session, call and card come from the signed approval
    # token and the clicker is checked against the session.
    class DingtalkApprovalActionService
      include ::Gitlab::Utils::StrongMemoize

      DECISIONS = { 'approve' => true, 'reject' => false }.freeze

      # @param callback [Gitlab::Dingtalk::CardCallback] a verified click
      def initialize(callback)
        @callback = callback
      end

      # Only the checks that need no DingTalk call run here, inside DingTalk's
      # two seconds; ApprovalDecisionWorker decides and checks the call again.
      #
      # @return [Hash] the response body; DingTalk shows nothing for an empty one
      def execute
        reason = refusal_reason
        return refuse(reason) if reason

        ::Ai::Messaging::ApprovalDecisionWorker.perform_async(
          workflow.id, user.id, DECISIONS[decision], fingerprint, callback.out_track_id
        )

        # Read only when it arrives in time; the worker hides the buttons anyway.
        {
          cardData: { cardParamMap: { Adapters::Dingtalk::APPROVAL_TOKEN_KEY => '' } },
          cardUpdateOptions: { updateCardDataByKey: true }
        }
      end

      private

      attr_reader :callback

      def refusal_reason # rubocop:disable Metrics/CyclomaticComplexity -- one guard per check, in the order they are cheap
        return :not_an_approval unless callback.action? && DECISIONS.key?(decision)
        return :invalid_token unless token_values && card_id == callback.out_track_id
        return :unavailable unless available?
        return :unknown_session unless context&.dig('adapter') == Adapters::Dingtalk.adapter_key
        return :not_requester unless requester?
        return :not_connected unless user&.active?

        :forbidden unless ::Feature.enabled?(:jh_dingtalk_duo_chat, user)
      end

      # Others in a group see the same card; only the DingTalk user who asked may answer it.
      def requester?
        context['corp_id'] == callback.corp_id && context['sender_staff_id'] == callback.user_id
      end

      # The same switches ChatOps checks before it answers a message.
      def available?
        ::License.feature_available?(:dingtalk_integration) && !::Gitlab.com? &&
          ::Gitlab::CurrentSettings.dingtalk_enabled?
      end

      def decision
        callback.action_params['decision']
      end

      def token_values
        Adapters::Dingtalk.approval_token_values(callback.action_params[Adapters::Dingtalk::APPROVAL_TOKEN_KEY])
      end
      strong_memoize_attr :token_values

      def fingerprint
        token_values[1]
      end

      def card_id
        token_values[2]
      end

      def workflow
        ::Ai::DuoWorkflows::Workflow.find_by_id(token_values[0])
      end
      strong_memoize_attr :workflow

      def context
        workflow&.messaging_callback_context
      end

      def user
        ::ChatNames::FindUserService.new(callback.corp_id, callback.user_id).execute&.user
      end
      strong_memoize_attr :user

      def refuse(reason)
        ::Gitlab::AppLogger.info(
          Labkit::Fields::LOG_MESSAGE => 'Refused DingTalk approval card click',
          Labkit::Fields::ERROR_TYPE => reason.to_s,
          Labkit::Fields::DUO_WORKFLOW_ID => token_values&.first
        )

        {}
      end
    end
  end
end
