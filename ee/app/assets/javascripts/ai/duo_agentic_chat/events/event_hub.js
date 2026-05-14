import createEventHub from '~/helpers/event_hub_factory';
import { CHAT_MESSAGE_TYPES } from 'ee/ai/constants';
import * as streamManager from '../websocket/stream_manager';
import { processWorkflowMessage } from '../websocket/workflow_utils';

let lastProcessedMessageId = null;

export const duoAgenticChatEventHub = createEventHub();

export const DUO_CHAT_TOOL_COMPLETED_EVENT = 'duo:tool-completed';

streamManager.subscribe('open', () => {
  lastProcessedMessageId = null;
});

streamManager.subscribe('message', async (event) => {
  const workflowData = await processWorkflowMessage(event, lastProcessedMessageId);
  if (!workflowData) return;

  lastProcessedMessageId = workflowData.lastProcessedMessageId;

  workflowData.messages.forEach((msg) => {
    const { message_type: messageType, tool_info: toolInfo, status } = msg || {};
    if (messageType !== CHAT_MESSAGE_TYPES.tool || status !== 'success' || !toolInfo?.name) return;

    duoAgenticChatEventHub.$emit(DUO_CHAT_TOOL_COMPLETED_EVENT, {
      name: toolInfo.name,
      args: toolInfo.args,
    });
  });
});
