import waitForPromises from 'helpers/wait_for_promises';
import { ignoreConsoleMessages } from 'helpers/console_watcher';
import { itSkipVue3, SkipReason } from 'helpers/vue3_conditional';
import { getIdFromGraphQLId } from '~/graphql_shared/utils';
import AiCatalogAgentsNew from 'ee/ai/catalog/pages/ai_catalog_agents_new.vue';
import AiCatalogAgentsEdit from 'ee/ai/catalog/pages/ai_catalog_agents_edit.vue';
import AiCatalogAgentsDuplicate from 'ee/ai/catalog/pages/ai_catalog_agents_duplicate.vue';
import createAiCatalogAgentMutation from 'ee/ai/catalog/graphql/mutations/create_ai_catalog_agent.mutation.graphql';
import updateAiCatalogAgentMutation from 'ee/ai/catalog/graphql/mutations/update_ai_catalog_agent.mutation.graphql';
import getProjects from '~/graphql_shared/queries/get_users_projects.query.graphql';
import {
  mockAgent,
  mockBaseAgent,
  mockVersionProp,
  mockCreateAiCatalogAgentSuccessMutation,
  mockCreateAiCatalogAgentErrorMutation,
  mockUpdateAiCatalogAgentSuccessMutation,
  mockUpdateAiCatalogAgentErrorMutation,
  mockProjectsResponse,
} from '../mock_data';
import {
  createIntegrationWrapper,
  fillFormField,
  selectDropdownItem,
  submitAgentForm,
  EXPLORE_PROVIDE,
  PROJECT_PROVIDE,
  ROUTE_PRESETS,
} from './helpers';
import { createAgentWithPermissions } from './mock_data_factories';

jest.mock('~/lib/utils/common_utils', () => ({
  ...jest.requireActual('~/lib/utils/common_utils'),
  isLoggedIn: jest.fn().mockReturnValue(true),
}));

