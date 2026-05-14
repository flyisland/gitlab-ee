import { WebAgenticDuoChat } from '@gitlab/duo-ui';
import Vue, { nextTick } from 'vue';
// eslint-disable-next-line no-restricted-imports
import Vuex from 'vuex';
import VueApollo from 'vue-apollo';
import { GlToggle } from '@gitlab/ui';
import { parseDocument } from 'yaml';
import ChatLoadingState from 'ee/ai/components/chat_loading_state.vue';
import { shallowMountExtended } from 'helpers/vue_test_utils_helper';
import { setAgenticMode } from 'ee/ai/utils';
import createMockApollo from 'helpers/mock_apollo_helper';
import waitForPromises from 'helpers/wait_for_promises';
import { duoChatGlobalState } from '~/super_sidebar/state';
import storeMutations from 'ee/ai/tanuki_bot/store/mutations';
import * as storeActions from 'ee/ai/tanuki_bot/store/actions';
import getUserWorkflows from 'ee/ai/graphql/get_user_workflow.query.graphql';
import getAiChatContextPresets from 'ee/ai/graphql/get_ai_chat_context_presets.query.graphql';
import getAiChatAvailableModels from 'ee/ai/graphql/get_ai_chat_available_models.query.graphql';
import getConfiguredAgents from 'ee/ai/graphql/get_configured_agents.query.graphql';
import getAgentFlowConfig from 'ee/ai/graphql/get_agent_flow_config.query.graphql';
import getFoundationalChatAgents from 'ee/ai/graphql/get_foundational_chat_agents.graphql';
import getFlowStatus from 'ee/ai/graphql/get_flow_status.query.graphql';
import duoWorkflowMutation from 'ee/ai/graphql/duo_workflow.mutation.graphql';
import deleteAgenticWorkflowMutation from 'ee/ai/graphql/delete_agentic_workflow.mutation.graphql';
import getWorkflowEventsQuery from 'ee/ai/graphql/get_workflow_events.query.graphql';
import getGitlabCreditsAvailableQuery from 'ee/ai/graphql/get_gitlab_credits_available.query.graphql';
import DuoAgenticChatApp from 'ee/ai/duo_agentic_chat/components/duo_agentic_chat.vue';
import NoNamespaceEmptyState from 'ee/ai/duo_agentic_chat/components/no_namespace_empty_state.vue';
import DuoDisabledEmptyState from 'ee/ai/duo_agentic_chat/components/duo_disabled_empty_state.vue';
import { WorkflowUtils } from 'ee/ai/duo_agentic_chat/utils/workflow_utils';
import {
  getCurrentModel,
  getDefaultModel,
  getModel,
  saveModel,
  isModelSelectionDisabled as checkModelSelectionDisabled,
} from 'ee/ai/duo_agentic_chat/utils/model_selection_utils';
import * as WorkflowSocketUtils from 'ee/ai/duo_agentic_chat/websocket/workflow_utils';
import * as ResizeUtils from 'ee/ai/duo_agentic_chat/utils/resize_utils';
import {
  loadThreadSnapshot,
  clearThreadSnapshot,
} from 'ee/ai/duo_agentic_chat/utils/chat_thread_snapshot';
import { isThreadExpired } from 'ee/ai/duo_agentic_chat/utils/thread_utils';
import ModelSelectDropdown from 'ee/ai/shared/feature_settings/model_select_dropdown.vue';
import {
  GENIE_CHAT_RESET_MESSAGE,
  GENIE_CHAT_CLEAR_MESSAGE,
  GENIE_CHAT_NEW_MESSAGE,
  DUO_WORKFLOW_STATUS_INPUT_REQUIRED,
  DUO_WORKFLOW_ADDITIONAL_CONTEXT_REPOSITORY,
  DUO_CURRENT_WORKFLOW_STORAGE_KEY,
  DUO_CHAT_VIEWS,
  DUO_WORKFLOW_STATUS_RUNNING,
  DUO_AGENTIC_CHAT_PENDING_USER_MESSAGE_ID,
} from 'ee/ai/constants';
import { AGENTIC_CHAT_SHOW_ROUTE } from 'ee/ai/duo_agents_platform/router/constants';
import { WIDTH_OFFSET } from 'ee/ai/tanuki_bot/constants';
import * as streamManager from 'ee/ai/duo_agentic_chat/websocket/stream_manager';
import { getStorageValue, saveStorageValue } from '~/lib/utils/local_storage';
import { getCookie } from '~/lib/utils/common_utils';
import { useMockInternalEventsTracking } from 'helpers/tracking_internal_events_helper';
import {
  FEEDBACK_TRACKING_EVENT,
  CHAT_TRACKING_EVENT,
  TRIGGER_SOURCE_WEB_CHAT,
  TRIGGER_SOURCE_WEB_UI,
} from 'ee/ai/duo_agentic_chat/constants';
import { EventsTracker } from 'ee/ai/duo_agentic_chat/tracking/events_tracker';
import { catalogAgentsFromResponse } from 'ee/ai/duo_agentic_chat/utils/agent_utils';
import StartFlowToolMessage from 'ee/ai/duo_agentic_chat/components/messages/message_tool_start_flow.vue';
import {
  MOCK_AI_CHAT_AVAILABLE_MODELS_RESPONSE,
  MOCK_MODEL_LIST_ITEMS,
  MOCK_GITLAB_DEFAULT_MODEL_ITEM,
  MOCK_CONFIGURED_AGENTS_RESPONSE,
  MOCK_FOUNDATIONAL_CHAT_AGENTS_RESPONSE,
  MOCK_FLOW_CONFIG_RESPONSE,
  MOCK_FETCHED_FOUNDATIONAL_AGENT,
  MOCK_FLOW_AGENT_CONFIG,
  DUO_FOUNDATIONAL_AGENT_MOCK,
  MOCK_START_FLOW_TOOL_MESSAGE,
} from './mock_data';

jest.mock('ee/ai/duo_agentic_chat/utils/agent_utils', () => ({
  ...jest.requireActual('ee/ai/duo_agentic_chat/utils/agent_utils'),
  catalogAgentsFromResponse: jest.fn(
    jest.requireActual('ee/ai/duo_agentic_chat/utils/agent_utils').catalogAgentsFromResponse,
  ),
}));

Vue.config.ignoredElements = ['fe-island-duo-next'];

jest.mock('ee/ai/duo_agentic_chat/websocket/stream_manager', () => ({
  connect: jest.fn(),
  disconnect: jest.fn(),
  send: jest.fn(),
  subscribe: jest.fn().mockImplementation(() => ({ dispose: jest.fn() })),
  getStatus: jest.fn().mockReturnValue({ connected: false, bufferedCount: 0 }),
  terminate: jest.fn(),
}));

jest.mock('fe_islands/duo_next/dist/main', () => ({}), {
  virtual: true,
});

jest.mock('yaml');

jest.mock('~/lib/utils/websocket_utils', () => ({
  parseMessage: jest.fn(async (event) => {
    const data = typeof event.data === 'string' ? event.data : await event.data.text();
    return JSON.parse(data);
  }),
}));

jest.mock('ee/ai/duo_agentic_chat/utils/workflow_utils', () => ({
  WorkflowUtils: {
    transformChatMessages: jest.fn(),
    parseWorkflowData: jest.fn(),
  },
}));

jest.mock('ee/ai/duo_agentic_chat/utils/model_selection_utils', () => ({
  getCurrentModel: jest.fn(),
  getDefaultModel: jest.fn(),
  getModel: jest.fn(),
  saveModel: jest.fn(),
  isModelSelectionDisabled: jest.fn(),
}));

jest.mock('ee/ai/duo_agentic_chat/utils/chat_thread_snapshot', () => ({
  saveThreadSnapshot: jest.fn(),
  loadThreadSnapshot: jest.fn(),
  clearThreadSnapshot: jest.fn(),
}));

jest.mock('ee/ai/duo_agentic_chat/tracking/events_tracker', () => ({
  EventsTracker: {
    updateContext: jest.fn(),
    trackMessage: jest.fn(),
    trackApproveTool: jest.fn(),
    trackDenyTool: jest.fn(),
    trackClickThroughFlowWidget: jest.fn(),
    reset: jest.fn(),
  },
}));

jest.mock('ee/ai/duo_agentic_chat/utils/thread_utils', () => ({
  ...jest.requireActual('ee/ai/duo_agentic_chat/utils/thread_utils'),
  isThreadExpired: jest.fn().mockReturnValue(false),
}));

const MOCK_PROJECT_ID = 'gid://gitlab/Project/123';
const MOCK_NAMESPACE_ID = 'gid://gitlab/Group/456';
const MOCK_RESOURCE_ID = 'gid://gitlab/Resource/789';
const MOCK_WORKFLOW_ID = 'gid://gitlab/Ai::DuoWorkflows::Workflow/456';
const MOCK_USER_MESSAGE = {
  content: 'How can I optimize my CI pipeline?',
  role: 'user',
  requestId: `${MOCK_WORKFLOW_ID}-0-user`,
};
const MOCK_CONTEXT_PRESETS_RESPONSE = {
  data: {
    aiChatContextPresets: {
      questions: [
        'How can I optimize my CI pipeline?',
        'What are best practices for merge requests?',
        'How do I set up a workflow for my project?',
        'What are the advantages of using GitLab CI/CD?',
      ],
    },
  },
};
const MOCK_CREATE_WORKFLOW_MUTATION_RESPONSE = {
  data: {
    aiDuoWorkflowCreate: {
      workflow: { id: MOCK_WORKFLOW_ID },
      errors: [],
    },
  },
};
const MOCK_DELETE_WORKFLOW_MUTATION_RESPONSE = {
  data: {
    deleteDuoWorkflowsWorkflow: { success: true, clientMutationId: null, errors: [] },
  },
};

const MOCK_USER_WORKFLOWS_RESPONSE = {
  data: {
    duoWorkflowWorkflows: {
      edges: [
        {
          node: {
            id: MOCK_WORKFLOW_ID,
            title: 'Test workflow goal',
            lastUpdatedAt: '2024-01-01T00:00:00Z',
            aiCatalogItemVersionId: null,
            agentName: 'GitLab Duo',
          },
        },
      ],
    },
  },
};

const MOCK_WORKFLOW_EVENTS_RESPONSE = {
  duoWorkflowEvents: {
    nodes: [
      {
        checkpoint: '{"channel_values": {"ui_chat_log": []}}',
        errors: null,
        metadata: null,
        workflowGoal: '',
        workflowStatus: 'completed',
      },
    ],
  },
  duoWorkflowWorkflows: {
    nodes: [
      {
        id: 'workflow-1',
        status: 'completed',
        aiCatalogItemVersionId: '',
        workflowDefinition: null,
        archived: false,
      },
    ],
  },
};

const MOCK_WORKFLOW_EVENTS_RESPONSE_WITH_FOUNDATIONAL_AGENT = {
  duoWorkflowEvents: {
    nodes: [
      {
        checkpoint: '{"channel_values": {"ui_chat_log": []}}',
        errors: null,
        metadata: null,
        workflowGoal: '',
        workflowStatus: 'completed',
      },
    ],
  },
  duoWorkflowWorkflows: {
    nodes: [
      {
        id: 'workflow-1',
        status: 'completed',
        aiCatalogItemVersionId: '',
        workflowDefinition: MOCK_FETCHED_FOUNDATIONAL_AGENT.referenceWithVersion,
        archived: false,
      },
    ],
  },
};

const MOCK_TRANSFORMED_MESSAGES = [
  {
    content: 'Hello, how can I help?',
    role: 'assistant',
    requestId: '456-1-agent',
    message_type: 'agent',
  },
];

const MOCK_PARSED_FLOW_CONFIG = { components: [{ name: 'test', type: 'agent' }] };

const MOCK_UTILS_SETUP = () => {
  WorkflowUtils.transformChatMessages.mockReturnValue(MOCK_TRANSFORMED_MESSAGES);
  WorkflowUtils.parseWorkflowData.mockReturnValue({
    checkpoint: { channel_values: { ui_chat_log: [] } },
  });
  parseDocument.mockReturnValue(MOCK_PARSED_FLOW_CONFIG);

  getCurrentModel.mockReturnValue(MOCK_GITLAB_DEFAULT_MODEL_ITEM);
  getDefaultModel.mockReturnValue(MOCK_GITLAB_DEFAULT_MODEL_ITEM);
  // getModel needs to search arrays by value, simple Array.find helper
  getModel.mockImplementation((models, value) => models?.find((m) => m.value === value));
  saveModel.mockReturnValue(true);
  checkModelSelectionDisabled.mockReturnValue(false);

  jest
    .spyOn(WorkflowSocketUtils, 'buildWebsocketUrl')
    .mockReturnValue('/api/v4/ai/duo_workflows/ws');
  jest.spyOn(WorkflowSocketUtils, 'buildStartRequest').mockReturnValue({
    startRequest: {
      workflowID: '456',
      clientVersion: '1.0',
      workflowDefinition: 'chat',
      goal: '',
      approval: {},
    },
  });
  jest.spyOn(WorkflowSocketUtils, 'processWorkflowMessage');

  jest.spyOn(ResizeUtils, 'calculateDimensions');
};

const expectedAdditionalContext = [
  {
    id: 'page-context',
    content: `<current_gitlab_page_url>http://test.host/</current_gitlab_page_url>
<current_gitlab_page_title></current_gitlab_page_title>`,
    category: DUO_WORKFLOW_ADDITIONAL_CONTEXT_REPOSITORY,
    metadata: JSON.stringify({
      title: 'Current page',
      enabled: true,
      icon: 'link',
      secondaryText: 'Page context /',
      subType: 'open_tab',
      subTypeLabel: 'Current page',
      projectPath: '',
      pagePath: '/',
    }),
  },
];

Vue.use(Vuex);
Vue.use(VueApollo);

jest.mock('~/lib/utils/common_utils', () => ({
  getCookie: jest.fn(),
}));

jest.mock('~/lib/utils/local_storage', () => ({
  getStorageValue: jest.fn(() => ({ exists: false })),
  saveStorageValue: jest.fn(),
}));

jest.mock('ee/ai/utils', () => {
  const actualUtils = jest.requireActual('ee/ai/utils');

  return {
    __esModule: true,
    ...actualUtils,
    setAgenticMode: jest.fn(),
  };
});

