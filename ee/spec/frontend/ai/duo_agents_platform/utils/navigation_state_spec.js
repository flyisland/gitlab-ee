import {
  getLastRouteState,
  saveRouteState,
  clearRouteState,
  restoreLastRoute,
  setupNavigationGuards,
  getStorageKey,
  trackTabRoutes,
} from 'ee/ai/duo_agents_platform/utils/navigation_state';
import { getStorageValue, saveStorageValue, removeStorageValue } from '~/lib/utils/local_storage';
import { duoChatGlobalState } from '~/super_sidebar/state';
import {
  AGENTIC_CHAT_SHOW_ROUTE,
  CLASSIC_CHAT_SHOW_ROUTE,
} from 'ee/ai/duo_agents_platform/router/constants';

jest.mock('~/lib/utils/local_storage', () => ({
  getStorageValue: jest.fn(() => ({ exists: false })),
  saveStorageValue: jest.fn(),
  removeStorageValue: jest.fn(),
}));

describe('Navigation State Utils', () => {
  const mockRoute = {
    name: 'agents_platform_show_route',
    params: { id: '123' },
    path: '/agent-sessions/123',
  };
  const mockRouteState = {
    name: 'agents_platform_show_route',
    params: { id: '123' },
  };
  const mockRouter = { push: jest.fn(), afterEach: jest.fn(), currentRoute: {} };
  const defaultStorageKey = 'duo_agents_platform_last_route';

  beforeEach(() => {
    jest.clearAllMocks();
    duoChatGlobalState.activeTab = null;
    duoChatGlobalState.lastRoutePerTab = {};
    mockRouter.currentRoute = {};
    duoChatGlobalState.chatMode = 'agentic';
  });

  describe('getStorageKey', () => {
    it.each([
      { context: undefined, expected: defaultStorageKey, description: 'when no context provided' },
      { context: null, expected: defaultStorageKey, description: 'when context is null' },
      {
        context: 'custom_context',
        expected: `${defaultStorageKey}_custom_context`,
        description: 'when context provided',
      },
    ])('returns $expected $description', ({ context, expected }) => {
      expect(getStorageKey(context)).toBe(expected);
    });
  });

  describe('getLastRouteState', () => {
    it.each([
      { exists: true, value: mockRouteState, expected: mockRouteState },
      { exists: false, expected: null },
    ])('returns $expected when storage exists: $exists', ({ exists, value, expected }) => {
      getStorageValue.mockReturnValue({ exists, value });

      expect(getLastRouteState()).toBe(expected);
      expect(getStorageValue).toHaveBeenCalledWith(defaultStorageKey);
    });
  });

  describe('saveRouteState', () => {
    it.each([
      {
        name: 'saves route state to localStorage when route has name',
        route: mockRoute,
        storageKey: undefined,
        expectedKey: defaultStorageKey,
        expectedValue: mockRouteState,
      },
      {
        name: 'saves route state with custom storage key',
        route: mockRoute,
        storageKey: 'custom_key',
        expectedKey: 'custom_key',
        expectedValue: mockRouteState,
      },
      {
        name: 'saves route state with empty params when params are undefined',
        route: { name: 'test_route', path: '/test' },
        storageKey: undefined,
        expectedKey: defaultStorageKey,
        expectedValue: { name: 'test_route', params: {} },
      },
    ])('$name', ({ route, storageKey, expectedKey, expectedValue }) => {
      saveRouteState(route, storageKey);
      expect(saveStorageValue).toHaveBeenCalledWith(expectedKey, expectedValue);
    });

    it('does not save when route has no name', () => {
      const routeWithoutName = { params: { id: '123' }, path: '/agent-sessions/123' };

      saveRouteState(routeWithoutName);
      expect(saveStorageValue).not.toHaveBeenCalled();
    });
  });

  describe('clearRouteState', () => {
    it('removes session ID from localStorage', () => {
      clearRouteState();
      expect(removeStorageValue).toHaveBeenCalledWith(defaultStorageKey);
    });
  });

  describe('restoreLastRoute', () => {
    describe('successful navigation', () => {
      beforeEach(() => {
        mockRouter.push.mockResolvedValue();
      });

      describe('with saved route', () => {
        beforeEach(() => {
          getStorageValue.mockReturnValue({
            exists: true,
            value: mockRouteState,
          });
        });

        it('navigates to saved route with default storage key', async () => {
          await restoreLastRoute(mockRouter, {});

          expect(getStorageValue).toHaveBeenCalledWith(defaultStorageKey);
          expect(mockRouter.push).toHaveBeenCalledWith(mockRouteState);
        });

        it('navigates to saved route with custom storage key', async () => {
          await restoreLastRoute(mockRouter, { storageKey: 'custom_key' });

          expect(getStorageValue).toHaveBeenCalledWith('custom_key');
          expect(mockRouter.push).toHaveBeenCalledWith(mockRouteState);
        });

        it('navigates to saved route with custom context', async () => {
          await restoreLastRoute(mockRouter, { context: 'custom_context' });

          expect(getStorageValue).toHaveBeenCalledWith(`${defaultStorageKey}_custom_context`);
          expect(mockRouter.push).toHaveBeenCalledWith(mockRouteState);
        });
      });

      describe('without saved route', () => {
        beforeEach(() => {
          getStorageValue.mockReturnValue({
            exists: false,
            value: null,
          });
        });

        describe('when agentic is available', () => {
          beforeEach(async () => {
            await restoreLastRoute(mockRouter, { isAgenticAvailable: true });
          });

          it('reads from the default storage key', () => {
            expect(getStorageValue).toHaveBeenCalledWith(defaultStorageKey);
          });

          it('navigates to agentic route', () => {
            expect(mockRouter.push).toHaveBeenCalledWith({ name: AGENTIC_CHAT_SHOW_ROUTE });
          });
        });

        describe('when agentic is not available', () => {
          beforeEach(async () => {
            await restoreLastRoute(mockRouter, { isAgenticAvailable: false });
          });

          it('reads from the default storage key', () => {
            expect(getStorageValue).toHaveBeenCalledWith(defaultStorageKey);
          });

          it('navigates to classic route', () => {
            expect(mockRouter.push).toHaveBeenCalledWith({ name: CLASSIC_CHAT_SHOW_ROUTE });
          });
        });

        describe('when a custom default route is specified', () => {
          beforeEach(async () => {
            await restoreLastRoute(mockRouter, { defaultRoute: 'custom_route' });
          });

          it('reads from the default storage key', () => {
            expect(getStorageValue).toHaveBeenCalledWith(defaultStorageKey);
          });

          it('navigates to the custom route', () => {
            expect(mockRouter.push).toHaveBeenCalledWith({ name: 'custom_route' });
          });
        });
      });
    });

    describe('when target route matches current route', () => {
      beforeEach(() => {
        getStorageValue.mockReturnValue({ exists: true, value: mockRouteState });
        mockRouter.currentRoute = {
          name: mockRouteState.name,
          params: mockRouteState.params,
        };
      });

      it('does not call router.push', async () => {
        await restoreLastRoute(mockRouter, {});

        expect(mockRouter.push).not.toHaveBeenCalled();
      });

      it('resolves successfully', async () => {
        await expect(restoreLastRoute(mockRouter, {})).resolves.toBeUndefined();
      });
    });

    describe('when target route name matches but params differ', () => {
      beforeEach(() => {
        getStorageValue.mockReturnValue({ exists: true, value: mockRouteState });
        mockRouter.currentRoute = {
          name: mockRouteState.name,
          params: { id: '456' },
        };
        mockRouter.push.mockResolvedValue();
      });

      it('calls router.push with the saved route', async () => {
        await restoreLastRoute(mockRouter, {});

        expect(mockRouter.push).toHaveBeenCalledWith(mockRouteState);
      });
    });

    describe('failed navigation', () => {
      beforeEach(() => {
        getStorageValue.mockReturnValue({ exists: true, value: mockRouteState });
        mockRouter.push.mockRejectedValueOnce(new Error('Navigation failed'));
        mockRouter.push.mockResolvedValueOnce();
      });

      describe('when agentic is available', () => {
        beforeEach(async () => {
          await restoreLastRoute(mockRouter, { isAgenticAvailable: true });
        });

        it('attempts the saved route first', () => {
          expect(mockRouter.push).toHaveBeenCalledWith(mockRouteState);
        });

        it('falls back to agentic route', () => {
          expect(mockRouter.push).toHaveBeenCalledWith({ name: AGENTIC_CHAT_SHOW_ROUTE });
        });

        it('clears the stored route state', () => {
          expect(removeStorageValue).toHaveBeenCalledWith(defaultStorageKey);
        });
      });

      describe('when agentic is not available', () => {
        beforeEach(async () => {
          await restoreLastRoute(mockRouter, { isAgenticAvailable: false });
        });

        it('attempts the saved route first', () => {
          expect(mockRouter.push).toHaveBeenCalledWith(mockRouteState);
        });

        it('falls back to classic route', () => {
          expect(mockRouter.push).toHaveBeenCalledWith({ name: CLASSIC_CHAT_SHOW_ROUTE });
        });

        it('clears the stored route state', () => {
          expect(removeStorageValue).toHaveBeenCalledWith(defaultStorageKey);
        });
      });

      describe('when using a custom context with agentic available', () => {
        beforeEach(async () => {
          await restoreLastRoute(mockRouter, {
            context: 'text_context',
            isAgenticAvailable: true,
          });
        });

        it('attempts the saved route first', () => {
          expect(mockRouter.push).toHaveBeenCalledWith(mockRouteState);
        });

        it('falls back to agentic route', () => {
          expect(mockRouter.push).toHaveBeenCalledWith({ name: AGENTIC_CHAT_SHOW_ROUTE });
        });

        it('clears the context-specific stored route state', () => {
          expect(removeStorageValue).toHaveBeenCalledWith(`${defaultStorageKey}_text_context`);
        });
      });

      describe('when a custom default route is specified', () => {
        beforeEach(async () => {
          await restoreLastRoute(mockRouter, { defaultRoute: 'custom_route' });
        });

        it('attempts the saved route first', () => {
          expect(mockRouter.push).toHaveBeenCalledWith(mockRouteState);
        });

        it('falls back to the custom route', () => {
          expect(mockRouter.push).toHaveBeenCalledWith({ name: 'custom_route' });
        });

        it('clears the stored route state', () => {
          expect(removeStorageValue).toHaveBeenCalledWith(defaultStorageKey);
        });
      });
    });
  });

  describe('setupNavigationGuards', () => {
    const setupGuard = (options = {}) => {
      setupNavigationGuards({
        router: mockRouter,
        ...options,
      });
      return mockRouter.afterEach.mock.calls[0][0];
    };

    it('sets up afterEach guard', () => {
      setupGuard();
      expect(mockRouter.afterEach).toHaveBeenCalledWith(expect.any(Function));
    });

    describe('guard behavior', () => {
      let guardFunction;

      beforeEach(() => {
        guardFunction = setupGuard();
      });

      it('saves route state when called', () => {
        guardFunction(mockRoute);
        expect(saveStorageValue).toHaveBeenCalledWith(defaultStorageKey, mockRouteState);
      });

      it('saves route state for routes outside agent sessions', () => {
        const otherRoute = { name: 'other_route', params: { id: '123' }, path: '/other-path/123' };
        const expectedState = { name: 'other_route', params: { id: '123' } };

        guardFunction(otherRoute);
        expect(saveStorageValue).toHaveBeenCalledWith(defaultStorageKey, expectedState);
      });
    });

    describe('configuration options', () => {
      it.each([
        {
          name: 'uses custom context storage key for custom context',
          options: { context: 'test_context' },
          expectedKey: `${defaultStorageKey}_test_context`,
        },
        {
          name: 'uses custom storage key when provided',
          options: { storageKey: 'custom_session_key' },
          expectedKey: 'custom_session_key',
        },
        {
          name: 'uses default storage key by default',
          options: {},
          expectedKey: defaultStorageKey,
        },
      ])('$name', ({ options, expectedKey }) => {
        const guardFunction = setupGuard(options);

        guardFunction(mockRoute);

        expect(saveStorageValue).toHaveBeenCalledWith(expectedKey, mockRouteState);
      });
    });
  });

  describe('trackTabRoutes', () => {
    it('stores route path for active tab', () => {
      duoChatGlobalState.activeTab = 'sessions';

      trackTabRoutes({ path: '/agent-sessions/123' });

      expect(duoChatGlobalState.lastRoutePerTab.sessions).toBe('/agent-sessions/123');
    });

    it('updates route when navigating within same tab', () => {
      duoChatGlobalState.activeTab = 'sessions';

      trackTabRoutes({ path: '/agent-sessions/123' });
      trackTabRoutes({ path: '/agent-sessions/456' });

      expect(duoChatGlobalState.lastRoutePerTab.sessions).toBe('/agent-sessions/456');
    });

    it('tracks routes independently for different tabs', () => {
      duoChatGlobalState.activeTab = 'sessions';
      trackTabRoutes({ path: '/agent-sessions/123' });

      duoChatGlobalState.activeTab = 'chat';
      trackTabRoutes({ path: '/chat-route' });

      expect(duoChatGlobalState.lastRoutePerTab).toEqual({
        sessions: '/agent-sessions/123',
        chat: '/chat-route',
      });
    });

    it('does not store route when no active tab', () => {
      duoChatGlobalState.activeTab = null;

      trackTabRoutes({ path: '/agent-sessions/123' });

      expect(duoChatGlobalState.lastRoutePerTab).toEqual({});
    });

    it('does not store route when path is missing', () => {
      duoChatGlobalState.activeTab = 'sessions';

      trackTabRoutes({ path: null });

      expect(duoChatGlobalState.lastRoutePerTab).toEqual({});
    });
  });
});
