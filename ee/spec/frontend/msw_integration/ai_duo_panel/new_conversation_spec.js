import Vue from 'vue';
import VueApollo from 'vue-apollo';
import { waitFor } from '@testing-library/dom';
import { duoChatGlobalState } from '~/super_sidebar/state';
import { CHAT_MODES } from '~/super_sidebar/constants';
import AiPanel from 'ee/ai/components/ai_panel.vue';
import { createApolloProvider } from 'ee/ai/graphql';
import { createRouter } from 'ee/ai/duo_agents_platform/router/ai_panel_router';
import { AGENTIC_CHAT_NEW_ROUTE } from 'ee/ai/duo_agents_platform/router/constants';
import createStore from 'ee/ai/tanuki_bot/store';
import { fullMount, waitForElement } from 'jest/msw_integration/test_helpers';
import { fixtures as aiDuoPanelFixtures } from '../handlers/ai_duo_panel';

Vue.use(VueApollo);

const chatConfiguration = {
  agenticTitle: 'GitLab Duo Agentic Chat',
  classicTitle: 'GitLab Duo Chat',
  defaultProps: {
    isAgenticAvailable: true,
    isClassicAvailable: false,
  },
};

// Simulates a thread loaded from the history panel.
const loadedThreadMessages = aiDuoPanelFixtures.messagesForFirstThread.map((m) => ({
  id: m.id,
  requestId: m.requestId,
  content: m.content,
  contentHtml: m.contentHtml,
  role: m.role,
  timestamp: m.timestamp,
  errors: m.errors,
  extras: m.extras,
}));

// A non-default catalog agent. `catalogAgentsFromResponse` flattens the node
// so the resulting `id` is `node.item.id`.
const targetAgentId = aiDuoPanelFixtures.catalogAgents[1].item.id;

describe('Starting a new conversation while a chat thread is loaded', () => {
  let wrapper;
  let router;
  let store;
  let apolloProvider;

  const findNewAgentToggle = () => document.querySelector('[data-testid="add-new-agent-toggle"]');
  const findTargetAgentItem = () =>
    document.querySelector(`[data-testid="listbox-item-${targetAgentId}"]`);

  const mountPanel = () => {
    router = createRouter('/', 'user', chatConfiguration);
    apolloProvider = createApolloProvider();
    store = createStore();

    store.dispatch('setMessages', loadedThreadMessages);

    wrapper = fullMount(AiPanel, {
      store,
      router,
      apolloProvider,
      propsData: {
        chatDisabledReason: '',
        shouldShowBlockedState: false,
      },
      provide: {
        isSidePanelView: true,
        chatConfiguration,
      },
      stubs: {
        // Stub the routed view so we don't boot the full DuoAgenticChat
        // state manager (which fires ~8 unrelated queries). The scenario
        // under test is driven entirely by the NavigationRail + NewChatButton.
        'router-view': {
          template: '<div data-testid="duo-chat-panel"></div>',
        },
      },
    });
  };

  const clearPanelStorage = () => {
    window.localStorage.clear();
    duoChatGlobalState.chatMode = CHAT_MODES.AGENTIC;
  };

  beforeEach(() => {
    clearPanelStorage();
  });

  afterEach(() => {
    wrapper?.destroy();
    wrapper = undefined;
    clearPanelStorage();
  });

  it('switches the current agent and navigates to the new-chat route when an agent is selected', async () => {
    mountPanel();

    // Seeded thread is present in the store.
    expect(store.state.messages).toHaveLength(loadedThreadMessages.length);
    expect(store.state.currentAgent).toBe(null);

    // The agent dropdown only renders after both agent queries resolve and
    // there is more than one visible agent.
    const toggle = await waitForElement(findNewAgentToggle);
    toggle.querySelector('button').click();

    const item = await waitForElement(findTargetAgentItem);
    item.click();

    // Vuex receives the new agent immediately via setCurrentAgent.
    await waitFor(() => {
      expect(store.state.currentAgent?.id).toBe(targetAgentId);
    });

    // The panel navigates to the agentic new-chat route in response to the
    // `new-chat` event emitted by NewChatButton — this is the route at
    // which DuoAgenticChat clears messages and starts a fresh thread.
    await waitFor(() => {
      expect(router.currentRoute.name).toBe(AGENTIC_CHAT_NEW_ROUTE);
    });
  });
});