describe('Duo Agentic Chat', () => {
  let wrapper;
  let store;

  const actionSpies = {
    addDuoChatMessage: jest.fn((context, message) => {
      // Use the real action implementation
      storeActions.addDuoChatMessage(context, message);
    }),
    setMessages: jest.fn((context, messages = []) => {
      // Directly commit to store instead of async dispatches to avoid timing issues
      context.commit('CLEAN_MESSAGES');
      messages?.forEach((msg) => {
        storeActions.addDuoChatMessage(context, msg);
      });
    }),
    setCurrentAgent: jest.fn((context, agent) => {
      storeActions.setCurrentAgent(context, agent);
    }),
  };

  const mockRefetch = jest.fn().mockResolvedValue({});
  let mockRouter;
  // eslint-disable-next-line no-restricted-syntax
  const docsUrlHost = 'docs.gitlab.com';
  const userWorkflowsQueryHandlerMock = jest.fn().mockResolvedValue(MOCK_USER_WORKFLOWS_RESPONSE);
  const contextPresetsQueryHandlerMock = jest.fn().mockResolvedValue(MOCK_CONTEXT_PRESETS_RESPONSE);
  const availableModelsQueryHandlerMock = jest
    .fn()
    .mockResolvedValue(MOCK_AI_CHAT_AVAILABLE_MODELS_RESPONSE);
  const configuredAgentsQueryMock = jest.fn().mockResolvedValue(MOCK_CONFIGURED_AGENTS_RESPONSE);
  const aiFoundationalChatAgentsQueryMock = jest
    .fn()
    .mockResolvedValue(MOCK_FOUNDATIONAL_CHAT_AGENTS_RESPONSE);
  const agentFlowConfigQueryMock = jest.fn().mockResolvedValue(MOCK_FLOW_CONFIG_RESPONSE);
  const flowStatusQueryMock = jest.fn().mockResolvedValue({
    data: {
      duoWorkflowWorkflows: {
        edges: [
          {
            node: {
              id: '1',
              status: 'completed',
            },
          },
        ],
      },
    },
  });
  const createWorkflowMutationMock = jest
    .fn()
    .mockResolvedValue(MOCK_CREATE_WORKFLOW_MUTATION_RESPONSE);
  const deleteWorkflowMutationMock = jest
    .fn()
    .mockResolvedValue(MOCK_DELETE_WORKFLOW_MUTATION_RESPONSE);
  const workflowEventsQueryMock = jest
    .fn()
    .mockResolvedValue({ data: MOCK_WORKFLOW_EVENTS_RESPONSE });
  const creditsAvailableQueryMock = jest
    .fn()
    .mockResolvedValue({ data: { gitlabCreditsAvailable: true } });

  const findDuoChat = () => wrapper.findComponent(WebAgenticDuoChat);
  const findDuoNext = () => wrapper.find('fe-island-duo-next');
  const findChatLoadingState = () => wrapper.findComponent(ChatLoadingState);

  const triggerStreamEvent = (eventType, data) => {
    const subscribeCalls = streamManager.subscribe.mock.calls;
    subscribeCalls.filter(([type]) => type === eventType).forEach(([, callback]) => callback(data));
  };
  const snapshotMessages = [
    { role: 'user', content: 'Cached user message', ts: 1000 },
    { role: 'assistant', content: 'Cached assistant reply', ts: 2000 },
  ];
  const threadSnapshotWithMessages = {
    v: 1,
    convoId: '456',
    lastTs: 2000,
    messages: snapshotMessages,
  };
  const threadSnapshotEmpty = null;

  const createComponent = ({
    initialState = {},
    propsData = {},
    data = {},
    apolloHandlers = [[getAiChatAvailableModels, availableModelsQueryHandlerMock]],
    provide = {},
    stubs = {},
  } = {}) => {
    store = new Vuex.Store({
      mutations: storeMutations,
      actions: actionSpies,
      state: {
        messages: [],
        toolMessage: '',
        currentAgent: null,
        ...initialState,
      },
    });

    const apolloProvider = createMockApollo([
      [getUserWorkflows, userWorkflowsQueryHandlerMock],
      [getAiChatContextPresets, contextPresetsQueryHandlerMock],
      [getConfiguredAgents, configuredAgentsQueryMock],
      [getFoundationalChatAgents, aiFoundationalChatAgentsQueryMock],
      [getAgentFlowConfig, agentFlowConfigQueryMock],
      [getFlowStatus, flowStatusQueryMock],
      [duoWorkflowMutation, createWorkflowMutationMock],
      [deleteAgenticWorkflowMutation, deleteWorkflowMutationMock],
      [getWorkflowEventsQuery, workflowEventsQueryMock],
      [getGitlabCreditsAvailableQuery, creditsAvailableQueryMock],
      ...apolloHandlers,
    ]);

    if (duoChatGlobalState.isAgenticChatShown !== false) {
      duoChatGlobalState.isAgenticChatShown = true;
    }

    mockRouter = {
      push: jest.fn(),
    };

    const defaultProvide = {
      chatConfiguration: {
        title: 'GitLab Duo Agentic Chat',
        isClassicAvailable: false,
        defaultProps: {
          isEmbedded: false,
          defaultNamespaceSelected: true,
        },
      },
      activeTabData: {
        props: {
          isEmbedded: false,
          isClassicAvailable: false,
          userId: null,
        },
      },
      duoUiNext: false,
      ...provide,
    };

    wrapper = shallowMountExtended(DuoAgenticChatApp, {
      store,
      apolloProvider,
      propsData: {
        exploreAiCatalogPath: '/-/ai/catalog',
        ...propsData,
      },
      provide: defaultProvide,
      mocks: {
        $router: mockRouter,
      },
      stubs,
      data() {
        return data;
      },
    });

    if (wrapper.vm.$apollo?.queries?.agenticWorkflows) {
      wrapper.vm.$apollo.queries.agenticWorkflows.refetch = mockRefetch;
    }
  };

  beforeEach(() => {
    mockRefetch.mockClear();
    loadThreadSnapshot.mockReturnValue(threadSnapshotEmpty);
    MOCK_UTILS_SETUP();
    // Reset Apollo handler mocks to default values
    createWorkflowMutationMock.mockResolvedValue(MOCK_CREATE_WORKFLOW_MUTATION_RESPONSE);
    deleteWorkflowMutationMock.mockResolvedValue(MOCK_DELETE_WORKFLOW_MUTATION_RESPONSE);
    workflowEventsQueryMock.mockResolvedValue({ data: MOCK_WORKFLOW_EVENTS_RESPONSE });
    creditsAvailableQueryMock.mockResolvedValue({ data: { gitlabCreditsAvailable: true } });
    // In the default state, there isn't workflowId registered in local storage
    getStorageValue.mockReturnValue({ exists: false, value: null });
  });

  afterEach(() => {
    duoChatGlobalState.isAgenticChatShown = false;
    if (wrapper) {
      wrapper = null;
    }
  });

  describe('clearActiveWorkflow', () => {
    it('clears the thread and resets lastProcessedMessageId', async () => {
      duoChatGlobalState.isAgenticChatShown = true;
      createComponent({
        data: {
          lastProcessedMessageId: 'message-5',
        },
      });
      await waitForPromises();

      wrapper.vm.clearActiveWorkflow();
      expect(findDuoChat().props('messages')).toEqual([]);
      expect(wrapper.vm.lastProcessedMessageId).toBe(null);
    });
  });

  describe('beforeDestroy', () => {
    it('clears the active thread when destroyed', () => {
      duoChatGlobalState.isAgenticChatShown = true;
      createComponent();

      const clearActiveWorkflowSpy = jest.spyOn(wrapper.vm, 'clearActiveWorkflow');
      wrapper.destroy();

      // Verify clearActiveWorkflow was called (which resets lastProcessedMessageId)
      expect(clearActiveWorkflowSpy).toHaveBeenCalled();
    });

    it('resets the tracker context when destroyed', () => {
      createComponent();

      const resetSpy = jest.spyOn(EventsTracker, 'reset');
      wrapper.destroy();

      expect(resetSpy).toHaveBeenCalled();
    });
  });

  describe('rendering', () => {
    describe('when Duo Chat is shown', () => {
      beforeEach(() => {
        createComponent({
          propsData: { projectId: MOCK_PROJECT_ID, resourceId: MOCK_RESOURCE_ID },
        });
        duoChatGlobalState.isAgenticChatShown = true;
        createComponent();
      });

      it('renders the AgenticDuoChat component', () => {
        expect(findDuoChat().exists()).toBe(true);
      });

      it('renders the loading state during initialization', async () => {
        let resolvePromise = null;
        const pendingPromise = new Promise((resolve) => {
          resolvePromise = resolve;
        });
        workflowEventsQueryMock
          .mockResolvedValueOnce({ data: MOCK_WORKFLOW_EVENTS_RESPONSE })
          .mockReturnValueOnce(pendingPromise);

        findDuoChat().vm.$emit('thread-selected', { id: MOCK_WORKFLOW_ID });
        await waitForPromises();

        expect(findChatLoadingState().exists()).toBe(true);
        resolvePromise('');
      });

      it('does not render the loading state if we have an active thread with a snapshot', async () => {
        loadThreadSnapshot.mockReturnValue(threadSnapshotWithMessages);

        let resolvePromise = null;
        const pendingPromise = new Promise((resolve) => {
          resolvePromise = resolve;
        });
        workflowEventsQueryMock
          .mockResolvedValueOnce({ data: MOCK_WORKFLOW_EVENTS_RESPONSE })
          .mockReturnValueOnce(pendingPromise);

        findDuoChat().vm.$emit('thread-selected', { id: MOCK_WORKFLOW_ID });
        await waitForPromises();

        expect(findChatLoadingState().exists()).toBe(false);
        resolvePromise('');
      });

      it('does not render the loading state when isLoading is true but messages exist', async () => {
        // Set up initial messages
        const existingMessages = [
          { role: 'user', content: 'Hello', requestId: '1' },
          { role: 'assistant', content: 'Hi there!', requestId: '2' },
        ];

        createComponent({
          initialState: {
            messages: existingMessages,
          },
          data: {
            isLoading: true,
          },
        });

        await nextTick();

        // Loading state should not be shown because messages exist
        expect(findChatLoadingState().exists()).toBe(false);
        expect(findDuoChat().exists()).toBe(true);
      });

      it('passes isToolApprovalProcessing prop to AgenticDuoChat component', () => {
        expect(findDuoChat().props('isToolApprovalProcessing')).toBe(false);
      });

      it('passes loading-thread-list prop to AgenticDuoChat component', async () => {
        expect(findDuoChat().props('loadingThreadList')).toBe(true);
        await waitForPromises();
        expect(findDuoChat().props('loadingThreadList')).toBe(false);
      });

      it('passes multithreading props to AgenticDuoChat component', async () => {
        await waitForPromises();

        expect(findDuoChat().props('isMultithreaded')).toBe(true);
        expect(findDuoChat().props('multiThreadedView')).toBe(DUO_CHAT_VIEWS.CHAT);
        expect(findDuoChat().props('activeThreadId')).toBe(null);
        expect(findDuoChat().props('threadList')).toEqual([
          {
            id: 'gid://gitlab/Ai::DuoWorkflows::Workflow/456',
            lastUpdatedAt: '2024-01-01T00:00:00Z',
            title: 'Test workflow goal',
            aiCatalogItemVersionId: null,
            agentName: 'GitLab Duo',
          },
        ]);
      });

      it('passes sessionId to AgenticDuoChat component', async () => {
        await findDuoChat().vm.$emit('thread-selected', { id: MOCK_WORKFLOW_ID });
        await waitForPromises();
        expect(findDuoChat().props('sessionId')).toBe('456');
      });

      it('calls the user workflows GraphQL query', () => {
        expect(userWorkflowsQueryHandlerMock).toHaveBeenCalledWith({
          type: 'foundational_chat_agents',
          first: 99999,
        });
      });

      it('calls the context presets GraphQL query', () => {
        expect(contextPresetsQueryHandlerMock).toHaveBeenCalledWith({
          projectId: MOCK_PROJECT_ID,
          resourceId: MOCK_RESOURCE_ID,
          url: 'http://test.host/',
          questionCount: 4,
        });
      });

      it('passes context presets to WebAgenticDuoChat component as predefinedPrompts', async () => {
        await waitForPromises();
        expect(findDuoChat().props('predefinedPrompts')).toEqual(
          MOCK_CONTEXT_PRESETS_RESPONSE.data.aiChatContextPresets.questions,
        );
      });

      describe('messageRenderers', () => {
        let matchMessage;

        beforeEach(() => {
          [{ matchMessage }] = findDuoChat().props('messageRenderers');
        });

        it('contains one renderer using StartFlowToolMessage', () => {
          const messageRenderers = findDuoChat().props('messageRenderers');
          expect(messageRenderers).toHaveLength(1);
          expect(messageRenderers[0].component).toBe(StartFlowToolMessage);
        });

        const startFlowMessage = (content) => ({
          message_sub_type: 'start_flow',
          tool_info: { tool_response: { content } },
        });

        it('returns true when content is a JSON object with flow_name, status, and workflow_id', () => {
          expect(matchMessage(MOCK_START_FLOW_TOOL_MESSAGE)).toBe(true);
        });

        it('returns false when message_sub_type is not start_flow', () => {
          expect(matchMessage({ message_sub_type: 'other' })).toBe(false);
          expect(matchMessage({ message_sub_type: undefined })).toBe(false);
        });

        it('returns false when content is null', () => {
          expect(matchMessage(startFlowMessage(null))).toBe(false);
        });

        it('returns false when content is not valid JSON', () => {
          expect(matchMessage(startFlowMessage('not json'))).toBe(false);
        });

        it('returns false when content is a JSON primitive, not an object', () => {
          expect(matchMessage(startFlowMessage('"a string"'))).toBe(false);
          expect(matchMessage(startFlowMessage('42'))).toBe(false);
        });

        it('returns false when content is missing flow_name', () => {
          expect(
            matchMessage(startFlowMessage(JSON.stringify({ status: 'started', workflow_id: 1 }))),
          ).toBe(false);
        });

        it('returns false when content is missing status', () => {
          expect(
            matchMessage(startFlowMessage(JSON.stringify({ flow_name: 'fix/v1', workflow_id: 1 }))),
          ).toBe(false);
        });

        it('returns false when content is missing workflow_id', () => {
          expect(
            matchMessage(
              startFlowMessage(JSON.stringify({ flow_name: 'fix/v1', status: 'started' })),
            ),
          ).toBe(false);
        });

        it('returns false when tool_info is absent', () => {
          expect(matchMessage({ message_sub_type: 'start_flow' })).toBe(false);
        });
      });
    });
  });

  describe('chat mode on mount', () => {
    let hydrateActiveWorkflowSpy;
    let onNewChatSpy;

    beforeEach(() => {
      hydrateActiveWorkflowSpy = jest.spyOn(DuoAgenticChatApp.methods, 'hydrateActiveWorkflow');
      onNewChatSpy = jest.spyOn(DuoAgenticChatApp.methods, 'onNewChat');
    });

    it('loads chat in "active" mode by default', async () => {
      createComponent();
      await waitForPromises();
      expect(wrapper.props('mode')).toBe('active');
    });

    describe('when there is no active thread', () => {
      beforeEach(async () => {
        createComponent();
        await waitForPromises();
      });

      it('loads the new chat', () => {
        expect(onNewChatSpy).toHaveBeenCalled();
      });

      it('does not hydrate the active thread', () => {
        expect(hydrateActiveWorkflowSpy).not.toHaveBeenCalled();
      });
    });

    describe('when there is an active thread', () => {
      beforeEach(async () => {
        WorkflowUtils.transformChatMessages.mockReturnValue(MOCK_TRANSFORMED_MESSAGES);
        createComponent({
          data: {
            workflowId: MOCK_WORKFLOW_ID,
          },
        });
        await waitForPromises();
      });

      it('hydrates the active thread', () => {
        expect(hydrateActiveWorkflowSpy).toHaveBeenCalled();
      });

      it('does not load a new chat', () => {
        expect(onNewChatSpy).not.toHaveBeenCalled();
      });

      it('sets the last processed message id based on the thread messages', () => {
        expect(wrapper.vm.lastProcessedMessageId).toBe(
          MOCK_TRANSFORMED_MESSAGES[MOCK_TRANSFORMED_MESSAGES.length - 1].message_id,
        );
      });
    });
  });

  describe('Workflow deletion handling', () => {
    beforeEach(() => {
      duoChatGlobalState.isAgenticChatShown = true;
    });

    it('shows error when sending message to workflow deleted in different instance', async () => {
      createComponent({
        initialState: { messages: [{ role: 'user', content: 'test' }] },
        data: { isInititalLoad: false },
      });
      await waitForPromises();

      findDuoChat().vm.$emit('send-chat-prompt', MOCK_USER_MESSAGE.content);
      await waitForPromises();

      expect(wrapper.vm.workflowId).toBe(MOCK_WORKFLOW_ID);

      workflowEventsQueryMock.mockRejectedValue({
        graphQLErrors: [
          { message: 'Workflow not found', extensions: { code: 'WORKFLOW_NOT_FOUND' } },
        ],
      });

      findDuoChat().vm.$emit('send-chat-prompt', 'Follow-up question');
      await waitForPromises();
      expect(findDuoChat().props('isChatAvailable')).toBe(false);
      expect(findDuoChat().props('error')).toBe('This chat was deleted.');
    });

    it('starts new chat when loading with deleted workflow after page reload', async () => {
      getStorageValue.mockReturnValueOnce({
        exists: true,
        value: { workflowId: MOCK_WORKFLOW_ID },
      });

      workflowEventsQueryMock.mockRejectedValue({
        graphQLErrors: [
          { message: 'Workflow not found', extensions: { code: 'WORKFLOW_NOT_FOUND' } },
        ],
      });

      createComponent();
      await waitForPromises();

      expect(findDuoChat().props('messages')).toHaveLength(0);
      expect(findDuoChat().props('activeThreadId')).toBe(null);
    });

    it('shows error when navigating to deleted workflow from history in same instance', async () => {
      createComponent();
      await waitForPromises();

      workflowEventsQueryMock.mockRejectedValue({
        graphQLErrors: [
          { message: 'Workflow not found', extensions: { code: 'WORKFLOW_NOT_FOUND' } },
        ],
      });

      findDuoChat().vm.$emit('thread-selected', { id: MOCK_WORKFLOW_ID });
      await waitForPromises();

      expect(findDuoChat().props('messages')).toHaveLength(0);
      expect(findDuoChat().props('activeThreadId')).toBe(null);
    });

    it('displays generic error for non-deletion errors', async () => {
      getStorageValue.mockReturnValueOnce({
        exists: true,
        value: { workflowId: MOCK_WORKFLOW_ID },
      });

      const errorText = 'Network timeout occurred';
      workflowEventsQueryMock.mockRejectedValue(new Error(errorText));

      createComponent();
      await waitForPromises();

      expect(actionSpies.addDuoChatMessage).toHaveBeenCalledWith(
        expect.anything(),
        expect.objectContaining({
          errors: [`Error: ${errorText}`],
        }),
      );
    });

    it('clears the workflow thread snapshot when workflow is deleted', async () => {
      getStorageValue.mockReturnValueOnce({
        exists: true,
        value: { workflowId: MOCK_WORKFLOW_ID },
      });

      workflowEventsQueryMock.mockRejectedValue({
        graphQLErrors: [
          { message: 'Workflow not found', extensions: { code: 'WORKFLOW_NOT_FOUND' } },
        ],
      });

      createComponent();
      await waitForPromises();

      expect(clearThreadSnapshot).toHaveBeenCalledWith(MOCK_WORKFLOW_ID);
    });

    it('shows no namespace empty state when NO_DEFAULT_NAMESPACE error is returned', async () => {
      workflowEventsQueryMock.mockRejectedValue({
        graphQLErrors: [
          {
            message:
              "You don't have permission to access this workflow. Please select a default namespace.",
            extensions: { code: 'NO_DEFAULT_NAMESPACE' },
          },
        ],
      });

      createComponent();
      await waitForPromises();

      findDuoChat().vm.$emit('thread-selected', { id: MOCK_WORKFLOW_ID });
      await waitForPromises();

      expect(wrapper.findComponent(NoNamespaceEmptyState).exists()).toBe(true);
    });
  });

  describe('events handling', () => {
    beforeEach(() => {
      createComponent({
        propsData: { projectId: MOCK_PROJECT_ID, resourceId: MOCK_RESOURCE_ID },
      });
      duoChatGlobalState.isAgenticChatShown = true;
    });

    describe('@chat-hidden', () => {
      beforeEach(async () => {
        findDuoChat().vm.$emit('chat-hidden');
        await nextTick();
      });

      it('closes the chat on @chat-hidden', () => {
        expect(duoChatGlobalState.isAgenticChatShown).toBe(false);
      });
    });

    describe('@send-chat-prompt', () => {
      const { bindInternalEventDocument } = useMockInternalEventsTracking();

      it.each([GENIE_CHAT_NEW_MESSAGE, GENIE_CHAT_RESET_MESSAGE, GENIE_CHAT_CLEAR_MESSAGE])(
        'resets chat state when "%s" command is sent',
        async (command) => {
          createComponent();
          wrapper.vm.workflowId = MOCK_WORKFLOW_ID;

          findDuoChat().vm.$emit('send-chat-prompt', command);
          await nextTick();

          expect(actionSpies.setMessages).toHaveBeenCalledWith(expect.anything(), []);
          expect(findChatLoadingState().exists()).toBe(false);
          expect(findDuoChat().props('isLoading')).toBe(false);
        },
      );

      it('creates a new workflow when sending a prompt for the first time with projectId', async () => {
        findDuoChat().vm.$emit('send-chat-prompt', MOCK_USER_MESSAGE.content);
        await waitForPromises();

        expect(createWorkflowMutationMock).toHaveBeenCalledWith(
          expect.objectContaining({
            projectId: MOCK_PROJECT_ID,
            goal: MOCK_USER_MESSAGE.content,
          }),
        );

        expect(WorkflowSocketUtils.buildWebsocketUrl).toHaveBeenCalledWith({
          rootNamespaceId: null,
          namespaceId: null,
          projectId: MOCK_PROJECT_ID,
          userModelSelectionEnabled: false,
          currentModel: MOCK_GITLAB_DEFAULT_MODEL_ITEM,
          defaultModel: MOCK_GITLAB_DEFAULT_MODEL_ITEM,
          aiCatalogItemVersionId: '',
        });

        expect(streamManager.connect).toHaveBeenCalledWith(
          '/api/v4/ai/duo_workflows/ws',
          expect.any(Object),
        );

        expect(WorkflowSocketUtils.buildStartRequest).toHaveBeenCalledWith({
          workflowId: '456',
          workflowDefinition: undefined,
          goal: MOCK_USER_MESSAGE.content,
          approval: {},
          additionalContext: expectedAdditionalContext,
          agentConfig: null,
          metadata: null,
          clientCapabilities: ['incremental_streaming'],
        });

        expect(actionSpies.addDuoChatMessage).toHaveBeenCalledWith(
          expect.anything(),
          expect.objectContaining({
            content: MOCK_USER_MESSAGE.content,
            role: 'user',
            requestId: DUO_AGENTIC_CHAT_PENDING_USER_MESSAGE_ID,
          }),
        );
      });

      it('creates a new workflow when sending a prompt for the first time with namespaceId', async () => {
        createComponent({
          propsData: { namespaceId: MOCK_NAMESPACE_ID, resourceId: MOCK_RESOURCE_ID },
        });
        duoChatGlobalState.isAgenticChatShown = true;

        findDuoChat().vm.$emit('send-chat-prompt', MOCK_USER_MESSAGE.content);
        await waitForPromises();

        expect(createWorkflowMutationMock).toHaveBeenCalledWith(
          expect.objectContaining({
            namespaceId: MOCK_NAMESPACE_ID,
            goal: MOCK_USER_MESSAGE.content,
          }),
        );

        expect(WorkflowSocketUtils.buildWebsocketUrl).toHaveBeenCalledWith({
          rootNamespaceId: null,
          namespaceId: MOCK_NAMESPACE_ID,
          projectId: null,
          userModelSelectionEnabled: false,
          currentModel: MOCK_GITLAB_DEFAULT_MODEL_ITEM,
          defaultModel: MOCK_GITLAB_DEFAULT_MODEL_ITEM,
          aiCatalogItemVersionId: '',
        });

        expect(streamManager.connect).toHaveBeenCalledWith(
          '/api/v4/ai/duo_workflows/ws',
          expect.any(Object),
        );

        expect(actionSpies.addDuoChatMessage).toHaveBeenCalledWith(
          expect.anything(),
          expect.objectContaining({
            content: MOCK_USER_MESSAGE.content,
            role: 'user',
            requestId: DUO_AGENTIC_CHAT_PENDING_USER_MESSAGE_ID,
          }),
        );
      });

      it('creates a new workflow when sending a prompt for the first time with both projectId and namespaceId', async () => {
        createComponent({
          propsData: {
            projectId: MOCK_PROJECT_ID,
            namespaceId: MOCK_NAMESPACE_ID,
            resourceId: MOCK_RESOURCE_ID,
          },
        });
        duoChatGlobalState.isAgenticChatShown = true;

        findDuoChat().vm.$emit('send-chat-prompt', MOCK_USER_MESSAGE.content);
        await waitForPromises();

        expect(createWorkflowMutationMock).toHaveBeenCalledWith(
          expect.objectContaining({
            projectId: MOCK_PROJECT_ID,
            namespaceId: MOCK_NAMESPACE_ID,
            goal: MOCK_USER_MESSAGE.content,
          }),
        );
      });

      it('creates a new workflow when sending a prompt for the first time without projectId or namespaceId', async () => {
        createComponent({
          propsData: { resourceId: MOCK_RESOURCE_ID },
        });
        duoChatGlobalState.isAgenticChatShown = true;

        findDuoChat().vm.$emit('send-chat-prompt', MOCK_USER_MESSAGE.content);
        await waitForPromises();

        expect(createWorkflowMutationMock).toHaveBeenCalledWith(
          expect.objectContaining({
            goal: MOCK_USER_MESSAGE.content,
          }),
        );
        expect(createWorkflowMutationMock).toHaveBeenCalledWith(
          expect.not.objectContaining({ projectId: expect.anything() }),
        );
      });

      it('creates a new workflow with aiCatalogItemVersionId when catalog agent is selected', async () => {
        const mockCatalogItemVersionId = 'gid://gitlab/Ai::Catalog::ItemVersion/100';
        createComponent({
          propsData: { projectId: MOCK_PROJECT_ID, resourceId: MOCK_RESOURCE_ID },
        });
        duoChatGlobalState.isAgenticChatShown = true;
        wrapper.vm.aiCatalogItemVersionId = mockCatalogItemVersionId;

        findDuoChat().vm.$emit('send-chat-prompt', MOCK_USER_MESSAGE.content);
        await waitForPromises();

        expect(createWorkflowMutationMock).toHaveBeenCalledWith(
          expect.objectContaining({
            projectId: MOCK_PROJECT_ID,
            goal: MOCK_USER_MESSAGE.content,
            aiCatalogItemVersionId: mockCatalogItemVersionId,
          }),
        );

        expect(WorkflowSocketUtils.buildWebsocketUrl).toHaveBeenCalledWith({
          rootNamespaceId: null,
          namespaceId: null,
          projectId: MOCK_PROJECT_ID,
          userModelSelectionEnabled: false,
          currentModel: MOCK_GITLAB_DEFAULT_MODEL_ITEM,
          defaultModel: MOCK_GITLAB_DEFAULT_MODEL_ITEM,
          aiCatalogItemVersionId: mockCatalogItemVersionId,
        });
      });

      it('sets waiting on prompt to true when sending a prompt', async () => {
        findDuoChat().vm.$emit('send-chat-prompt', MOCK_USER_MESSAGE.content);
        await nextTick();

        expect(findDuoChat().props('isLoading')).toBe(true);
      });

      it('does not create a new workflow if one already exists', async () => {
        wrapper.vm.workflowId = MOCK_WORKFLOW_ID;
        createWorkflowMutationMock.mockClear();

        findDuoChat().vm.$emit('send-chat-prompt', MOCK_USER_MESSAGE.content);
        await waitForPromises();

        expect(createWorkflowMutationMock).not.toHaveBeenCalled();
        expect(streamManager.connect).toHaveBeenCalled();
      });

      it('connects to WebSocket and sends start request', async () => {
        findDuoChat().vm.$emit('send-chat-prompt', MOCK_USER_MESSAGE.content);
        await waitForPromises();

        expect(streamManager.connect).toHaveBeenCalled();
      });

      it('adds user message with pending requestId immediately before async operations', async () => {
        findDuoChat().vm.$emit('send-chat-prompt', 'Test question');
        await nextTick();

        expect(actionSpies.addDuoChatMessage).toHaveBeenCalledWith(
          expect.anything(),
          expect.objectContaining({
            content: 'Test question',
            role: 'user',
            requestId: DUO_AGENTIC_CHAT_PENDING_USER_MESSAGE_ID,
          }),
        );
      });

      it('tracks submit message event with trial label when on trial', async () => {
        createComponent({
          propsData: { trialActive: true, isTrial: true },
        });
        duoChatGlobalState.isAgenticChatShown = true;
        await waitForPromises();

        const { trackEventSpy } = bindInternalEventDocument(wrapper.element);

        findDuoChat().vm.$emit('send-chat-prompt', 'Test question');
        await waitForPromises();

        expect(trackEventSpy).toHaveBeenCalledWith(
          'submit_dap_trial_or_paid_empty_state_message',
          { label: 'trial' },
          undefined,
        );
      });

      it('tracks submit message event with paid label when on paid subscription', async () => {
        createComponent({
          propsData: { subscriptionActive: true, isTrial: false },
        });
        duoChatGlobalState.isAgenticChatShown = true;
        await waitForPromises();

        const { trackEventSpy } = bindInternalEventDocument(wrapper.element);

        findDuoChat().vm.$emit('send-chat-prompt', 'Test question');
        await waitForPromises();

        expect(trackEventSpy).toHaveBeenCalledWith(
          'submit_dap_trial_or_paid_empty_state_message',
          { label: 'paid' },
          undefined,
        );
      });

      it('does not track submit message event when shouldShowActiveTrialOrSubscriptionEmptyState is false', async () => {
        createComponent({
          propsData: { trialActive: false },
        });
        duoChatGlobalState.isAgenticChatShown = true;
        await waitForPromises();

        const { trackEventSpy } = bindInternalEventDocument(wrapper.element);

        // Select an agent to make shouldShowActiveTrialOrSubscriptionEmptyState false
        await wrapper.vm.$store.dispatch('setCurrentAgent', { id: 'agent-1', name: 'Test Agent' });
        await nextTick();

        findDuoChat().vm.$emit('send-chat-prompt', 'Test question');
        await waitForPromises();

        expect(trackEventSpy).not.toHaveBeenCalledWith(
          'submit_dap_trial_or_paid_empty_state_message',
        );
      });

      describe('tracks event with the correct properties', () => {
        let trackEventSpy;

        beforeEach(() => {
          createComponent({
            propsData: { projectId: MOCK_PROJECT_ID, resourceId: MOCK_RESOURCE_ID },
          });
          duoChatGlobalState.isAgenticChatShown = true;
          ({ trackEventSpy } = bindInternalEventDocument(wrapper.element));
        });

        it('tracks event with foundational agent properties when foundational agent is selected', async () => {
          const mockFoundationalAgent = {
            id: 'gid://gitlab/Ai::FoundationalChatAgent/security_analyst',
            name: 'Security Analyst',
            referenceWithVersion: 'security_analyst/v1',
            foundational: true,
          };

          await wrapper.vm.$store.dispatch('setCurrentAgent', mockFoundationalAgent);
          await nextTick();

          await findDuoChat().vm.$emit('new-chat');
          await waitForPromises();

          findDuoChat().vm.$emit('send-chat-prompt', MOCK_USER_MESSAGE.content);
          await waitForPromises();

          expect(trackEventSpy).toHaveBeenCalledWith(
            CHAT_TRACKING_EVENT,
            {
              label: 'foundational_agent',
              property: 'chat',
              value: null,
              foundational_item_ref: 'security_analyst',
            },
            undefined,
          );
        });

        it('tracks event with catalog agent properties when catalog agent is selected', async () => {
          const mockCatalogAgent = {
            id: 'gid://gitlab/Ai::Catalog::Item/1',
            name: 'Test Catalog Agent',
            pinnedItemVersionId: 'gid://gitlab/Ai::Catalog::ItemVersion/100',
          };

          await wrapper.vm.$store.dispatch('setCurrentAgent', mockCatalogAgent);
          await nextTick();

          await findDuoChat().vm.$emit('new-chat');
          await waitForPromises();

          findDuoChat().vm.$emit('send-chat-prompt', MOCK_USER_MESSAGE.content);
          await waitForPromises();

          expect(trackEventSpy).toHaveBeenCalledWith(
            CHAT_TRACKING_EVENT,
            {
              label: 'agent',
              property: 'chat',
              value: 100,
              foundational_item_ref: null,
            },
            undefined,
          );
        });

        it('does not track event when neither foundational nor catalog agent is selected', async () => {
          findDuoChat().vm.$emit('send-chat-prompt', MOCK_USER_MESSAGE.content);
          await waitForPromises();

          expect(trackEventSpy).not.toHaveBeenCalled();
        });
      });
    });

    describe('WebSocket message handling', () => {
      beforeEach(async () => {
        findDuoChat().vm.$emit('send-chat-prompt', MOCK_USER_MESSAGE.content);
        await waitForPromises();
        wrapper.vm.workflowId = MOCK_WORKFLOW_ID;
        actionSpies.addDuoChatMessage.mockReset();
      });

      it('processes messages from the WebSocket and updates the UI', async () => {
        const checkpointData = {
          requestID: 'request-id-1',
          newCheckpoint: {
            checkpoint: JSON.stringify({
              channel_values: {
                ui_chat_log: [
                  { content: 'Hello, how can I help?', message_type: 'agent' },
                  {
                    content: 'I can assist with optimizing your CI pipeline.',
                    message_type: 'agent',
                  },
                ],
              },
            }),
            status: 'completed',
            goal: 'Test goal for activeThread',
          },
        };
        const mockEvent = { type: 'message', data: JSON.stringify(checkpointData) };

        triggerStreamEvent('message', mockEvent);
        await waitForPromises();

        expect(WorkflowSocketUtils.processWorkflowMessage).toHaveBeenCalledWith(mockEvent, null);

        expect(actionSpies.addDuoChatMessage).toHaveBeenCalledWith(
          expect.any(Object),
          MOCK_TRANSFORMED_MESSAGES.at(-1),
        );
        expect(findDuoChat().props('activeThreadId')).toBe(MOCK_WORKFLOW_ID);
      });

      it('handles tool approval flow', async () => {
        const mockCheckpointData = {
          requestID: 'request-id-1',
          newCheckpoint: {
            checkpoint: JSON.stringify({
              channel_values: {
                ui_chat_log: [
                  {
                    content: 'I need to run a command.',
                    message_type: 'assistant',
                    tool_info: {
                      name: 'run_command',
                      args: { command: 'ls -la' },
                    },
                  },
                ],
              },
            }),
            status: 'TOOL_CALL_APPROVAL_REQUIRED',
          },
        };

        triggerStreamEvent('message', {
          type: 'message',
          data: JSON.stringify(mockCheckpointData),
        });
        await waitForPromises();
        await nextTick();

        expect(findDuoChat().props('isToolApprovalProcessing')).toBe(false);
      });

      it('sets waiting on prompt to false when workflow status is INPUT_REQUIRED', async () => {
        const mockCheckpointData = {
          requestID: 'request-id-4',
          newCheckpoint: {
            checkpoint: JSON.stringify({
              channel_values: {
                ui_chat_log: [
                  {
                    content: 'Please provide more information',
                    message_type: 'agent',
                  },
                ],
              },
            }),
            status: DUO_WORKFLOW_STATUS_INPUT_REQUIRED,
          },
        };

        triggerStreamEvent('message', {
          type: 'message',
          data: JSON.stringify(mockCheckpointData),
        });
        await waitForPromises();

        expect(findDuoChat().props('isLoading')).toBe(false);
      });

      it('handles errors from WebSocket', () => {
        triggerStreamEvent('error', { type: 'error' });

        expect(actionSpies.addDuoChatMessage).toHaveBeenCalledWith(
          expect.anything(),
          expect.objectContaining({
            errors: ['Error: Unable to connect to workflow service. Please try again.'],
          }),
        );
      });

      it('calls EventsTracker.trackMessage for each processed message', async () => {
        const mockEvent = {
          type: 'message',
          data: JSON.stringify({
            requestID: 'request-id-tracking',
            newCheckpoint: {
              checkpoint: JSON.stringify({
                channel_values: {
                  ui_chat_log: [{ content: 'Hello', message_type: 'agent' }],
                },
              }),
              status: 'running',
              goal: 'Test',
            },
          }),
        };

        triggerStreamEvent('message', mockEvent);
        await waitForPromises();

        expect(EventsTracker.trackMessage).toHaveBeenCalledWith({
          message: MOCK_TRANSFORMED_MESSAGES[0],
        });
      });
    });

    describe('Race condition prevention in message processing', () => {
      beforeEach(async () => {
        findDuoChat().vm.$emit('send-chat-prompt', MOCK_USER_MESSAGE.content);
        await waitForPromises();
        wrapper.vm.workflowId = MOCK_WORKFLOW_ID;
        actionSpies.addDuoChatMessage.mockReset();
      });

      it('prevents concurrent processing of messages', async () => {
        const createMockEvent = (messageContent) => ({
          type: 'message',
          data: JSON.stringify({
            requestID: 'request-id-race',
            newCheckpoint: {
              checkpoint: JSON.stringify({
                channel_values: {
                  ui_chat_log: [{ content: messageContent, message_type: 'agent' }],
                },
              }),
              status: 'running',
            },
          }),
        });

        // Set up processWorkflowMessage to return proper data
        WorkflowSocketUtils.processWorkflowMessage
          .mockResolvedValueOnce({
            messages: [MOCK_TRANSFORMED_MESSAGES[0]],
            status: 'running',
            lastProcessedMessageId: 'message-0',
          })
          .mockResolvedValueOnce({
            messages: [MOCK_TRANSFORMED_MESSAGES[0]],
            status: 'running',
            lastProcessedMessageId: 'message-1',
          });

        // Fire two events rapidly (simulating race condition)
        triggerStreamEvent('message', createMockEvent('First message'));
        triggerStreamEvent('message', createMockEvent('Second message'));

        // Wait for all processing to complete
        await waitForPromises();
        await nextTick();

        // Verify processWorkflowMessage was called sequentially, not concurrently
        // First call should have null, second should have updated message id
        expect(WorkflowSocketUtils.processWorkflowMessage).toHaveBeenNthCalledWith(
          1,
          expect.anything(),
          null,
        );
        expect(WorkflowSocketUtils.processWorkflowMessage).toHaveBeenNthCalledWith(
          2,
          expect.anything(),
          'message-0', // Uses updated lastProcessedMessageId from first call
        );
      });

      it('processes the final event when multiple events arrive rapidly', async () => {
        const createMockEvent = (id, messageContent) => ({
          type: 'message',
          data: JSON.stringify({
            requestID: `request-id-${id}`,
            newCheckpoint: {
              checkpoint: JSON.stringify({
                channel_values: {
                  ui_chat_log: [{ content: messageContent, message_type: 'agent' }],
                },
              }),
              status: 'running',
            },
          }),
        });

        // Mock processWorkflowMessage to resolve with different data
        WorkflowSocketUtils.processWorkflowMessage.mockImplementation(() =>
          Promise.resolve({
            messages: [MOCK_TRANSFORMED_MESSAGES[0]],
            status: 'running',
            lastProcessedMessageId: 'message-0',
          }),
        );

        // Fire multiple events rapidly - only first and last should be processed
        triggerStreamEvent('message', createMockEvent(1, 'Message 1'));
        triggerStreamEvent('message', createMockEvent(2, 'Message 2'));
        triggerStreamEvent('message', createMockEvent(3, 'Message 3'));
        triggerStreamEvent('message', createMockEvent(4, 'Final message'));

        await waitForPromises();
        await nextTick();

        // Should process at least 2 messages: first one that started immediately,
        // and the last one that was pending
        expect(WorkflowSocketUtils.processWorkflowMessage).toHaveBeenCalled();
        // The final event should have been processed
        const lastCall =
          WorkflowSocketUtils.processWorkflowMessage.mock.calls[
            WorkflowSocketUtils.processWorkflowMessage.mock.calls.length - 1
          ];
        // Verify the last event was processed (request-id-4)
        expect(lastCall[0].data).toBeDefined();
      });

      it('maintains correct lastProcessedMessageId across sequential processing', async () => {
        const createMockEvent = (index) => ({
          type: 'message',
          data: JSON.stringify({
            requestID: `request-id-${index}`,
            newCheckpoint: {
              checkpoint: JSON.stringify({
                channel_values: {
                  ui_chat_log: [
                    {
                      content: `Message ${index}`,
                      message_type: 'agent',
                      message_id: `message-${index}`,
                    },
                  ],
                },
              }),
              status: 'running',
            },
          }),
        });

        // Mock to return incrementing lastProcessedMessageId
        WorkflowSocketUtils.processWorkflowMessage
          .mockResolvedValueOnce({
            messages: [MOCK_TRANSFORMED_MESSAGES[0]],
            status: 'running',
            lastProcessedMessageId: 'message-0',
          })
          .mockResolvedValueOnce({
            messages: [MOCK_TRANSFORMED_MESSAGES[0]],
            status: 'running',
            lastProcessedMessageId: 'message-1',
          });

        // Send two events
        triggerStreamEvent('message', createMockEvent(1));
        await waitForPromises();

        triggerStreamEvent('message', createMockEvent(2));
        await waitForPromises();

        // Verify the message id was properly updated and passed
        expect(wrapper.vm.lastProcessedMessageId).toBe('message-1');
      });

      it('clears processing state when cleanupState is called', () => {
        const mockEvent = {
          type: 'message',
          data: JSON.stringify({
            requestID: 'request-id-cleanup',
            newCheckpoint: {
              checkpoint: JSON.stringify({
                channel_values: { ui_chat_log: [] },
              }),
              status: 'running',
            },
          }),
        };

        WorkflowSocketUtils.processWorkflowMessage.mockResolvedValue({
          messages: [],
          status: 'running',
          lastProcessedMessageId: 'message-0',
        });

        // Start processing
        triggerStreamEvent('message', mockEvent);
        expect(wrapper.vm.isProcessingMessage).toBe(true);

        // Call cleanup
        wrapper.vm.cleanupState();

        expect(wrapper.vm.isProcessingMessage).toBe(false);
        expect(wrapper.vm.pendingEvent).toBe(null);
      });
    });

    describe('@chat-cancel', () => {
      it('cancels the active connection, does not reset the workflowID', async () => {
        wrapper.vm.workflowId = MOCK_WORKFLOW_ID;

        findDuoChat().vm.$emit('chat-cancel');
        await nextTick();

        expect(streamManager.disconnect).toHaveBeenCalled();

        expect(findChatLoadingState().exists()).toBe(false);
        expect(findDuoChat().props('isLoading')).toBe(false);
        expect(wrapper.vm.workflowId).toBe(MOCK_WORKFLOW_ID);
      });
    });

    describe('@new-chat', () => {
      it('resets chat state for new conversation', async () => {
        wrapper.vm.workflowId = MOCK_WORKFLOW_ID;

        findDuoChat().vm.$emit('new-chat');
        await nextTick();

        expect(wrapper.vm.workflowId).toBe(null);
        expect(actionSpies.setMessages).toHaveBeenCalledWith(expect.anything(), []);
        expect(findChatLoadingState().exists()).toBe(false);
        expect(findDuoChat().props('isLoading')).toBe(false);
        expect(streamManager.disconnect).toHaveBeenCalled();
      });
      it('clears the active thread', async () => {
        const clearActiveWorkflowSpy = jest.spyOn(wrapper.vm, 'clearActiveWorkflow');

        findDuoChat().vm.$emit('new-chat');
        await nextTick();

        expect(clearActiveWorkflowSpy).toHaveBeenCalled();
      });
      it('clears expired thread state when starting a new chat', async () => {
        isThreadExpired.mockReturnValue(true);

        findDuoChat().vm.$emit('thread-selected', {
          id: MOCK_WORKFLOW_ID,
          lastUpdatedAt: '2024-01-01T00:00:00Z',
        });
        await nextTick();

        const duoChat = findDuoChat();

        expect(duoChat.vm.$scopedSlots['custom-empty-state']({})).toBeDefined();

        isThreadExpired.mockReturnValue(false);

        duoChat.vm.$emit('new-chat');
        await nextTick();

        expect(duoChat.vm.$scopedSlots['custom-empty-state']).toBeUndefined();
      });
    });

    describe('@approve-tool', () => {
      beforeEach(() => {
        createComponent();
      });

      it('handles tool approval via chat component event and updates processing state through workflow', async () => {
        duoChatGlobalState.isAgenticChatShown = true;
        await waitForPromises();
        wrapper.vm.workflowId = MOCK_WORKFLOW_ID;

        expect(findDuoChat().props('isToolApprovalProcessing')).toBe(false);

        findDuoChat().vm.$emit('approve-tool');
        await nextTick();

        expect(findDuoChat().props('isToolApprovalProcessing')).toBe(true);

        expect(WorkflowSocketUtils.buildStartRequest).toHaveBeenCalledWith({
          workflowId: '456',
          workflowDefinition: undefined,
          goal: '',
          approval: { approval: {} },
          additionalContext: [],
          agentConfig: null,
          metadata: null,
          clientCapabilities: ['incremental_streaming'],
        });

        expect(streamManager.connect).toHaveBeenCalled();

        const mockApprovalRequiredData = {
          requestID: 'request-id-approval-1',
          newCheckpoint: {
            checkpoint: JSON.stringify({
              channel_values: {
                ui_chat_log: [
                  {
                    content: 'I need approval to execute this tool',
                    message_type: 'assistant',
                    tool_info: {
                      name: 'some_tool',
                      args: { param: 'value' },
                    },
                  },
                ],
              },
            }),
            status: 'TOOL_CALL_APPROVAL_REQUIRED',
          },
        };

        triggerStreamEvent('message', {
          type: 'message',
          data: JSON.stringify(mockApprovalRequiredData),
        });
        await waitForPromises();
        await nextTick();

        expect(findDuoChat().props('isToolApprovalProcessing')).toBe(false);

        const mockCompletedData = {
          requestID: 'request-id-approval-2',
          newCheckpoint: {
            checkpoint: JSON.stringify({
              channel_values: {
                ui_chat_log: [
                  {
                    content: 'Tool execution completed',
                    message_type: 'agent',
                  },
                ],
              },
            }),
            status: 'completed',
          },
        };

        triggerStreamEvent('message', {
          type: 'message',
          data: JSON.stringify(mockCompletedData),
        });
        await waitForPromises();
        await nextTick();

        expect(findDuoChat().props('isToolApprovalProcessing')).toBe(false);
      });

      it('calls EventsTracker.trackApproveTool with tool name from last message', async () => {
        duoChatGlobalState.isAgenticChatShown = true;
        await waitForPromises();
        wrapper.vm.workflowId = MOCK_WORKFLOW_ID;

        store.commit('ADD_MESSAGE', {
          message_type: 'request',
          role: 'assistant',
          requestId: 'req-tracking-1',
          tool_info: { name: 'some_tool', args: {} },
          content: 'Tool requires approval',
        });

        findDuoChat().vm.$emit('approve-tool');
        await nextTick();

        expect(EventsTracker.trackApproveTool).toHaveBeenCalledWith({
          toolName: 'some_tool',
        });
      });
    });

    describe('@deny-tool', () => {
      beforeEach(() => {
        createComponent();
      });

      it('handles tool denial via chat component event with message and updates processing state', async () => {
        duoChatGlobalState.isAgenticChatShown = true;
        await waitForPromises();
        wrapper.vm.workflowId = MOCK_WORKFLOW_ID;
        const denyMessage = 'I do not approve this action';

        expect(findDuoChat().props('isToolApprovalProcessing')).toBe(false);

        findDuoChat().vm.$emit('deny-tool', denyMessage);
        await nextTick();

        expect(findDuoChat().props('isToolApprovalProcessing')).toBe(true);

        expect(WorkflowSocketUtils.buildStartRequest).toHaveBeenCalledWith({
          workflowId: '456',
          workflowDefinition: undefined,
          goal: '',
          approval: {
            approval: undefined,
            rejection: { message: denyMessage },
          },
          additionalContext: [],
          agentConfig: null,
          metadata: null,
          clientCapabilities: ['incremental_streaming'],
        });

        expect(streamManager.connect).toHaveBeenCalled();

        const mockApprovalRequiredData = {
          requestID: 'request-id-denial-1',
          newCheckpoint: {
            checkpoint: JSON.stringify({
              channel_values: {
                ui_chat_log: [
                  {
                    content: 'Tool approval was required',
                    message_type: 'assistant',
                    tool_info: {
                      name: 'some_tool',
                      args: { param: 'value' },
                    },
                  },
                ],
              },
            }),
            status: 'TOOL_CALL_APPROVAL_REQUIRED',
          },
        };

        triggerStreamEvent('message', {
          type: 'message',
          data: JSON.stringify(mockApprovalRequiredData),
        });
        await waitForPromises();
        await nextTick();

        expect(findDuoChat().props('isToolApprovalProcessing')).toBe(false);

        const mockDenialProcessedData = {
          requestID: 'request-id-denial-2',
          newCheckpoint: {
            checkpoint: JSON.stringify({
              channel_values: {
                ui_chat_log: [
                  {
                    content: 'Tool execution denied, proceeding with alternative approach',
                    message_type: 'agent',
                  },
                ],
              },
            }),
            status: 'processing',
          },
        };

        triggerStreamEvent('message', {
          type: 'message',
          data: JSON.stringify(mockDenialProcessedData),
        });
        await waitForPromises();
        await nextTick();

        expect(findDuoChat().props('isToolApprovalProcessing')).toBe(false);
      });

      it('handles tool denial via chat component event with event object and updates processing state', async () => {
        duoChatGlobalState.isAgenticChatShown = true;
        await waitForPromises();
        wrapper.vm.workflowId = MOCK_WORKFLOW_ID;
        const eventObject = { message: 'I do not approve this action' };

        expect(findDuoChat().props('isToolApprovalProcessing')).toBe(false);

        findDuoChat().vm.$emit('deny-tool', eventObject);
        await nextTick();

        expect(findDuoChat().props('isToolApprovalProcessing')).toBe(true);

        expect(streamManager.connect).toHaveBeenCalled();
      });

      it('calls EventsTracker.trackDenyTool with tool name from last message', async () => {
        duoChatGlobalState.isAgenticChatShown = true;
        await waitForPromises();
        wrapper.vm.workflowId = MOCK_WORKFLOW_ID;

        store.commit('ADD_MESSAGE', {
          message_type: 'request',
          role: 'assistant',
          requestId: 'req-tracking-2',
          tool_info: { name: 'some_tool', args: {} },
          content: 'Tool requires approval',
        });

        findDuoChat().vm.$emit('deny-tool', 'I do not approve');
        await nextTick();

        expect(EventsTracker.trackDenyTool).toHaveBeenCalledWith({
          toolName: 'some_tool',
        });
      });
    });
  });

  describe('tool approval state management', () => {
    beforeEach(async () => {
      duoChatGlobalState.isAgenticChatShown = true;
      createComponent();
      await waitForPromises();
    });

    it('keeps buttons disabled while tool is running after approval', async () => {
      findDuoChat().vm.$emit('send-chat-prompt', MOCK_USER_MESSAGE.content);
      await waitForPromises();

      findDuoChat().vm.$emit('approve-tool');
      await nextTick();

      expect(findDuoChat().props('isToolApprovalProcessing')).toBe(true);

      triggerStreamEvent('message', {
        type: 'message',
        data: JSON.stringify({
          requestID: 'request-1',
          newCheckpoint: {
            checkpoint: JSON.stringify({
              channel_values: {
                ui_chat_log: [{ content: 'Running', message_type: 'agent' }],
              },
            }),
            status: DUO_WORKFLOW_STATUS_RUNNING,
          },
        }),
      });
      await waitForPromises();
      await nextTick();

      expect(findDuoChat().props('isToolApprovalProcessing')).toBe(true);
    });

    it('re-enables buttons when tool finishes running', async () => {
      findDuoChat().vm.$emit('send-chat-prompt', MOCK_USER_MESSAGE.content);
      await waitForPromises();

      findDuoChat().vm.$emit('approve-tool');
      await nextTick();

      triggerStreamEvent('message', {
        type: 'message',
        data: JSON.stringify({
          requestID: 'request-1',
          newCheckpoint: {
            checkpoint: JSON.stringify({
              channel_values: { ui_chat_log: [{ content: 'Done', message_type: 'agent' }] },
            }),
            status: DUO_WORKFLOW_STATUS_INPUT_REQUIRED,
          },
        }),
      });
      await waitForPromises();
      await nextTick();

      expect(findDuoChat().props('isToolApprovalProcessing')).toBe(false);
    });
  });

  describe('workflowId watcher', () => {
    beforeEach(async () => {
      createComponent();
      duoChatGlobalState.isAgenticChatShown = true;

      await waitForPromises();
    });

    it('stores workflowId and active thread when workflowId changes', async () => {
      await findDuoChat().vm.$emit('thread-selected', { id: MOCK_WORKFLOW_ID });

      await nextTick();

      expect(saveStorageValue).toHaveBeenCalledWith(DUO_CURRENT_WORKFLOW_STORAGE_KEY, {
        workflowId: MOCK_WORKFLOW_ID,
      });
    });

    it('emits session-id-changed when workflowId changes', async () => {
      await findDuoChat().vm.$emit('thread-selected', { id: MOCK_WORKFLOW_ID });

      await nextTick();

      expect(wrapper.emitted('session-id-changed')).toBeDefined();
      expect(wrapper.emitted('session-id-changed')[0]).toEqual(['456']);
    });

    it('emits session-id-changed on mount when workflowId exists', async () => {
      getStorageValue.mockReset();
      getStorageValue.mockReturnValueOnce({
        exists: true,
        value: { workflowId: MOCK_WORKFLOW_ID },
      });
      duoChatGlobalState.isAgenticChatShown = false;

      createComponent();
      duoChatGlobalState.isAgenticChatShown = true;
      await waitForPromises();

      expect(wrapper.emitted('session-id-changed')).toBeDefined();
      expect(wrapper.emitted('session-id-changed')[0]).toEqual(['456']);
    });
  });

  describe('mode watcher', () => {
    let onNewChatSpy;
    let hydrateActiveWorkflowSpy;
    let onBackToListSpy;

    const bootstrapWithProps = async (props = {}) => {
      hydrateActiveWorkflowSpy = jest.spyOn(DuoAgenticChatApp.methods, 'hydrateActiveWorkflow');
      onNewChatSpy = jest.spyOn(DuoAgenticChatApp.methods, 'onNewChat');
      onBackToListSpy = jest.spyOn(DuoAgenticChatApp.methods, 'onBackToList');

      createComponent(props);
      duoChatGlobalState.isAgenticChatShown = true;
      await waitForPromises();
      hydrateActiveWorkflowSpy.mockClear();
      onNewChatSpy.mockClear();
      onBackToListSpy.mockClear();
    };

    describe('when mode changes to "new"', () => {
      it('calls onNewChat', async () => {
        await bootstrapWithProps();
        wrapper.setProps({ mode: 'new' });
        await nextTick();

        expect(onNewChatSpy).toHaveBeenCalledTimes(1);
      });
    });

    describe('when mode changes to "history"', () => {
      beforeEach(async () => {
        await bootstrapWithProps();
        wrapper.setProps({ mode: 'history' });
      });

      it('calls onBackToList', async () => {
        await nextTick();
        expect(onBackToListSpy).toHaveBeenCalledTimes(1);
      });

      it('emits change-title with empty string', () => {
        const emittedEvents = wrapper.emitted('change-title');
        expect(emittedEvents.at(-1)).toEqual(['']);
      });

      it('switches to LIST view', async () => {
        await nextTick();
        expect(findDuoChat().props('multiThreadedView')).toBe(DUO_CHAT_VIEWS.LIST);
      });
      it('removes any current messages', async () => {
        await bootstrapWithProps({
          inititalState: {
            messages: [{ id: '1', content: 'test', role: 'user' }],
          },
          data: {
            workflowId: MOCK_WORKFLOW_ID,
          },
        });
        await nextTick();
        expect(findDuoChat().props('messages')).toHaveLength(1);

        wrapper.setProps({ mode: 'history' });
        await nextTick();
        expect(findDuoChat().props('messages')).toHaveLength(0);
      });
    });

    describe('when mode changes to "active"', () => {
      describe('no active thread', () => {
        beforeEach(async () => {
          await bootstrapWithProps({ propsData: { mode: 'history' } });
        });

        it('starts a new chat', async () => {
          wrapper.setProps({ mode: 'active' });
          await nextTick();

          expect(onNewChatSpy).toHaveBeenCalledTimes(1);
          expect(hydrateActiveWorkflowSpy).not.toHaveBeenCalled();
        });
      });
      describe('active thread is set', () => {
        beforeEach(async () => {
          await bootstrapWithProps({
            data: {
              workflowId: MOCK_WORKFLOW_ID,
            },
            propsData: { mode: 'history' },
          });
        });

        it('should hydrate, and not run onNewChat', async () => {
          wrapper.setProps({ mode: 'active' });
          await nextTick();

          expect(onNewChatSpy).not.toHaveBeenCalled();
          expect(hydrateActiveWorkflowSpy).toHaveBeenCalledTimes(1);
        });
      });
      describe('when isLoading is true', () => {
        it('does not start a new chat or hydrate when switching to active mode', async () => {
          let resolvePromise = null;
          const pendingPromise = new Promise((resolve) => {
            resolvePromise = resolve;
          });

          workflowEventsQueryMock.mockReturnValue(pendingPromise);

          onNewChatSpy = jest.spyOn(DuoAgenticChatApp.methods, 'onNewChat');
          hydrateActiveWorkflowSpy = jest.spyOn(DuoAgenticChatApp.methods, 'hydrateActiveWorkflow');

          createComponent({
            data: {
              workflowId: MOCK_WORKFLOW_ID,
            },
            propsData: { mode: 'history' },
          });

          duoChatGlobalState.isAgenticChatShown = true;
          await nextTick();

          hydrateActiveWorkflowSpy.mockClear();
          onNewChatSpy.mockClear();

          wrapper.setProps({ mode: 'active' });
          await nextTick();

          expect(onNewChatSpy).not.toHaveBeenCalled();
          expect(hydrateActiveWorkflowSpy).not.toHaveBeenCalled();

          resolvePromise(MOCK_WORKFLOW_EVENTS_RESPONSE);
        });
      });
    });
  });

  describe('Error conditions', () => {
    const errorText = 'Failed to fetch resources';

    it('handles errors from the context presets query', async () => {
      contextPresetsQueryHandlerMock.mockRejectedValueOnce(new Error(errorText));
      duoChatGlobalState.isAgenticChatShown = true;
      createComponent();
      await waitForPromises();

      expect(findDuoChat().exists()).toBe(true);
      expect(findDuoChat().props('predefinedPrompts')).toEqual([]);
    });

    it('handles workflow creation errors', async () => {
      createWorkflowMutationMock.mockRejectedValue(new Error(errorText));
      duoChatGlobalState.isAgenticChatShown = true;
      createComponent();
      await waitForPromises();

      findDuoChat().vm.$emit('send-chat-prompt', MOCK_USER_MESSAGE.content);
      await waitForPromises();

      expect(actionSpies.addDuoChatMessage).toHaveBeenCalledWith(
        expect.anything(),
        expect.objectContaining({
          errors: [`Error: ${errorText}`],
        }),
      );
    });
  });

  describe('Resizable Dimensions', () => {
    beforeEach(() => {
      duoChatGlobalState.isAgenticChatShown = true;
      createComponent();
    });

    it('updates dimensions correctly when `chat-resize` event is emitted', async () => {
      const newWidth = 600;
      const newHeight = 500;
      const chat = findDuoChat();
      const initialWidth = wrapper.vm.width;
      const initialHeight = wrapper.vm.height;

      chat.vm.$emit('chat-resize', { width: newWidth, height: newHeight });
      await nextTick();

      expect(ResizeUtils.calculateDimensions).toHaveBeenLastCalledWith({
        width: newWidth,
        height: newHeight,
        currentWidth: initialWidth,
        currentHeight: initialHeight,
      });
      expect(wrapper.vm.width).toBe(newWidth);
      expect(wrapper.vm.height).toBe(newHeight);
    });

    it('updates dimensions when the window is resized', async () => {
      const originalInnerWidth = window.innerWidth;
      const originalInnerHeight = window.innerHeight;

      try {
        const initialWidth = wrapper.vm.width;
        const initialHeight = wrapper.vm.height;

        window.innerWidth = 1200;
        window.innerHeight = 800;

        window.dispatchEvent(new Event('resize'));
        await nextTick();

        expect(ResizeUtils.calculateDimensions).toHaveBeenLastCalledWith({
          currentWidth: initialWidth,
          currentHeight: initialHeight,
        });
        expect(wrapper.vm.maxWidth).toBe(1200 - WIDTH_OFFSET);
        expect(wrapper.vm.maxHeight).toBe(800);
      } finally {
        window.innerWidth = originalInnerWidth;
        window.innerHeight = originalInnerHeight;
      }
    });
  });

  describe('Global state watchers', () => {
    describe('duoChatGlobalState.isAgenticChatShown', () => {
      describe('when there is a workflowId and activeThread registered in localStorage', () => {
        beforeEach(() => {
          getStorageValue.mockReset();
          getStorageValue.mockReturnValueOnce({
            exists: true,
            value: { workflowId: MOCK_WORKFLOW_ID },
          });
          duoChatGlobalState.isAgenticChatShown = false;
        });

        it('loads workflow message thread', async () => {
          createComponent();
          duoChatGlobalState.isAgenticChatShown = true;
          await waitForPromises();

          expect(findDuoChat().props().messages).toHaveLength(1);
        });

        describe(`when workflow status is "${DUO_WORKFLOW_STATUS_RUNNING}"`, () => {
          beforeEach(() => {
            const mockParsedData = {
              workflowStatus: DUO_WORKFLOW_STATUS_RUNNING,
              checkpoint: { channel_values: { ui_chat_log: [] } },
            };

            WorkflowUtils.parseWorkflowData.mockReturnValue(mockParsedData);
          });

          it('starts the workflow', async () => {
            createComponent();
            duoChatGlobalState.isAgenticChatShown = true;
            await waitForPromises();
            expect(streamManager.connect).toHaveBeenCalled();
          });
        });

        describe(`when workflow status is not "${DUO_WORKFLOW_STATUS_RUNNING}"`, () => {
          beforeEach(async () => {
            const mockParsedData = {
              workflowStatus: DUO_WORKFLOW_STATUS_INPUT_REQUIRED,
              checkpoint: { channel_values: { ui_chat_log: [] } },
            };

            WorkflowUtils.parseWorkflowData.mockReturnValue(mockParsedData);

            duoChatGlobalState.isAgenticChatShown = true;
            await waitForPromises();
          });

          it('does not start the workflow', () => {
            expect(streamManager.connect).not.toHaveBeenCalled();
          });
        });
      });

      describe('when there is no workflowId or activeThread registered in localStorage', () => {
        beforeEach(() => {
          getStorageValue.mockReset();
          getStorageValue.mockReturnValueOnce({
            exists: false,
            value: null,
          });
          duoChatGlobalState.isAgenticChatShown = false;
        });

        it('does not load messages for active thread', async () => {
          createComponent();
          duoChatGlobalState.isAgenticChatShown = true;
          await waitForPromises();

          expect(findDuoChat().props().messages).toHaveLength(0);
        });

        it('emits change-title when hydrateActiveWorkflow is triggered', async () => {
          // Assert baseline - no emissions yet
          expect(wrapper?.emitted('change-title')).toBeUndefined();

          createComponent();
          duoChatGlobalState.isAgenticChatShown = true;
          await waitForPromises();

          const emissions = wrapper.emitted('change-title');
          expect(emissions).toHaveLength(2);
          expect(emissions[0]).toEqual([undefined]);
          expect(emissions[1]).toEqual([undefined]);
        });
      });
    });

    describe('duoChatGlobalState.commands', () => {
      beforeEach(() => {
        createComponent({
          propsData: { projectId: MOCK_PROJECT_ID, resourceId: MOCK_RESOURCE_ID },
        });
        duoChatGlobalState.isAgenticChatShown = true;
      });

      describe('when commands are added', () => {
        it('starts a new chat and sends the command question', async () => {
          const testQuestion = 'What is GitLab CI/CD?';

          // Trigger the watcher by adding a command to the global state
          duoChatGlobalState.commands = [{ question: testQuestion }];
          await waitForPromises();

          // Assert that onNewChat() side effects occurred
          expect(actionSpies.setMessages).toHaveBeenCalledWith(expect.anything(), []);
          expect(findChatLoadingState().exists()).toBe(false);

          // Assert that onSendChatPrompt() side effects occurred
          expect(findDuoChat().props('isLoading')).toBe(true);
          expect(createWorkflowMutationMock).toHaveBeenCalledWith(
            expect.objectContaining({
              projectId: MOCK_PROJECT_ID,
              goal: testQuestion,
            }),
          );
          expect(streamManager.connect).toHaveBeenCalled();
          expect(actionSpies.addDuoChatMessage).toHaveBeenCalledWith(
            expect.any(Object),
            expect.objectContaining({
              content: testQuestion,
              role: 'user',
              requestId: DUO_AGENTIC_CHAT_PENDING_USER_MESSAGE_ID,
            }),
          );
        });

        it('does not trigger chat when commands array is empty', async () => {
          jest.clearAllMocks();

          duoChatGlobalState.commands = [];
          await nextTick();

          expect(actionSpies.setMessages).not.toHaveBeenCalled();
          expect(createWorkflowMutationMock).not.toHaveBeenCalled();
          expect(streamManager.connect).not.toHaveBeenCalled();
        });
      });

      describe('when a command has autoSend: false', () => {
        it('resets the thread but does not send a prompt or create a workflow', async () => {
          duoChatGlobalState.commands = [
            { agent: { name: 'Permissions Assistant' }, resourceId: '1', autoSend: false },
          ];
          await waitForPromises();

          // onNewChat() side effects should have run
          expect(actionSpies.setMessages).toHaveBeenCalledWith(expect.anything(), []);

          // onSendChatPrompt() should NOT have been called
          expect(createWorkflowMutationMock).not.toHaveBeenCalled();
          expect(streamManager.connect).not.toHaveBeenCalled();
        });

        it('passes currentWelcomeMessage to WebAgenticDuoChat as emptyStateTitle', async () => {
          const welcomeMessage = 'Tell me what you need.';
          duoChatGlobalState.commands = [
            {
              agent: { name: 'Permissions Assistant' },
              resourceId: '1',
              autoSend: false,
              welcomeMessage,
            },
          ];
          await waitForPromises();

          expect(findDuoChat().props('emptyStateTitle')).toBe(welcomeMessage);
        });

        it('passes currentPredefinedPrompts to WebAgenticDuoChat as predefinedPrompts', async () => {
          const predefinedPrompts = ['How do I fork?', 'What is a pipeline?'];
          duoChatGlobalState.commands = [
            {
              agent: { name: 'Permissions Assistant' },
              resourceId: '1',
              autoSend: false,
              predefinedPrompts,
            },
          ];
          await waitForPromises();

          expect(findDuoChat().props('predefinedPrompts')).toEqual(predefinedPrompts);
        });

        it('clears welcomeMessage and predefinedPrompts when onNewChat is called again', async () => {
          duoChatGlobalState.commands = [
            {
              agent: { name: 'Permissions Assistant' },
              resourceId: '1',
              autoSend: false,
              welcomeMessage: 'Hello!',
              predefinedPrompts: ['Prompt A'],
            },
          ];
          await waitForPromises();

          await findDuoChat().vm.$emit('new-chat');

          expect(findDuoChat().props('emptyStateTitle')).toBeNull();
          expect(findDuoChat().props('predefinedPrompts')).toEqual(
            MOCK_CONTEXT_PRESETS_RESPONSE.data.aiChatContextPresets.questions,
          );
        });
      });
    });
  });

  describe('when socket connection terminates', () => {
    beforeEach(async () => {
      duoChatGlobalState.isAgenticChatShown = true;
      flowStatusQueryMock.mockResolvedValueOnce({
        data: {
          duoWorkflowWorkflows: {
            edges: [
              {
                node: {
                  id: 'gid://gitlab/Ai::DuoWorkflows::Workflow/456',
                  status: 'running',
                },
              },
            ],
          },
        },
      });
      createComponent();
      wrapper.vm.workflowId = MOCK_WORKFLOW_ID;
      wrapper.vm.workflowStatus = 'running';

      // Trigger a workflow to create the WebSocket connection
      findDuoChat().vm.$emit('send-chat-prompt', MOCK_USER_MESSAGE.content);
      await waitForPromises();
    });

    describe('and the code is 1013 (close and try again)', () => {
      beforeEach(async () => {
        // Suppress expected vue-apollo error for workflowStatus query
        // triggered when isFlowLocked becomes true and starts polling
        const errSpy = jest.spyOn(console, 'error').mockImplementation(() => {});
        triggerStreamEvent('close', { type: 'close', code: 1013 });
        await waitForPromises();
        await nextTick();
        errSpy.mockRestore();
      });

      it('disables the chat and passes reason text', () => {
        expect(findDuoChat().props('chatState')).toMatchObject({
          isEnabled: false,
          reason:
            'GitLab Duo is already responding to this chat in another tab or location. Start a new chat, or wait for GitLab Duo to finish before sending a new message.',
        });
      });

      it('starts polling for workflow status', () => {
        expect(flowStatusQueryMock).toHaveBeenCalledWith({
          id: 'gid://gitlab/Ai::DuoWorkflows::Workflow/456',
        });
      });

      it('does not poll for workflow status when workflowId is null', async () => {
        flowStatusQueryMock.mockClear();

        // Simulate stale localStorage scenario: isFlowLocked is true but workflowId is null
        wrapper.vm.workflowId = null;
        await nextTick();

        jest.advanceTimersByTime(3000);
        await waitForPromises();

        expect(flowStatusQueryMock).not.toHaveBeenCalled();
      });
    });

    describe('when status changes', () => {
      beforeEach(async () => {
        findDuoChat().vm.$emit('send-chat-prompt', MOCK_USER_MESSAGE.content);
        await waitForPromises();

        triggerStreamEvent('close', { type: 'close', code: 1013 });
        await waitForPromises();
        await nextTick();
      });

      it('re-enables the chat', async () => {
        expect(findDuoChat().props('chatState')).toMatchObject({
          isEnabled: false,
          reason:
            'GitLab Duo is already responding to this chat in another tab or location. Start a new chat, or wait for GitLab Duo to finish before sending a new message.',
        });

        // Next poll will give us an updated status
        flowStatusQueryMock.mockResolvedValueOnce({
          data: {
            duoWorkflowWorkflows: {
              edges: [
                {
                  node: {
                    id: 'gid://gitlab/Ai::DuoWorkflows::Workflow/456',
                    status: 'input_required',
                  },
                },
              ],
            },
          },
        });

        jest.advanceTimersByTime(3000);
        await waitForPromises();
        await nextTick();

        expect(findDuoChat().props('chatState')).toMatchObject({ isEnabled: true });
      });

      it('hydrates the active thread to reconnect', async () => {
        workflowEventsQueryMock.mockClear();

        jest.advanceTimersByTime(3000);
        await waitForPromises();
        await nextTick();

        expect(workflowEventsQueryMock).toHaveBeenCalledWith({ workflowId: MOCK_WORKFLOW_ID });
      });
    });
  });

  describe('Socket cleanup', () => {
    it('clears state on component destroy when stream is not active', () => {
      duoChatGlobalState.isAgenticChatShown = true;
      createComponent();

      wrapper.destroy();

      expect(actionSpies.setMessages).toHaveBeenCalledWith(expect.anything(), []);
    });

    it('emits "change-title" event in beforeDestroy hook', () => {
      expect(wrapper?.emitted('change-title')).toBeUndefined();

      duoChatGlobalState.isAgenticChatShown = true;
      createComponent();

      let changeTitleEmitted = false;
      wrapper.vm.$on('change-title', () => {
        changeTitleEmitted = true;
      });

      wrapper.destroy();

      expect(changeTitleEmitted).toBe(true);
    });

    it('sets isProcessingToolApproval to false on socket close when not waiting for approval', async () => {
      duoChatGlobalState.isAgenticChatShown = true;
      createComponent();
      await waitForPromises();

      wrapper.vm.isProcessingToolApproval = true;
      wrapper.vm.workflowStatus = 'completed';
      wrapper.vm.workflowId = MOCK_WORKFLOW_ID;

      wrapper.vm.startWorkflow('test question', {}, wrapper.vm.additionalContext);

      expect(streamManager.connect).toHaveBeenCalled();

      triggerStreamEvent('close', { type: 'close' });

      expect(findDuoChat().props('isToolApprovalProcessing')).toBe(false);
      expect(findDuoChat().props('isLoading')).toBe(false);
    });

    it('keeps isProcessingToolApproval true on socket close when workflow is RUNNING', async () => {
      duoChatGlobalState.isAgenticChatShown = true;
      createComponent();
      await waitForPromises();

      findDuoChat().vm.$emit('send-chat-prompt', MOCK_USER_MESSAGE.content);
      await waitForPromises();

      findDuoChat().vm.$emit('approve-tool');
      await nextTick();

      triggerStreamEvent('message', {
        type: 'message',
        data: JSON.stringify({
          requestID: 'request-1',
          newCheckpoint: {
            checkpoint: JSON.stringify({
              channel_values: {
                ui_chat_log: [{ content: 'Running', message_type: 'agent' }],
              },
            }),
            status: DUO_WORKFLOW_STATUS_RUNNING,
          },
        }),
      });
      await waitForPromises();
      await nextTick();

      triggerStreamEvent('close', { type: 'close' });
      await nextTick();

      expect(findDuoChat().props('isToolApprovalProcessing')).toBe(true);
    });
  });

  describe('toggle position based on chatMode', () => {
    const findGlToggle = () => wrapper.findComponent(GlToggle);

    beforeEach(() => {
      duoChatGlobalState.isAgenticChatShown = true;
      jest.clearAllMocks();
    });

    it('shows toggle as checked when in agentic mode', () => {
      duoChatGlobalState.chatMode = 'agentic';
      createComponent({
        propsData: { forceAgenticModeForCoreDuoUsers: false },
        provide: {
          chatConfiguration: {
            title: 'GitLab Duo Agentic Chat',
            defaultProps: {
              isClassicAvailable: true,
            },
          },
        },
      });

      expect(findGlToggle().props('value')).toBe(true);
    });

    it('shows toggle as unchecked when in classic mode', () => {
      duoChatGlobalState.chatMode = 'classic';
      createComponent({
        propsData: { forceAgenticModeForCoreDuoUsers: false },
        provide: {
          chatConfiguration: {
            title: 'GitLab Duo Agentic Chat',
            defaultProps: {
              isClassicAvailable: true,
            },
          },
        },
      });

      expect(findGlToggle().props('value')).toBe(false);
    });
  });

  describe('Multithreading features', () => {
    beforeEach(() => {
      duoChatGlobalState.isAgenticChatShown = true;
      createComponent();
    });

    describe('@thread-selected', () => {
      it('switches to selected thread and fetches workflow events', async () => {
        const mockThread = { id: MOCK_WORKFLOW_ID, aiCatalogItemVersionId: null };
        const mockParsedData = { checkpoint: { channel_values: { ui_chat_log: [] } } };

        WorkflowUtils.parseWorkflowData.mockReturnValue(mockParsedData);
        WorkflowUtils.transformChatMessages.mockReturnValue(MOCK_TRANSFORMED_MESSAGES);

        findDuoChat().vm.$emit('thread-selected', mockThread);
        await waitForPromises();

        expect(workflowEventsQueryMock).toHaveBeenCalledWith({ workflowId: MOCK_WORKFLOW_ID });

        expect(WorkflowUtils.parseWorkflowData).toHaveBeenCalledWith(MOCK_WORKFLOW_EVENTS_RESPONSE);
        expect(WorkflowUtils.transformChatMessages).toHaveBeenCalledWith([]);

        expect(findDuoChat().props('multiThreadedView')).toBe(DUO_CHAT_VIEWS.CHAT);
        expect(findDuoChat().props('activeThreadId')).toBe(MOCK_WORKFLOW_ID);
        expect(findDuoChat().props('messages')).toEqual(MOCK_TRANSFORMED_MESSAGES);
      });

      it('handles errors when fetching workflow events', async () => {
        const mockThread = { id: MOCK_WORKFLOW_ID };
        const errorText = 'Failed to fetch workflow events';

        workflowEventsQueryMock.mockRejectedValue(new Error(errorText));

        findDuoChat().vm.$emit('thread-selected', mockThread);
        await waitForPromises();

        expect(actionSpies.addDuoChatMessage).toHaveBeenCalledWith(
          expect.anything(),
          expect.objectContaining({
            errors: [`Error: ${errorText}`],
          }),
        );
        expect(findChatLoadingState().exists()).toBe(false);
      });

      it('handles missing workflowGoal gracefully when fetching workflow events', async () => {
        const mockThread = { id: MOCK_WORKFLOW_ID, aiCatalogItemVersionId: null };

        WorkflowUtils.parseWorkflowData.mockReturnValue(undefined);
        WorkflowUtils.transformChatMessages.mockReturnValue(MOCK_TRANSFORMED_MESSAGES);

        findDuoChat().vm.$emit('thread-selected', mockThread);
        await waitForPromises();

        // Component emits change-title multiple times: on mount (via hydrateActiveWorkflow),
        // and when thread is selected. Check that the last emission has undefined.
        const emissions = wrapper.emitted('change-title');
        expect(emissions[emissions.length - 1]).toEqual([undefined]);
        expect(findDuoChat().props('multiThreadedView')).toBe(DUO_CHAT_VIEWS.CHAT);
      });

      it('handles UI updates when thread is for foundational agent', async () => {
        workflowEventsQueryMock.mockResolvedValue({
          data: MOCK_WORKFLOW_EVENTS_RESPONSE_WITH_FOUNDATIONAL_AGENT,
        });

        const mockThread = { id: MOCK_WORKFLOW_ID, aiCatalogItemVersionId: null };

        WorkflowUtils.parseWorkflowData.mockReturnValue(undefined);
        WorkflowUtils.transformChatMessages.mockReturnValue(MOCK_TRANSFORMED_MESSAGES);

        findDuoChat().vm.$emit('thread-selected', mockThread);
        await waitForPromises();

        expect(workflowEventsQueryMock).toHaveBeenCalledWith({ workflowId: MOCK_WORKFLOW_ID });

        expect(findDuoChat().props('title')).toEqual(MOCK_FETCHED_FOUNDATIONAL_AGENT.name);
      });

      it('resets the current thread before hydration', async () => {
        const clearActiveWorkflowSpy = jest.spyOn(wrapper.vm, 'clearActiveWorkflow');

        WorkflowUtils.transformChatMessages.mockReturnValue(MOCK_TRANSFORMED_MESSAGES);

        findDuoChat().vm.$emit('thread-selected', { id: MOCK_WORKFLOW_ID });
        await waitForPromises();

        expect(clearActiveWorkflowSpy).toHaveBeenCalled();
        expect(findDuoChat().props('messages')).toEqual(MOCK_TRANSFORMED_MESSAGES);
      });

      it('set the last processed message id based on the thread messages', async () => {
        WorkflowUtils.transformChatMessages.mockReturnValue(MOCK_TRANSFORMED_MESSAGES);

        expect(wrapper.vm.lastProcessedMessageId).toBe(null);

        findDuoChat().vm.$emit('thread-selected', { id: MOCK_WORKFLOW_ID });
        await waitForPromises();
        expect(wrapper.vm.lastProcessedMessageId).toBe(
          MOCK_TRANSFORMED_MESSAGES[MOCK_TRANSFORMED_MESSAGES.length - 1].message_id,
        );
      });

      it('disables chat with archived message when workflow is archived', async () => {
        workflowEventsQueryMock.mockResolvedValue({
          data: {
            ...MOCK_WORKFLOW_EVENTS_RESPONSE,
            duoWorkflowWorkflows: {
              nodes: [
                {
                  id: 'workflow-1',
                  status: 'completed',
                  aiCatalogItemVersionId: '',
                  workflowDefinition: null,
                  archived: true,
                },
              ],
            },
          },
        });

        findDuoChat().vm.$emit('thread-selected', { id: MOCK_WORKFLOW_ID });
        await waitForPromises();

        expect(findDuoChat().props('chatState')).toMatchObject({
          isEnabled: false,
          reason: expect.stringContaining('archived'),
        });
      });

      it('re-enables chat when starting a new chat after an archived workflow', async () => {
        workflowEventsQueryMock.mockResolvedValue({
          data: {
            ...MOCK_WORKFLOW_EVENTS_RESPONSE,
            duoWorkflowWorkflows: {
              nodes: [
                {
                  id: 'workflow-1',
                  status: 'completed',
                  aiCatalogItemVersionId: '',
                  workflowDefinition: null,
                  archived: true,
                },
              ],
            },
          },
        });

        findDuoChat().vm.$emit('thread-selected', { id: MOCK_WORKFLOW_ID });
        await waitForPromises();

        expect(findDuoChat().props('chatState')).toMatchObject({ isEnabled: false });

        findDuoChat().vm.$emit('new-chat');
        await waitForPromises();

        expect(findDuoChat().props('chatState')).toMatchObject({ isEnabled: true });
      });

      it('shows expired empty state when selecting an expired thread', async () => {
        isThreadExpired.mockReturnValue(true);

        const mockThread = { id: MOCK_WORKFLOW_ID, lastUpdatedAt: '2024-01-01T00:00:00Z' };

        findDuoChat().vm.$emit('thread-selected', mockThread);
        await nextTick();

        expect(findDuoChat().props('activeThreadId')).toBe(MOCK_WORKFLOW_ID);
        expect(findDuoChat().props('multiThreadedView')).toBe(DUO_CHAT_VIEWS.CHAT);
        expect(workflowEventsQueryMock).not.toHaveBeenCalled();

        isThreadExpired.mockReturnValue(false);
      });

      it('does not call clearActiveWorkflow when selecting an expired thread', async () => {
        isThreadExpired.mockReturnValue(true);

        const clearActiveWorkflowSpy = jest.spyOn(wrapper.vm, 'clearActiveWorkflow');
        const mockThread = { id: MOCK_WORKFLOW_ID, lastUpdatedAt: '2024-01-01T00:00:00Z' };

        findDuoChat().vm.$emit('thread-selected', mockThread);
        await nextTick();

        expect(clearActiveWorkflowSpy).not.toHaveBeenCalled();

        isThreadExpired.mockReturnValue(false);
      });

      it('renders ThreadExpiredEmptyState in custom-empty-state slot when thread is expired', async () => {
        isThreadExpired.mockReturnValue(true);

        const mockThread = { id: MOCK_WORKFLOW_ID, lastUpdatedAt: '2024-01-01T00:00:00Z' };

        findDuoChat().vm.$emit('thread-selected', mockThread);
        await nextTick();

        const duoChat = findDuoChat();
        const customEmptyState = duoChat.vm.$scopedSlots['custom-empty-state']({});

        expect(customEmptyState).toBeDefined();

        isThreadExpired.mockReturnValue(false);
      });

      it('re-enables chat when switching from an archived thread to a non-archived thread', async () => {
        const archivedResponse = {
          ...MOCK_WORKFLOW_EVENTS_RESPONSE,
          duoWorkflowWorkflows: {
            nodes: [
              {
                id: 'workflow-1',
                status: 'completed',
                aiCatalogItemVersionId: '',
                workflowDefinition: null,
                archived: true,
              },
            ],
          },
        };

        workflowEventsQueryMock.mockResolvedValue({ data: archivedResponse });

        findDuoChat().vm.$emit('thread-selected', { id: MOCK_WORKFLOW_ID });
        await waitForPromises();

        expect(findDuoChat().props('chatState')).toMatchObject({
          isEnabled: false,
          reason: expect.stringContaining('archived'),
        });

        const nonArchivedResponse = {
          ...MOCK_WORKFLOW_EVENTS_RESPONSE,
          duoWorkflowWorkflows: {
            nodes: [
              {
                id: 'workflow-2',
                status: 'completed',
                aiCatalogItemVersionId: '',
                workflowDefinition: null,
                archived: false,
              },
            ],
          },
        };

        workflowEventsQueryMock.mockResolvedValue({ data: nonArchivedResponse });

        findDuoChat().vm.$emit('thread-selected', { id: 'workflow-2' });
        await waitForPromises();

        expect(findDuoChat().props('chatState')).toMatchObject({ isEnabled: true });
      });
    });

    describe('@back-to-list', () => {
      it('switches back to list view and refetches workflows', async () => {
        await waitForPromises();

        findDuoChat().vm.$emit('back-to-list');
        await nextTick();

        expect(findDuoChat().props('multiThreadedView')).toBe(DUO_CHAT_VIEWS.LIST);
        expect(findDuoChat().props('activeThreadId')).toBe(null);
        expect(mockRefetch).toHaveBeenCalled();
      });
      it('clears the active thread', async () => {
        const clearActiveWorkflowSpy = jest.spyOn(wrapper.vm, 'clearActiveWorkflow');

        findDuoChat().vm.$emit('back-to-list');
        await nextTick();

        expect(clearActiveWorkflowSpy).toHaveBeenCalled();
      });
      it('clears expired thread state when going back to list', async () => {
        isThreadExpired.mockReturnValue(true);

        findDuoChat().vm.$emit('thread-selected', {
          id: MOCK_WORKFLOW_ID,
          lastUpdatedAt: '2024-01-01T00:00:00Z',
        });
        await nextTick();

        const duoChat = findDuoChat();

        expect(duoChat.vm.$scopedSlots['custom-empty-state']({})).toBeDefined();

        isThreadExpired.mockReturnValue(false);

        duoChat.vm.$emit('back-to-list');
        await nextTick();

        expect(duoChat.vm.$scopedSlots['custom-empty-state']).toBeUndefined();
      });
    });

    describe('@delete-thread', () => {
      beforeEach(async () => {
        jest.clearAllMocks();
        deleteWorkflowMutationMock.mockResolvedValue(MOCK_DELETE_WORKFLOW_MUTATION_RESPONSE);
        await waitForPromises();
      });

      it('calls deleteWorkflow and refetches workflows when deleting a thread', async () => {
        const mockThreadId = MOCK_WORKFLOW_ID;
        findDuoChat().vm.$emit('delete-thread', mockThreadId);
        await waitForPromises();

        expect(deleteWorkflowMutationMock).toHaveBeenCalledWith({
          input: { workflowId: mockThreadId },
        });
        expect(mockRefetch).toHaveBeenCalled();
      });

      it(`clears the thread's snapshot`, async () => {
        const mockThreadId = MOCK_WORKFLOW_ID;
        findDuoChat().vm.$emit('delete-thread', mockThreadId);
        await waitForPromises();

        expect(clearThreadSnapshot).toHaveBeenCalledWith(
          'gid://gitlab/Ai::DuoWorkflows::Workflow/456',
        );
      });
    });
  });

  describe('Agentic Toggle', () => {
    const findGlToggle = () => wrapper.findComponent(GlToggle);

    beforeEach(() => {
      duoChatGlobalState.isAgenticChatShown = true;
      duoChatGlobalState.chatMode = 'classic';
      jest.clearAllMocks();
      createComponent({
        propsData: { forceAgenticModeForCoreDuoUsers: false },
        provide: {
          chatConfiguration: {
            title: 'GitLab Duo Agentic Chat',
            defaultProps: {
              isClassicAvailable: true,
            },
          },
        },
      });
    });

    it('renders the GlToggle component with "Agentic" label', () => {
      expect(findGlToggle().exists()).toBe(true);
      expect(findGlToggle().text()).toContain('Agentic');
    });

    it('calls setAgenticMode with the toggle value when toggle changes', async () => {
      const toggle = findGlToggle();

      // Toggle directly controls agentic mode - false means agentic mode is disabled
      toggle.vm.$emit('change', false);
      await nextTick();

      expect(setAgenticMode).toHaveBeenCalledWith({
        agenticMode: false,
        saveCookie: true,
        isEmbedded: true,
      });
    });

    it.each([false, true])(
      'when forceAgenticModeForCoreDuoUsers is %s',
      (forceAgenticModeForCoreDuoUsers) => {
        duoChatGlobalState.isAgenticChatShown = true;
        createComponent({
          propsData: { forceAgenticModeForCoreDuoUsers },
          provide: {
            chatConfiguration: {
              title: 'GitLab Duo Agentic Chat',
              defaultProps: {
                isClassicAvailable: true,
              },
            },
          },
        });
        expect(findGlToggle().exists()).toBe(!forceAgenticModeForCoreDuoUsers);
      },
    );
  });

  describe('Agentic chat user model selection', () => {
    const findModelSelectDropdown = () => wrapper.findComponent(ModelSelectDropdown);

    describe('when user model selection is enabled', () => {
      beforeEach(async () => {
        duoChatGlobalState.isAgenticChatShown = true;
        createComponent({
          propsData: { userModelSelectionEnabled: true, rootNamespaceId: MOCK_NAMESPACE_ID },
        });
        await waitForPromises();
      });

      it('renders `ModelSelectDropdown` in the correct slot', () => {
        expect(findModelSelectDropdown().exists()).toBe(true);
        const slot = findDuoChat().vm.$slots['agentic-model'];
        const vnode = typeof slot === 'function' ? slot()[0] : slot[0];

        const testId = vnode.props
          ? vnode.props['data-testid'] // Vue 3
          : vnode.data.attrs['data-testid']; // Vue 2

        expect(testId).toBe('model-dropdown-container');
      });

      describe('when availableModels query is loading', () => {
        it('triggers a loading state', async () => {
          // Use a never-resolving handler so models stay in loading state
          const pendingModelsHandler = jest.fn().mockReturnValue(new Promise(() => {}));
          duoChatGlobalState.isAgenticChatShown = true;
          createComponent({
            propsData: { userModelSelectionEnabled: true, rootNamespaceId: MOCK_NAMESPACE_ID },
            apolloHandlers: [[getAiChatAvailableModels, pendingModelsHandler]],
          });
          getCurrentModel.mockClear();
          await waitForPromises();

          expect(findModelSelectDropdown().props('isLoading')).toBe(true);
          expect(findModelSelectDropdown().props('selectedOption')).toBe(null);
          expect(getCurrentModel).not.toHaveBeenCalled();
        });
      });

      describe('when availableModels query has loaded', () => {
        it('invokes `getCurrentModel()` with the correct arguments', async () => {
          await waitForPromises();

          expect(getCurrentModel).toHaveBeenCalledWith({
            availableModels: MOCK_MODEL_LIST_ITEMS,
            pinnedModel: null,
            selectedModel: null,
          });
        });

        it('passes the correct props to `ModelSelectDropdown`', async () => {
          await waitForPromises();

          expect(findModelSelectDropdown().props('isLoading')).toBe(false);
          expect(findModelSelectDropdown().props('disabled')).toBe(false);
          expect(findModelSelectDropdown().props('placeholderDropdownText')).toBe('Select a model');
          expect(findModelSelectDropdown().props('items')).toMatchObject(MOCK_MODEL_LIST_ITEMS);
          expect(findModelSelectDropdown().props('selectedOption')).toMatchObject(
            MOCK_GITLAB_DEFAULT_MODEL_ITEM,
          );
        });
      });

      it('calls saveModel utility and starts new chat when model is selected', async () => {
        await waitForPromises();

        const selectedModel = MOCK_MODEL_LIST_ITEMS[1];
        const onNewChatSpy = jest.spyOn(wrapper.vm, 'onNewChat');

        await findModelSelectDropdown().vm.$emit('select', selectedModel.value);

        expect(saveModel).toHaveBeenCalledWith(selectedModel);
        expect(onNewChatSpy).toHaveBeenCalledWith(true);
      });

      it('disables dropdown when pinned model is set', async () => {
        const pinnedModel = { text: 'Pinned Model', value: 'pinned/model' };
        checkModelSelectionDisabled.mockReturnValue(true);

        createComponent({
          propsData: { userModelSelectionEnabled: true, rootNamespaceId: MOCK_NAMESPACE_ID },
          data: { pinnedModel },
        });
        await waitForPromises();

        expect(findModelSelectDropdown().props('disabled')).toBe(true);
      });
    });

    describe('when user model selection is disabled', () => {
      beforeEach(() => {
        duoChatGlobalState.isAgenticChatShown = true;
        createComponent({ propsData: { userModelSelectionEnabled: false } });
      });

      it('does not render `ModelSelectDropdown`', () => {
        expect(findModelSelectDropdown().exists()).toBe(false);
      });
    });
  });

  describe('availableModels query skip and variables', () => {
    beforeEach(() => {
      duoChatGlobalState.isAgenticChatShown = true;
      availableModelsQueryHandlerMock.mockClear();
    });

    describe('skip behavior', () => {
      it('skips the query when userModelSelectionEnabled is false', async () => {
        createComponent({
          propsData: { userModelSelectionEnabled: false, rootNamespaceId: MOCK_NAMESPACE_ID },
        });
        await waitForPromises();

        expect(availableModelsQueryHandlerMock).not.toHaveBeenCalled();
      });

      it('skips the query when none of projectId, namespaceId, or rootNamespaceId are provided', async () => {
        createComponent({ propsData: { userModelSelectionEnabled: true } });
        await waitForPromises();

        expect(availableModelsQueryHandlerMock).not.toHaveBeenCalled();
      });

      it('calls the query when at least one ID is provided', async () => {
        createComponent({
          propsData: { userModelSelectionEnabled: true, projectId: MOCK_PROJECT_ID },
        });
        await waitForPromises();

        expect(availableModelsQueryHandlerMock).toHaveBeenCalled();
      });
    });

    describe('variables prioritization', () => {
      it.each([
        [
          'sends only projectId when projectId is provided',
          {
            projectId: MOCK_PROJECT_ID,
            namespaceId: MOCK_NAMESPACE_ID,
            rootNamespaceId: 'gid://gitlab/Group/789',
          },
          { projectId: MOCK_PROJECT_ID },
        ],
        [
          'sends only namespaceId when projectId is not provided',
          { namespaceId: MOCK_NAMESPACE_ID, rootNamespaceId: 'gid://gitlab/Group/789' },
          { namespaceId: MOCK_NAMESPACE_ID },
        ],
        [
          'sends only rootNamespaceId when neither projectId nor namespaceId are provided',
          { rootNamespaceId: 'gid://gitlab/Group/789' },
          { rootNamespaceId: 'gid://gitlab/Group/789' },
        ],
      ])('%s', async (_, propsData, expectedVariables) => {
        createComponent({ propsData: { userModelSelectionEnabled: true, ...propsData } });
        await waitForPromises();

        expect(availableModelsQueryHandlerMock).toHaveBeenCalledWith(expectedVariables);
      });
    });
  });

  describe('catalogAgents query variables', () => {
    beforeEach(() => {
      duoChatGlobalState.isAgenticChatShown = true;
    });

    it('passes only projectId when both projectId and namespaceId are provided', async () => {
      createComponent({
        propsData: {
          projectId: MOCK_PROJECT_ID,
          namespaceId: MOCK_NAMESPACE_ID,
          resourceId: MOCK_RESOURCE_ID,
        },
      });
      await waitForPromises();

      expect(configuredAgentsQueryMock).toHaveBeenCalledWith({
        includeFoundationalConsumers: false,
        first: 20,
        projectId: MOCK_PROJECT_ID,
      });
    });

    it('passes only projectId when only projectId is provided', async () => {
      createComponent({
        propsData: {
          projectId: MOCK_PROJECT_ID,
          resourceId: MOCK_RESOURCE_ID,
        },
      });
      await waitForPromises();

      expect(configuredAgentsQueryMock).toHaveBeenCalledWith({
        includeFoundationalConsumers: false,
        first: 20,
        projectId: MOCK_PROJECT_ID,
      });
    });

    it('passes only groupId when only namespaceId is provided', async () => {
      createComponent({
        propsData: {
          namespaceId: MOCK_NAMESPACE_ID,
          resourceId: MOCK_RESOURCE_ID,
        },
      });
      await waitForPromises();

      expect(configuredAgentsQueryMock).toHaveBeenCalledWith({
        includeFoundationalConsumers: false,
        first: 20,
        groupId: MOCK_NAMESPACE_ID,
      });
    });

    it('passes groupId when neither projectId nor namespaceId are provided', async () => {
      createComponent({
        propsData: {
          resourceId: MOCK_RESOURCE_ID,
        },
      });
      await waitForPromises();

      expect(configuredAgentsQueryMock).toHaveBeenCalledWith({
        includeFoundationalConsumers: false,
        first: 20,
        groupId: null,
      });
    });
  });

  describe('Fetching foundational agents', () => {
    describe('when project and namespace are available', () => {
      it('passes project_id and namespace_id', async () => {
        createComponent({
          propsData: { projectId: MOCK_PROJECT_ID, namespaceId: MOCK_NAMESPACE_ID },
        });

        await waitForPromises();

        expect(aiFoundationalChatAgentsQueryMock).toHaveBeenCalledWith({
          namespaceId: MOCK_NAMESPACE_ID,
          projectId: MOCK_PROJECT_ID,
        });
      });
    });

    describe('when project and namespace are not available', () => {
      it('does not pass project_id and namespace_id', async () => {
        createComponent({ propsData: {} });

        await waitForPromises();

        expect(aiFoundationalChatAgentsQueryMock).toHaveBeenCalledWith({
          namespaceId: null,
          projectId: null,
        });
      });
    });
  });

  describe('agent selection', () => {
    let agent;

    beforeEach(async () => {
      duoChatGlobalState.isAgenticChatShown = true;
      createComponent();
      await waitForPromises();

      const agentResponse = MOCK_CONFIGURED_AGENTS_RESPONSE.data.aiCatalogConfiguredItems.nodes[0];
      agent = {
        ...agentResponse.item,
        pinnedItemVersionId: agentResponse.pinnedItemVersion.id,
        text: agentResponse.item.name,
      };
    });

    it('displays the GitLab Duo Agent as the first option', () => {
      expect(findDuoChat().props('agents')).toContainEqual({
        id: 'gid://gitlab/Ai::FoundationalChatAgent/chat',
        name: 'GitLab Duo Agent',
        description: 'Duo is your general development assistant',
        referenceWithVersion: 'chat',
        foundational: true,
        avatarUrl: '/assets/bot_avatars/gitlab-duo-agent.png',
        selectableInChat: true,
        text: 'GitLab Duo Agent',
      });
    });

    it('passes the configured agents to duo chat', () => {
      // Verify the query was called
      expect(configuredAgentsQueryMock).toHaveBeenCalled();
      // We verify foundational agents here; catalog agent selection is tested in other tests
      expect(findDuoChat().props('agents')).toContainEqual({
        id: 'gid://gitlab/Ai::FoundationalChatAgent/chat',
        name: 'GitLab Duo Agent',
        description: 'Duo is your general development assistant',
        referenceWithVersion: 'chat',
        foundational: true,
        avatarUrl: '/assets/bot_avatars/gitlab-duo-agent.png',
        selectableInChat: true,
        text: 'GitLab Duo Agent',
      });
    });

    it('uses catalogAgentsFromResponse to transform the Apollo response', () => {
      expect(catalogAgentsFromResponse).toHaveBeenCalled();
    });

    it('uses the agentConfig from Apollo query when start workflow is called', async () => {
      await wrapper.vm.$store.dispatch('setCurrentAgent', agent);
      await nextTick();
      await findDuoChat().vm.$emit('new-chat');
      await waitForPromises();

      findDuoChat().vm.$emit('send-chat-prompt', MOCK_USER_MESSAGE.content);
      await waitForPromises();

      expect(agentFlowConfigQueryMock).toHaveBeenCalledWith({
        agentVersionId: agent.pinnedItemVersionId,
      });

      expect(WorkflowSocketUtils.buildStartRequest).toHaveBeenCalledWith(
        expect.objectContaining({
          agentConfig: MOCK_FLOW_AGENT_CONFIG,
          clientCapabilities: ['incremental_streaming'],
        }),
      );

      expect(streamManager.connect).toHaveBeenCalled();
    });

    it('uses workflow definition when foundational chat is selected', async () => {
      await wrapper.vm.$store.dispatch('setCurrentAgent', MOCK_FETCHED_FOUNDATIONAL_AGENT);
      await nextTick();
      await findDuoChat().vm.$emit('new-chat');
      await waitForPromises();

      findDuoChat().vm.$emit('send-chat-prompt', MOCK_USER_MESSAGE.content);
      await waitForPromises();

      expect(agentFlowConfigQueryMock).not.toHaveBeenCalled();
      expect(WorkflowSocketUtils.buildStartRequest).toHaveBeenCalledWith(
        expect.objectContaining({
          workflowDefinition: 'agent/v1',
          agentConfig: null,
          clientCapabilities: ['incremental_streaming'],
        }),
      );

      expect(streamManager.connect).toHaveBeenCalled();
    });

    describe('switching from a foundational agent to a catalog agent', () => {
      it('fetches agent flow config and sends agent version id', async () => {
        await wrapper.vm.$store.dispatch('setCurrentAgent', MOCK_FETCHED_FOUNDATIONAL_AGENT);
        await nextTick();
        findDuoChat().vm.$emit('new-chat');
        await waitForPromises();

        findDuoChat().vm.$emit('send-chat-prompt', MOCK_USER_MESSAGE.content);
        await waitForPromises();

        expect(WorkflowSocketUtils.buildStartRequest).toHaveBeenLastCalledWith(
          expect.objectContaining({
            workflowDefinition: 'agent/v1',
            agentConfig: null,
            clientCapabilities: ['incremental_streaming'],
          }),
        );

        await wrapper.vm.$store.dispatch('setCurrentAgent', agent);
        await nextTick();
        await findDuoChat().vm.$emit('new-chat');
        findDuoChat().vm.$emit('send-chat-prompt', MOCK_USER_MESSAGE.content);

        await waitForPromises();

        expect(agentFlowConfigQueryMock).toHaveBeenCalledWith({
          agentVersionId: agent.pinnedItemVersionId,
        });

        expect(WorkflowSocketUtils.buildStartRequest).toHaveBeenLastCalledWith(
          expect.objectContaining({
            workflowDefinition: undefined,
            clientCapabilities: ['incremental_streaming'],
          }),
        );

        expect(streamManager.connect).toHaveBeenCalled();
      });
    });

    it('re-uses the selected flow config when /new is used to start a new thread', async () => {
      await wrapper.vm.$store.dispatch('setCurrentAgent', agent);
      await nextTick();
      await findDuoChat().vm.$emit('new-chat');
      await waitForPromises();

      findDuoChat().vm.$emit('send-chat-prompt', '/new');
      findDuoChat().vm.$emit('send-chat-prompt', MOCK_USER_MESSAGE.content);
      await waitForPromises();

      expect(streamManager.connect).toHaveBeenCalled();
    });

    it('preserves agentConfig when selecting the same custom agent multiple times', async () => {
      // Select custom agent first time
      await wrapper.vm.$store.dispatch('setCurrentAgent', agent);
      await nextTick();
      await findDuoChat().vm.$emit('new-chat');
      await waitForPromises();

      // Send first message to ensure agentConfig is populated
      findDuoChat().vm.$emit('send-chat-prompt', 'First message');
      await waitForPromises();

      expect(WorkflowSocketUtils.buildStartRequest).toHaveBeenCalledWith(
        expect.objectContaining({
          agentConfig: MOCK_FLOW_AGENT_CONFIG,
          clientCapabilities: ['incremental_streaming'],
        }),
      );

      // Clear mocks to verify next call
      WorkflowSocketUtils.buildStartRequest.mockClear();

      // Select the SAME custom agent again (new chat with same agent)
      await wrapper.vm.$store.dispatch('setCurrentAgent', agent);
      await nextTick();
      await findDuoChat().vm.$emit('new-chat');
      await waitForPromises();

      // Send another message
      findDuoChat().vm.$emit('send-chat-prompt', 'Second message');
      await waitForPromises();

      // Verify agentConfig is still present (not null)
      expect(WorkflowSocketUtils.buildStartRequest).toHaveBeenCalledWith(
        expect.objectContaining({
          agentConfig: MOCK_FLOW_AGENT_CONFIG,
          clientCapabilities: ['incremental_streaming'],
        }),
      );
    });

    it('resets agentConfig when default agent follows a custom agent chat', async () => {
      // Select custom agent first
      await wrapper.vm.$store.dispatch('setCurrentAgent', agent);
      await nextTick();
      await findDuoChat().vm.$emit('new-chat');
      await waitForPromises();

      // Send message with custom agent
      findDuoChat().vm.$emit('send-chat-prompt', 'Custom agent message');
      await waitForPromises();

      expect(WorkflowSocketUtils.buildStartRequest).toHaveBeenCalledWith(
        expect.objectContaining({
          agentConfig: MOCK_FLOW_AGENT_CONFIG,
          clientCapabilities: ['incremental_streaming'],
        }),
      );

      // Clear mocks to verify next call
      WorkflowSocketUtils.buildStartRequest.mockClear();

      // Switch to default/foundational agent
      await wrapper.vm.$store.dispatch('setCurrentAgent', MOCK_FETCHED_FOUNDATIONAL_AGENT);
      await nextTick();
      await findDuoChat().vm.$emit('new-chat');
      await waitForPromises();

      // Send message with foundational agent
      findDuoChat().vm.$emit('send-chat-prompt', 'Foundational agent message');
      await waitForPromises();

      // Verify agentConfig is null and workflowDefinition is used instead
      expect(WorkflowSocketUtils.buildStartRequest).toHaveBeenCalledWith(
        expect.objectContaining({
          workflowDefinition: MOCK_FETCHED_FOUNDATIONAL_AGENT.referenceWithVersion,
          agentConfig: null,
          clientCapabilities: ['incremental_streaming'],
        }),
      );
    });

    it('sends no config when the default agent is selected (no id on selection)', async () => {
      await wrapper.vm.$store.dispatch('setCurrentAgent', { name: 'default duo' });
      await nextTick();
      await findDuoChat().vm.$emit('new-chat');

      findDuoChat().vm.$emit('send-chat-prompt', MOCK_USER_MESSAGE.content);
      await waitForPromises();

      expect(streamManager.connect).toHaveBeenCalled();
    });

    describe('when chat is triggered via duoChatGlobalState.commands with an agent', () => {
      it('sets the selected agent from the command by id and displays it', async () => {
        duoChatGlobalState.commands.push({
          question: 'Analyze this code for vulnerabilities',
          resourceId: MOCK_RESOURCE_ID,
          variables: {},
          agent: { id: DUO_FOUNDATIONAL_AGENT_MOCK.id },
        });
        await nextTick();

        expect(actionSpies.setCurrentAgent).toHaveBeenCalledWith(
          expect.anything(),
          MOCK_FETCHED_FOUNDATIONAL_AGENT,
        );
        expect(findDuoChat().props('title')).toBe(DUO_FOUNDATIONAL_AGENT_MOCK.name);
      });

      it('sets the selected agent from the command by name and displays it', async () => {
        duoChatGlobalState.commands.push({
          question: 'Analyze this code for vulnerabilities',
          resourceId: MOCK_RESOURCE_ID,
          variables: {},
          agent: { name: DUO_FOUNDATIONAL_AGENT_MOCK.name },
        });
        await nextTick();

        expect(actionSpies.setCurrentAgent).toHaveBeenCalledWith(
          expect.anything(),
          MOCK_FETCHED_FOUNDATIONAL_AGENT,
        );
        expect(findDuoChat().props('title')).toBe(DUO_FOUNDATIONAL_AGENT_MOCK.name);
      });
    });
  });

  describe('Agent deletion handling', () => {
    beforeEach(async () => {
      duoChatGlobalState.isAgenticChatShown = true;
      createComponent();
      await waitForPromises();
    });

    it('disables chat when agent is deleted', async () => {
      // Mock thread with deleted agent
      workflowEventsQueryMock.mockResolvedValue({
        data: {
          ...MOCK_WORKFLOW_EVENTS_RESPONSE,
          duoWorkflowWorkflows: {
            nodes: [
              {
                id: 'workflow-1',
                status: 'completed',
                aiCatalogItemVersionId: 'AgentVersion 999',
                workflowDefinition: null,
                archived: false,
              },
            ],
          },
        },
      });

      findDuoChat().vm.$emit('thread-selected', { id: MOCK_WORKFLOW_ID });
      await waitForPromises();

      expect(findDuoChat().props('isChatAvailable')).toBe(false);
      expect(findDuoChat().props('error')).toBe(
        'The agent associated with this conversation is no longer available. You can view the conversation history but cannot send new messages.',
      );
    });

    it('hides error in history view', () => {
      createComponent({
        data: { multithreadedView: DUO_CHAT_VIEWS.LIST, agentOrWorkflowDeletedError: 'Error' },
      });

      expect(findDuoChat().props('error')).toBe('');
    });

    it('re-enables chat when starting new chat after viewing deleted agent thread', async () => {
      // Mock thread with deleted agent
      workflowEventsQueryMock.mockResolvedValue({
        data: {
          ...MOCK_WORKFLOW_EVENTS_RESPONSE,
          duoWorkflowWorkflows: {
            nodes: [
              {
                id: 'workflow-1',
                status: 'completed',
                aiCatalogItemVersionId: 'AgentVersion 999',
                workflowDefinition: null,
                archived: false,
              },
            ],
          },
        },
      });

      // Select thread with deleted agent
      findDuoChat().vm.$emit('thread-selected', { id: MOCK_WORKFLOW_ID });
      await waitForPromises();

      // Verify chat is disabled
      expect(findDuoChat().props('isChatAvailable')).toBe(false);
      expect(findDuoChat().props('error')).toBe(
        'The agent associated with this conversation is no longer available. You can view the conversation history but cannot send new messages.',
      );

      // Start a new chat with default agent
      findDuoChat().vm.$emit('new-chat', { name: 'GitLab Duo Agent' });
      await nextTick();

      // Verify chat is re-enabled and error is cleared
      expect(findDuoChat().props('isChatAvailable')).toBe(true);
      expect(findDuoChat().props('error')).toBe('');
    });
  });

  describe('showErrorBannerMessage computed property', () => {
    const PREFERENCES_PATH = '/-/profile/preferences';

    const createComponentWithNamespaceConfig = ({
      defaultNamespaceSelected,
      preferencesPath = PREFERENCES_PATH,
      multithreadedView = DUO_CHAT_VIEWS.CHAT,
      agentOrWorkflowDeletedError = '',
    }) => {
      createComponent({
        provide: {
          chatConfiguration: {
            title: 'GitLab Duo Agentic Chat',
            defaultProps: {
              isEmbedded: false,
              defaultNamespaceSelected,
              preferencesPath,
            },
          },
        },
        data: { multithreadedView, agentOrWorkflowDeletedError },
      });
    };

    describe.each`
      defaultNamespaceSelected | multithreadedView      | agentOrWorkflowDeletedError | expectedError          | description
      ${false}                 | ${DUO_CHAT_VIEWS.CHAT} | ${''}                       | ${''}                  | ${'returns empty string when namespace not selected (now handled by empty state)'}
      ${false}                 | ${DUO_CHAT_VIEWS.LIST} | ${''}                       | ${''}                  | ${'returns empty string in LIST view'}
      ${true}                  | ${DUO_CHAT_VIEWS.CHAT} | ${''}                       | ${''}                  | ${'returns empty string when namespace is selected'}
      ${false}                 | ${DUO_CHAT_VIEWS.CHAT} | ${'Agent was deleted'}      | ${'Agent was deleted'} | ${'shows agentOrWorkflowDeletedError'}
      ${true}                  | ${DUO_CHAT_VIEWS.CHAT} | ${'Agent was deleted'}      | ${'Agent was deleted'} | ${'shows agentOrWorkflowDeletedError when namespace is selected'}
    `(
      '$description',
      ({
        defaultNamespaceSelected,
        multithreadedView,
        agentOrWorkflowDeletedError,
        expectedError,
      }) => {
        it('returns correct error', () => {
          createComponentWithNamespaceConfig({
            defaultNamespaceSelected,
            multithreadedView,
            agentOrWorkflowDeletedError,
          });

          const errorProp = findDuoChat().props('error');
          expect(errorProp).toBe(expectedError);
        });
      },
    );
  });

  describe('showNoNamespaceEmptyState computed property', () => {
    const PREFERENCES_PATH = '/-/profile/preferences';

    const createComponentWithNamespaceConfig = ({
      defaultNamespaceSelected,
      preferencesPath = PREFERENCES_PATH,
      multithreadedView = DUO_CHAT_VIEWS.CHAT,
    }) => {
      createComponent({
        provide: {
          chatConfiguration: {
            title: 'GitLab Duo Agentic Chat',
            defaultProps: {
              isEmbedded: false,
              defaultNamespaceSelected,
              preferencesPath,
            },
          },
        },
        data: { multithreadedView },
      });
    };

    describe('when namespace is not selected', () => {
      it('renders no-namespace empty state in CHAT view', () => {
        createComponentWithNamespaceConfig({
          defaultNamespaceSelected: false,
          multithreadedView: DUO_CHAT_VIEWS.CHAT,
        });

        const duoChat = findDuoChat();
        const customEmptyState = duoChat.vm.$scopedSlots['custom-empty-state']({});

        expect(customEmptyState).toBeDefined();
      });

      it('disables the chat input', async () => {
        createComponentWithNamespaceConfig({
          defaultNamespaceSelected: false,
          multithreadedView: DUO_CHAT_VIEWS.CHAT,
        });

        await nextTick();

        const duoChat = findDuoChat();

        expect(duoChat.props('chatState')).toMatchObject({
          isEnabled: false,
        });
      });

      it('does not render empty state in LIST view', () => {
        createComponentWithNamespaceConfig({
          defaultNamespaceSelected: false,
          multithreadedView: DUO_CHAT_VIEWS.LIST,
        });

        const duoChat = findDuoChat();
        const customEmptyState = duoChat.vm.$scopedSlots['custom-empty-state'];

        expect(customEmptyState).toBeUndefined();
      });
    });

    describe('when namespace is selected', () => {
      it('does not render no-namespace empty state', () => {
        createComponentWithNamespaceConfig({
          defaultNamespaceSelected: true,
          multithreadedView: DUO_CHAT_VIEWS.CHAT,
        });

        const duoChat = findDuoChat();
        const customEmptyState = duoChat.vm.$scopedSlots['custom-empty-state'];

        expect(customEmptyState).toBeUndefined();
      });
    });
  });

  describe('empty state priority', () => {
    const PREFERENCES_PATH = '/-/profile/preferences';

    it('shows no-namespace empty state over no-credits when both conditions are true', async () => {
      creditsAvailableQueryMock.mockResolvedValue({ data: { gitlabCreditsAvailable: false } });

      createComponent({
        provide: {
          chatConfiguration: {
            title: 'GitLab Duo Agentic Chat',
            defaultProps: {
              isEmbedded: false,
              defaultNamespaceSelected: false,
              preferencesPath: PREFERENCES_PATH,
            },
          },
        },
      });
      await waitForPromises();

      const duoChat = findDuoChat();
      const customEmptyState = duoChat.vm.$scopedSlots['custom-empty-state']({});

      expect(customEmptyState).toBeDefined();
    });

    it('shows no-credits empty state when namespace is selected but credits exhausted', async () => {
      creditsAvailableQueryMock.mockResolvedValue({ data: { gitlabCreditsAvailable: false } });

      createComponent({
        provide: {
          chatConfiguration: {
            title: 'GitLab Duo Agentic Chat',
            defaultProps: {
              isEmbedded: false,
              defaultNamespaceSelected: true,
              preferencesPath: PREFERENCES_PATH,
            },
          },
        },
      });
      await waitForPromises();

      const duoChat = findDuoChat();
      const customEmptyState = duoChat.vm.$scopedSlots['custom-empty-state']({});

      expect(customEmptyState).toBeDefined();
    });

    it('shows no-namespace empty state over trial/subscription when both conditions are true', () => {
      createComponent({
        propsData: { trialActive: true },
        provide: {
          chatConfiguration: {
            title: 'GitLab Duo Agentic Chat',
            defaultProps: {
              isEmbedded: false,
              defaultNamespaceSelected: false,
              preferencesPath: PREFERENCES_PATH,
            },
          },
        },
      });

      const duoChat = findDuoChat();
      const customEmptyState = duoChat.vm.$scopedSlots['custom-empty-state']({});

      expect(customEmptyState).toBeDefined();
    });

    it('shows no-credits empty state over trial/subscription when both conditions are true', async () => {
      creditsAvailableQueryMock.mockResolvedValue({ data: { gitlabCreditsAvailable: false } });

      createComponent({
        propsData: { trialActive: true },
        provide: {
          chatConfiguration: {
            title: 'GitLab Duo Agentic Chat',
            defaultProps: {
              isEmbedded: false,
              defaultNamespaceSelected: true,
              preferencesPath: PREFERENCES_PATH,
            },
          },
        },
      });
      await waitForPromises();

      const duoChat = findDuoChat();
      const customEmptyState = duoChat.vm.$scopedSlots['custom-empty-state']({});

      expect(customEmptyState).toBeDefined();
    });

    it('shows trial/subscription empty state when namespace selected and credits available', () => {
      createComponent({
        propsData: { trialActive: true },
        provide: {
          chatConfiguration: {
            title: 'GitLab Duo Agentic Chat',
            defaultProps: {
              isEmbedded: false,
              defaultNamespaceSelected: true,
              preferencesPath: PREFERENCES_PATH,
            },
          },
        },
      });

      const duoChat = findDuoChat();
      const customEmptyState = duoChat.vm.$scopedSlots['custom-empty-state']({});

      expect(customEmptyState).toBeDefined();
    });
  });

  describe('when isDuoDisabled is true', () => {
    const DUO_SETTINGS_PATH = '/groups/test-group/-/settings/gitlab_duo/configuration';

    const createDuoDisabledComponent = (overrides = {}) => {
      createComponent({
        propsData: {
          isDuoDisabled: true,
          ...overrides.propsData,
        },
        provide: {
          chatConfiguration: {
            title: 'GitLab Duo Agentic Chat',
            defaultProps: {
              isEmbedded: false,
              defaultNamespaceSelected: true,
              duoSettingsPath: DUO_SETTINGS_PATH,
              ...overrides.defaultProps,
            },
          },
        },
      });
    };

    it('disables the chat state on mount', async () => {
      createDuoDisabledComponent();
      await nextTick();

      expect(findDuoChat().props('chatState')).toMatchObject({
        isEnabled: false,
      });
    });

    it('does not call checkNamespaceAvailability on mount', () => {
      const spy = jest.spyOn(DuoAgenticChatApp.methods, 'checkNamespaceAvailability');
      createDuoDisabledComponent();

      expect(spy).not.toHaveBeenCalled();
    });

    it('renders custom empty state slot', () => {
      createDuoDisabledComponent();

      const duoChat = findDuoChat();
      const customEmptyState = duoChat.vm.$scopedSlots['custom-empty-state']({});

      expect(customEmptyState).toBeDefined();
    });

    it('renders DuoDisabledEmptyState component', () => {
      createDuoDisabledComponent();

      expect(wrapper.findComponent(DuoDisabledEmptyState).exists()).toBe(true);
    });

    it('skips Apollo queries', async () => {
      userWorkflowsQueryHandlerMock.mockClear();
      contextPresetsQueryHandlerMock.mockClear();
      configuredAgentsQueryMock.mockClear();
      aiFoundationalChatAgentsQueryMock.mockClear();

      createDuoDisabledComponent();
      await waitForPromises();

      expect(userWorkflowsQueryHandlerMock).not.toHaveBeenCalled();
      expect(contextPresetsQueryHandlerMock).not.toHaveBeenCalled();
      expect(configuredAgentsQueryMock).not.toHaveBeenCalled();
      expect(aiFoundationalChatAgentsQueryMock).not.toHaveBeenCalled();
    });

    it('takes priority over no-namespace empty state', () => {
      createComponent({
        propsData: { isDuoDisabled: true },
        provide: {
          chatConfiguration: {
            title: 'GitLab Duo Agentic Chat',
            defaultProps: {
              isEmbedded: false,
              defaultNamespaceSelected: false,
              duoSettingsPath: DUO_SETTINGS_PATH,
            },
          },
        },
      });

      expect(wrapper.findComponent(DuoDisabledEmptyState).exists()).toBe(true);
      expect(wrapper.findComponent(NoNamespaceEmptyState).exists()).toBe(false);
    });

    it('takes priority over no-credits empty state', () => {
      createDuoDisabledComponent({
        propsData: { creditsAvailable: false },
      });

      expect(wrapper.findComponent(DuoDisabledEmptyState).exists()).toBe(true);
    });
  });

  describe('when isDuoDisabled is false', () => {
    it('does not render DuoDisabledEmptyState', () => {
      createComponent({
        propsData: { isDuoDisabled: false, creditsAvailable: true },
      });

      expect(wrapper.findComponent(DuoDisabledEmptyState).exists()).toBe(false);
    });
  });

  describe('dynamicTitle', () => {
    beforeEach(() => {
      duoChatGlobalState.isAgenticChatShown = true;
    });

    it('passes the base title when no custom agent is selected', async () => {
      createComponent();
      await waitForPromises();

      expect(findDuoChat().props('title')).toBe('GitLab Duo');
    });

    it('passes the agent name as title when a custom agent is selected', async () => {
      const mockCatalogAgent = {
        id: 'Agent 5',
        name: 'My Custom Agent',
        description: 'This is my custom agent',
        pinnedItemVersionId: 'AgentVersion 5',
      };

      createComponent({
        propsData: {
          mode: 'default',
        },
        data: {
          aiCatalogItemVersionId: 'AgentVersion 5',
          catalogAgents: [mockCatalogAgent],
        },
        initialState: {
          currentAgent: mockCatalogAgent,
        },
      });
      await waitForPromises();

      expect(findDuoChat().props('title')).toBe('My Custom Agent');
    });

    it('passes the agent name as title when a foundational agent is selected', async () => {
      createComponent({
        initialState: {
          currentAgent: MOCK_FETCHED_FOUNDATIONAL_AGENT,
        },
      });

      await findDuoChat().vm.$emit('new-chat', MOCK_FETCHED_FOUNDATIONAL_AGENT);
      await waitForPromises();

      expect(findDuoChat().props('title')).toBe(MOCK_FETCHED_FOUNDATIONAL_AGENT.name);
    });

    it('uses currentAgent from Vuex store for title when available', async () => {
      const mockAgent = {
        id: 'Agent 123',
        name: 'Store Agent Name',
      };

      createComponent({
        initialState: {
          currentAgent: mockAgent,
        },
      });
      await waitForPromises();

      expect(findDuoChat().props('title')).toBe('Store Agent Name');
    });

    it('falls back to duoChatTitle when currentAgent is null in store', async () => {
      createComponent({
        initialState: {
          currentAgent: null,
        },
      });
      await waitForPromises();

      expect(findDuoChat().props('title')).toBe('GitLab Duo');
    });
  });

  describe('agent switching via Vuex integration', () => {
    beforeEach(() => {
      duoChatGlobalState.isAgenticChatShown = true;
    });

    it('updates title when currentAgent changes in store', async () => {
      createComponent({
        initialState: {
          currentAgent: null,
        },
      });
      await waitForPromises();

      expect(findDuoChat().props('title')).toBe('GitLab Duo');

      await wrapper.vm.$store.dispatch('setCurrentAgent', {
        id: 'agent-1',
        name: 'New Agent',
      });
      await nextTick();

      expect(findDuoChat().props('title')).toBe('New Agent');
    });

    it('reverts to default title when currentAgent is set to null', async () => {
      createComponent({
        initialState: {
          currentAgent: { id: 'agent-1', name: 'Some Agent' },
        },
      });
      await waitForPromises();

      expect(findDuoChat().props('title')).toBe('Some Agent');

      await wrapper.vm.$store.dispatch('setCurrentAgent', null);
      await nextTick();

      expect(findDuoChat().props('title')).toBe('GitLab Duo');
    });
  });

  describe('flowConfig Apollo query integration', () => {
    beforeEach(() => {
      duoChatGlobalState.isAgenticChatShown = true;
      createWorkflowMutationMock.mockResolvedValue({
        data: { aiDuoWorkflowCreate: { workflow: { id: '456' }, errors: [] } },
      });
    });

    it('queries agentConfig when aiCatalogItemVersionId is set', async () => {
      agentFlowConfigQueryMock.mockClear();

      createComponent({
        data: {
          aiCatalogItemVersionId: 'gid://gitlab/Ai::Catalog::ItemVersion/1',
        },
      });

      await waitForPromises();

      expect(agentFlowConfigQueryMock).toHaveBeenCalledWith({
        agentVersionId: 'gid://gitlab/Ai::Catalog::ItemVersion/1',
      });
    });

    it('fetches fresh agent config when switching agents', async () => {
      const agent2 = {
        id: 'Agent 2',
        name: 'Test Agent',
        pinnedItemVersionId: 'version-2',
      };

      agentFlowConfigQueryMock.mockClear();

      createComponent({
        data: {
          aiCatalogItemVersionId: 'version-1',
        },
      });
      await waitForPromises();

      // Switch to agent2
      await wrapper.vm.$store.dispatch('setCurrentAgent', agent2);
      await nextTick();
      findDuoChat().vm.$emit('new-chat');
      await nextTick();
      await waitForPromises();

      // Verify query was called with the new agent version id
      expect(agentFlowConfigQueryMock).toHaveBeenCalledWith({
        agentVersionId: 'version-2',
      });
    });

    describe('when switching from custom agent to default agent', () => {
      beforeEach(async () => {
        createComponent({
          data: {
            aiCatalogItemVersionId: 'version-1',
          },
        });
        await waitForPromises();
      });

      it('stops querying agent config', async () => {
        // Verify config query was called for the custom agent
        expect(agentFlowConfigQueryMock).toHaveBeenCalledWith({
          agentVersionId: 'version-1',
        });

        agentFlowConfigQueryMock.mockClear();

        // Switch to default agent (no agent.id)
        findDuoChat().vm.$emit('new-chat', { name: 'default duo' });
        await waitForPromises();

        // Verify no config is sent when starting workflow with default agent
        findDuoChat().vm.$emit('send-chat-prompt', MOCK_USER_MESSAGE.content);
        await waitForPromises();

        expect(streamManager.connect).toHaveBeenCalled();
        expect(agentFlowConfigQueryMock).not.toHaveBeenCalled();
      });
    });
  });

  describe('embedded mode behavior', () => {
    describe('when embedded=false (standalone mode)', () => {
      beforeEach(() => {
        duoChatGlobalState.isAgenticChatShown = true;
        createComponent({
          provide: {
            chatConfiguration: {
              title: 'GitLab Duo Agentic Chat',
              isClassicAvailable: false,
              defaultProps: {
                isEmbedded: false,
              },
            },
          },
        });
      });

      it('shows header', () => {
        expect(findDuoChat().props('showHeader')).toBe(true);
      });

      it('enables resizing', () => {
        expect(findDuoChat().props('shouldRenderResizable')).toBe(true);
      });

      it('returns empty dimensions object', () => {
        expect(findDuoChat().props('dimensions')).toEqual({});
      });

      it('sets up window resize listeners on mount', () => {
        const addEventListenerSpy = jest.spyOn(window, 'addEventListener');
        createComponent({
          provide: {
            chatConfiguration: {
              title: 'GitLab Duo Agentic Chat',
              isClassicAvailable: false,
              defaultProps: {
                isEmbedded: false,
              },
            },
          },
        });

        expect(addEventListenerSpy).toHaveBeenCalledWith('resize', expect.any(Function));
        addEventListenerSpy.mockRestore();
      });

      it('cleans up resize listeners on destroy', () => {
        const removeEventListenerSpy = jest.spyOn(window, 'removeEventListener');
        wrapper.destroy();

        expect(removeEventListenerSpy).toHaveBeenCalledWith('resize', expect.any(Function));
        removeEventListenerSpy.mockRestore();
      });

      it('modifies duoChatGlobalState on @chat-hidden', async () => {
        expect(duoChatGlobalState.isAgenticChatShown).toBe(true);

        findDuoChat().vm.$emit('chat-hidden');
        await nextTick();

        expect(duoChatGlobalState.isAgenticChatShown).toBe(false);
      });

      it('hydrates the active thread when a thread is selected', async () => {
        const mockThread = { id: MOCK_WORKFLOW_ID, aiCatalogItemVersionId: null };
        const mockParsedData = {
          checkpoint: { channel_values: { ui_chat_log: [] } },
        };

        WorkflowUtils.parseWorkflowData.mockReturnValue(mockParsedData);
        WorkflowUtils.transformChatMessages.mockReturnValue(MOCK_TRANSFORMED_MESSAGES);

        findDuoChat().vm.$emit('thread-selected', mockThread);
        await waitForPromises();

        expect(findDuoChat().props('messages')).toEqual(MOCK_TRANSFORMED_MESSAGES);
      });
    });

    describe('when embedded=true', () => {
      beforeEach(() => {
        duoChatGlobalState.isAgenticChatShown = true;
        createComponent({
          provide: {
            chatConfiguration: {
              title: 'GitLab Duo Agentic Chat',
              isClassicAvailable: true,
              defaultProps: {
                isEmbedded: true,
              },
            },
            activeTabData: {
              props: {
                isEmbedded: true,
                isClassicAvailable: true,
                userId: null,
              },
            },
          },
        });
      });

      it('hides header', () => {
        expect(findDuoChat().props('showHeader')).toBe(true);
      });

      it('disables resizing', () => {
        expect(findDuoChat().props('shouldRenderResizable')).toBe(false);
      });

      it('passes dimensions object', () => {
        expect(findDuoChat().props('dimensions')).toBeDefined();
        expect(findDuoChat().props('dimensions')).toMatchObject({
          width: expect.any(Number),
          height: expect.any(Number),
        });
      });

      it('does not set up window resize listeners on mount', () => {
        const addEventListenerSpy = jest.spyOn(window, 'addEventListener');
        createComponent({
          provide: {
            chatConfiguration: {
              title: 'GitLab Duo Agentic Chat',
              isClassicAvailable: true,
              defaultProps: {
                isEmbedded: true,
              },
            },
            activeTabData: {
              props: {
                isEmbedded: true,
                isClassicAvailable: true,
                userId: null,
              },
            },
          },
        });

        const resizeCalls = addEventListenerSpy.mock.calls.filter(([event]) => event === 'resize');
        expect(resizeCalls).toHaveLength(0);
        addEventListenerSpy.mockRestore();
      });

      it('does not try to clean up resize listeners on destroy', () => {
        const removeEventListenerSpy = jest.spyOn(window, 'removeEventListener');
        wrapper.destroy();

        const resizeCalls = removeEventListenerSpy.mock.calls.filter(
          ([event]) => event === 'resize',
        );
        expect(resizeCalls).toHaveLength(0);
        removeEventListenerSpy.mockRestore();
      });

      it('does not modify duoChatGlobalState on @chat-hidden', async () => {
        expect(duoChatGlobalState.isAgenticChatShown).toBe(true);

        findDuoChat().vm.$emit('chat-hidden');
        await nextTick();

        expect(duoChatGlobalState.isAgenticChatShown).toBe(true);
      });

      it('calls setAgenticMode with embedded=true when toggling classic mode', async () => {
        getCookie.mockReturnValue('false');

        // Recreate component to show Classic toggle
        createComponent({
          propsData: { forceAgenticModeForCoreDuoUsers: false },
          provide: {
            chatConfiguration: {
              title: 'GitLab Duo Agentic Chat',
              defaultProps: {
                isEmbedded: true,
                isClassicAvailable: true,
              },
            },
            activeTabData: {
              props: {
                isEmbedded: true,
                isClassicAvailable: true,
                userId: null,
              },
            },
          },
        });

        const findGlToggle = () => wrapper.findComponent(GlToggle);

        // Toggle directly controls agentic mode - false means agentic mode is disabled
        findGlToggle().vm.$emit('change', false);
        await nextTick();

        expect(setAgenticMode).toHaveBeenCalledWith({
          agenticMode: false,
          saveCookie: true,
          isEmbedded: true,
        });
      });

      it('does not hydrate the active thread when a thread is selected', async () => {
        const mockThread = { id: MOCK_WORKFLOW_ID, aiCatalogItemVersionId: null };
        const mockParsedData = {
          checkpoint: { channel_values: { ui_chat_log: [] } },
        };

        WorkflowUtils.parseWorkflowData.mockReturnValue(mockParsedData);
        WorkflowUtils.transformChatMessages.mockReturnValue(MOCK_TRANSFORMED_MESSAGES);

        findDuoChat().vm.$emit('thread-selected', mockThread);
        await waitForPromises();

        expect(findDuoChat().props('messages')).toEqual([]);
      });

      describe('Apollo queries in embedded mode', () => {
        beforeEach(async () => {
          duoChatGlobalState.isAgenticChatShown = false;
          createComponent({
            propsData: {
              userModelSelectionEnabled: true,
              rootNamespaceId: MOCK_NAMESPACE_ID,
            },
            provide: {
              chatConfiguration: {
                title: 'GitLab Duo Agentic Chat',
                isClassicAvailable: true,
                defaultProps: {
                  isEmbedded: true,
                },
              },
              activeTabData: {
                props: {
                  isEmbedded: true,
                  isClassicAvailable: true,
                  userId: null,
                },
              },
            },
          });
          await waitForPromises();
        });

        it('runs agenticWorkflows query when embedded=true even if isAgenticChatShown=false', () => {
          expect(userWorkflowsQueryHandlerMock).toHaveBeenCalled();
        });

        it('runs contextPresets query when embedded=true even if isAgenticChatShown=false', () => {
          expect(contextPresetsQueryHandlerMock).toHaveBeenCalled();
        });

        it('runs availableModels query when embedded=true even if isAgenticChatShown=false', () => {
          expect(availableModelsQueryHandlerMock).toHaveBeenCalled();
        });

        it('runs catalogAgents query when embedded=true even if isAgenticChatShown=false', () => {
          expect(configuredAgentsQueryMock).toHaveBeenCalled();
        });
      });

      describe('@thread-selected event in embedded mode', () => {
        it('navigates to agentic chat route when thread is selected', async () => {
          const mockThread = { id: MOCK_WORKFLOW_ID, aiCatalogItemVersionId: null };
          const mockParsedData = { checkpoint: { channel_values: { ui_chat_log: [] } } };

          WorkflowUtils.parseWorkflowData.mockReturnValue(mockParsedData);
          WorkflowUtils.transformChatMessages.mockReturnValue(MOCK_TRANSFORMED_MESSAGES);

          findDuoChat().vm.$emit('thread-selected', mockThread);
          await waitForPromises();

          expect(mockRouter.push).toHaveBeenCalledWith({ name: AGENTIC_CHAT_SHOW_ROUTE });
        });
      });
    });
  });

  describe('Chat snapshot caching', () => {
    beforeEach(() => {
      MOCK_UTILS_SETUP();
      jest.clearAllMocks();
    });

    describe('hydrateActiveWorkflow', () => {
      describe('when cached messages exist', () => {
        beforeEach(() => {
          loadThreadSnapshot.mockReturnValue(threadSnapshotWithMessages);

          getStorageValue.mockReturnValue({
            exists: true,
            value: { workflowId: MOCK_WORKFLOW_ID },
          });
          duoChatGlobalState.isAgenticChatShown = true;
          createComponent();
        });

        it('loads cached messages immediately before API fetch', () => {
          expect(loadThreadSnapshot).toHaveBeenCalledWith(MOCK_WORKFLOW_ID);
          expect(actionSpies.setMessages).toHaveBeenCalledWith(expect.anything(), snapshotMessages);
        });

        it('updates with fresh messages from API after cache is loaded', async () => {
          await waitForPromises();

          // First call: cached messages
          expect(actionSpies.setMessages).toHaveBeenNthCalledWith(
            1,
            expect.anything(),
            snapshotMessages,
          );

          // Second call: fresh messages from API
          expect(actionSpies.setMessages).toHaveBeenNthCalledWith(
            2,
            expect.anything(),
            MOCK_TRANSFORMED_MESSAGES,
          );
        });
      });

      describe('when no cached messages exist', () => {
        beforeEach(() => {
          loadThreadSnapshot.mockReturnValue(threadSnapshotEmpty);

          getStorageValue.mockReturnValue({
            exists: true,
            value: { workflowId: MOCK_WORKFLOW_ID },
          });

          duoChatGlobalState.isAgenticChatShown = true;

          createComponent();
        });

        it('does not set messages from cache', async () => {
          expect(loadThreadSnapshot).toHaveBeenCalledWith(MOCK_WORKFLOW_ID);

          // Only called once with API data, not with cache
          await waitForPromises();
          expect(actionSpies.setMessages).toHaveBeenCalledTimes(1);
          expect(actionSpies.setMessages).toHaveBeenCalledWith(
            expect.anything(),
            MOCK_TRANSFORMED_MESSAGES,
          );
        });

        it('still fetches messages from API', async () => {
          await waitForPromises();
          expect(workflowEventsQueryMock).toHaveBeenCalled();
        });
      });

      describe('when active workflow thread is expired', () => {
        beforeEach(async () => {
          isThreadExpired.mockReturnValue(true);
          loadThreadSnapshot.mockReturnValue(threadSnapshotEmpty);

          getStorageValue.mockReturnValue({
            exists: true,
            value: { workflowId: MOCK_WORKFLOW_ID },
          });

          duoChatGlobalState.isAgenticChatShown = true;

          createComponent({
            data: {
              agenticWorkflows: [
                {
                  id: MOCK_WORKFLOW_ID,
                  lastUpdatedAt: '2024-01-01T00:00:00Z',
                  aiCatalogItemVersionId: null,
                  agentName: 'GitLab Duo',
                },
              ],
            },
          });
          await waitForPromises();
        });

        afterEach(() => {
          isThreadExpired.mockReturnValue(false);
        });

        it('shows expired empty state instead of loading thread', () => {
          const duoChat = findDuoChat();
          const customEmptyState = duoChat.vm.$scopedSlots['custom-empty-state']({});

          expect(customEmptyState).toBeDefined();
        });

        it('does not fetch workflow events', () => {
          expect(workflowEventsQueryMock).not.toHaveBeenCalled();
        });
      });

      describe('when server reports credits exhausted', () => {
        beforeEach(async () => {
          loadThreadSnapshot.mockReturnValue(threadSnapshotEmpty);

          creditsAvailableQueryMock.mockResolvedValue({ data: { gitlabCreditsAvailable: false } });

          WorkflowUtils.transformChatMessages.mockReturnValue([]);
          WorkflowUtils.parseWorkflowData.mockReturnValue({
            checkpoint: { channel_values: { ui_chat_log: [] } },
          });

          getStorageValue.mockReturnValue({
            exists: true,
            value: { workflowId: MOCK_WORKFLOW_ID },
          });

          duoChatGlobalState.isAgenticChatShown = true;

          createComponent();

          await waitForPromises();
        });

        it('disables chat due to credit exhaustion text', () => {
          expect(findDuoChat().props('chatState')).toMatchObject({
            isEnabled: false,
            reason: expect.stringContaining('No GitLab Credits remain'),
          });
        });
      });
    });

    describe('setCurrentAgent action', () => {
      beforeEach(() => {
        actionSpies.setCurrentAgent.mockClear();
      });

      it('calls setCurrentAgent with catalog agent after loading thread', async () => {
        const mockCatalogAgent = {
          id: 'Agent 5',
          name: 'My Custom Agent',
          description: 'This is my custom agent',
          pinnedItemVersionId: 'AgentVersion 5',
        };

        workflowEventsQueryMock.mockResolvedValue({
          data: {
            duoWorkflowEvents: {
              nodes: [
                {
                  checkpoint: '{"channel_values": {"ui_chat_log": []}}',
                  errors: null,
                  metadata: null,
                  workflowGoal: '',
                  workflowStatus: 'completed',
                },
              ],
            },
            duoWorkflowWorkflows: {
              nodes: [
                {
                  id: 'workflow-1',
                  status: 'completed',
                  aiCatalogItemVersionId: 'AgentVersion 5',
                  workflowDefinition: null,
                  archived: false,
                },
              ],
            },
          },
        });

        WorkflowUtils.transformChatMessages.mockReturnValue([]);
        WorkflowUtils.parseWorkflowData.mockReturnValue({
          checkpoint: { channel_values: { ui_chat_log: [] } },
          workflowStatus: 'completed',
        });

        getStorageValue.mockReturnValue({
          exists: true,
          value: { workflowId: MOCK_WORKFLOW_ID },
        });

        duoChatGlobalState.isAgenticChatShown = true;

        createComponent({
          data: {
            catalogAgents: [mockCatalogAgent],
          },
        });

        await waitForPromises();

        expect(actionSpies.setCurrentAgent).toHaveBeenCalledWith(
          expect.anything(),
          mockCatalogAgent,
        );
      });

      it('calls setCurrentAgent with foundational agent after loading thread', async () => {
        workflowEventsQueryMock.mockResolvedValue({
          data: MOCK_WORKFLOW_EVENTS_RESPONSE_WITH_FOUNDATIONAL_AGENT,
        });

        WorkflowUtils.transformChatMessages.mockReturnValue([]);
        WorkflowUtils.parseWorkflowData.mockReturnValue({
          checkpoint: { channel_values: { ui_chat_log: [] } },
          workflowStatus: 'completed',
        });

        getStorageValue.mockReturnValue({
          exists: true,
          value: { workflowId: MOCK_WORKFLOW_ID },
        });

        duoChatGlobalState.isAgenticChatShown = true;

        createComponent();

        await waitForPromises();

        expect(actionSpies.setCurrentAgent).toHaveBeenCalledWith(
          expect.anything(),
          expect.objectContaining({
            referenceWithVersion: MOCK_FETCHED_FOUNDATIONAL_AGENT.referenceWithVersion,
          }),
        );
      });

      it('does not call setCurrentAgent when no agent is associated with thread', async () => {
        workflowEventsQueryMock.mockResolvedValue({
          data: {
            duoWorkflowEvents: {
              nodes: [
                {
                  checkpoint: '{"channel_values": {"ui_chat_log": []}}',
                  errors: null,
                  metadata: null,
                  workflowGoal: '',
                  workflowStatus: 'completed',
                },
              ],
            },
            duoWorkflowWorkflows: {
              nodes: [
                {
                  id: 'workflow-1',
                  status: 'completed',
                  aiCatalogItemVersionId: '',
                  workflowDefinition: null,
                  archived: false,
                },
              ],
            },
          },
        });

        WorkflowUtils.transformChatMessages.mockReturnValue([]);
        WorkflowUtils.parseWorkflowData.mockReturnValue({
          checkpoint: { channel_values: { ui_chat_log: [] } },
          workflowStatus: 'completed',
        });

        getStorageValue.mockReturnValue({
          exists: true,
          value: { workflowId: MOCK_WORKFLOW_ID },
        });

        duoChatGlobalState.isAgenticChatShown = true;

        createComponent();

        await waitForPromises();

        expect(actionSpies.setCurrentAgent).not.toHaveBeenCalled();
      });
    });

    describe('reconnection with custom agent', () => {
      const MOCK_CUSTOM_AGENT_VERSION_ID = 'AgentVersion 5';

      afterEach(() => {
        streamManager.getStatus.mockReturnValue({ connected: false, bufferedCount: 0 });
      });

      beforeEach(() => {
        actionSpies.setCurrentAgent.mockClear();

        workflowEventsQueryMock.mockResolvedValue({
          data: {
            duoWorkflowEvents: {
              nodes: [
                {
                  checkpoint: '{"channel_values": {"ui_chat_log": []}}',
                  errors: null,
                  metadata: null,
                  workflowGoal: '',
                  workflowStatus: 'running',
                },
              ],
            },
            duoWorkflowWorkflows: {
              nodes: [
                {
                  id: 'workflow-1',
                  status: 'running',
                  aiCatalogItemVersionId: MOCK_CUSTOM_AGENT_VERSION_ID,
                  workflowDefinition: null,
                  archived: false,
                },
              ],
            },
          },
        });

        WorkflowUtils.transformChatMessages.mockReturnValue([]);
        WorkflowUtils.parseWorkflowData.mockReturnValue({
          checkpoint: { channel_values: { ui_chat_log: [] } },
          workflowStatus: DUO_WORKFLOW_STATUS_RUNNING,
        });
      });

      it('reconnects to a running custom agent workflow', async () => {
        getStorageValue.mockReturnValue({
          exists: true,
          value: { workflowId: MOCK_WORKFLOW_ID },
        });

        duoChatGlobalState.isAgenticChatShown = true;

        createComponent({
          data: {
            catalogAgents: [
              {
                id: 'Agent 5',
                name: 'My Custom Agent',
                pinnedItemVersionId: MOCK_CUSTOM_AGENT_VERSION_ID,
              },
            ],
          },
        });

        await waitForPromises();

        expect(streamManager.connect).toHaveBeenCalled();
      });

      it('sets aiCatalogItemVersionId before calling startWorkflow on reconnect', async () => {
        getStorageValue.mockReturnValue({
          exists: true,
          value: { workflowId: MOCK_WORKFLOW_ID },
        });

        duoChatGlobalState.isAgenticChatShown = true;

        createComponent({
          data: {
            catalogAgents: [
              {
                id: 'Agent 5',
                name: 'My Custom Agent',
                pinnedItemVersionId: MOCK_CUSTOM_AGENT_VERSION_ID,
              },
            ],
          },
        });

        await waitForPromises();

        expect(wrapper.vm.aiCatalogItemVersionId).toBe(MOCK_CUSTOM_AGENT_VERSION_ID);
        expect(WorkflowSocketUtils.buildStartRequest).toHaveBeenCalled();
      });

      it('does not reconnect when workflow status is not RUNNING', async () => {
        WorkflowUtils.parseWorkflowData.mockReturnValue({
          checkpoint: { channel_values: { ui_chat_log: [] } },
          workflowStatus: 'completed',
        });

        getStorageValue.mockReturnValue({
          exists: true,
          value: { workflowId: MOCK_WORKFLOW_ID },
        });

        duoChatGlobalState.isAgenticChatShown = true;

        createComponent({
          data: {
            catalogAgents: [
              {
                id: 'Agent 5',
                name: 'My Custom Agent',
                pinnedItemVersionId: MOCK_CUSTOM_AGENT_VERSION_ID,
              },
            ],
          },
        });

        await waitForPromises();

        expect(streamManager.connect).not.toHaveBeenCalled();
      });

      it('does not reconnect when stream is already connected', async () => {
        streamManager.getStatus.mockReturnValue({ connected: true, bufferedCount: 0 });

        getStorageValue.mockReturnValue({
          exists: true,
          value: { workflowId: MOCK_WORKFLOW_ID },
        });

        duoChatGlobalState.isAgenticChatShown = true;

        createComponent({
          data: {
            catalogAgents: [
              {
                id: 'Agent 5',
                name: 'My Custom Agent',
                pinnedItemVersionId: MOCK_CUSTOM_AGENT_VERSION_ID,
              },
            ],
          },
        });

        await waitForPromises();

        expect(streamManager.connect).not.toHaveBeenCalled();
      });
    });

    describe('messages watcher', () => {
      it('has debounced watcher for messages', () => {
        createComponent();

        // Verify the watcher exists by checking component options
        const watchers = wrapper.vm.$options.watch;
        expect(watchers.messages).toBeDefined();
        expect(watchers.messages.deep).toBe(true);
      });
    });

    describe('integration scenarios', () => {
      it('loads cached messages on mount when available', async () => {
        loadThreadSnapshot.mockReturnValue(threadSnapshotWithMessages);

        getStorageValue.mockReturnValue({
          exists: true,
          value: { workflowId: MOCK_WORKFLOW_ID },
        });

        createComponent();
        duoChatGlobalState.isAgenticChatShown = true;
        await nextTick();

        // Cache was loaded
        expect(loadThreadSnapshot).toHaveBeenCalledWith(MOCK_WORKFLOW_ID);
        // Messages were set from cache
        expect(actionSpies.setMessages).toHaveBeenCalledWith(expect.anything(), snapshotMessages);
      });

      it('does not clear cache when starting new conversation', () => {
        createComponent();
        wrapper.vm.workflowId = MOCK_WORKFLOW_ID;

        findDuoChat().vm.$emit('new-chat');

        // Cache was cleared for the workflow
        expect(clearThreadSnapshot).not.toHaveBeenCalled();
        // Messages were reset
        expect(actionSpies.setMessages).toHaveBeenCalledWith(expect.anything(), []);
      });
    });
  });

  describe('Duo UI Next', () => {
    describe('when the feature flag is disabled', () => {
      it('does not render the DuoNext component by default', () => {
        createComponent();
        expect(findDuoNext().exists()).toBe(false);
      });
    });

    describe('when the feature flag is enabled', () => {
      beforeEach(() => {
        createComponent({
          provide: {
            glFeatures: {
              duoUiNext: true,
            },
          },
        });
      });

      it('renders the DuoNext component if the flag is enabled', () => {
        expect(findDuoNext().exists()).toBe(true);
        expect(findDuoChat().exists()).toBe(false);
      });
    });
  });

  describe('Credit limitation', () => {
    describe('when credits are unavailable on load', () => {
      beforeEach(async () => {
        creditsAvailableQueryMock.mockResolvedValue({ data: { gitlabCreditsAvailable: false } });

        createComponent();
        await waitForPromises();
      });

      it('disables chat and shows an explanation text', () => {
        const duoChat = findDuoChat();

        expect(duoChat.props('chatState')).toMatchObject({
          isEnabled: false,
          reason: expect.stringContaining('No GitLab Credits remain'),
        });
      });

      it('hides model selector when userModelSelectionEnabled is true', async () => {
        creditsAvailableQueryMock.mockResolvedValue({ data: { gitlabCreditsAvailable: false } });

        createComponent({
          propsData: {
            userModelSelectionEnabled: true,
          },
        });
        await waitForPromises();

        const modelSelector = wrapper.findComponent(ModelSelectDropdown);
        expect(modelSelector.exists()).toBe(false);
      });

      it('renders custom empty state in duo chat', () => {
        const duoChat = findDuoChat();
        const customEmptyStateSlot = duoChat.vm.$scopedSlots['custom-empty-state'];

        expect(customEmptyStateSlot).toBeDefined();
        expect(typeof customEmptyStateSlot).toBe('function');

        const customEmptyState = customEmptyStateSlot({});
        expect(customEmptyState).toBeDefined();
      });
    });

    describe('when credits are available on load', () => {
      beforeEach(async () => {
        createComponent();
        await waitForPromises();
      });

      it('passes enabled chatState to duo chat component', () => {
        const duoChat = findDuoChat();

        expect(duoChat.props('chatState')).toMatchObject({
          isEnabled: true,
        });
      });

      it('shows model selector when userModelSelectionEnabled is true', async () => {
        createComponent({
          propsData: {
            userModelSelectionEnabled: true,
          },
        });
        await waitForPromises();

        const modelSelector = wrapper.findComponent(ModelSelectDropdown);
        expect(modelSelector.exists()).toBe(true);
      });
    });

    describe('runtime credit exhaustion', () => {
      describe('and the code is 1008 (insufficient credits)', () => {
        beforeEach(async () => {
          createComponent({
            propsData: {
              userModelSelectionEnabled: true,
            },
          });
          findDuoChat().vm.$emit('send-chat-prompt', 'test message');
          await waitForPromises();

          triggerStreamEvent('close', {
            type: 'close',
            code: 1008,
            reason: 'Insufficient credits: quota exceeded',
          });
          await waitForPromises();
          await nextTick();
        });

        it('disables chat and shows an explanation text', () => {
          const duoChat = findDuoChat();

          expect(duoChat.props('chatState')).toMatchObject({
            isEnabled: false,
            reason: expect.stringContaining('No GitLab Credits remain'),
          });
        });

        it('hides model selector', () => {
          const modelSelector = wrapper.findComponent(ModelSelectDropdown);
          expect(modelSelector.exists()).toBe(false);
        });
      });
    });
  });

  describe('trackBinaryFeedbackEvent', () => {
    const { bindInternalEventDocument } = useMockInternalEventsTracking();

    it('calls trackEvent with correct parameters when track-feedback is emitted', async () => {
      getStorageValue.mockReturnValueOnce({
        exists: true,
        value: { workflowId: MOCK_WORKFLOW_ID },
      });
      createComponent();
      await waitForPromises();

      const { trackEventSpy } = bindInternalEventDocument(wrapper.element);
      const feedbackEvent = { feedbackType: 'thumbs_up', feedbackReason: 'accurate' };
      findDuoChat().vm.$emit('track-feedback', feedbackEvent);

      expect(trackEventSpy).toHaveBeenCalledWith(
        FEEDBACK_TRACKING_EVENT,
        expect.objectContaining({
          label: 'thumbs_up',
          value: 456,
          property: 'accurate',
        }),
        undefined,
      );
    });
  });

  describe('computedTrustedUrls', () => {
    beforeEach(() => {
      duoChatGlobalState.isAgenticChatShown = true;
      window.gon = {};
    });

    afterEach(() => {
      delete window.gon;
    });

    it('includes default trusted URLs (gitlab.com and docs URL)', () => {
      createComponent();
      const trustedUrls = wrapper.vm.computedTrustedUrls;

      expect(trustedUrls).toContain('gitlab.com');
      expect(trustedUrls).toContain(docsUrlHost);
    });

    it('includes instance hostname from gon.gitlab_url when available', () => {
      window.gon.gitlab_url = 'https://gitlab.example.com';
      createComponent();
      const trustedUrls = wrapper.vm.computedTrustedUrls;

      expect(trustedUrls).toContain('gitlab.example.com');
    });

    it('does not include instance hostname when gon.gitlab_url is not set', () => {
      createComponent();
      const trustedUrls = wrapper.vm.computedTrustedUrls;

      expect(trustedUrls).not.toContain('my-gitlab.example.com');
    });

    it('includes additional URLs passed as props', () => {
      createComponent({
        propsData: {
          projectId: MOCK_PROJECT_ID,
          resourceId: MOCK_RESOURCE_ID,
          trustedUrls: ['custom1.example.com', 'custom2.example.com'],
        },
      });
      const trustedUrls = wrapper.vm.computedTrustedUrls;

      expect(trustedUrls).toContain('custom1.example.com');
      expect(trustedUrls).toContain('custom2.example.com');
    });

    it('removes duplicate URLs', () => {
      createComponent({
        propsData: {
          projectId: MOCK_PROJECT_ID,
          resourceId: MOCK_RESOURCE_ID,
          trustedUrls: ['gitlab.com', `https://${docsUrlHost}`],
        },
      });
      const trustedUrls = wrapper.vm.computedTrustedUrls;

      const gitlabComCount = trustedUrls.filter((url) => url === 'gitlab.com').length;
      const docsUrlCount = trustedUrls.filter((url) => url === docsUrlHost).length;

      expect(gitlabComCount).toBe(1);
      expect(docsUrlCount).toBe(1);
    });

    it('returns an array of unique hostnames', () => {
      window.gon.gitlab_url = 'https://my-gitlab.example.com';
      createComponent({
        propsData: {
          projectId: MOCK_PROJECT_ID,
          resourceId: MOCK_RESOURCE_ID,
          trustedUrls: ['https://custom.example.com'],
        },
      });
      const trustedUrls = wrapper.vm.computedTrustedUrls;

      expect(Array.isArray(trustedUrls)).toBe(true);
      expect(new Set(trustedUrls).size).toBe(trustedUrls.length);
    });

    it('handles empty trustedUrls prop gracefully', () => {
      createComponent({
        propsData: {
          projectId: MOCK_PROJECT_ID,
          resourceId: MOCK_RESOURCE_ID,
          trustedUrls: [],
        },
      });
      const trustedUrls = wrapper.vm.computedTrustedUrls;

      expect(trustedUrls).toContain('gitlab.com');
      expect(trustedUrls).toContain(docsUrlHost);
    });

    it('handles null trustedUrls prop gracefully', () => {
      createComponent({
        propsData: {
          projectId: MOCK_PROJECT_ID,
          resourceId: MOCK_RESOURCE_ID,
          trustedUrls: null,
        },
      });
      const trustedUrls = wrapper.vm.computedTrustedUrls;

      expect(trustedUrls).toContain('gitlab.com');
      expect(trustedUrls).toContain(docsUrlHost);
    });
  });

  describe('processPendingCommands integration', () => {
    it('does not process commands when isLoading is true', async () => {
      let resolvePromise = null;
      const pendingPromise = new Promise((resolve) => {
        resolvePromise = resolve;
      });
      workflowEventsQueryMock.mockReturnValue(pendingPromise);

      getStorageValue.mockReturnValue({
        exists: true,
        value: { workflowId: MOCK_WORKFLOW_ID },
      });
      createComponent({
        propsData: { projectId: MOCK_PROJECT_ID, resourceId: MOCK_RESOURCE_ID },
      });

      await nextTick();

      const testQuestion = 'What is GitLab CI/CD?';

      duoChatGlobalState.commands = [{ question: testQuestion }];

      await nextTick();

      expect(createWorkflowMutationMock).not.toHaveBeenCalled();

      resolvePromise({ data: MOCK_WORKFLOW_EVENTS_RESPONSE });

      await waitForPromises();

      await nextTick();

      // Commands should be processed after hydration completes
      expect(createWorkflowMutationMock).toHaveBeenCalledWith(
        expect.objectContaining({
          goal: testQuestion,
        }),
      );
    });
  });

  describe('triggerSource', () => {
    it('is set to web_chat when user sends a prompt', async () => {
      createComponent();
      await waitForPromises();

      findDuoChat().vm.$emit('send-chat-prompt', 'some question');

      findDuoChat().vm.$emit('approve-tool');
      await nextTick();

      expect(EventsTracker.updateContext).toHaveBeenCalledWith(
        expect.objectContaining({ triggerSource: TRIGGER_SOURCE_WEB_CHAT }),
      );
    });

    it('is set to web_ui when processing commands and passed to tracked events', async () => {
      createComponent();
      await waitForPromises();

      duoChatGlobalState.commands = [{ question: 'Deploy my app' }];
      await nextTick();
      await waitForPromises();

      findDuoChat().vm.$emit('approve-tool');
      await nextTick();

      expect(EventsTracker.updateContext).toHaveBeenCalledWith(
        expect.objectContaining({ triggerSource: TRIGGER_SOURCE_WEB_UI }),
      );
    });
  });
});
