import waitForPromises from 'helpers/wait_for_promises';
import { ignoreConsoleMessages } from 'helpers/console_watcher';
import * as commonUtils from '~/lib/utils/common_utils';
import AiCatalogAgentsShow from 'ee/ai/catalog/pages/ai_catalog_agents_show.vue';
import aiCatalogProjectUserPermissionsQuery from 'ee/ai/catalog/graphql/queries/ai_catalog_project_user_permissions.query.graphql';
import aiCatalogGroupUserPermissionsQuery from 'ee/ai/catalog/graphql/queries/ai_catalog_group_user_permissions.query.graphql';
import aiCatalogProjectsMaintainerQuery from 'ee/ai/catalog/graphql/queries/ai_catalog_projects_maintainer.query.graphql';
import { mockVersionProp } from '../mock_data';
import {
  createIntegrationWrapper,
  openActionsDropdown,
  expectActions,
  ACTION_STATE,
  EXPLORE_PROVIDE,
  PROJECT_PROVIDE,
  GROUP_PROVIDE,
  EXTERNAL_PROJECT_PROVIDE,
  EXTERNAL_GROUP_PROVIDE,
  ROUTE_PRESETS,
} from './helpers';
import {
  createAgentWithPermissions,
  createProjectPermissionsHandler,
  createGroupPermissionsHandler,
  createProjectsMaintainerHandler,
} from './mock_data_factories';

jest.mock('~/lib/utils/common_utils', () => ({
  ...jest.requireActual('~/lib/utils/common_utils'),
  isLoggedIn: jest.fn().mockReturnValue(true),
}));

