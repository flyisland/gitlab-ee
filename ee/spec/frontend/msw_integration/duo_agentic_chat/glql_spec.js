import Vue from 'vue';
// eslint-disable-next-line no-restricted-imports
import Vuex from 'vuex';
import VueApollo from 'vue-apollo';
import { waitFor } from '@testing-library/vue';
import { createApolloProvider } from 'ee/ai/graphql';
import DuoAgenticChatStateManager from 'ee/ai/duo_agentic_chat/components/duo_agentic_chat_state_manager.vue';
import storeMutations from 'ee/ai/tanuki_bot/store/mutations';
import * as storeActions from 'ee/ai/tanuki_bot/store/actions';
import { fullMount } from 'jest/msw_integration/test_helpers';

// Regression coverage for GLQL embedded views failing to render in Duo
// (agentic) Chat while a response streams in — they only mounted after a full
// page reload.
//
// The whole point of this spec is to exercise the *real* markdown → renderGFM →
// GLQL facade pipeline, so we deliberately do NOT mock `render_gfm`,
// `workflow_utils`, or `messages_utils`. Only the websocket transport is stubbed.

// The stream worker is not under test. Stub the transport at the module level
// and capture the subscribed callbacks so the spec can push a checkpoint the
// same way the worker would.
const mockSubscribers = {};
jest.mock('ee/ai/duo_agentic_chat/websocket/stream_manager', () => ({
  connect: jest.fn(),
  disconnect: jest.fn(),
  send: jest.fn(),
  subscribe: jest.fn((eventType, callback) => {
    mockSubscribers[eventType] = callback;
    return { dispose: jest.fn() };
  }),
  getStatus: jest.fn().mockReturnValue({ connected: false, bufferedCount: 0 }),
  terminate: jest.fn(),
}));

Vue.use(Vuex);
Vue.use(VueApollo);

const GOAL = 'Show me a GLQL view of my issues';

// A markdown reply carrying a fenced GLQL block. This is what the assistant
// streams back; the facade must mount from it without a page reload.
const AGENT_MARKDOWN = [
  'Here are your open issues:',
  '',
  '```glql',
  'assignee = currentUser()',
  '```',
  '',
].join('\n');

const buildCheckpointEvent = (uiChatLog, status = 'success') => ({
  type: 'message',
  data: JSON.stringify({
    newCheckpoint: {
      checkpoint: JSON.stringify({ channel_values: { ui_chat_log: uiChatLog } }),
      status,
      goal: GOAL,
    },
  }),
});

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

const createStore = () =>
  new Vuex.Store({
    mutations: storeMutations,
    actions: storeActions,
    state: {
      messages: [],
      toolMessage: '',
      currentAgent: null,
    },
  });

describe('Duo Agentic Chat | rendering a GLQL view from a streamed message', () => {
  let wrapper;

  const mountStateManager = () => {
    wrapper = fullMount(DuoAgenticChatStateManager, {
      store: createStore(),
      apolloProvider: createApolloProvider(),
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

  afterEach(() => {
    wrapper?.destroy();
    wrapper = undefined;
  });

  it('mounts the GLQL facade from the streamed assistant message', async () => {
    mountStateManager();

    // The state manager subscribes to the stream on mount; push a completed
    // checkpoint whose ui_chat_log carries the user prompt and the assistant's
    // markdown reply with the GLQL block.
    await waitFor(() => expect(typeof mockSubscribers.message).toBe('function'));

    mockSubscribers.message(
      buildCheckpointEvent([
        {
          message_id: 'msg-user-1',
          message_type: 'user',
          content: GOAL,
          timestamp: '2026-07-07T00:00:00.000Z',
        },
        {
          message_id: 'msg-agent-1',
          message_type: 'agent',
          content: AGENT_MARKDOWN,
          timestamp: '2026-07-07T00:00:01.000Z',
        },
      ]),
    );

    // renderGFM detects the `.language-glql` block and mounts the facade via a
    // dynamic import; waitFor polls until it resolves.
    await waitFor(() => {
      expect(document.querySelector('[data-testid="glql-facade"]')).not.toBeNull();
    });
  });
});
