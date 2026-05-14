import Vue, { nextTick } from 'vue';
import VueApollo from 'vue-apollo';
import { GlTabs, GlTab } from '@gitlab/ui';
import createMockApollo from 'helpers/mock_apollo_helper';
import waitForPromises from 'helpers/wait_for_promises';
import { shallowMountExtended } from 'helpers/vue_test_utils_helper';
import { useMockInternalEventsTracking } from 'helpers/tracking_internal_events_helper';
import AiFlowsIndex from 'ee/ai/duo_agents_platform/pages/flows/ai_flows_index.vue';
import AiCatalogListHeader from 'ee/ai/catalog/components/ai_catalog_list_header.vue';
import AiCatalogConfiguredItemsWrapper from 'ee/ai/duo_agents_platform/components/catalog/ai_catalog_configured_items_wrapper.vue';
import projectAiCatalogFlowsQuery from 'ee/ai/duo_agents_platform/graphql/queries/get_project_flows.query.graphql';
import aiCatalogFlowsQuery from 'ee/ai/catalog/graphql/queries/ai_catalog_flows.query.graphql';
import ErrorsAlert from '~/vue_shared/components/errors_alert.vue';
import aiCatalogConfiguredItemsQuery from 'ee/ai/catalog/graphql/queries/ai_catalog_configured_items.query.graphql';
import aiCatalogGroupUserPermissionsQuery from 'ee/ai/catalog/graphql/queries/ai_catalog_group_user_permissions.query.graphql';
import aiCatalogProjectUserPermissionsQuery from 'ee/ai/catalog/graphql/queries/ai_catalog_project_user_permissions.query.graphql';
import {
  mockConfiguredItemsEmptyResponse,
  mockGroupUserPermissionsResponse,
  mockProjectUserPermissionsResponse,
  mockFlowsWithConfigs,
  mockPageInfo,
  mockCatalogItemsResponse,
} from 'ee_jest/ai/catalog/mock_data';
import {
  TRACK_EVENT_VIEW_AI_CATALOG_PROJECT_MANAGED,
  TRACK_EVENT_TYPE_FLOW,
} from 'ee/ai/catalog/constants';
import { mockProjectFlowsResponse } from '../../mock_data';

Vue.use(VueApollo);

