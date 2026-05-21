import { CHAT_MESSAGE_TYPES, GENIE_CHAT_MODEL_ROLES } from 'ee/ai/constants';

export const WorkflowUtils = {
  getLatestCheckpoint(duoWorkflowEvents) {
    if (!duoWorkflowEvents.length) {
      return null;
    }

    const sortedCheckpoints = [...duoWorkflowEvents].sort((a, b) => {
      return new Date(b.checkpoint.ts).getTime() - new Date(a.checkpoint.ts).getTime();
    });

    return sortedCheckpoints[0];
  },

  parseWorkflowData(response) {
    return this.getLatestCheckpoint(
      response.duoWorkflowEvents.nodes.map((e) => ({
        ...e,
        checkpoint: JSON.parse(e.checkpoint),
      })),
    );
  },

  transformChatMessages(uiChatLog) {
    return uiChatLog.map((msg) => {
      const role = [CHAT_MESSAGE_TYPES.agent, CHAT_MESSAGE_TYPES.request].includes(msg.message_type)
        ? GENIE_CHAT_MODEL_ROLES.assistant
        : msg.message_type;

      // Only add extras if user message has additionalContext
      // ref: https://gitlab.com/gitlab-org/editor-extensions/gitlab-lsp/-/blob/main/packages/lib_webview_agentic_chat/src/app/chat/utils/chat_message_helpers.js#L80-82
      if (msg.message_type === 'user' && msg.additional_context) {
        // eslint-disable-next-line no-param-reassign
        msg.extras = { contextItems: msg.additional_context };
      }

      return {
        ...msg,
        role,
        requestId: msg.message_id,
        message_type: msg.message_type,
      };
    });
  },
};
