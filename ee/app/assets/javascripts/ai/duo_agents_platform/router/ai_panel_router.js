import Vue from 'vue';
import VueRouter from 'vue-router';
import { s__, __ } from '~/locale';
import NestedRouteApp from '~/vue_shared/spa/components/router_view.vue';
import { duoChatGlobalState } from '~/super_sidebar/state';
import { eventHub, SHOW_SESSION } from 'ee/ai/events/panel';
import { setAiPanelTab } from 'ee/ai/graphql';
import DuoAgenticChat from 'ee/ai/duo_agentic_chat/components/duo_agentic_chat.vue';
import DuoChat from 'ee/ai/tanuki_bot/components/duo_chat.vue';
import AgentsPlatformShow from '../pages/show/duo_agents_platform_show.vue';
import {
  getStorageKey,
  restoreLastRoute,
  saveRouteState,
  setupNavigationGuards,
  trackTabRoutes,
} from '../utils/navigation_state';
import { safeRouterPush } from '../utils/router_utils';
import {
  AGENTS_PLATFORM_INDEX_ROUTE,
  AGENTS_PLATFORM_SHOW_ROUTE,
  AGENTIC_CHAT_HISTORY_ROUTE,
  AGENTIC_CHAT_NEW_ROUTE,
  AGENTIC_CHAT_SHOW_ROUTE,
  CLASSIC_CHAT_HISTORY_ROUTE,
  CLASSIC_CHAT_NEW_ROUTE,
  CLASSIC_CHAT_SHOW_ROUTE,
  CLOSED_ROUTE,
  ROUTE_TO_TAB,
} from './constants';
import { getNamespaceIndexComponent } from './utils';

Vue.use(VueRouter);

const SAVED_ROUTE_CONTEXT = 'side_panel';

/**
 * Syncs the activeTab state from the current route.
 * @param {Object} to - The route object to sync from
 */
const syncTabFromRoute = (to) => {
  const tab = ROUTE_TO_TAB[to.name];
  if (tab && duoChatGlobalState.activeTab !== tab) {
    setAiPanelTab(tab);
  }
};

const setupRouterPanelEvents = (router) => {
  eventHub.$on(SHOW_SESSION, async ({ id }) => {
    await safeRouterPush(
      router,
      { name: AGENTS_PLATFORM_SHOW_ROUTE, params: { id } },
      { component: 'AiPanelRouter' },
    );
  });
};

export const createRouter = (base, namespace, chatConfiguration) => {
  const { defaultProps = {} } = chatConfiguration;

  const router = new VueRouter({
    base,
    mode: 'abstract',
    routes: [
      {
        name: CLOSED_ROUTE,
        path: '/closed',
        component: { render: () => null },
      },
      {
        name: AGENTIC_CHAT_SHOW_ROUTE,
        path: '/agentic-chat',
        component: DuoAgenticChat,
        props: { ...defaultProps, mode: 'active' },
        meta: {
          text: s__('DuoAgentsPlatform|Chat'),
          title: chatConfiguration.agenticTitle,
        },
      },
      {
        name: AGENTIC_CHAT_NEW_ROUTE,
        path: '/agentic-chat/new',
        component: DuoAgenticChat,
        props: { ...defaultProps, mode: 'new' },
        meta: {
          text: s__('DuoAgentsPlatform|Chat'),
          title: chatConfiguration.agenticTitle,
        },
      },
      {
        name: AGENTIC_CHAT_HISTORY_ROUTE,
        path: '/agentic-chat/history',
        component: DuoAgenticChat,
        props: { ...defaultProps, mode: 'history' },
        meta: { title: __('History') },
      },

      {
        name: CLASSIC_CHAT_SHOW_ROUTE,
        path: '/classic-chat/',
        component: DuoChat,
        props: { ...defaultProps, mode: 'chat' },
        meta: {
          text: s__('DuoAgentsPlatform|Chat'),
          title: chatConfiguration.classicTitle,
        },
      },
      {
        name: CLASSIC_CHAT_NEW_ROUTE,
        path: '/classic-chat/new',
        component: DuoChat,
        props: { ...defaultProps, mode: 'new' },
        meta: {
          text: s__('DuoAgentsPlatform|Chat'),
          title: chatConfiguration.classicTitle,
        },
      },
      {
        name: CLASSIC_CHAT_HISTORY_ROUTE,
        path: '/classic-chat/history',
        component: DuoChat,
        props: { ...defaultProps, mode: 'history' },
        meta: { title: __('History') },
      },

      {
        component: NestedRouteApp,
        path: '/agent-sessions',
        meta: {
          text: s__('DuoAgentsPlatform|Sessions'),
          title: __('Sessions'),
        },
        children: [
          {
            name: AGENTS_PLATFORM_INDEX_ROUTE,
            path: '',
            component: getNamespaceIndexComponent(namespace),
          },
          {
            name: AGENTS_PLATFORM_SHOW_ROUTE,
            path: ':id(\\d+)',
            component: AgentsPlatformShow,
            beforeEnter(to, _from, next) {
              saveRouteState(to, getStorageKey(SAVED_ROUTE_CONTEXT));
              next();
            },
          },
        ],
      },
    ],
  });

  // Set up navigation guards for session state persistence (enabled for side panels)
  setupNavigationGuards({
    router,
    context: SAVED_ROUTE_CONTEXT,
  });

  // Track routes for AI panel tab navigation
  router.beforeEach((to, _from, next) => {
    trackTabRoutes(to);
    next();
  });

  // Sync activeTab from route changes
  router.afterEach((to) => {
    syncTabFromRoute(to);
  });

  setupRouterPanelEvents(router);

  // Use nextTick to ensure router is properly initialized before navigation
  // This is needed for abstract routers because it needs a base route
  Vue.nextTick(() => {
    const isAgenticAvailable = defaultProps.isAgenticAvailable ?? false;
    restoreLastRoute(router, {
      context: SAVED_ROUTE_CONTEXT,
      defaultRoute: CLOSED_ROUTE,
      isAgenticAvailable,
    });
  });

  return router;
};
