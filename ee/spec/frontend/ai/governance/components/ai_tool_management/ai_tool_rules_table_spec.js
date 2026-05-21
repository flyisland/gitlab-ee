import Vue from 'vue';
import VueApollo from 'vue-apollo';
import { GlAlert, GlKeysetPagination, GlLoadingIcon, GlTruncate } from '@gitlab/ui';
import { mountExtended } from 'helpers/vue_test_utils_helper';
import createMockApollo from 'helpers/mock_apollo_helper';
import waitForPromises from 'helpers/wait_for_promises';
import { createAlert } from '~/alert';
import AiToolRulesTable from 'ee/ai/governance/components/ai_tool_management/ai_tool_rules_table.vue';
import AiToolRuleAccessControl from 'ee/ai/governance/components/ai_tool_management/ai_tool_rule_access_control.vue';

jest.mock('~/alert');

Vue.use(VueApollo);

const mockPageInfo = {
  hasNextPage: true,
  hasPreviousPage: false,
  startCursor: 'cursor-start',
  endCursor: 'cursor-end',
  __typename: 'PageInfo',
};

const mockToolRules = {
  nodes: [
    {
      id: 'list_issues',
      name: 'list_issues',
      actionType: 'READ',
      category: 'GitLab Read',
      source: 'gitlab',
      webAccess: 'ALLOW',
      localAccess: null,
      __typename: 'AiToolRule',
    },
    {
      id: 'run_command',
      name: 'run_command',
      actionType: 'DESTROY',
      category: 'Commands',
      source: 'gitlab',
      webAccess: 'DENY',
      localAccess: 'ASK',
      __typename: 'AiToolRule',
    },
  ],
  pageInfo: mockPageInfo,
  __typename: 'AiToolRuleConnection',
};

const mockMutationSuccess = (overrides = {}) => ({
  data: {
    updateAiToolRule: {
      id: 'list_issues',
      webAccess: 'ASK',
      localAccess: null,
      errors: [],
      __typename: 'UpdateAiToolRulePayload',
      ...overrides,
    },
  },
});

