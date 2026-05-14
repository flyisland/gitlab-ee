import { InternalEvents } from '~/tracking';
import { CHAT_MESSAGE_TYPES } from 'ee/ai/constants';
import {
  TRIGGER_SOURCE_WEB_CHAT,
  TRACKING_EVENT_RECOMMEND_TOOL,
  TRACKING_EVENT_TOOL_SUCCEEDED,
  TRACKING_EVENT_TOOL_FAILED,
  TRACKING_EVENT_APPROVE_TOOL,
  TRACKING_EVENT_DENY_TOOL,
  TRACKING_EVENT_CLICK_THROUGH_FLOW_WIDGET,
} from '../constants';

const TOOL_STATUS_SUCCESS = 'success';
const TOOL_STATUS_FAILED = 'failure';

const trackedMessageIds = new Set();

let context = {
  sessionId: undefined,
  flowType: undefined,
  triggerSource: TRIGGER_SOURCE_WEB_CHAT,
  model: undefined,
};

export const EventsTracker = {
  reset() {
    trackedMessageIds.clear();
    context = {
      sessionId: undefined,
      flowType: undefined,
      triggerSource: TRIGGER_SOURCE_WEB_CHAT,
      model: undefined,
    };
  },

  updateContext({ sessionId, flowType, triggerSource, model } = {}) {
    if (sessionId !== undefined) context.sessionId = sessionId;
    if (flowType !== undefined) context.flowType = flowType;
    if (triggerSource !== undefined) context.triggerSource = triggerSource;
    if (model !== undefined) context.model = model;
  },

  trackMessage({ message } = {}) {
    if (!message) return;

    const { message_id: messageId, message_type: messageType, tool_info: toolInfo } = message;
    if (!toolInfo) return;
    if (trackedMessageIds.has(messageId)) return;
    trackedMessageIds.add(messageId);

    const status = toolInfo.tool_response?.status;

    const additionalProperties = {
      tool_name: toolInfo.name,
      session_id: context.sessionId,
      flow_type: context.flowType,
      trigger_source: context.triggerSource,
      model: context.model,
    };

    if (messageType === CHAT_MESSAGE_TYPES.request) {
      InternalEvents.trackEvent(TRACKING_EVENT_RECOMMEND_TOOL, additionalProperties);
    } else if (
      messageType === CHAT_MESSAGE_TYPES.tool &&
      [TOOL_STATUS_FAILED, TOOL_STATUS_SUCCESS].includes(status)
    ) {
      const event =
        status === TOOL_STATUS_SUCCESS ? TRACKING_EVENT_TOOL_SUCCEEDED : TRACKING_EVENT_TOOL_FAILED;
      InternalEvents.trackEvent(event, additionalProperties);
    }
  },

  trackApproveTool({ toolName } = {}) {
    InternalEvents.trackEvent(TRACKING_EVENT_APPROVE_TOOL, {
      tool_name: toolName,
      session_id: context.sessionId,
      flow_type: context.flowType,
      trigger_source: context.triggerSource,
      model: context.model,
    });
  },

  trackDenyTool({ toolName } = {}) {
    InternalEvents.trackEvent(TRACKING_EVENT_DENY_TOOL, {
      tool_name: toolName,
      session_id: context.sessionId,
      flow_type: context.flowType,
      trigger_source: context.triggerSource,
      model: context.model,
    });
  },

  trackClickThroughFlowWidget({ toolName } = {}) {
    InternalEvents.trackEvent(TRACKING_EVENT_CLICK_THROUGH_FLOW_WIDGET, {
      tool_name: toolName,
      session_id: context.sessionId,
      flow_type: context.flowType,
      trigger_source: context.triggerSource,
      model: context.model,
    });
  },
};
