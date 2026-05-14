import waitForPromises from 'helpers/wait_for_promises';
import { ignoreConsoleMessages } from 'helpers/console_watcher';
import AiCatalogAgentsShow from 'ee/ai/catalog/pages/ai_catalog_agents_show.vue';
import deleteAiCatalogAgentMutation from 'ee/ai/catalog/graphql/mutations/delete_ai_catalog_agent.mutation.graphql';
import createAiCatalogItemConsumerMutation from 'ee/ai/catalog/graphql/mutations/create_ai_catalog_item_consumer.mutation.graphql';
import deleteAiCatalogItemConsumerMutation from 'ee/ai/catalog/graphql/mutations/delete_ai_catalog_item_consumer.mutation.graphql';
import reportAiCatalogItemMutation from 'ee/ai/catalog/graphql/mutations/report_ai_catalog_item.mutation.graphql';
import aiCatalogProjectUserPermissionsQuery from 'ee/ai/catalog/graphql/queries/ai_catalog_project_user_permissions.query.graphql';
import aiCatalogGroupUserPermissionsQuery from 'ee/ai/catalog/graphql/queries/ai_catalog_group_user_permissions.query.graphql';
import aiCatalogProjectsMaintainerQuery from 'ee/ai/catalog/graphql/queries/ai_catalog_projects_maintainer.query.graphql';
import aiCatalogAgentQuery from 'ee/ai/catalog/graphql/queries/ai_catalog_agent.query.graphql';
import getProjects from '~/graphql_shared/queries/get_users_projects.query.graphql';
import {
  mockAgent,
  mockVersionProp,
  mockCatalogAgentDeleteResponse,
  mockAiCatalogItemConsumerCreateSuccessProjectResponse,
  mockAiCatalogItemConsumerDeleteResponse,
  mockReportAiCatalogItemSuccessMutation,
  mockProjectUserPermissionsResponse,
  mockGroupUserPermissionsResponse,
  mockProjectsMaintainerResponse,
  mockProjectsResponse,
} from '../mock_data';
import {
  createIntegrationWrapper,
  openActionsDropdown,
  expectActions,
  ACTION_STATE,
  clickDeleteAndConfirm,
  clickDisableAndConfirm,
  clickEnableButton,
  selectEnableModalDropdownItem,
  submitEnableModal,
  clickReportAndFillForm,
  EXPLORE_PROVIDE,
  PROJECT_PROVIDE,
  ROUTE_PRESETS,
} from './helpers';
import { createAgentWithPermissions } from './mock_data_factories';

jest.mock('~/lib/utils/common_utils', () => ({
  ...jest.requireActual('~/lib/utils/common_utils'),
  isLoggedIn: jest.fn().mockReturnValue(true),
}));

const agentRefetchHandler = () =>
  jest.fn().mockResolvedValue({ data: { aiCatalogAgent: mockAgent } });

