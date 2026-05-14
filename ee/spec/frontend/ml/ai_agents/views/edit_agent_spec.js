import {
  GlButton,
  GlFormInput,
  GlFormTextarea,
  GlForm,
  GlExperimentBadge,
  GlFormFields,
  GlAlert,
  GlEmptyState,
} from '@gitlab/ui';
import Vue from 'vue';
import VueApollo from 'vue-apollo';
import { mountExtended } from 'helpers/vue_test_utils_helper';
import EditAgent from 'ee/ml/ai_agents/views/edit_agent.vue';
import getLatestAiAgentVersionQuery from 'ee/ml/ai_agents/graphql/queries/get_latest_ai_agent_version.query.graphql';
import createMockApollo from 'helpers/mock_apollo_helper';
import waitForPromises from 'helpers/wait_for_promises';
import TitleArea from '~/vue_shared/components/registry/title_area.vue';
import {
  getLatestAiAgentResponse,
  getLatestAiAgentErrorResponse,
  getLatestAiAgentNotFoundResponse,
} from '../graphql/mocks';

Vue.use(VueApollo);

const push = jest.fn();
const $router = {
  push,
};

describe('ee/ml/ai_agents/views/edit_agent', () => {
  let wrapper;
  let apolloMocks;
  const agentId = 1;

  const createComponent = () => {
    const apolloProvider = createMockApollo(apolloMocks);

    wrapper = mountExtended(EditAgent, {
      apolloProvider,
      provide: { projectPath: 'path/to/project' },
      mocks: {
        $router,
        $route: {
          params: {
            agentId,
          },
        },
      },
    });
  };

  const findTitleArea = () => wrapper.findComponent(TitleArea);
  const findBadge = () => wrapper.findComponent(GlExperimentBadge);
  const findButton = () => wrapper.findComponent(GlButton);
  const findForm = () => wrapper.findComponent(GlForm);
  const findInput = () => wrapper.findComponent(GlFormInput);
  const findTextarea = () => wrapper.findComponent(GlFormTextarea);
  const findFormFields = () => wrapper.findComponent(GlFormFields);
  const findErrorAlert = () => wrapper.findComponent(GlAlert);
  const findEmptyState = () => wrapper.findComponent(GlEmptyState);

  describe('when the agent data has successfully loaded', () => {
    beforeEach(async () => {
      apolloMocks = [
        [getLatestAiAgentVersionQuery, jest.fn().mockResolvedValueOnce(getLatestAiAgentResponse)],
      ];
      createComponent();
      await waitForPromises();
    });

    it('renders the page title', () => {
      expect(findTitleArea().text()).toContain('Agent Settings');
    });

    it('displays the experiment badge', () => {
      expect(findBadge().exists()).toBe(true);
    });

    it('renders the button', () => {
      expect(findButton().text()).toBe('Update agent');
    });

    it('renders the form and expected inputs', () => {
      expect(findForm().exists()).toBe(true);
      expect(findInput().exists()).toBe(true);
      expect(findTextarea().exists()).toBe(true);
      expect(findFormFields().props('values').name).toEqual('agent-1');
      expect(findFormFields().props('values').prompt).toEqual('example prompt');
    });
  });

  describe('when the agent data fails to load', () => {
    beforeEach(async () => {
      apolloMocks = [
        [
          getLatestAiAgentVersionQuery,
          jest.fn().mockResolvedValueOnce(getLatestAiAgentNotFoundResponse),
        ],
      ];
      createComponent();
      await waitForPromises();
    });

    it('displays an error', () => {
      expect(findEmptyState().text()).toBe('The requested agent was not found.');
    });
  });

  describe('when an exceptions happens loading data', () => {
    beforeEach(async () => {
      apolloMocks = [
        [
          getLatestAiAgentVersionQuery,
          jest.fn().mockResolvedValueOnce(getLatestAiAgentErrorResponse),
        ],
      ];
      createComponent();
      await waitForPromises();
    });

    it('displays an error', () => {
      expect(findErrorAlert().text()).toContain('An error has occurred when loading the agent.');
    });
  });
});
