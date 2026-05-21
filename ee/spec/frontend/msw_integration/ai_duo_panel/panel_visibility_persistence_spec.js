import Vue from 'vue';
import VueApollo from 'vue-apollo';
import { waitFor } from '@testing-library/dom';
import { duoChatGlobalState } from '~/super_sidebar/state';
import { CHAT_MODES } from '~/super_sidebar/constants';
import AiPanel from 'ee/ai/components/ai_panel.vue';
import { createApolloProvider } from 'ee/ai/graphql';
import { createRouter } from 'ee/ai/duo_agents_platform/router/ai_panel_router';
import { CLOSED_ROUTE } from 'ee/ai/duo_agents_platform/router/constants';
import { fullMount, waitForElement } from 'jest/msw_integration/test_helpers';

Vue.use(VueApollo);

const chatConfiguration = {
  agenticTitle: 'GitLab Duo Agentic Chat',
  classicTitle: 'GitLab Duo Chat',
  defaultProps: {
    isAgenticAvailable: true,
    isClassicAvailable: false,
    duoSettingsPath: '/groups/gitlab-org/-/settings/gitlab_duo',
  },
};

describe('AI panel visibility persists across reloads', () => {
  let wrapper;
  let router;
  let apolloProvider;

  const findPanelContent = () => document.querySelector('[data-testid="duo-chat-panel"]');
  const findDuoDisabledToggle = () => document.querySelector('[data-testid="duo-disabled-toggle"]');
  const findChatToggle = () => document.querySelector('[data-testid="ai-chat-toggle"]');

  const mountPanel = ({
    chatDisabledReason = '',
    shouldShowBlockedState = false,
    autoExpand = false,
  } = {}) => {
    router = createRouter('/', 'user', { ...chatConfiguration, autoExpand });
    apolloProvider = createApolloProvider();

    wrapper = fullMount(AiPanel, {
      router,
      apolloProvider,
      propsData: {
        chatDisabledReason,
        shouldShowBlockedState,
      },
      provide: {
        isSidePanelView: true,
        chatConfiguration: { ...chatConfiguration, autoExpand },
      },
      stubs: {
        'router-view': {
          template: '<div data-testid="duo-chat-panel"></div>',
        },
      },
    });
  };

  const clearPanelStorage = () => {
    window.localStorage.clear();
    duoChatGlobalState.chatMode = CHAT_MODES.AGENTIC;
    duoChatGlobalState.lastRoutePerTab = {};
  };

  beforeEach(() => {
    clearPanelStorage();
  });

  afterEach(() => {
    wrapper?.destroy();
    wrapper = undefined;
    clearPanelStorage();
  });

  describe('when GitLab Duo is disabled (admin)', () => {
    it('stays collapsed after reload when user closes the disabled Duo panel', async () => {
      mountPanel({ chatDisabledReason: 'project', shouldShowBlockedState: true });

      await waitForElement(findDuoDisabledToggle);
      expect(findPanelContent()).toBe(null);

      // Open panel
      findDuoDisabledToggle().click();
      await waitFor(() => {
        expect(findPanelContent()).not.toBe(null);
      });

      // Close panel
      findDuoDisabledToggle().click();
      await waitFor(() => {
        expect(router.currentRoute.name).toBe(CLOSED_ROUTE);
      });
      await waitFor(() => {
        expect(findPanelContent()).toBe(null);
      });

      // Simulate reload
      wrapper.destroy();
      document.body.innerHTML = '';

      mountPanel({ chatDisabledReason: 'project', shouldShowBlockedState: true });

      await waitForElement(findDuoDisabledToggle);
      expect(findPanelContent()).toBe(null);
    });
  });

  describe('when Duo is enabled (regular user)', () => {
    it('stays collapsed after reload when the user closes the panel', async () => {
      mountPanel();

      await waitForElement(findChatToggle);

      // Open the chat panel
      findChatToggle().click();
      await waitFor(() => {
        expect(findPanelContent()).not.toBe(null);
      });

      // Close the chat panel by toggling the active tab again
      findChatToggle().click();
      await waitFor(() => {
        expect(router.currentRoute.name).toBe(CLOSED_ROUTE);
      });
      await waitFor(() => {
        expect(findPanelContent()).toBe(null);
      });

      // Simulate reload
      wrapper.destroy();
      document.body.innerHTML = '';

      mountPanel();

      await waitForElement(findChatToggle);
      expect(findPanelContent()).toBe(null);
      expect(router.currentRoute.name).toBe(CLOSED_ROUTE);
    });
  });
});
