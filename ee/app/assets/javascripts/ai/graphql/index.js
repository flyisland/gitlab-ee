import { makeVar } from '@apollo/client/core';
import VueApollo from 'vue-apollo';
import createDefaultClient from '~/lib/graphql';
import { logError } from '~/lib/logger';
import Cookies from '~/lib/utils/cookies';
import { duoChatGlobalState } from '~/super_sidebar/state';
import { eventHub, SHOW_SESSION, SHOW_NEW_CHAT, QUEUE_CHAT_COMMAND } from '../events/panel';

export const ACTIVE_TAB_KEY = 'ai_panel_active_tab';

export const activeTab = makeVar();
const isMaximizedVar = makeVar(false);
const infoToggleStatesVar = makeVar({});
const agentSessionStatusVar = makeVar(null);
const panelTitleVar = makeVar(null);
const panelSubtitleVar = makeVar(null);

export const setAiPanelTab = (tab) => {
  if (tab) {
    Cookies.set(ACTIVE_TAB_KEY, tab);
  } else {
    Cookies.remove(ACTIVE_TAB_KEY);
  }

  duoChatGlobalState.activeTab = tab || undefined;
  return activeTab(tab || undefined);
};

export const setMaximized = (value) => {
  return isMaximizedVar(value);
};

export const toggleMaximized = () => {
  const current = isMaximizedVar();
  return isMaximizedVar(!current);
};

export const getInfoToggleVisible = (sessionId, context = 'default') => {
  const states = infoToggleStatesVar();
  const key = `${context}:${sessionId}`;
  return states[key] ?? false;
};

export const toggleInfoToggle = (sessionId, context = 'default') => {
  const states = infoToggleStatesVar();
  const key = `${context}:${sessionId}`;
  const newValue = !getInfoToggleVisible(sessionId, context);
  infoToggleStatesVar({
    ...states,
    [key]: newValue,
  });
  return newValue;
};

export const setInfoToggleVisible = (sessionId, value, context = 'default') => {
  const states = infoToggleStatesVar();
  const key = `${context}:${sessionId}`;
  infoToggleStatesVar({
    ...states,
    [key]: value,
  });
};

export const setAgentSessionStatus = (status) => {
  return agentSessionStatusVar(status);
};

export const setPanelTitle = (title) => {
  return panelTitleVar(title);
};

export const setPanelSubtitle = (subtitle) => {
  return panelSubtitleVar(subtitle);
};

const setupPanelEvents = () => {
  eventHub.$on(SHOW_SESSION, () => {
    setAiPanelTab('sessions');
  });
  eventHub.$on(SHOW_NEW_CHAT, () => {
    setAiPanelTab('chat');
  });
  eventHub.$on(QUEUE_CHAT_COMMAND, async (command) => {
    try {
      const { sendDuoChatCommand } = await import('../utils');
      sendDuoChatCommand(command);
    } catch (e) {
      logError(
        'Failed to import `sendDuoChatCommand`function from ee/app/assets/javascripts/ai/utils.js',
        e,
      );
    }
  });
};

export const cacheConfig = {
  typePolicies: {
    Query: {
      fields: {
        activeTab: {
          read() {
            return activeTab();
          },
        },
        isMaximized: {
          read() {
            return isMaximizedVar();
          },
        },
        infoToggleStates: {
          read() {
            return infoToggleStatesVar();
          },
        },
        agentSessionStatus: {
          read() {
            return agentSessionStatusVar();
          },
        },
        panelTitle: {
          read() {
            return panelTitleVar();
          },
        },
        panelSubtitle: {
          read() {
            return panelSubtitleVar();
          },
        },
      },
    },
  },
};

export const createApolloProvider = ({ autoExpand = false } = {}) => {
  const savedTab = Cookies.get(ACTIVE_TAB_KEY);

  if (autoExpand && !savedTab) {
    activeTab('chat');
  } else {
    activeTab(savedTab);
  }

  setupPanelEvents();

  const defaultClient = createDefaultClient(
    {},
    {
      cacheConfig,
    },
  );

  return new VueApollo({ defaultClient });
};
