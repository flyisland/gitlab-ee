import createEventHub from '~/helpers/event_hub_factory';
import { CHAT_MESSAGE_TYPES } from 'ee/ai/constants';
import * as streamManager from 'ee/ai/duo_agentic_chat/websocket/stream_manager';
import { processWorkflowMessage } from 'ee/ai/duo_agentic_chat/websocket/workflow_utils';

jest.mock('~/helpers/event_hub_factory');
jest.mock('ee/ai/duo_agentic_chat/websocket/stream_manager');
jest.mock('ee/ai/duo_agentic_chat/websocket/workflow_utils');

describe('duo agentic chat event hub', () => {
  let mockEventHub;
  let subscribedHandlers;
  let DUO_CHAT_TOOL_COMPLETED_EVENT;

  beforeEach(() => {
    subscribedHandlers = {};

    streamManager.subscribe.mockImplementation((event, handler) => {
      subscribedHandlers[event] = handler;
    });

    mockEventHub = { $emit: jest.fn(), $on: jest.fn(), $off: jest.fn() };
    createEventHub.mockReturnValue(mockEventHub);

    jest.isolateModules(() => {
      // eslint-disable-next-line global-require
      const hub = require('ee/ai/duo_agentic_chat/events/event_hub');
      DUO_CHAT_TOOL_COMPLETED_EVENT = hub.DUO_CHAT_TOOL_COMPLETED_EVENT;
    });
  });

  it('creates an event hub', () => {
    expect(createEventHub).toHaveBeenCalled();
  });

  it('exports the event hub as a named export', () => {
    let duoAgenticChatEventHub;
    jest.isolateModules(() => {
      duoAgenticChatEventHub =
        // eslint-disable-next-line global-require
        require('ee/ai/duo_agentic_chat/events/event_hub').duoAgenticChatEventHub;
    });

    expect(duoAgenticChatEventHub).toBeDefined();
    expect(duoAgenticChatEventHub.$emit).toBeDefined();
  });

  it('exports the DUO_CHAT_TOOL_COMPLETED_EVENT constant', () => {
    expect(DUO_CHAT_TOOL_COMPLETED_EVENT).toBe('duo:tool-completed');
  });

  it('subscribes to stream manager open and message events', () => {
    expect(streamManager.subscribe).toHaveBeenCalledWith('open', expect.any(Function));
    expect(streamManager.subscribe).toHaveBeenCalledWith('message', expect.any(Function));
  });

  describe('on message', () => {
    const triggerMessage = async (messages, lastProcessedMessageId = 'msg-1') => {
      processWorkflowMessage.mockResolvedValue({ messages, lastProcessedMessageId });
      await subscribedHandlers.message({ data: 'test' });
    };

    it('emits DUO_CHAT_TOOL_COMPLETED_EVENT for successful tool messages', async () => {
      await triggerMessage([
        {
          message_type: CHAT_MESSAGE_TYPES.tool,
          status: 'success',
          tool_info: { name: 'update_form', args: { select: ['read'] } },
        },
      ]);

      expect(mockEventHub.$emit).toHaveBeenCalledWith(DUO_CHAT_TOOL_COMPLETED_EVENT, {
        name: 'update_form',
        args: { select: ['read'] },
      });
    });

    it('does not emit for non-tool messages', async () => {
      await triggerMessage([
        {
          message_type: CHAT_MESSAGE_TYPES.agent,
          status: 'success',
          tool_info: { name: 'update_form', args: {} },
        },
      ]);

      expect(mockEventHub.$emit).not.toHaveBeenCalled();
    });

    it('does not emit for failed tool messages', async () => {
      await triggerMessage([
        {
          message_type: CHAT_MESSAGE_TYPES.tool,
          status: 'error',
          tool_info: { name: 'update_form', args: {} },
        },
      ]);

      expect(mockEventHub.$emit).not.toHaveBeenCalled();
    });

    it('does not emit when tool_info has no name', async () => {
      await triggerMessage([
        {
          message_type: CHAT_MESSAGE_TYPES.tool,
          status: 'success',
          tool_info: { args: {} },
        },
      ]);

      expect(mockEventHub.$emit).not.toHaveBeenCalled();
    });

    it('does not emit when processWorkflowMessage returns null', async () => {
      processWorkflowMessage.mockResolvedValue(null);
      await subscribedHandlers.message({ data: 'test' });

      expect(mockEventHub.$emit).not.toHaveBeenCalled();
    });

    it('emits for each successful tool message in a batch', async () => {
      await triggerMessage([
        {
          message_type: CHAT_MESSAGE_TYPES.tool,
          status: 'success',
          tool_info: { name: 'tool_a', args: { a: 1 } },
        },
        {
          message_type: CHAT_MESSAGE_TYPES.tool,
          status: 'success',
          tool_info: { name: 'tool_b', args: { b: 2 } },
        },
      ]);

      expect(mockEventHub.$emit).toHaveBeenCalledTimes(2);
      expect(mockEventHub.$emit).toHaveBeenCalledWith(DUO_CHAT_TOOL_COMPLETED_EVENT, {
        name: 'tool_a',
        args: { a: 1 },
      });
      expect(mockEventHub.$emit).toHaveBeenCalledWith(DUO_CHAT_TOOL_COMPLETED_EVENT, {
        name: 'tool_b',
        args: { b: 2 },
      });
    });
  });
});
