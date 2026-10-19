# frozen_string_literal: true

module Ai
  module Messaging
    # Applies a click on an approval card button (Adapters::Feishu) and returns
    # the toast Feishu shows the clicker. The callback has already been
    # verified as Feishu's (Gitlab::Chatops::FeishuBotHandler), so the button
    # value is the one the card was sent with; who clicked is the operator.
    class FeishuApprovalActionService
      include ::Gitlab::Utils::StrongMemoize

      def initialize(operator_user_id:, value:)
        @operator_user_id = operator_user_id
        @value = value.is_a?(Hash) ? value.with_indifferent_access : {}
      end

      def execute
        decision = value[Adapters::Feishu::APPROVAL_ACTION]
        # Not one of ours: an empty answer leaves the card as it is.
        return {} unless [Adapters::Feishu::APPROVE, Adapters::Feishu::REJECT].include?(decision)

        return toast(:error, error_text(:forbidden)) unless available?

        workflow = ::Ai::DuoWorkflows::Workflow.find_by_id(value[:workflow_id])
        context = workflow&.messaging_callback_context
        return toast(:error, error_text(:approval_not_pending)) unless context&.dig('adapter') == 'feishu'

        # Others in a group see the same card; only the Feishu user who asked,
        # still bound to a GitLab account, may answer it.
        unless operator_user_id.present? && context['sender_id'] == operator_user_id
          return toast(:error, not_requester_text)
        end

        return toast(:error, not_connected_text) unless user

        ::Gitlab::I18n.with_user_locale(user) { decide(workflow, context, decision == Adapters::Feishu::APPROVE) }
      end

      private

      attr_reader :operator_user_id, :value

      # Only the checks that answer the clicker fast; the decision itself runs in
      # Ai::Messaging::ApprovalDecisionWorker, which checks the call again.
      def decide(workflow, context, approved)
        unless user.active? && ::Feature.enabled?(:jh_feishu_duo_chat, user)
          return toast(:error, error_text(:forbidden))
        end

        unless ::Ai::Messaging::ApprovalDecisionService.pending?(workflow, value[:fingerprint].to_s)
          Adapters::Feishu.from_callback_context(context).expire_approval_card(value[:card_id], workflow)
          return toast(:error, error_text(:approval_not_pending))
        end

        ::Ai::Messaging::ApprovalDecisionWorker.perform_async(
          workflow.id, user.id, approved, value[:fingerprint].to_s, value[:card_id].to_s
        )

        toast(:success, approved ? approved_text : s_('JH|DuoFeishu|Cancelled that action.'))
      end

      # The same switches ChatOps checks before it answers a message.
      def available?
        ::License.feature_available?(:feishu_bot_integration) && !::Gitlab.com? &&
          ::Integrations::FeishuBot.for_instance.first&.activated?
      end

      def user
        ::ChatNames::FindUserService.new(
          ::Gitlab::Chatops::FeishuBotHandler::BIND_TEAM_ID, operator_user_id
        ).execute&.user
      end
      strong_memoize_attr :user

      def error_text(reason)
        Adapters::Feishu.new(app_id: nil, chat_id: nil, sender_id: nil, message_id: nil).error_message(reason)
      end

      def approved_text
        s_('JH|DuoFeishu|Approved. Duo is continuing.')
      end

      def not_requester_text
        s_('JH|DuoFeishu|Only the person who started this session can answer this request.')
      end

      def not_connected_text
        s_('JH|DuoFeishu|Connect your JiHu GitLab account before answering this request.')
      end

      def toast(type, content)
        { toast: { type: type.to_s, content: content } }
      end
    end
  end
end