describe('Agent — show page actions integration', () => {
  ignoreConsoleMessages([
    /Runtime directive used on component with non-element root node/,
    /Unknown query/,
  ]);

  const createPermissionHandlers = () => [
    [
      aiCatalogProjectUserPermissionsQuery,
      jest.fn().mockResolvedValue(mockProjectUserPermissionsResponse),
    ],
    [
      aiCatalogGroupUserPermissionsQuery,
      jest.fn().mockResolvedValue(mockGroupUserPermissionsResponse),
    ],
    [aiCatalogProjectsMaintainerQuery, jest.fn().mockResolvedValue(mockProjectsMaintainerResponse)],
  ];

  const mountShowPage = ({ agent, provide = {}, apolloHandlers = [] } = {}) => {
    const defaultAgent = agent || createAgentWithPermissions();
    return createIntegrationWrapper(AiCatalogAgentsShow, {
      provide: { ...PROJECT_PROVIDE, ...provide },
      props: {
        aiCatalogAgent: defaultAgent,
        version: { ...mockVersionProp, setActiveVersionKey: jest.fn() },
      },
      apolloHandlers: [...createPermissionHandlers(), ...apolloHandlers],
      route: ROUTE_PRESETS.agentShow,
    });
  };

  describe('Delete', () => {
    it('as maintainer: clicking Hide and confirming hides the agent and redirects to list', async () => {
      const deleteHandler = jest.fn().mockResolvedValue(mockCatalogAgentDeleteResponse);
      const agent = createAgentWithPermissions({ forceHardDeleteAiCatalogItem: false });
      const { wrapper, router } = mountShowPage({
        agent,
        apolloHandlers: [[deleteAiCatalogAgentMutation, deleteHandler]],
      });
      await waitForPromises();

      await openActionsDropdown(wrapper);
      expect(wrapper.findByTestId('delete-button').text()).toContain('Hide');

      await clickDeleteAndConfirm(wrapper);
      await waitForPromises();

      expect(deleteHandler).toHaveBeenCalledWith(
        expect.objectContaining({ id: agent.id, forceHardDelete: false }),
      );
      expect(wrapper.vm.$toast.show).toHaveBeenCalledWith('Agent hidden.');
      expect(router.currentRoute.name).toBe(ROUTE_PRESETS.agentList.name);
    });

    it('as admin: clicking Delete and confirming permanently deletes the agent and redirects to list', async () => {
      const deleteHandler = jest.fn().mockResolvedValue(mockCatalogAgentDeleteResponse);
      const agent = createAgentWithPermissions({ forceHardDeleteAiCatalogItem: true });
      const { wrapper, router } = mountShowPage({
        agent,
        apolloHandlers: [[deleteAiCatalogAgentMutation, deleteHandler]],
      });
      await waitForPromises();

      await openActionsDropdown(wrapper);
      expect(wrapper.findByTestId('delete-button').text()).toContain('Delete');

      await clickDeleteAndConfirm(wrapper);
      await waitForPromises();

      expect(deleteHandler).toHaveBeenCalledWith(
        expect.objectContaining({ id: agent.id, forceHardDelete: true }),
      );
      expect(wrapper.vm.$toast.show).toHaveBeenCalledWith('Agent deleted.');
      expect(router.currentRoute.name).toBe(ROUTE_PRESETS.agentList.name);
    });
  });

  describe('Enable', () => {
    it('enabling from the catalog selects a project and enables the agent', async () => {
      const consumerHandler = jest
        .fn()
        .mockResolvedValue(mockAiCatalogItemConsumerCreateSuccessProjectResponse);
      const agent = createAgentWithPermissions({ adminAiCatalogItem: false });
      const { wrapper } = mountShowPage({
        agent,
        provide: EXPLORE_PROVIDE,
        apolloHandlers: [
          [createAiCatalogItemConsumerMutation, consumerHandler],
          [aiCatalogAgentQuery, agentRefetchHandler()],
          [getProjects, jest.fn().mockResolvedValue(mockProjectsResponse)],
        ],
      });
      await waitForPromises();

      await clickEnableButton(wrapper);
      await selectEnableModalDropdownItem('project-id', 'gid://gitlab/Project/1');
      await submitEnableModal();
      await waitForPromises();

      expect(consumerHandler).toHaveBeenCalledWith(
        expect.objectContaining({
          input: expect.objectContaining({
            itemId: agent.id,
            target: { projectId: 'gid://gitlab/Project/1' },
          }),
        }),
      );
      expect(wrapper.vm.$toast.show).toHaveBeenCalledWith(
        expect.stringContaining('Agent enabled'),
        expect.any(Object),
      );
    });

    it('enabling from a project adds the agent to that project', async () => {
      const consumerHandler = jest
        .fn()
        .mockResolvedValue(mockAiCatalogItemConsumerCreateSuccessProjectResponse);
      const agent = createAgentWithPermissions({
        adminAiCatalogItem: false,
        projectConfigEnabled: false,
      });
      const { wrapper } = mountShowPage({
        agent,
        apolloHandlers: [
          [createAiCatalogItemConsumerMutation, consumerHandler],
          [aiCatalogAgentQuery, agentRefetchHandler()],
          [getProjects, jest.fn().mockResolvedValue(mockProjectsResponse)],
        ],
      });
      await waitForPromises();

      await clickEnableButton(wrapper);
      await selectEnableModalDropdownItem('project-id', 'gid://gitlab/Project/1');
      await submitEnableModal();
      await waitForPromises();

      expect(consumerHandler).toHaveBeenCalledWith(
        expect.objectContaining({
          input: expect.objectContaining({
            itemId: agent.id,
            target: { projectId: 'gid://gitlab/Project/1' },
          }),
        }),
      );
      expect(wrapper.vm.$toast.show).toHaveBeenCalledWith(expect.stringContaining('Agent enabled'));
    });

    it('a private agent already enabled in a group can still be enabled in other projects', async () => {
      const agent = createAgentWithPermissions({
        adminAiCatalogItem: false,
        isPublic: false,
        groupConfigEnabled: true,
      });
      const { wrapper } = mountShowPage({ agent, provide: EXPLORE_PROVIDE });
      await waitForPromises();

      await expectActions(wrapper, {
        'enable-button': ACTION_STATE.VISIBLE,
      });
    });
  });

  describe('Disable', () => {
    it('disabling from a project removes the agent from that project', async () => {
      const disableHandler = jest.fn().mockResolvedValue(mockAiCatalogItemConsumerDeleteResponse);
      const agent = createAgentWithPermissions({ projectConfigEnabled: true });
      const { wrapper } = mountShowPage({
        agent,
        apolloHandlers: [
          [deleteAiCatalogItemConsumerMutation, disableHandler],
          [aiCatalogAgentQuery, agentRefetchHandler()],
        ],
      });
      await waitForPromises();

      await clickDisableAndConfirm(wrapper);
      await waitForPromises();

      expect(disableHandler).toHaveBeenCalledWith(
        expect.objectContaining({ id: agent.configurationForProject.id }),
      );
      expect(wrapper.vm.$toast.show).toHaveBeenCalledWith('Agent disabled in this project.');
    });
  });

  describe('Report', () => {
    it('submitting a report with a reason and body shows a success toast', async () => {
      const reportHandler = jest.fn().mockResolvedValue(mockReportAiCatalogItemSuccessMutation);
      const agent = createAgentWithPermissions();
      const { wrapper } = mountShowPage({
        agent,
        apolloHandlers: [[reportAiCatalogItemMutation, reportHandler]],
      });
      await waitForPromises();

      await clickReportAndFillForm(wrapper, {
        reason: 'SPAM_OR_LOW_QUALITY',
        body: 'This is spam content',
      });
      await waitForPromises();

      expect(reportHandler).toHaveBeenCalledWith(
        expect.objectContaining({
          input: { id: agent.id, reason: 'SPAM_OR_LOW_QUALITY', body: 'This is spam content' },
        }),
      );
      expect(wrapper.vm.$toast.show).toHaveBeenCalledWith('Report submitted successfully.');
    });
  });
});
