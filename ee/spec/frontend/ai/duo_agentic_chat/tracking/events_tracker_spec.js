import { useMockInternalEventsTracking } from 'helpers/tracking_internal_events_helper';
import { EventsTracker } from 'ee/ai/duo_agentic_chat/tracking/events_tracker';
import {
  TRIGGER_SOURCE_WEB_CHAT,
  TRIGGER_SOURCE_WEB_UI,
  TRACKING_EVENT_RECOMMEND_TOOL,
  TRACKING_EVENT_TOOL_SUCCEEDED,
  TRACKING_EVENT_TOOL_FAILED,
  TRACKING_EVENT_APPROVE_TOOL,
  TRACKING_EVENT_DENY_TOOL,
  TRACKING_EVENT_CLICK_THROUGH_FLOW_WIDGET,
} from 'ee/ai/duo_agentic_chat/constants';
import { MOCK_CHAT_MESSAGES } from '../utils/mock_data';

describe('duo_agentic_chat/tracking/events_tracker', () => {
  const { bindInternalEventDocument } = useMockInternalEventsTracking();

  const sessionId = '42';
  const flowType = 'my_agent';
  const model = 'claude-3-5-sonnet';

  let trackEventSpy;

  beforeEach(() => {
    EventsTracker.reset();
    ({ trackEventSpy } = bindInternalEventDocument());
  });

  describe('trackMessage', () => {
    it('tracks recommend_tool_duo_chat for request messages with tool_info', () => {
      EventsTracker.updateContext({
        sessionId,
        flowType,
        triggerSource: TRIGGER_SOURCE_WEB_UI,
        model,
      });
      EventsTracker.trackMessage({ message: MOCK_CHAT_MESSAGES.request });

      expect(trackEventSpy).toHaveBeenCalledWith(TRACKING_EVENT_RECOMMEND_TOOL, {
        tool_name: MOCK_CHAT_MESSAGES.request.tool_info.name,
        session_id: sessionId,
        flow_type: flowType,
        trigger_source: TRIGGER_SOURCE_WEB_UI,
        model,
      });
    });

    it('tracks tool_succeeded_duo_chat for tool messages with status success', () => {
      EventsTracker.updateContext({ sessionId, flowType, model });
      EventsTracker.trackMessage({ message: MOCK_CHAT_MESSAGES.tool });

      expect(trackEventSpy).toHaveBeenCalledWith(TRACKING_EVENT_TOOL_SUCCEEDED, {
        tool_name: MOCK_CHAT_MESSAGES.tool.tool_info.name,
        session_id: sessionId,
        flow_type: flowType,
        trigger_source: TRIGGER_SOURCE_WEB_CHAT,
        model,
      });
    });

    it('tracks tool_failed_duo_chat for tool messages with status failure', () => {
      const failedToolMessage = {
        ...MOCK_CHAT_MESSAGES.tool,
        tool_info: {
          ...MOCK_CHAT_MESSAGES.tool.tool_info,
          tool_response: {
            ...MOCK_CHAT_MESSAGES.tool.tool_info.tool_response,
            status: 'failure',
          },
        },
      };

      EventsTracker.updateContext({ sessionId, flowType, model });
      EventsTracker.trackMessage({ message: failedToolMessage });

      expect(trackEventSpy).toHaveBeenCalledWith(TRACKING_EVENT_TOOL_FAILED, {
        tool_name: failedToolMessage.tool_info.name,
        session_id: sessionId,
        flow_type: flowType,
        trigger_source: TRIGGER_SOURCE_WEB_CHAT,
        model,
      });
    });

    it('does not track for messages without tool_info', () => {
      EventsTracker.trackMessage({ message: MOCK_CHAT_MESSAGES.agentComplete });

      expect(trackEventSpy).not.toHaveBeenCalled();
    });

    it('does not track for agent messages with tool_info', () => {
      EventsTracker.trackMessage({
        message: { ...MOCK_CHAT_MESSAGES.request, message_type: 'agent' },
      });

      expect(trackEventSpy).not.toHaveBeenCalled();
    });

    it('does not track the same message more than once', () => {
      EventsTracker.trackMessage({ message: MOCK_CHAT_MESSAGES.request });
      EventsTracker.trackMessage({ message: MOCK_CHAT_MESSAGES.request });

      expect(trackEventSpy).toHaveBeenCalledTimes(1);
    });
  });

  describe('trackApproveTool', () => {
    it('tracks approve_tool_duo_chat with the provided properties', () => {
      EventsTracker.updateContext({ sessionId, flowType, model });
      EventsTracker.trackApproveTool({ toolName: 'create_commit' });

      expect(trackEventSpy).toHaveBeenCalledWith(TRACKING_EVENT_APPROVE_TOOL, {
        tool_name: 'create_commit',
        session_id: sessionId,
        flow_type: flowType,
        trigger_source: TRIGGER_SOURCE_WEB_CHAT,
        model,
      });
    });
  });

  describe('trackDenyTool', () => {
    it('tracks deny_tool_duo_chat with the provided properties', () => {
      EventsTracker.updateContext({ sessionId, flowType, model });
      EventsTracker.trackDenyTool({ toolName: 'run_command' });

      expect(trackEventSpy).toHaveBeenCalledWith(TRACKING_EVENT_DENY_TOOL, {
        tool_name: 'run_command',
        session_id: sessionId,
        flow_type: flowType,
        trigger_source: TRIGGER_SOURCE_WEB_CHAT,
        model,
      });
    });
  });

  describe('trackClickThroughFlowWidget', () => {
    it('tracks click_through_flow_widget with the provided properties', () => {
      EventsTracker.updateContext({ sessionId, flowType, model });
      EventsTracker.trackClickThroughFlowWidget({ toolName: 'some_tool' });

      expect(trackEventSpy).toHaveBeenCalledWith(TRACKING_EVENT_CLICK_THROUGH_FLOW_WIDGET, {
        tool_name: 'some_tool',
        session_id: sessionId,
        flow_type: flowType,
        trigger_source: TRIGGER_SOURCE_WEB_CHAT,
        model,
      });
    });
  });
});