describe('AiFlowsIndex', () => {
  let wrapper;
  let mockApollo;

  const mockToast = {
    show: jest.fn(),
  };
  const mockProjectId = 1;
  const mockRootGroupId = 10000;
  const mockProjectPath = 'test-group/test-project';
  const mockConfiguredItemsQueryHandler = jest
    .fn()
    .mockResolvedValue(mockConfiguredItemsEmptyResponse);
  const mockGroupUserPermissionsQueryHandler = jest
    .fn()
    .mockResolvedValue(mockGroupUserPermissionsResponse);
  const mockProjectUserPermissionsQueryHandler = jest
    .fn()
    .mockResolvedValue(mockProjectUserPermissionsResponse);
  const mockProjectFlowsQueryHandler = jest.fn().mockResolvedValue(mockProjectFlowsResponse);
  const mockCatalogItemsQueryHandler = jest.fn().mockResolvedValue(mockCatalogItemsResponse);

  const { bindInternalEventDocument } = useMockInternalEventsTracking();

  const defaultProvide = {
    projectId: mockProjectId,
    projectPath: mockProjectPath,
    isProjectNamespace: true,
    exploreAiCatalogFlowsPath: '/explore/ai-catalog/flows',
    rootGroupId: mockRootGroupId,
  };

  const createComponent = ({ provide = {} } = {}) => {
    mockApollo = createMockApollo([
      [aiCatalogConfiguredItemsQuery, mockConfiguredItemsQueryHandler],
      [projectAiCatalogFlowsQuery, mockProjectFlowsQueryHandler],
      [aiCatalogFlowsQuery, mockCatalogItemsQueryHandler],
      [aiCatalogGroupUserPermissionsQuery, mockGroupUserPermissionsQueryHandler],
      [aiCatalogProjectUserPermissionsQuery, mockProjectUserPermissionsQueryHandler],
    ]);

    wrapper = shallowMountExtended(AiFlowsIndex, {
      apolloProvider: mockApollo,
      provide: {
        ...defaultProvide,
        ...provide,
      },
      mocks: {
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
  const findManagedList = () => wrapper.findByTestId('managed-flows-list');
  const findCatalogList = () => wrapper.findByTestId('catalog-flows-list');
  const findTabs = () => wrapper.findComponent(GlTabs);
  const findAllTabs = () => wrapper.findAllComponents(GlTab);

  describe('component rendering', () => {
    beforeEach(() => {
      createComponent();
    });

    it('renders AiCatalogListHeader component', () => {
      expect(wrapper.findComponent(AiCatalogListHeader).exists()).toBe(true);
    });

    it('renders AiCatalogConfiguredItemsWrapper component with correct props', () => {
      expect(findConfiguredItemsWrapper().props()).toMatchObject({
        emptyStateTitle: 'Use flows in your project.',
        emptyStateDescription: 'Flows use multiple agents to complete tasks automatically.',
        emptyStateButtonText: 'Explore the AI Catalog',
        itemTypes: ['FLOW'],
      });
    });

    it('switches to Catalog tab when empty state button is clicked in Enabled tab', async () => {
      findConfiguredItemsWrapper().vm.$emit('empty-state-click');
      await nextTick();

      expect(findTabs().props('value')).toBe(2);
    });
  });

  describe('when "Managed" tab is selected', () => {
    const baseQueryVariables = {
      projectPath: mockProjectPath,
      allAvailable: false,
      search: '',
      projectId: `gid://gitlab/Project/${mockProjectId}`,
      groupId: `gid://gitlab/Group/${mockRootGroupId}`,
      after: null,
      before: null,
      first: 20,
      last: null,
    };

    beforeEach(() => {
      createComponent();
      findTabs().vm.$emit('input', 1);
    });

    it('renders AiCatalogList component', async () => {
      const managedList = findManagedList();

      expect(managedList.props('isLoading')).toBe(true);

      await waitForPromises();

      expect(managedList.props('items')).toEqual(mockFlowsWithConfigs);
      expect(managedList.props('isLoading')).toBe(false);
    });

    it('fetches list data', () => {
      expect(mockProjectFlowsQueryHandler).toHaveBeenCalledWith(baseQueryVariables);
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
        expect(mockProjectFlowsQueryHandler).toHaveBeenCalledWith(baseQueryVariables);
      });

      it('refetches query with correct variables when paging forward', async () => {
        findManagedList().vm.$emit('next-page');
        await nextTick();
        expect(mockProjectFlowsQueryHandler).toHaveBeenCalledWith(baseQueryVariables);
      });
    });

    describe('search functionality', () => {
      beforeEach(async () => {
        await waitForPromises();
      });

      it('refetches query with search term when search is submitted', async () => {
        findManagedList().vm.$emit('search', ['test flow']);
        await nextTick();

        expect(mockProjectFlowsQueryHandler).toHaveBeenCalledWith({
          ...baseQueryVariables,
          search: 'test flow',
        });
      });

      it('clears search term when clear-search is emitted', async () => {
        // First set a search term
        findManagedList().vm.$emit('search', ['test flow']);
        await nextTick();

        // Then clear it
        findManagedList().vm.$emit('clear-search');
        await nextTick();

        expect(mockProjectFlowsQueryHandler).toHaveBeenLastCalledWith(baseQueryVariables);
      });

      it('maintains search term when switching tabs', async () => {
        // First set a search term
        findManagedList().vm.$emit('search', ['test flow']);
        await nextTick();

        // Click on Enabled tab
        findAllTabs().at(0).vm.$emit('click');
        await nextTick();

        expect(mockProjectFlowsQueryHandler).toHaveBeenLastCalledWith({
          ...baseQueryVariables,
          search: 'test flow',
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
            groupId: mockGroupId,
            groupPath: mockGroupPath,
            projectId: null,
            projectPath: null,
            isProjectNamespace: false,
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

  describe('error handling', () => {
    beforeEach(() => {
      createComponent();
    });

    it('handles error event from wrapper component', async () => {
      const errorPayload = {
        title: 'Failed to disable flow',
        errors: ['Some error message'],
      };

      await findConfiguredItemsWrapper().vm.$emit('error', errorPayload);

      expect(findErrorsAlert().props('title')).toBe('Failed to disable flow');
      expect(findErrorsAlert().props('errors')).toEqual(['Some error message']);
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
          { label: TRACK_EVENT_TYPE_FLOW },
          undefined,
        );
      });
    });

    describe('when "Managed" tab is clicked but was already active', () => {
      beforeEach(() => {
        createComponent();
        findTabs().vm.$emit('input', 1);
      });

      it(`does not ${TRACK_EVENT_VIEW_AI_CATALOG_PROJECT_MANAGED} event again`, () => {
        const { trackEventSpy } = bindInternalEventDocument(wrapper.element);

        findAllTabs().at(1).vm.$emit('click');

        expect(trackEventSpy).not.toHaveBeenCalledWith(
          TRACK_EVENT_VIEW_AI_CATALOG_PROJECT_MANAGED,
          { label: TRACK_EVENT_TYPE_FLOW },
          undefined,
        );
      });
    });
  });
});
