import Vue from 'vue';
import VueApollo from 'vue-apollo';
import { shallowMountExtended } from 'helpers/vue_test_utils_helper';
import waitForPromises from 'helpers/wait_for_promises';
import createMockApollo from 'helpers/mock_apollo_helper';
import { createAlert } from '~/alert';
import WorkItemAgentSessions from 'ee/work_items/components/agent_sessions/index.vue';
import AgentSessionsList from 'ee/ai/shared/widgets/agent_sessions_list.vue';
import getDuoAgentSessionsOnWorkItemQuery from 'ee/ai/shared/widgets/graphql/get_duo_agent_sessions_on_work_item.query.graphql';

Vue.use(VueApollo);

jest.mock('~/alert');

const WORK_ITEM_ID = 'gid://gitlab/WorkItem/1';

const buildSession = (overrides = {}) => ({
  __typename: 'DuoWorkflow',
  id: 'gid://gitlab/Ai::DuoWorkflows::Workflow/1',
  status: 'RUNNING',
  humanStatus: 'Running',
  createdAt: '2024-01-15T09:00:00Z',
  updatedAt: '2024-01-15T10:00:00Z',
  workflowDefinition: 'my_flow',
  userId: null,
  project: {
    __typename: 'Project',
    id: 'gid://gitlab/Project/1',
    name: 'project',
    fullPath: 'namespace/project',
  },
  ...overrides,
});

const buildQueryResponse = (nodes = []) => ({
  data: {
    workItem: {
      __typename: 'WorkItem',
      id: WORK_ITEM_ID,
      features: {
        __typename: 'WorkItemFeatures',
        aiSession: {
          __typename: 'WorkItemAiSession',
          duoWorkflows: {
            __typename: 'DuoWorkflowConnection',
            nodes,
          },
        },
      },
    },
  },
});

describe('WorkItemAgentSessions', () => {
  let wrapper;
  let queryHandler;

  const createComponent = ({ workItemId = WORK_ITEM_ID, handler = queryHandler } = {}) => {
    wrapper = shallowMountExtended(WorkItemAgentSessions, {
      apolloProvider: createMockApollo([[getDuoAgentSessionsOnWorkItemQuery, handler]]),
      propsData: { workItemId },
    });
  };

  const findSessionsList = () => wrapper.findComponent(AgentSessionsList);

  beforeEach(() => {
    queryHandler = jest.fn().mockResolvedValue(buildQueryResponse());
  });

  describe('Apollo query', () => {
    it('queries with the workItemId', () => {
      createComponent();

      expect(queryHandler).toHaveBeenCalledWith(expect.objectContaining({ id: WORK_ITEM_ID }));
    });

    it('skips the query when workItemId is not set', () => {
      createComponent({ workItemId: null });

      expect(queryHandler).not.toHaveBeenCalled();
    });

    it('calls createAlert on query error', async () => {
      const error = new Error('GraphQL error');
      createComponent({ handler: jest.fn().mockRejectedValue(error) });
      await waitForPromises();

      expect(createAlert).toHaveBeenCalledWith(
        expect.objectContaining({ captureError: true, error }),
      );
    });
  });

  describe('AgentSessionsList', () => {
    it('is rendered while the query is in flight', () => {
      createComponent({ handler: jest.fn().mockReturnValue(new Promise(() => {})) });

      expect(findSessionsList().exists()).toBe(true);
      expect(findSessionsList().props('isLoading')).toBe(true);
    });

    it('passes all fetched sessions to the list', async () => {
      const sessions = [
        buildSession({ id: 'gid://gitlab/Ai::DuoWorkflows::Workflow/1', status: 'RUNNING' }),
        buildSession({ id: 'gid://gitlab/Ai::DuoWorkflows::Workflow/2', status: 'FINISHED' }),
      ];
      createComponent({ handler: jest.fn().mockResolvedValue(buildQueryResponse(sessions)) });
      await waitForPromises();

      expect(findSessionsList().props('sessions')).toEqual(sessions);
    });

    it('passes isLoading=false once the query resolves', async () => {
      const sessions = [buildSession()];
      createComponent({ handler: jest.fn().mockResolvedValue(buildQueryResponse(sessions)) });
      await waitForPromises();

      expect(findSessionsList().props('isLoading')).toBe(false);
    });
  });
});
