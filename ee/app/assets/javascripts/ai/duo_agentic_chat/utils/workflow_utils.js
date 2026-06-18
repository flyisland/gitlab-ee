import { CHAT_MESSAGE_TYPES, GENIE_CHAT_MODEL_ROLES } from 'ee/ai/constants';

export const WorkflowUtils = {
  parseWorkflowData(response) {
    const [workflow] = response.duoWorkflowWorkflows.nodes ?? [];
    return workflow?.latestCheckpoint ?? null;
  },

  parseWorkflowStatus(response) {
    const [workflow] = response?.duoWorkflowWorkflows?.nodes ?? [];
    return workflow?.status ?? null;
  },

  normalizeDuoMessages(duoMessages) {
    return duoMessages.map(
      ({
        messageType,
        messageSubType,
        toolInfo,
        messageId,
        correlationId,
        additionalContext,
        ...rest
      }) => ({
        ...rest,
        message_type: messageType,
        message_sub_type: messageSubType,
        tool_info: toolInfo ? JSON.parse(toolInfo) : toolInfo,
        message_id: messageId,
        correlation_id: correlationId,
        additional_context: additionalContext,
      }),
    );
  },

  findLatestTodoToolInfo(messages) {
    for (let i = messages.length - 1; i >= 0; i -= 1) {
      const { tool_info: toolInfo } = messages[i];
      if (toolInfo?.name === 'todo_write' && toolInfo?.args?.todos?.length) {
        return toolInfo;
      }
    }
    return null;
  },

  transformChatMessages(uiChatLog) {
    return uiChatLog.map((msg) => {
      const role = [CHAT_MESSAGE_TYPES.agent, CHAT_MESSAGE_TYPES.request].includes(msg.message_type)
        ? GENIE_CHAT_MODEL_ROLES.assistant
        : msg.message_type;

      // Only add extras if user message has additionalContext
      // ref: https://gitlab.com/gitlab-org/editor-extensions/gitlab-lsp/-/blob/main/packages/lib_webview_agentic_chat/src/app/chat/utils/chat_message_helpers.js#L80-82
      if (msg.message_type === 'user' && msg.additional_context) {
        const INTERNAL_CATEGORIES = new Set(['orbit_context']);
        // eslint-disable-next-line no-param-reassign
        msg.extras = {
          contextItems: msg.additional_context.filter((c) => !INTERNAL_CATEGORIES.has(c.category)),
        };
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