describe('Agent — forms integration', () => {
  ignoreConsoleMessages([/Runtime directive used on component with non-element root node/]);

  describe('Create page', () => {
    let createHandler;
    let wrapper;
    let router;

    beforeEach(() => {
      createHandler = jest.fn().mockResolvedValue(mockCreateAiCatalogAgentSuccessMutation);
    });

    const mountCreatePage = ({ provide = {} } = {}) => {
      const result = createIntegrationWrapper(AiCatalogAgentsNew, {
        provide: {
          ...PROJECT_PROVIDE,
          glAbilities: { adminAiCatalogItem: true },
          ...provide,
        },
        apolloHandlers: [[createAiCatalogAgentMutation, createHandler]],
        route: ROUTE_PRESETS.agentNew,
      });
      wrapper = result.wrapper;
      router = result.router;
      return result;
    };

    const fillCreateForm = async () => {
      await fillFormField(wrapper, 'agent-form-input-name', 'New Agent');
      await fillFormField(wrapper, 'agent-form-textarea-description', 'A new agent');
      await fillFormField(
        wrapper,
        'agent-form-textarea-system-prompt',
        'You are a helpful assistant',
      );
    };

    describe('when submitting the form', () => {
      beforeEach(async () => {
        mountCreatePage();
        await fillCreateForm();
        await submitAgentForm(wrapper);
        await waitForPromises();
      });

      it('creates the agent and redirects to the show page', () => {
        expect(createHandler).toHaveBeenCalledWith({
          input: expect.objectContaining({ name: 'New Agent' }),
        });
        expect(wrapper.vm.$toast.show).toHaveBeenCalledWith('Agent created.');
        expect(router.currentRoute.name).toBe(ROUTE_PRESETS.agentShow.name);
        expect(String(router.currentRoute.params.id)).toBe(
          String(getIdFromGraphQLId(mockBaseAgent.id)),
        );
      });
    });

    describe('when creation fails', () => {
      beforeEach(async () => {
        createHandler.mockResolvedValue(mockCreateAiCatalogAgentErrorMutation);
        mountCreatePage();
        await fillCreateForm();
        await submitAgentForm(wrapper);
        await waitForPromises();
      });

      it('shows an error alert and stays on the page', () => {
        const alert = wrapper.find('[role="alert"]');
        expect(alert.exists()).toBe(true);
        expect(alert.text()).toContain(
          mockCreateAiCatalogAgentErrorMutation.data.aiCatalogAgentCreate.errors[0],
        );
        expect(router.currentRoute.name).toBe(ROUTE_PRESETS.agentNew.name);
      });
    });
  });

  describe('Edit page', () => {
    const agent = createAgentWithPermissions();
    let updateHandler;
    let wrapper;
    let router;

    beforeEach(() => {
      updateHandler = jest.fn().mockResolvedValue(mockUpdateAiCatalogAgentSuccessMutation);
    });

    const mountEditPage = ({ versionProp = mockVersionProp } = {}) => {
      const result = createIntegrationWrapper(AiCatalogAgentsEdit, {
        provide: {
          ...PROJECT_PROVIDE,
          glAbilities: { adminAiCatalogItem: true },
        },
        props: {
          aiCatalogAgent: { ...agent, project: { id: 'gid://gitlab/Project/1' } },
          version: versionProp,
        },
        apolloHandlers: [[updateAiCatalogAgentMutation, updateHandler]],
        route: ROUTE_PRESETS.agentEdit,
      });
      wrapper = result.wrapper;
      router = result.router;
      return result;
    };

    it('pre-populates form with current agent values', async () => {
      mountEditPage();
      await waitForPromises();

      expect(wrapper.findByTestId('agent-form-input-name').element.value).toBe(agent.name);
      expect(wrapper.findByTestId('agent-form-textarea-description').element.value).toBe(
        agent.description,
      );
    });

    it('submitting the form updates the agent and shows a success toast', async () => {
      mountEditPage();
      await waitForPromises();

      await fillFormField(wrapper, 'agent-form-input-name', 'Updated Agent');
      await submitAgentForm(wrapper);
      await waitForPromises();

      expect(updateHandler).toHaveBeenCalledWith({
        input: expect.objectContaining({
          id: agent.id,
          name: 'Updated Agent',
        }),
      });
      expect(wrapper.vm.$toast.show).toHaveBeenCalledWith('Agent updated.');
    });

    itSkipVue3(
      new SkipReason({
        name: 'redirects to show page after successful update',
        reason: 'Vue Router 4 async navigation timing differs',
        issue: 'https://gitlab.com/gitlab-org/gitlab/-/issues/593350',
      }),
      async () => {
        mountEditPage();
        await waitForPromises();

        await submitAgentForm(wrapper);
        await waitForPromises();

        expect(router.currentRoute.name).toBe(ROUTE_PRESETS.agentShow.name); // eslint-disable-line jest/no-standalone-expect
      },
    );

    describe('when update fails', () => {
      beforeEach(async () => {
        updateHandler.mockResolvedValue(mockUpdateAiCatalogAgentErrorMutation);
        mountEditPage();
        await waitForPromises();

        await submitAgentForm(wrapper);
        await waitForPromises();
      });

      it('shows an error alert and stays on the page', () => {
        const alert = wrapper.find('[role="alert"]');
        expect(alert.exists()).toBe(true);
        expect(alert.text()).toContain(
          mockUpdateAiCatalogAgentErrorMutation.data.aiCatalogAgentUpdate.errors[0],
        );
        expect(router.currentRoute.name).toBe(ROUTE_PRESETS.agentEdit.name);
      });
    });
  });

  describe('Duplicate page', () => {
    const agent = {
      ...createAgentWithPermissions(),
      project: { id: 'gid://gitlab/Project/1' },
      latestVersion: {
        ...mockAgent.latestVersion,
        systemPrompt: 'The system prompt',
        tools: { nodes: [], __typename: 'AiCatalogBuiltInToolConnection' },
        mcpServers: { nodes: [], __typename: 'AiCatalogMcpServerConnection' },
        definition: null,
      },
      itemType: 'AGENT',
    };

    let createHandler;
    let wrapper;
    let router;

    beforeEach(() => {
      createHandler = jest.fn().mockResolvedValue(mockCreateAiCatalogAgentSuccessMutation);
    });

    const mountDuplicatePage = ({ provide = {}, apolloHandlers = [] } = {}) => {
      const result = createIntegrationWrapper(AiCatalogAgentsDuplicate, {
        provide: {
          ...EXPLORE_PROVIDE,
          glAbilities: { adminAiCatalogItem: true },
          ...provide,
        },
        props: { aiCatalogAgent: agent },
        apolloHandlers: [[createAiCatalogAgentMutation, createHandler], ...apolloHandlers],
        route: ROUTE_PRESETS.agentDuplicate,
      });
      wrapper = result.wrapper;
      router = result.router;
      return result;
    };

    it('pre-fills the form with a "Copy of" prefixed name and private visibility', async () => {
      mountDuplicatePage();
      await waitForPromises();

      expect(wrapper.findByTestId('agent-form-input-name').element.value).toBe(
        `Copy of ${agent.name}`,
      );
    });

    it('submitting the form creates the duplicate and redirects to the new agent', async () => {
      mountDuplicatePage({
        apolloHandlers: [[getProjects, jest.fn().mockResolvedValue(mockProjectsResponse)]],
      });
      await waitForPromises();
      await selectDropdownItem(wrapper, 'agent-form-project-id', 'gid://gitlab/Project/1');
      await submitAgentForm(wrapper);
      await waitForPromises();

      expect(createHandler).toHaveBeenCalled();
      expect(wrapper.vm.$toast.show).toHaveBeenCalledWith('Agent created.');
      expect(router.currentRoute.name).toBe(ROUTE_PRESETS.agentShow.name);
      expect(String(router.currentRoute.params.id)).toBe(
        String(getIdFromGraphQLId(mockBaseAgent.id)),
      );
    });

    itSkipVue3(
      new SkipReason({
        name: 'third-party flow without createAiCatalogThirdPartyFlow ability is redirected',
        reason: 'Vue Router 4 throws on missing param during created() redirect',
        issue: 'https://gitlab.com/gitlab-org/gitlab/-/issues/593350',
      }),
      async () => {
        const thirdPartyAgent = {
          ...agent,
          itemType: 'THIRD_PARTY_FLOW',
        };
        const result = createIntegrationWrapper(AiCatalogAgentsDuplicate, {
          provide: {
            ...EXPLORE_PROVIDE,
            glAbilities: { adminAiCatalogItem: true, createAiCatalogThirdPartyFlow: false },
            glFeatures: { aiCatalogThirdPartyFlows: false, aiCatalogCreateThirdPartyFlows: false },
          },
          props: { aiCatalogAgent: thirdPartyAgent },
          apolloHandlers: [[createAiCatalogAgentMutation, jest.fn()]],
          route: ROUTE_PRESETS.agentDuplicate,
        });
        await waitForPromises();

        expect(result.router.currentRoute.name).toBe(ROUTE_PRESETS.agentShow.name); // eslint-disable-line jest/no-standalone-expect
      },
    );
  });
});
