import Vue from 'vue';
// eslint-disable-next-line no-restricted-imports
import Vuex from 'vuex';
import VueApollo from 'vue-apollo';
import { rest } from 'msw';
import { waitFor } from '@testing-library/vue';
import { duoChatGlobalState } from '~/super_sidebar/state';
import { CHAT_MODES } from '~/super_sidebar/constants';
import { saveSessionStorageValue } from '~/lib/utils/local_storage';
import { DUO_CURRENT_WORKFLOW_STORAGE_KEY } from 'ee/ai/constants';
import { createApolloProvider } from 'ee/ai/graphql';
import DuoAgenticChatStateManager from 'ee/ai/duo_agentic_chat/components/duo_agentic_chat_state_manager.vue';
import storeMutations from 'ee/ai/tanuki_bot/store/mutations';
import * as storeActions from 'ee/ai/tanuki_bot/store/actions';
import { fullMount, getText } from 'jest/msw_integration/test_helpers';
import { server } from 'jest/msw_integration/server';
import { MOCK_WORKFLOW_NUMERIC_ID, fixtures } from '../handlers/duo_agentic_chat';

// The websocket worker is not under test here — we only exercise the
// GraphQL hydration path. Stub at the module level the same way the
// existing duo_agentic_chat_state_manager_spec.js does.
jest.mock('ee/ai/duo_agentic_chat/websocket/stream_manager', () => ({
  connect: jest.fn(),
  disconnect: jest.fn(),
  send: jest.fn(),
  subscribe: jest.fn().mockImplementation(() => ({ dispose: jest.fn() })),
  getStatus: jest.fn().mockReturnValue({ connected: false, bufferedCount: 0 }),
  terminate: jest.fn(),
}));

jest.mock('ee/ai/duo_agentic_chat/events/event_hub', () => ({
  initDuoAgenticChatEventHub: jest.fn().mockReturnValue({ dispose: jest.fn() }),
  subscribeToEvent: jest.fn().mockReturnValue({ dispose: jest.fn() }),
}));

jest.mock('ee/ai/duo_agentic_chat/observability/events_tracker', () => ({
  EventsTracker: {
    updateContext: jest.fn(),
    trackApproveTool: jest.fn(),
    trackDenyTool: jest.fn(),
    trackClickThroughFlowWidget: jest.fn(),
    reset: jest.fn(),
  },
}));

jest.mock('ee/ai/duo_agentic_chat/observability/sentry_utils');

// NOTE: we intentionally do NOT mock `workflow_utils`, `apollo_utils`,
// or `chat_thread_snapshot`. These are the modules whose real behaviour
// the spec is exercising.

Vue.use(Vuex);
Vue.use(VueApollo);

const provideStub = {
  badgeType: 'beta',
  chatConfiguration: {
    title: 'GitLab Duo Agentic Chat',
    isClassicAvailable: false,
    defaultProps: {
      defaultNamespaceSelected: true,
    },
  },
  activeTabData: {
    props: {
      isClassicAvailable: false,
      userId: null,
    },
  },
  duoUiNext: false,
};

const actionSpies = {
  addDuoChatMessage: jest.fn((context, message) => {
    storeActions.addDuoChatMessage(context, message);
  }),
  setMessages: jest.fn((context, messages = []) => {
    context.commit('CLEAN_MESSAGES');
    messages?.forEach((msg) => storeActions.addDuoChatMessage(context, msg));
  }),
  setCurrentAgent: jest.fn((context, agent) => {
    storeActions.setCurrentAgent(context, agent);
  }),
};

const createStore = () =>
  new Vuex.Store({
    mutations: storeMutations,
    actions: actionSpies,
    state: {
      messages: [],
      toolMessage: '',
      currentAgent: null,
    },
  });

