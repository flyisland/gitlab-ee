import Vue, { nextTick } from 'vue';
import VueApollo from 'vue-apollo';
import { GlTabs, GlTab } from '@gitlab/ui';
import createMockApollo from 'helpers/mock_apollo_helper';
import waitForPromises from 'helpers/wait_for_promises';
import { shallowMountExtended } from 'helpers/vue_test_utils_helper';
import { useMockInternalEventsTracking } from 'helpers/tracking_internal_events_helper';
import AiAgentsIndex from 'ee/ai/duo_agents_platform/pages/agents/ai_agents_index.vue';
import AiCatalogListHeader from 'ee/ai/catalog/components/ai_catalog_list_header.vue';
import AiCatalogConfiguredItemsWrapper from 'ee/ai/duo_agents_platform/components/catalog/ai_catalog_configured_items_wrapper.vue';
import ErrorsAlert from '~/vue_shared/components/errors_alert.vue';
import aiCatalogGroupUserPermissionsQuery from 'ee/ai/catalog/graphql/queries/ai_catalog_group_user_permissions.query.graphql';
import aiCatalogProjectUserPermissionsQuery from 'ee/ai/catalog/graphql/queries/ai_catalog_project_user_permissions.query.graphql';
import projectAiCatalogAgentsQuery from 'ee/ai/duo_agents_platform/graphql/queries/get_project_agents.query.graphql';
import aiCatalogAgentsQuery from 'ee/ai/catalog/graphql/queries/ai_catalog_agents.query.graphql';
import {
  mockAgentsWithConfig,
  mockPageInfo,
  mockGroupUserPermissionsResponse,
  mockProjectUserPermissionsResponse,
  mockConfiguredItemsEmptyResponse,
  mockCatalogItemsResponse,
} from 'ee_jest/ai/catalog/mock_data';
import aiCatalogConfiguredItemsQuery from 'ee/ai/catalog/graphql/queries/ai_catalog_configured_items.query.graphql';
import {
  TRACK_EVENT_VIEW_AI_CATALOG_PROJECT_MANAGED,
  TRACK_EVENT_TYPE_AGENT,
} from 'ee/ai/catalog/constants';
import { mockProjectAgentsResponse } from '../../mock_data';

Vue.use(VueApollo);

