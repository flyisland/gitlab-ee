import { isEqual } from 'lodash-es';
import { getStorageValue, saveStorageValue, removeStorageValue } from '~/lib/utils/local_storage';
import { CHAT_MODES } from '~/super_sidebar/constants';
import { duoChatGlobalState } from '~/super_sidebar/state';
import { getDefaultRouteForTab } from '../router/utils';
import { safeRouterPush } from './router_utils';

const BASE_STORAGE_KEY = 'duo_agents_platform_last_route';

export const getStorageKey = (context) =>
  context ? `${BASE_STORAGE_KEY}_${context}` : BASE_STORAGE_KEY;

export const getLastRouteState = (storageKey = BASE_STORAGE_KEY) => {
  const { exists, value } = getStorageValue(storageKey);
  return exists ? value : null;
};

export const saveRouteState = (route, storageKey = BASE_STORAGE_KEY) => {
  if (route.name) {
    saveStorageValue(storageKey, {
      name: route.name,
      params: route.params || {},
    });
  }
};

export const clearRouteState = (storageKey = BASE_STORAGE_KEY) => {
  removeStorageValue(storageKey);
};

export const restoreLastRoute = async (router, options = {}) => {
  const {
    defaultRoute = null,
    context = null,
    storageKey = null,
    isAgenticAvailable = false,
  } = options;
  const key = storageKey || getStorageKey(context);
  const routeState = getLastRouteState(key);

  // If no saved route, determine default based on chat mode
  if (!routeState) {
    const isAgenticMode = isAgenticAvailable && duoChatGlobalState.chatMode === CHAT_MODES.AGENTIC;
    const fallback = defaultRoute || getDefaultRouteForTab('chat', isAgenticMode);
    await safeRouterPush(router, { name: fallback }, { component: 'NavigationState' });
    return;
  }

  // Check if current route already matches the saved route
  const { currentRoute } = router;
  if (
    currentRoute &&
    currentRoute.name === routeState.name &&
    isEqual(currentRoute.params, routeState.params || {})
  ) {
    return;
  }

  // Try to restore saved route, fall back to mode-aware default on error
  try {
    await safeRouterPush(router, routeState, { component: 'NavigationState' });
  } catch (err) {
    if (err.name === 'NavigationDuplicated') return;
    clearRouteState(key);
    const isAgenticMode = isAgenticAvailable && duoChatGlobalState.chatMode === CHAT_MODES.AGENTIC;
    const fallback = defaultRoute || getDefaultRouteForTab('chat', isAgenticMode);
    await safeRouterPush(router, { name: fallback }, { component: 'NavigationState' });
  }
};

export const setupNavigationGuards = ({ router, context = null, storageKey = null }) => {
  const key = storageKey || getStorageKey(context);
  router.afterEach((to) => {
    saveRouteState(to, key);
  });
};

export const trackTabRoutes = ({ path }) => {
  const { activeTab, lastRoutePerTab } = duoChatGlobalState;

  if (!activeTab || !path) {
    return;
  }

  if (!lastRoutePerTab) {
    duoChatGlobalState.lastRoutePerTab = {};
  }

  duoChatGlobalState.lastRoutePerTab[activeTab] = path;
};