describe('AiToolRulesTable', () => {
  let wrapper;
  let mutationHandler;

  const createComponent = ({
    aiToolRulesResolver = jest.fn().mockReturnValue(mockToolRules),
    mutationHandlerImpl = jest.fn().mockResolvedValue(mockMutationSuccess()),
  } = {}) => {
    mutationHandler = mutationHandlerImpl;

    const apolloProvider = createMockApollo([], {
      Query: { aiToolRules: aiToolRulesResolver },
      Mutation: { updateAiToolRule: (_, { input }) => mutationHandler({ input }) },
    });

    wrapper = mountExtended(AiToolRulesTable, {
      apolloProvider,
      provide: {
        groupFullPath: 'gitlab-org',
      },
      stubs: {
        AiToolRuleAccessControl: true,
        GlTruncate,
      },
    });
  };

  const findAlert = () => wrapper.findComponent(GlAlert);
  const findRows = () => wrapper.findAllByTestId('ai-tool-rule-row');
  const findPagination = () => wrapper.findComponent(GlKeysetPagination);
  const findAccessControls = (testId) => wrapper.findAllByTestId(testId);
  const findWebAccessControl = (index = 0) =>
    findAccessControls('tool-web-access-control').at(index);
  const findLocalAccessControl = (index = 0) =>
    findAccessControls('tool-local-access-control').at(index);

  afterEach(() => {
    createAlert.mockClear();
  });

  describe('when loading', () => {
    beforeEach(() => {
      createComponent({ aiToolRulesResolver: jest.fn() });
    });

    it('shows loading icon', () => {
      expect(wrapper.findComponent(GlLoadingIcon).exists()).toBe(true);
    });

    it('does not show error alert', () => {
      expect(findAlert().exists()).toBe(false);
    });
  });

  describe('when data is loaded', () => {
    beforeEach(async () => {
      createComponent();
      await waitForPromises();
    });

    it('renders a row for each tool rule', () => {
      expect(findRows()).toHaveLength(2);
    });

    it('renders tool names', () => {
      const names = wrapper.findAllByTestId('tool-name');
      expect(names.at(0).text()).toBe('list_issues');
      expect(names.at(1).text()).toBe('run_command');
    });

    it('renders tool categories', () => {
      const categories = wrapper.findAllByTestId('tool-category');
      expect(categories.at(0).text()).toBe('GitLab Read');
      expect(categories.at(1).text()).toBe('Commands');
    });

    it('renders tool sources', () => {
      const sources = wrapper.findAllByTestId('tool-source');
      expect(sources.at(0).text()).toBe('gitlab');
    });

    it('renders action type badges', () => {
      expect(wrapper.findAllByTestId('tool-action-type').at(0).text()).toBe('READ');
      expect(wrapper.findAllByTestId('tool-action-type').at(1).text()).toBe('DESTROY');
    });

    it('renders web access controls with correct value', () => {
      expect(findAccessControls('tool-web-access-control')).toHaveLength(2);
    });

    it('renders local access controls with correct value', () => {
      expect(findAccessControls('tool-local-access-control')).toHaveLength(2);
    });
  });

  describe('updateRule', () => {
    beforeEach(async () => {
      createComponent();
      await waitForPromises();
    });

    it('calls the mutation with correct variables when webAccess is updated', async () => {
      findWebAccessControl(0).findComponent(AiToolRuleAccessControl).vm.$emit('select', 'ASK');
      await waitForPromises();

      expect(mutationHandler).toHaveBeenCalledWith({
        input: {
          toolId: 'list_issues',
          webAccess: 'ASK',
          localAccess: null,
        },
      });
    });

    it('calls the mutation with correct variables when localAccess is updated', async () => {
      findLocalAccessControl(0).findComponent(AiToolRuleAccessControl).vm.$emit('select', 'DENY');
      await waitForPromises();

      expect(mutationHandler).toHaveBeenCalledWith({
        input: {
          toolId: 'list_issues',
          webAccess: 'ALLOW',
          localAccess: 'DENY',
        },
      });
    });

    it('clears isLoading after the mutation resolves', async () => {
      findWebAccessControl(0).findComponent(AiToolRuleAccessControl).vm.$emit('select', 'ASK');
      await waitForPromises();

      expect(
        findWebAccessControl(0).findComponent(AiToolRuleAccessControl).props('isLoading'),
      ).toBe(false);
    });

    describe('when the mutation returns GraphQL errors', () => {
      beforeEach(async () => {
        createComponent({
          mutationHandlerImpl: jest
            .fn()
            .mockResolvedValue(mockMutationSuccess({ errors: ['Something went wrong'] })),
        });
        await waitForPromises();

        findWebAccessControl(0).findComponent(AiToolRuleAccessControl).vm.$emit('select', 'ASK');
        await waitForPromises();
      });

      it('calls createAlert with the error message', () => {
        expect(createAlert).toHaveBeenCalledWith({
          message: 'Failed to update tool rule. Please try again.',
          captureError: true,
        });
      });
    });

    describe('when the mutation throws a network error', () => {
      beforeEach(async () => {
        createComponent({
          mutationHandlerImpl: jest.fn().mockRejectedValue(new Error('Network error')),
        });
        await waitForPromises();

        findWebAccessControl(0).findComponent(AiToolRuleAccessControl).vm.$emit('select', 'ASK');
        await waitForPromises();
      });

      it('calls createAlert with the error message', () => {
        expect(createAlert).toHaveBeenCalledWith({
          message: 'Failed to update tool rule. Please try again.',
          captureError: true,
        });
      });
    });
  });

  describe('pagination', () => {
    describe('when pages are available', () => {
      let aiToolRulesResolver;

      beforeEach(async () => {
        aiToolRulesResolver = jest.fn().mockReturnValue(mockToolRules);
        createComponent({ aiToolRulesResolver });
        await waitForPromises();
      });

      it('renders pagination', () => {
        expect(findPagination().exists()).toBe(true);
      });

      it('fetches next page when pagination emits next', async () => {
        findPagination().vm.$emit('next', mockPageInfo.endCursor);
        await waitForPromises();

        expect(aiToolRulesResolver).toHaveBeenCalledTimes(2);
        expect(aiToolRulesResolver).toHaveBeenLastCalledWith(
          expect.anything(),
          expect.objectContaining({ after: mockPageInfo.endCursor, before: null }),
          expect.anything(),
          expect.anything(),
        );
      });

      it('fetches previous page when pagination emits prev', async () => {
        findPagination().vm.$emit('prev', mockPageInfo.startCursor);
        await waitForPromises();

        expect(aiToolRulesResolver).toHaveBeenCalledTimes(2);
        expect(aiToolRulesResolver).toHaveBeenLastCalledWith(
          expect.anything(),
          expect.objectContaining({ before: mockPageInfo.startCursor, after: null }),
          expect.anything(),
          expect.anything(),
        );
      });
    });

    describe('when no pages are available', () => {
      it('does not render pagination', async () => {
        createComponent({
          aiToolRulesResolver: jest.fn().mockReturnValue({
            ...mockToolRules,
            pageInfo: { hasNextPage: false, hasPreviousPage: false, __typename: 'PageInfo' },
          }),
        });
        await waitForPromises();

        expect(findPagination().exists()).toBe(false);
      });
    });
  });

  describe('empty state', () => {
    beforeEach(async () => {
      createComponent({
        aiToolRulesResolver: jest.fn().mockReturnValue({
          nodes: [],
          pageInfo: { hasNextPage: false, hasPreviousPage: false, __typename: 'PageInfo' },
          __typename: 'AiToolRuleConnection',
        }),
      });
      await waitForPromises();
    });

    it('shows empty state message', () => {
      expect(wrapper.findByTestId('ai-tool-rules-empty').exists()).toBe(true);
      expect(wrapper.text()).toContain('No tool rules found.');
    });
  });

  describe('error state', () => {
    beforeEach(async () => {
      createComponent({
        aiToolRulesResolver: jest.fn().mockRejectedValue(new Error('GraphQL error')),
      });
      await waitForPromises();
    });

    it('shows error alert', () => {
      expect(findAlert().exists()).toBe(true);
      expect(findAlert().text()).toContain('Failed to load tool rules.');
    });
  });
});