describe('Agent — show page and RBAC integration', () => {
  ignoreConsoleMessages([/Runtime directive used on component with non-element root node/]);

  describe('Show page — renders details', () => {
    const mountShow = ({ agent, provide = {}, apolloHandlers = [] } = {}) => {
      const defaultAgent = agent || createAgentWithPermissions();
      return createIntegrationWrapper(AiCatalogAgentsShow, {
        provide: { ...PROJECT_PROVIDE, ...provide },
        props: {
          aiCatalogAgent: defaultAgent,
          version: mockVersionProp,
        },
        apolloHandlers: [
          [aiCatalogProjectUserPermissionsQuery, createProjectPermissionsHandler()],
          [aiCatalogGroupUserPermissionsQuery, createGroupPermissionsHandler()],
          ...apolloHandlers,
        ],
        route: ROUTE_PRESETS.agentShow,
      });
    };

    it('renders agent name and description', async () => {
      const { wrapper } = mountShow();
      await waitForPromises();

      expect(wrapper.text()).toContain('Test AI Agent 1');
      expect(wrapper.text()).toContain('A helpful AI assistant for testing purposes');
    });

    it('renders system prompt through the component tree', async () => {
      const { wrapper } = mountShow();
      await waitForPromises();

      expect(wrapper.text()).toContain('The system prompt');
    });

    it('renders agent type as Custom for non-foundational agents', async () => {
      const { wrapper } = mountShow();
      await waitForPromises();

      expect(wrapper.text()).toContain('Custom');
    });

    it('renders visibility information', async () => {
      const { wrapper } = mountShow();
      await waitForPromises();

      expect(wrapper.text()).toContain('Visibility');
    });
  });

  describe('Show page RBAC — Explore namespace', () => {
    afterEach(() => {
      commonUtils.isLoggedIn.mockReturnValue(true);
    });

    const mountExplore = ({ agent, permissionOverrides = {} } = {}) => {
      const defaultAgent = agent || createAgentWithPermissions();
      return createIntegrationWrapper(AiCatalogAgentsShow, {
        provide: EXPLORE_PROVIDE,
        props: {
          aiCatalogAgent: defaultAgent,
          version: mockVersionProp,
        },
        apolloHandlers: [
          [
            aiCatalogProjectUserPermissionsQuery,
            createProjectPermissionsHandler(permissionOverrides),
          ],
          [aiCatalogGroupUserPermissionsQuery, createGroupPermissionsHandler(permissionOverrides)],
          [aiCatalogProjectsMaintainerQuery, createProjectsMaintainerHandler()],
        ],
        route: ROUTE_PRESETS.agentShow,
      });
    };

    it('user without item permissions sees Enable, Duplicate, and Report', async () => {
      const agent = createAgentWithPermissions({
        adminAiCatalogItem: false,
      });
      const { wrapper } = mountExplore({ agent });
      await waitForPromises();

      await expectActions(wrapper, {
        'enable-button': ACTION_STATE.VISIBLE,
        'duplicate-button': ACTION_STATE.VISIBLE,
        'report-button': ACTION_STATE.VISIBLE,
        'edit-button': ACTION_STATE.HIDDEN,
        'disable-button': ACTION_STATE.HIDDEN,
        'delete-button': ACTION_STATE.HIDDEN,
      });
    });

    it('user without item permissions does NOT see Enable for foundational agent', async () => {
      const agent = createAgentWithPermissions({
        adminAiCatalogItem: false,
        foundational: true,
      });
      const { wrapper } = mountExplore({ agent });
      await waitForPromises();

      await expectActions(wrapper, {
        'duplicate-button': ACTION_STATE.VISIBLE,
        'enable-button': ACTION_STATE.HIDDEN,
        'edit-button': ACTION_STATE.HIDDEN,
        'disable-button': ACTION_STATE.HIDDEN,
        'delete-button': ACTION_STATE.HIDDEN,
        'report-button': ACTION_STATE.HIDDEN,
      });
    });

    it('unauthenticated user sees no action buttons', async () => {
      commonUtils.isLoggedIn.mockReturnValue(false);

      const agent = createAgentWithPermissions({
        adminAiCatalogItem: false,
        reportAiCatalogItem: false,
      });
      const { wrapper } = mountExplore({ agent });
      await waitForPromises();

      await expectActions(wrapper, {
        'edit-button': ACTION_STATE.HIDDEN,
        'enable-button': ACTION_STATE.HIDDEN,
        'more-actions-dropdown': ACTION_STATE.HIDDEN,
        'duplicate-button': ACTION_STATE.HIDDEN,
        'disable-button': ACTION_STATE.HIDDEN,
        'delete-button': ACTION_STATE.HIDDEN,
        'report-button': ACTION_STATE.HIDDEN,
      });
    });

    it('private item with existing group config shows active Enable', async () => {
      const agent = createAgentWithPermissions({
        adminAiCatalogItem: false,
        isPublic: false,
        groupConfigEnabled: true,
      });
      const { wrapper } = mountExplore({ agent });
      await waitForPromises();
      await openActionsDropdown(wrapper);

      await expectActions(wrapper, {
        'enable-button': ACTION_STATE.VISIBLE,
        'duplicate-button': ACTION_STATE.VISIBLE,
        'report-button': ACTION_STATE.VISIBLE,
        'edit-button': ACTION_STATE.HIDDEN,
        'disable-button': ACTION_STATE.HIDDEN,
        'delete-button': ACTION_STATE.HIDDEN,
      });
    });

    it('private item without group config shows active Enable', async () => {
      const agent = createAgentWithPermissions({
        adminAiCatalogItem: false,
        isPublic: false,
        groupConfigEnabled: false,
      });
      const { wrapper } = mountExplore({ agent });
      await waitForPromises();

      await expectActions(wrapper, {
        'enable-button': ACTION_STATE.VISIBLE,
        'duplicate-button': ACTION_STATE.VISIBLE,
        'report-button': ACTION_STATE.VISIBLE,
        'edit-button': ACTION_STATE.HIDDEN,
        'disable-button': ACTION_STATE.HIDDEN,
        'delete-button': ACTION_STATE.HIDDEN,
      });
    });
  });

  describe('Show page RBAC — Project namespace', () => {
    const mountProject = ({ agent, permissionOverrides = {} } = {}) => {
      const defaultAgent = agent || createAgentWithPermissions();
      return createIntegrationWrapper(AiCatalogAgentsShow, {
        provide: PROJECT_PROVIDE,
        props: {
          aiCatalogAgent: defaultAgent,
          version: mockVersionProp,
        },
        apolloHandlers: [
          [
            aiCatalogProjectUserPermissionsQuery,
            createProjectPermissionsHandler(permissionOverrides),
          ],
          [aiCatalogGroupUserPermissionsQuery, createGroupPermissionsHandler(permissionOverrides)],
        ],
        route: ROUTE_PRESETS.agentShow,
      });
    };

    it('item admin sees all actions when enabled', async () => {
      const agent = createAgentWithPermissions({ projectConfigEnabled: true });
      const { wrapper } = mountProject({ agent });
      await waitForPromises();
      await openActionsDropdown(wrapper);

      await expectActions(wrapper, {
        'edit-button': ACTION_STATE.VISIBLE,
        'enable-button': ACTION_STATE.VISIBLE,
        'duplicate-button': ACTION_STATE.VISIBLE,
        'delete-button': ACTION_STATE.VISIBLE,
        'disable-button': ACTION_STATE.VISIBLE,
        'report-button': ACTION_STATE.VISIBLE,
      });
    });

    it('consumer admin (non-item-admin) sees Enable when not enabled', async () => {
      const agent = createAgentWithPermissions({
        adminAiCatalogItem: false,
        reportAiCatalogItem: false,
        projectConfigEnabled: false,
      });
      const { wrapper } = mountProject({
        agent,
        permissionOverrides: { adminAiCatalogItemConsumer: true },
      });
      await waitForPromises();

      await expectActions(wrapper, {
        'enable-button': ACTION_STATE.VISIBLE,
        'edit-button': ACTION_STATE.HIDDEN,
        'duplicate-button': ACTION_STATE.HIDDEN,
        'delete-button': ACTION_STATE.HIDDEN,
        'disable-button': ACTION_STATE.HIDDEN,
        'report-button': ACTION_STATE.HIDDEN,
      });
    });

    it('consumer admin sees Enable and Disable when public item is enabled', async () => {
      const agent = createAgentWithPermissions({
        adminAiCatalogItem: false,
        reportAiCatalogItem: false,
        projectConfigEnabled: true,
      });
      const { wrapper } = mountProject({
        agent,
        permissionOverrides: { adminAiCatalogItemConsumer: true },
      });
      await waitForPromises();
      await openActionsDropdown(wrapper);

      await expectActions(wrapper, {
        'enable-button': ACTION_STATE.VISIBLE,
        'disable-button': ACTION_STATE.VISIBLE,
        'edit-button': ACTION_STATE.HIDDEN,
        'duplicate-button': ACTION_STATE.HIDDEN,
        'delete-button': ACTION_STATE.HIDDEN,
        'report-button': ACTION_STATE.HIDDEN,
      });
    });

    it('user with no permissions sees no action buttons', async () => {
      const agent = createAgentWithPermissions({
        adminAiCatalogItem: false,
        reportAiCatalogItem: false,
      });
      const { wrapper } = mountProject({
        agent,
        permissionOverrides: { adminAiCatalogItemConsumer: false },
      });
      await waitForPromises();

      await expectActions(wrapper, {
        'edit-button': ACTION_STATE.HIDDEN,
        'enable-button': ACTION_STATE.HIDDEN,
        'more-actions-dropdown': ACTION_STATE.HIDDEN,
        'duplicate-button': ACTION_STATE.HIDDEN,
        'disable-button': ACTION_STATE.HIDDEN,
        'delete-button': ACTION_STATE.HIDDEN,
        'report-button': ACTION_STATE.HIDDEN,
      });
    });

    it('instance admin sees hard Delete option', async () => {
      const agent = createAgentWithPermissions({
        forceHardDeleteAiCatalogItem: true,
      });
      const { wrapper } = mountProject({ agent });
      await waitForPromises();
      await openActionsDropdown(wrapper);

      await expectActions(wrapper, {
        'edit-button': ACTION_STATE.VISIBLE,
        'enable-button': ACTION_STATE.VISIBLE,
        'duplicate-button': ACTION_STATE.VISIBLE,
        'delete-button': ACTION_STATE.VISIBLE,
        'disable-button': ACTION_STATE.VISIBLE,
        'report-button': ACTION_STATE.VISIBLE,
      });
      expect(wrapper.findByTestId('delete-button').text()).toContain('Delete');
    });

    it('user with only reportAiCatalogItem sees Report', async () => {
      const agent = createAgentWithPermissions({
        adminAiCatalogItem: false,
        reportAiCatalogItem: true,
      });
      const { wrapper } = mountProject({
        agent,
        permissionOverrides: { adminAiCatalogItemConsumer: false },
      });
      await waitForPromises();
      await openActionsDropdown(wrapper);

      await expectActions(wrapper, {
        'report-button': ACTION_STATE.VISIBLE,
        'edit-button': ACTION_STATE.HIDDEN,
        'enable-button': ACTION_STATE.HIDDEN,
        'duplicate-button': ACTION_STATE.HIDDEN,
        'disable-button': ACTION_STATE.HIDDEN,
        'delete-button': ACTION_STATE.HIDDEN,
      });
    });

    it('user with reportAiCatalogItem does NOT see Report on foundational agents', async () => {
      const agent = createAgentWithPermissions({
        adminAiCatalogItem: false,
        reportAiCatalogItem: true,
        foundational: true,
      });
      const { wrapper } = mountProject({
        agent,
        permissionOverrides: { adminAiCatalogItemConsumer: false },
      });
      await waitForPromises();

      await expectActions(wrapper, {
        'report-button': ACTION_STATE.HIDDEN,
        'edit-button': ACTION_STATE.HIDDEN,
        'enable-button': ACTION_STATE.HIDDEN,
        'duplicate-button': ACTION_STATE.HIDDEN,
        'disable-button': ACTION_STATE.HIDDEN,
        'delete-button': ACTION_STATE.HIDDEN,
      });
    });

    it('private item not enabled — consumer admin sees Enable', async () => {
      const agent = createAgentWithPermissions({
        adminAiCatalogItem: false,
        reportAiCatalogItem: false,
        isPublic: false,
        projectConfigEnabled: false,
      });
      const { wrapper } = mountProject({
        agent,
        permissionOverrides: { adminAiCatalogItemConsumer: true },
      });
      await waitForPromises();

      await expectActions(wrapper, {
        'enable-button': ACTION_STATE.VISIBLE,
        'edit-button': ACTION_STATE.HIDDEN,
        'duplicate-button': ACTION_STATE.HIDDEN,
        'delete-button': ACTION_STATE.HIDDEN,
        'disable-button': ACTION_STATE.HIDDEN,
        'report-button': ACTION_STATE.HIDDEN,
      });
    });

    it('private item already enabled — consumer admin sees Disable but not Enable', async () => {
      const agent = createAgentWithPermissions({
        adminAiCatalogItem: false,
        reportAiCatalogItem: false,
        isPublic: false,
        projectConfigEnabled: true,
      });
      const { wrapper } = mountProject({
        agent,
        permissionOverrides: { adminAiCatalogItemConsumer: true },
      });
      await waitForPromises();
      await openActionsDropdown(wrapper);

      await expectActions(wrapper, {
        'disable-button': ACTION_STATE.VISIBLE,
        'enable-button': ACTION_STATE.HIDDEN,
        'edit-button': ACTION_STATE.HIDDEN,
        'duplicate-button': ACTION_STATE.HIDDEN,
        'delete-button': ACTION_STATE.HIDDEN,
        'report-button': ACTION_STATE.HIDDEN,
      });
    });

    it('consumer admin does NOT see Enable for foundational agent when disabled', async () => {
      const agent = createAgentWithPermissions({
        adminAiCatalogItem: false,
        foundational: true,
        projectConfigEnabled: false,
      });
      const { wrapper } = mountProject({
        agent,
        permissionOverrides: { adminAiCatalogItemConsumer: true },
      });
      await waitForPromises();

      await expectActions(wrapper, {
        'enable-button': ACTION_STATE.HIDDEN,
        'edit-button': ACTION_STATE.HIDDEN,
      });
    });

    it('consumer admin does NOT see Disable for foundational agent when enabled', async () => {
      const agent = createAgentWithPermissions({
        adminAiCatalogItem: false,
        foundational: true,
        projectConfigEnabled: true,
      });
      const { wrapper } = mountProject({
        agent,
        permissionOverrides: { adminAiCatalogItemConsumer: true },
      });
      await waitForPromises();

      await expectActions(wrapper, {
        'disable-button': ACTION_STATE.HIDDEN,
        'more-actions-dropdown': ACTION_STATE.HIDDEN,
      });
    });

    it('item admin does NOT see Enable/Disable for foundational agent', async () => {
      const agent = createAgentWithPermissions({
        foundational: true,
        projectConfigEnabled: false,
      });
      const { wrapper } = mountProject({ agent });
      await waitForPromises();
      await openActionsDropdown(wrapper);

      await expectActions(wrapper, {
        'enable-button': ACTION_STATE.HIDDEN,
        'edit-button': ACTION_STATE.VISIBLE,
        'duplicate-button': ACTION_STATE.VISIBLE,
        'delete-button': ACTION_STATE.VISIBLE,
      });
    });
  });

  describe('Show page RBAC — Group namespace', () => {
    const mountGroup = ({ agent, permissionOverrides = {} } = {}) => {
      const defaultAgent = agent || createAgentWithPermissions();
      return createIntegrationWrapper(AiCatalogAgentsShow, {
        provide: GROUP_PROVIDE,
        props: {
          aiCatalogAgent: defaultAgent,
          version: mockVersionProp,
        },
        apolloHandlers: [
          [
            aiCatalogProjectUserPermissionsQuery,
            createProjectPermissionsHandler(permissionOverrides),
          ],
          [aiCatalogGroupUserPermissionsQuery, createGroupPermissionsHandler(permissionOverrides)],
        ],
        route: ROUTE_PRESETS.agentShow,
      });
    };

    it('consumer admin sees Disable and Report when enabled', async () => {
      const agent = createAgentWithPermissions({ groupConfigEnabled: true });
      const { wrapper } = mountGroup({
        agent,
        permissionOverrides: { adminAiCatalogItemConsumer: true },
      });
      await waitForPromises();
      await openActionsDropdown(wrapper);

      await expectActions(wrapper, {
        'disable-button': ACTION_STATE.VISIBLE,
        'report-button': ACTION_STATE.VISIBLE,
        'edit-button': ACTION_STATE.HIDDEN,
        'enable-button': ACTION_STATE.HIDDEN,
        'duplicate-button': ACTION_STATE.HIDDEN,
        'delete-button': ACTION_STATE.HIDDEN,
      });
    });

    it('user with reportAiCatalogItem sees only Report', async () => {
      const agent = createAgentWithPermissions({
        adminAiCatalogItem: false,
        reportAiCatalogItem: true,
      });
      const { wrapper } = mountGroup({
        agent,
        permissionOverrides: { adminAiCatalogItemConsumer: false },
      });
      await waitForPromises();
      await openActionsDropdown(wrapper);

      await expectActions(wrapper, {
        'report-button': ACTION_STATE.VISIBLE,
        'edit-button': ACTION_STATE.HIDDEN,
        'enable-button': ACTION_STATE.HIDDEN,
        'duplicate-button': ACTION_STATE.HIDDEN,
        'disable-button': ACTION_STATE.HIDDEN,
        'delete-button': ACTION_STATE.HIDDEN,
      });
    });

    it('user with reportAiCatalogItem does NOT see Report on foundational agents', async () => {
      const agent = createAgentWithPermissions({
        adminAiCatalogItem: false,
        reportAiCatalogItem: true,
        foundational: true,
      });
      const { wrapper } = mountGroup({
        agent,
        permissionOverrides: { adminAiCatalogItemConsumer: false },
      });
      await waitForPromises();

      await expectActions(wrapper, {
        'report-button': ACTION_STATE.HIDDEN,
        'edit-button': ACTION_STATE.HIDDEN,
        'enable-button': ACTION_STATE.HIDDEN,
        'duplicate-button': ACTION_STATE.HIDDEN,
        'disable-button': ACTION_STATE.HIDDEN,
        'delete-button': ACTION_STATE.HIDDEN,
      });
    });
  });

  describe('User interacts with an agent from groups and projects that do not own the agent', () => {
    // The agent is owned by group-1, but the user browses from group-2.
    // Item-level actions (Edit, Delete) require ownership of the agent —
    // cross-namespace users never see these.
    // Consumer-level actions (Enable, Disable) depend on the user's role
    // in the browsing namespace, independent of the agent's owner.

    describe('Browsing from a project whose group does not own the agent', () => {
      const mountExternalProject = ({ agent, permissionOverrides = {} } = {}) => {
        const defaultAgent = agent || createAgentWithPermissions();
        return createIntegrationWrapper(AiCatalogAgentsShow, {
          provide: EXTERNAL_PROJECT_PROVIDE,
          props: {
            aiCatalogAgent: defaultAgent,
            version: mockVersionProp,
          },
          apolloHandlers: [
            [
              aiCatalogProjectUserPermissionsQuery,
              createProjectPermissionsHandler(permissionOverrides),
            ],
            [
              aiCatalogGroupUserPermissionsQuery,
              createGroupPermissionsHandler(permissionOverrides),
            ],
          ],
          route: ROUTE_PRESETS.agentShow,
        });
      };

      it('project maintainer sees Enable, Disable, and Report but not Edit/Delete', async () => {
        const agent = createAgentWithPermissions({
          adminAiCatalogItem: false,
          projectConfigEnabled: true,
        });
        const { wrapper } = mountExternalProject({
          agent,
          permissionOverrides: { adminAiCatalogItemConsumer: true },
        });
        await waitForPromises();
        await openActionsDropdown(wrapper);

        await expectActions(wrapper, {
          'enable-button': ACTION_STATE.VISIBLE,
          'disable-button': ACTION_STATE.VISIBLE,
          'report-button': ACTION_STATE.VISIBLE,
          'edit-button': ACTION_STATE.HIDDEN,
          'duplicate-button': ACTION_STATE.HIDDEN,
          'delete-button': ACTION_STATE.HIDDEN,
        });
      });

      it('project maintainer sees Enable and Report when not yet enabled', async () => {
        const agent = createAgentWithPermissions({
          adminAiCatalogItem: false,
          projectConfigEnabled: false,
        });
        const { wrapper } = mountExternalProject({
          agent,
          permissionOverrides: { adminAiCatalogItemConsumer: true },
        });
        await waitForPromises();

        await expectActions(wrapper, {
          'enable-button': ACTION_STATE.VISIBLE,
          'report-button': ACTION_STATE.VISIBLE,
          'edit-button': ACTION_STATE.HIDDEN,
          'duplicate-button': ACTION_STATE.HIDDEN,
          'delete-button': ACTION_STATE.HIDDEN,
          'disable-button': ACTION_STATE.HIDDEN,
        });
      });

      it('user with no permissions sees no actions', async () => {
        const agent = createAgentWithPermissions({
          adminAiCatalogItem: false,
          reportAiCatalogItem: false,
        });
        const { wrapper } = mountExternalProject({
          agent,
          permissionOverrides: { adminAiCatalogItemConsumer: false },
        });
        await waitForPromises();

        await expectActions(wrapper, {
          'report-button': ACTION_STATE.HIDDEN,
          'enable-button': ACTION_STATE.HIDDEN,
          'edit-button': ACTION_STATE.HIDDEN,
          'duplicate-button': ACTION_STATE.HIDDEN,
          'delete-button': ACTION_STATE.HIDDEN,
          'disable-button': ACTION_STATE.HIDDEN,
        });
      });

      it('user who can report sees only Report', async () => {
        const agent = createAgentWithPermissions({
          adminAiCatalogItem: false,
          reportAiCatalogItem: true,
        });
        const { wrapper } = mountExternalProject({
          agent,
          permissionOverrides: { adminAiCatalogItemConsumer: false },
        });
        await waitForPromises();

        await expectActions(wrapper, {
          'report-button': ACTION_STATE.VISIBLE,
          'enable-button': ACTION_STATE.HIDDEN,
          'edit-button': ACTION_STATE.HIDDEN,
          'duplicate-button': ACTION_STATE.HIDDEN,
          'delete-button': ACTION_STATE.HIDDEN,
          'disable-button': ACTION_STATE.HIDDEN,
        });
      });

      it('private item already enabled — project maintainer sees Disable but not Enable', async () => {
        const agent = createAgentWithPermissions({
          adminAiCatalogItem: false,
          reportAiCatalogItem: false,
          isPublic: false,
          projectConfigEnabled: true,
        });
        const { wrapper } = mountExternalProject({
          agent,
          permissionOverrides: { adminAiCatalogItemConsumer: true },
        });
        await waitForPromises();
        await openActionsDropdown(wrapper);

        await expectActions(wrapper, {
          'disable-button': ACTION_STATE.VISIBLE,
          'enable-button': ACTION_STATE.HIDDEN,
          'edit-button': ACTION_STATE.HIDDEN,
          'duplicate-button': ACTION_STATE.HIDDEN,
          'delete-button': ACTION_STATE.HIDDEN,
          'report-button': ACTION_STATE.HIDDEN,
        });
      });
    });

    describe('Browsing from a group that does not own the agent', () => {
      const mountExternalGroup = ({ agent, permissionOverrides = {} } = {}) => {
        const defaultAgent = agent || createAgentWithPermissions();
        return createIntegrationWrapper(AiCatalogAgentsShow, {
          provide: EXTERNAL_GROUP_PROVIDE,
          props: {
            aiCatalogAgent: defaultAgent,
            version: mockVersionProp,
          },
          apolloHandlers: [
            [
              aiCatalogProjectUserPermissionsQuery,
              createProjectPermissionsHandler(permissionOverrides),
            ],
            [
              aiCatalogGroupUserPermissionsQuery,
              createGroupPermissionsHandler(permissionOverrides),
            ],
          ],
          route: ROUTE_PRESETS.agentShow,
        });
      };

      it('group maintainer sees Disable and Report when enabled but not Edit/Delete/Duplicate', async () => {
        const agent = createAgentWithPermissions({
          adminAiCatalogItem: false,
          groupConfigEnabled: true,
        });
        const { wrapper } = mountExternalGroup({
          agent,
          permissionOverrides: { adminAiCatalogItemConsumer: true },
        });
        await waitForPromises();
        await openActionsDropdown(wrapper);

        await expectActions(wrapper, {
          'disable-button': ACTION_STATE.VISIBLE,
          'report-button': ACTION_STATE.VISIBLE,
          'edit-button': ACTION_STATE.HIDDEN,
          'duplicate-button': ACTION_STATE.HIDDEN,
          'delete-button': ACTION_STATE.HIDDEN,
          'enable-button': ACTION_STATE.HIDDEN,
        });
      });

      it('user with no permissions sees no actions', async () => {
        const agent = createAgentWithPermissions({
          adminAiCatalogItem: false,
          reportAiCatalogItem: false,
        });
        const { wrapper } = mountExternalGroup({
          agent,
          permissionOverrides: { adminAiCatalogItemConsumer: false },
        });
        await waitForPromises();

        await expectActions(wrapper, {
          'report-button': ACTION_STATE.HIDDEN,
          'enable-button': ACTION_STATE.HIDDEN,
          'edit-button': ACTION_STATE.HIDDEN,
          'duplicate-button': ACTION_STATE.HIDDEN,
          'delete-button': ACTION_STATE.HIDDEN,
          'disable-button': ACTION_STATE.HIDDEN,
        });
      });

      it('user who can report sees only Report', async () => {
        const agent = createAgentWithPermissions({
          adminAiCatalogItem: false,
          reportAiCatalogItem: true,
        });
        const { wrapper } = mountExternalGroup({
          agent,
          permissionOverrides: { adminAiCatalogItemConsumer: false },
        });
        await waitForPromises();

        await expectActions(wrapper, {
          'report-button': ACTION_STATE.VISIBLE,
          'enable-button': ACTION_STATE.HIDDEN,
          'edit-button': ACTION_STATE.HIDDEN,
          'duplicate-button': ACTION_STATE.HIDDEN,
          'delete-button': ACTION_STATE.HIDDEN,
          'disable-button': ACTION_STATE.HIDDEN,
        });
      });
    });
  });
});