describe('AiAgentsIndex', () => {
  let wrapper;
  let mockApollo;

  const mockRouter = {
    push: jest.fn(),
  };
  const mockToast = {
    show: jest.fn(),
  };
  const mockProjectId = 1;
  const mockRootGroupId = 10000;
  const mockProjectPath = '/mock-group/test-project';
  const mockConfiguredItemsQueryHandler = jest
    .fn()
    .mockResolvedValue(mockConfiguredItemsEmptyResponse);
  const mockProjectAgentsQueryHandler = jest.fn().mockResolvedValue(mockProjectAgentsResponse);
  const mockCatalogItemsQueryHandler = jest.fn().mockResolvedValue(mockCatalogItemsResponse);
  const mockGroupUserPermissionsQueryHandler = jest
    .fn()
    .mockResolvedValue(mockGroupUserPermissionsResponse);
  const mockProjectUserPermissionsQueryHandler = jest
    .fn()
    .mockResolvedValue(mockProjectUserPermissionsResponse);

  const { bindInternalEventDocument } = useMockInternalEventsTracking();

  const createComponent = ({ provide = {} } = {}) => {
    mockApollo = createMockApollo([
      [aiCatalogConfiguredItemsQuery, mockConfiguredItemsQueryHandler],
      [projectAiCatalogAgentsQuery, mockProjectAgentsQueryHandler],
      [aiCatalogAgentsQuery, mockCatalogItemsQueryHandler],
      [aiCatalogGroupUserPermissionsQuery, mockGroupUserPermissionsQueryHandler],
      [aiCatalogProjectUserPermissionsQuery, mockProjectUserPermissionsQueryHandler],
    ]);

    wrapper = shallowMountExtended(AiAgentsIndex, {
      apolloProvider: mockApollo,
      provide: {
        isProjectNamespace: true,
        projectId: mockProjectId,
        projectPath: mockProjectPath,
        exploreAiCatalogAgentsPath: '/explore/ai-catalog/agents',
        rootGroupId: mockRootGroupId,
        glFeatures: {
          aiCatalogThirdPartyFlows: true,
        },
        ...provide,
      },
      mocks: {
        $router: mockRouter,
        $toast: mockToast,
      },
      stubs: {
        GlTab,
        AiCatalogConfiguredItemsWrapper,
      },
    });
  };

  const findErrorsAlert = () => wrapper.findComponent(ErrorsAlert);
  const findConfiguredItemsWrapper = () => wrapper.findComponent(AiCatalogConfiguredItemsWrapper);
  const findManagedList = () => wrapper.findByTestId('managed-agents-list');
  const findCatalogList = () => wrapper.findByTestId('catalog-agents-list');
  const findTabs = () => wrapper.findComponent(GlTabs);
  const findAllTabs = () => wrapper.findAllComponents(GlTab);

  describe('component rendering', () => {
    beforeEach(() => {
      createComponent();
    });

    it('renders AiCatalogListHeader component', () => {
      expect(wrapper.findComponent(AiCatalogListHeader).exists()).toBe(true);
    });

    it('renders AiCatalogConfiguredItemsWrapper with correct props', () => {
      expect(findConfiguredItemsWrapper().props()).toMatchObject({
        emptyStateTitle: 'Use agents in your project.',
        emptyStateDescription: 'Use agents to automate tasks and answer questions.',
        emptyStateButtonText: 'Explore the AI Catalog',
        itemTypes: ['AGENT', 'THIRD_PARTY_FLOW'],
      });
    });

    it('switches to Catalog tab when empty state button is clicked in Enabled tab', async () => {
      findConfiguredItemsWrapper().vm.$emit('empty-state-click');
      await nextTick();

      expect(findTabs().props('value')).toBe(2);
    });
  });

  describe('when "Managed" tab is selected', () => {
    beforeEach(() => {
      mockProjectAgentsQueryHandler.mockResolvedValue(mockProjectAgentsResponse);
      createComponent();
      findTabs().vm.$emit('input', 1);
    });

    it('renders AiCatalogList component', async () => {
      const managedList = findManagedList();

      expect(managedList.props('isLoading')).toBe(true);

      await waitForPromises();

      expect(managedList.props('items')).toMatchObject(mockAgentsWithConfig);
      expect(managedList.props('isLoading')).toBe(false);
    });

    it('fetches list data', () => {
      expect(mockProjectAgentsQueryHandler).toHaveBeenCalledWith({
        projectId: `gid://gitlab/Project/${mockProjectId}`,
        groupId: `gid://gitlab/Group/${mockRootGroupId}`,
        itemTypes: ['AGENT', 'THIRD_PARTY_FLOW'],
        projectPath: mockProjectPath,
        search: '',
        allAvailable: false,
        after: null,
        before: null,
        first: 20,
        last: null,
      });
    });

    it('passes empty state props to AiCatalogListWrapper', async () => {
      await waitForPromises();

      const managedList = findManagedList();
      expect(managedList.props()).toMatchObject({
        emptyStateTitle: 'Use agents in your project.',
        emptyStateDescription: 'Use agents to automate tasks and answer questions.',
        emptyStateButtonText: 'Explore the AI Catalog',
      });
    });

    it('determines update status on each item correctly', async () => {
      const catalogList = findManagedList();
      await waitForPromises();
      const items = catalogList.props('items');

      expect(items[0].isUpdateAvailable).toBe(true);
      expect(items[1].isUpdateAvailable).toBe(false);
      expect(items[2].isUpdateAvailable).toBe(false);
    });

    describe('pagination', () => {
      beforeEach(async () => {
        await waitForPromises();
      });

      it('passes pageInfo to list component', () => {
        expect(findManagedList().props('pageInfo')).toMatchObject(mockPageInfo);
      });

      it('refetches query with correct variables when paging backward', async () => {
        findManagedList().vm.$emit('prev-page');
        await nextTick();
        expect(mockProjectAgentsQueryHandler).toHaveBeenCalledWith({
          projectId: `gid://gitlab/Project/${mockProjectId}`,
          groupId: `gid://gitlab/Group/${mockRootGroupId}`,
          itemTypes: ['AGENT', 'THIRD_PARTY_FLOW'],
          projectPath: mockProjectPath,
          allAvailable: false,
          search: '',
          after: null,
          before: 'eyJpZCI6IjUxIn0',
          first: null,
          last: 20,
        });
      });

      it('refetches query with correct variables when paging forward', async () => {
        findManagedList().vm.$emit('next-page');
        await nextTick();
        expect(mockProjectAgentsQueryHandler).toHaveBeenCalledWith({
          projectId: `gid://gitlab/Project/${mockProjectId}`,
          groupId: `gid://gitlab/Group/${mockRootGroupId}`,
          itemTypes: ['AGENT', 'THIRD_PARTY_FLOW'],
          projectPath: mockProjectPath,
          allAvailable: false,
          search: '',
          after: 'eyJpZCI6IjM1In0',
          before: null,
          first: 20,
          last: null,
        });
      });
    });

    describe('search functionality', () => {
      beforeEach(async () => {
        await waitForPromises();
      });

      it('refetches query with search term when search is submitted', async () => {
        findManagedList().vm.$emit('search', ['test agent']);
        await nextTick();

        expect(mockProjectAgentsQueryHandler).toHaveBeenCalledWith({
          projectId: `gid://gitlab/Project/${mockProjectId}`,
          groupId: `gid://gitlab/Group/${mockRootGroupId}`,
          itemTypes: ['AGENT', 'THIRD_PARTY_FLOW'],
          projectPath: mockProjectPath,
          allAvailable: false,
          search: 'test agent',
          after: null,
          before: null,
          first: 20,
          last: null,
        });
      });

      it('clears search term when clear-search is emitted', async () => {
        // First set a search term
        findManagedList().vm.$emit('search', ['test agent']);
        await nextTick();

        // Then clear it
        findManagedList().vm.$emit('clear-search');
        await nextTick();

        expect(mockProjectAgentsQueryHandler).toHaveBeenLastCalledWith({
          projectId: `gid://gitlab/Project/${mockProjectId}`,
          groupId: `gid://gitlab/Group/${mockRootGroupId}`,
          projectPath: mockProjectPath,
          itemTypes: ['AGENT', 'THIRD_PARTY_FLOW'],
          allAvailable: false,
          search: '',
          after: null,
          before: null,
          first: 20,
          last: null,
        });
      });

      it('maintains search term when switching tabs', async () => {
        // First set a search term
        findManagedList().vm.$emit('search', ['test flow']);
        await nextTick();

        // Click on Enabled tab
        findAllTabs().at(0).vm.$emit('click');
        await nextTick();

        expect(mockProjectAgentsQueryHandler).toHaveBeenLastCalledWith({
          projectId: `gid://gitlab/Project/${mockProjectId}`,
          groupId: `gid://gitlab/Group/${mockRootGroupId}`,
          projectPath: mockProjectPath,
          itemTypes: ['AGENT', 'THIRD_PARTY_FLOW'],
          allAvailable: false,
          search: 'test flow',
          after: null,
          before: null,
          first: 20,
          last: null,
        });
      });
    });
  });

  describe('when "Catalog" tab is selected', () => {
    beforeEach(async () => {
      createComponent();
      findTabs().vm.$emit('input', 2);
      await waitForPromises();
    });

    it('renders AiCatalogList component', () => {
      expect(findCatalogList().exists()).toBe(true);
    });

    it('fetches catalog query', () => {
      expect(mockCatalogItemsQueryHandler).toHaveBeenCalled();
    });

    it('displays error alert when catalog query fails', () => {
      mockCatalogItemsQueryHandler.mockRejectedValue(new Error('Query failed'));

      expect(findErrorsAlert().exists()).toBe(true);
    });
  });

  describe('when "Managed" tab is selected and the Feature Flag for third party flows tab is disabled', () => {
    beforeEach(() => {
      mockProjectAgentsQueryHandler.mockResolvedValue(mockProjectAgentsResponse);
      createComponent({
        provide: {
          glFeatures: {
            aiCatalogThirdPartyFlows: false,
          },
        },
      });
      findTabs().vm.$emit('input', 1);
    });

    it('does not fetch third party flows when fetching list data', () => {
      expect(mockProjectAgentsQueryHandler).toHaveBeenCalledWith({
        projectId: `gid://gitlab/Project/${mockProjectId}`,
        groupId: `gid://gitlab/Group/${mockRootGroupId}`,
        itemTypes: ['AGENT'],
        projectPath: mockProjectPath,
        allAvailable: false,
        after: null,
        before: null,
        first: 20,
        last: null,
        search: '',
      });
    });
  });

  describe('Apollo queries', () => {
    describe('when in project namespace', () => {
      beforeEach(() => {
        createComponent();
      });

      it('fetches project user permissions', () => {
        expect(mockProjectUserPermissionsQueryHandler).toHaveBeenCalledWith({
          fullPath: mockProjectPath,
        });
      });

      it('skips group user permissions query', () => {
        expect(mockGroupUserPermissionsQueryHandler).not.toHaveBeenCalled();
      });
    });

    describe('when in group namespace', () => {
      const mockGroupId = 2;
      const mockGroupPath = 'test-group';

      beforeEach(() => {
        createComponent({
          provide: {
            isProjectNamespace: false,
            groupId: mockGroupId,
            groupPath: mockGroupPath,
            projectId: null,
            projectPath: null,
          },
        });
      });

      it('fetches group user permissions', () => {
        expect(mockGroupUserPermissionsQueryHandler).toHaveBeenCalledWith({
          fullPath: mockGroupPath,
        });
      });

      it('skips project user permissions query', () => {
        expect(mockProjectUserPermissionsQueryHandler).not.toHaveBeenCalled();
      });
    });
  });

  describe('itemTypeConfigEnabled', () => {
    beforeEach(() => {
      createComponent();
    });

    describe('disableActionItem.showActionItem', () => {
      it('returns false when user does not have adminAiCatalogItemConsumer permission', () => {
        const { showActionItem } = wrapper.vm.itemTypeConfigEnabled.disableActionItem;
        const item = { foundational: false };

        expect(showActionItem(item)).toBe(false);
      });

      it('returns false when item is foundational', async () => {
        createComponent({
          provide: {
            projectId: mockProjectId,
            projectPath: mockProjectPath,
            exploreAiCatalogPath: '/explore/ai-catalog',
            rootGroupId: mockRootGroupId,
          },
        });
        await waitForPromises();

        // Mock the user permissions to have adminAiCatalogItemConsumer
        wrapper.vm.projectUserPermissions = { adminAiCatalogItemConsumer: true };
        await nextTick();

        const { showActionItem } = wrapper.vm.itemTypeConfigEnabled.disableActionItem;
        const foundationalItem = { foundational: true };

        expect(showActionItem(foundationalItem)).toBe(false);
      });

      it('returns true when user has adminAiCatalogItemConsumer permission and item is not foundational', async () => {
        createComponent({
          provide: {
            projectId: mockProjectId,
            projectPath: mockProjectPath,
            exploreAiCatalogPath: '/explore/ai-catalog',
            rootGroupId: mockRootGroupId,
          },
        });
        await waitForPromises();

        // Mock the user permissions to have adminAiCatalogItemConsumer
        wrapper.vm.projectUserPermissions = { adminAiCatalogItemConsumer: true };
        await nextTick();

        const { showActionItem } = wrapper.vm.itemTypeConfigEnabled.disableActionItem;
        const regularItem = { foundational: false };

        expect(showActionItem(regularItem)).toBe(true);
      });
    });
  });

  describe('tracking events', () => {
    describe('when "Managed" tab is clicked', () => {
      it(`tracks ${TRACK_EVENT_VIEW_AI_CATALOG_PROJECT_MANAGED} event`, () => {
        const { trackEventSpy } = bindInternalEventDocument(wrapper.element);

        createComponent();
        findAllTabs().at(1).vm.$emit('click');

        expect(trackEventSpy).toHaveBeenCalledWith(
          TRACK_EVENT_VIEW_AI_CATALOG_PROJECT_MANAGED,
          { label: TRACK_EVENT_TYPE_AGENT },
          undefined,
        );
      });
    });

    describe('when "Managed" tab is clicked but was already active', () => {
      beforeEach(() => {
        createComponent();
        findTabs().vm.$emit('input', 1);
      });

      it(`does not track ${TRACK_EVENT_VIEW_AI_CATALOG_PROJECT_MANAGED} event again`, () => {
        const { trackEventSpy } = bindInternalEventDocument(wrapper.element);

        findAllTabs().at(1).vm.$emit('click');

        expect(trackEventSpy).not.toHaveBeenCalledWith(
          TRACK_EVENT_VIEW_AI_CATALOG_PROJECT_MANAGED,
          { label: TRACK_EVENT_TYPE_AGENT },
          undefined,
        );
      });
    });
  });
});