describe('Duo Agentic Chat | hydrating a thread through real Apollo', () => {
  let wrapper;
  let store;
  let apolloProvider;

  const mountStateManager = () => {
    store = createStore();
    apolloProvider = createApolloProvider();

    wrapper = fullMount(DuoAgenticChatStateManager, {
      store,
      apolloProvider,
      propsData: {
        mode: 'active',
        exploreAiCatalogPath: '/-/ai/catalog',
      },
      provide: provideStub,
      mocks: {
        $router: { push: jest.fn() },
      },
    });
  };

  beforeEach(() => {
    // The ai_duo_panel handler also registers a getWorkflowLatestCheckpoint
    // handler and runs earlier in the chain, so it would otherwise serve
    // its own placeholder workflow for this test. Override with our fixture
    // for the duration of this spec.
    server.use(
      rest.post('http://test.host/api/graphql', (req, res, ctx) => {
        const body = typeof req.body === 'string' ? JSON.parse(req.body) : req.body;
        if (body.operationName === 'getWorkflowLatestCheckpoint') {
          return res(ctx.json(fixtures.getWorkflowLatestCheckpoint));
        }
        // hydrateActiveWorkflow now gates on the thread appearing in the
        // agenticWorkflows list before loading it; serve the generated
        // getUserWorkflows fixture (same workflow factory, so the node id
        // matches MOCK_WORKFLOW_GID) so the thread is found and hydrated.
        if (body.operationName === 'getUserWorkflows') {
          return res(ctx.json(fixtures.getUserWorkflows));
        }
        return undefined;
      }),
    );

    // The state manager picks up workflowId from sessionStorage on mount and
    // hydrates that thread; seed it so hydrateActiveWorkflow runs against
    // our MSW fixture.
    saveSessionStorageValue(DUO_CURRENT_WORKFLOW_STORAGE_KEY, {
      workflowId: MOCK_WORKFLOW_NUMERIC_ID,
    });
    duoChatGlobalState.chatMode = CHAT_MODES.AGENTIC;
  });

  afterEach(() => {
    wrapper?.destroy();
    wrapper = undefined;
    window.sessionStorage.clear();
    duoChatGlobalState.chatMode = null;
  });

  it('renders the hydrated conversation with parsed tool_info and per-message context items', async () => {
    mountStateManager();

    // Wait for hydrateActiveWorkflow to render the six fixture messages
    // (user-A, agent-A, tool-C, tool-D, user-B, agent-B). Both markers
    // below come from the conversation content — once they appear, the
    // tool message and both users' context tokens have all rendered.
    await waitFor(() => {
      // Regression #1 — `5dcff523`: `toolInfo` arrives from GraphQL as a
      // JSON string and `WorkflowUtils.normalizeDuoMessages` must parse it
      // into an object. The tool-message template (`message_tool.vue`)
      // reads `tool_info.name` and translates it through
      // `tool_message_registry` into a user-visible label — `gitlab_api_get`
      // becomes "Queried GitLab". Without the JSON.parse, `tool_info` is a
      // raw string, `tool_info.name` is `undefined`, and the readable
      // label never reaches the DOM.
      expect(getText(document.body)).toContain('Queried GitLab');

      // Regression #2 — `0c04847116`: Apollo's default `__typename:id`
      // normalisation would collapse the two messages'
      // `chat-rules-user-instructions` entries (same id) into a single
      // shared cache slot. User-A's chat-rules item has
      // `metadata.title: "chat-rules.md"`; user-B's has
      // `metadata.title: "Ignore previous chat-rules.md"` (the "ignore
      // previous" marker that fires when a previously injected file is
      // missing from the next project's repository). Without the
      // `AiAdditionalContext: { keyFields: false }` typePolicy in
      // `ee/app/assets/javascripts/ai/graphql/index.js`, user-B's metadata
      // is overwritten by user-A's and the "Ignore previous" title never
      // reaches the DOM.
      expect(getText(document.body)).toContain('Ignore previous chat-rules.md');
    });
  });
});
