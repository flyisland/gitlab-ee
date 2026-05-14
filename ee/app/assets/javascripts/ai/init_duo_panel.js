import Vue from 'vue';
import VueApollo from 'vue-apollo';
import { parseBoolean } from '~/lib/utils/common_utils';
import { __ } from '~/locale';
import { createRouter } from 'ee/ai/duo_agents_platform/router/ai_panel_router';
import DuoAgenticChat from 'ee/ai/duo_agentic_chat/components/duo_agentic_chat.vue';
import DuoChat from 'ee/ai/tanuki_bot/components/duo_chat.vue';
import { activeWorkItemIds } from '~/work_items/utils';
import { setAgenticMode } from 'ee/ai/utils';
import store from './tanuki_bot/store';
import { createApolloProvider } from './graphql';
import AIPanel from './components/ai_panel.vue';
import AIPanelEmptyState from './components/ai_panel_empty_state.vue';

function initDuoPanelEmptyState() {
  const el = document.getElementById('duo-chat-panel-empty-state');

  if (!el) {
    return false;
  }

  Vue.use(VueApollo);

  const {
    newTrialPath,
    trialDuration,
    namespaceType,
    isTrialExpired,
    buyAddonPath,
    canBuyAddon,
    canStartTrial,
  } = el.dataset;

  const autoExpand = parseBoolean(el.dataset.autoExpand);
  const apolloProvider = createApolloProvider({ autoExpand });

  return new Vue({
    el,
    name: 'AIPanelEmptyStateApp',
    apolloProvider,
    provide: {
      autoExpand,
      canStartTrial: parseBoolean(canStartTrial),
      isTrialExpired: parseBoolean(isTrialExpired),
      newTrialPath,
      trialDuration,
      namespaceType,
      buyAddonPath,
      canBuyAddon: parseBoolean(canBuyAddon),
    },
    render(renderElement) {
      return renderElement(AIPanelEmptyState);
    },
  });
}

export function initDuoPanel() {
  const el = document.getElementById('duo-chat-panel');

  if (!el) {
    return initDuoPanelEmptyState();
  }

  const {
    userId,
    projectId,
    projectPath,
    namespaceId,
    rootNamespaceId,
    resourceId,
    metadata,
    userModelSelectionEnabled,
    agenticAvailable,
    classicAvailable,
    forceAgenticModeForCoreDuoUsers,
    agenticUnavailableMessage,
    chatTitle,
    chatDisabledReason,
    duoSettingsPath,
    defaultNamespaceSelected,
    preferencesPath,
    isTrial,
    buyAddonPath,
    canBuyAddon,
    trialActive,
    subscriptionActive,
    exploreAiCatalogPath,
    autoExpand,
  } = el.dataset;

  if (parseBoolean(forceAgenticModeForCoreDuoUsers)) {
    setAgenticMode({ agenticMode: true, saveCookie: true });
  }

  Vue.use(VueApollo);

  const apolloProvider = createApolloProvider({ autoExpand: parseBoolean(autoExpand) });

  // Configure chat-specific values in a single configuration object
  const chatConfiguration = {
    agenticComponent: DuoAgenticChat,
    classicComponent: DuoChat,
    agenticTitle: chatTitle || __('GitLab Duo Agentic Chat'),
    classicTitle: __('GitLab Duo Chat'),
    defaultProps: {
      isEmbedded: true,
      userId,
      projectId,
      projectPath,
      namespaceId,
      rootNamespaceId,
      resourceId,
      metadata,
      agenticUnavailableMessage,
      userModelSelectionEnabled: parseBoolean(userModelSelectionEnabled),
      isAgenticAvailable: parseBoolean(agenticAvailable),
      isClassicAvailable: parseBoolean(classicAvailable),
      forceAgenticModeForCoreDuoUsers: parseBoolean(forceAgenticModeForCoreDuoUsers),
      chatTitle,
      canConfigureDuoSettings: Boolean(duoSettingsPath),
      duoSettingsPath,
      defaultNamespaceSelected: parseBoolean(defaultNamespaceSelected),
      preferencesPath,
      isTrial: parseBoolean(isTrial),
      buyAddonPath,
      canBuyAddon: parseBoolean(canBuyAddon),
      trialActive: parseBoolean(trialActive ?? 'false'),
      subscriptionActive: parseBoolean(subscriptionActive ?? 'false'),
      exploreAiCatalogPath,
    },
  };

  const router = createRouter('/', 'user', chatConfiguration);

  return new Vue({
    el,
    name: 'DuoPanel',
    store: store(),
    router,
    apolloProvider,
    provide: {
      isSidePanelView: true,
      // Inject chat configuration directly to components that need it
      chatConfiguration,
    },
    render(createElement) {
      const latestActiveWorkItemId = activeWorkItemIds.value[activeWorkItemIds.value.length - 1];
      return createElement(AIPanel, {
        props: {
          name: 'AiPanel',
          userId,
          projectId,
          namespaceId,
          rootNamespaceId,
          resourceId: latestActiveWorkItemId ?? resourceId,
          metadata,
          userModelSelectionEnabled: parseBoolean(userModelSelectionEnabled),
          chatDisabledReason,
        },
      });
    },
  });
}
