import VueApollo from 'vue-apollo';
import Vue from 'vue';
import { isLoggedIn } from '~/lib/utils/common_utils';
import * as Sentry from '~/sentry/sentry_browser_wrapper';
import createMockApollo from 'helpers/mock_apollo_helper';
import { shallowMountExtended } from 'helpers/vue_test_utils_helper';
import waitForPromises from 'helpers/wait_for_promises';
import { useMockInternalEventsTracking } from 'helpers/tracking_internal_events_helper';
import AiCatalogItemsIndex from 'ee/ai/catalog/pages/ai_catalog_items_index.vue';
import AiCatalogListWrapper from 'ee/ai/catalog/components/ai_catalog_list_wrapper.vue';
import AiCatalogListHeader from 'ee/ai/catalog/components/ai_catalog_list_header.vue';
import aiCatalogItemsQuery from 'ee/ai/catalog/graphql/queries/ai_catalog_items.query.graphql';
import {
  AI_CATALOG_TYPE_AGENT,
  AI_CATALOG_TYPE_FLOW,
  AI_CATALOG_TYPE_THIRD_PARTY_FLOW,
  TRACK_EVENT_VIEW_AI_CATALOG_ITEM_INDEX,
  TRACK_EVENT_TYPE_AGENT,
  TRACK_EVENT_TYPE_FLOW,
} from 'ee/ai/catalog/constants';
import {
  mockAgents,
  mockFlows,
  mockCatalogItemsResponse,
  mockCatalogFlowsResponse,
  mockPageInfo,
} from '../mock_data';

jest.mock('~/sentry/sentry_browser_wrapper');
jest.mock('~/lib/utils/common_utils');

Vue.use(VueApollo);

const ITEM_TYPE_SCENARIOS = [
  {
    itemType: AI_CATALOG_TYPE_AGENT,
    query: aiCatalogItemsQuery,
    mockItems: mockAgents,
    mockResponse: mockCatalogItemsResponse,
    trackLabel: TRACK_EVENT_TYPE_AGENT,
    glFeatures: { aiCatalogThirdPartyFlows: true },
    resolvedItemTypes: [AI_CATALOG_TYPE_AGENT, AI_CATALOG_TYPE_THIRD_PARTY_FLOW],
  },
  {
    itemType: AI_CATALOG_TYPE_FLOW,
    query: aiCatalogItemsQuery,
    mockItems: mockFlows,
    mockResponse: mockCatalogFlowsResponse,
    trackLabel: TRACK_EVENT_TYPE_FLOW,
    glFeatures: {},
    resolvedItemTypes: [AI_CATALOG_TYPE_FLOW],
  },
];

describe('AiCatalogItemsIndex', () => {
  describe.each(ITEM_TYPE_SCENARIOS)(
    'when itemType is $itemType',
    ({ itemType, query, mockItems, mockResponse, trackLabel, glFeatures, resolvedItemTypes }) => {
      let wrapper;
      let mockApollo;
      let mockRouter;
      let mockRoute;
      let mockCatalogItemsQueryHandler;

      const { bindInternalEventDocument } = useMockInternalEventsTracking();

      beforeEach(() => {
        mockRouter = { push: jest.fn(), replace: jest.fn() };
        mockRoute = { query: {} };
        mockCatalogItemsQueryHandler = jest.fn().mockResolvedValue(mockResponse);
      });

      const createComponent = ({ provide = {}, routeQuery = {} } = {}) => {
        isLoggedIn.mockReturnValue(true);
        mockApollo = createMockApollo([[query, mockCatalogItemsQueryHandler]]);
        mockRoute.query = routeQuery;

        wrapper = shallowMountExtended(AiCatalogItemsIndex, {
          apolloProvider: mockApollo,
          propsData: { itemType },
          mocks: { $router: mockRouter, $route: mockRoute },
          provide: {
            glFeatures,
            ...provide,
          },
        });
      };

      const findListWrapper = () => wrapper.findComponent(AiCatalogListWrapper);

      describe('component rendering', () => {
        beforeEach(() => {
          createComponent();
        });

        it('renders AiCatalogListHeader', () => {
          expect(wrapper.findComponent(AiCatalogListHeader).exists()).toBe(true);
        });

        it('renders AiCatalogListWrapper', () => {
          expect(findListWrapper().exists()).toBe(true);
        });

        it('passes loading state as true initially', () => {
          expect(findListWrapper().props('isLoading')).toBe(true);
        });

        it('passes items and isLoading=false after data loads', async () => {
          await waitForPromises();

          expect(findListWrapper().props('items')).toEqual(mockItems);
          expect(findListWrapper().props('isLoading')).toBe(false);
        });
      });

      describe('Apollo query', () => {
        it('fetches with correct itemTypes by default', () => {
          createComponent();

          expect(mockCatalogItemsQueryHandler).toHaveBeenCalledWith(
            expect.objectContaining({ itemTypes: resolvedItemTypes }),
          );
        });
      });

      describe('pagination', () => {
        it('passes pageInfo to list component', async () => {
          createComponent();
          await waitForPromises();

          expect(findListWrapper().props('pageInfo')).toMatchObject(mockPageInfo);
        });

        it('refetches query with correct variables when paging forward', async () => {
          createComponent();
          await waitForPromises();

          findListWrapper().vm.$emit('next-page');

          expect(mockCatalogItemsQueryHandler).toHaveBeenCalledWith(
            expect.objectContaining({
              after: 'eyJpZCI6IjM1In0',
              before: null,
              first: 20,
              last: null,
            }),
          );
        });

        it('refetches query with correct variables when paging backward', async () => {
          createComponent();
          await waitForPromises();

          findListWrapper().vm.$emit('prev-page');

          expect(mockCatalogItemsQueryHandler).toHaveBeenCalledWith(
            expect.objectContaining({
              before: 'eyJpZCI6IjUxIn0',
              after: null,
              first: null,
              last: 20,
            }),
          );
        });
      });

      describe('search', () => {
        describe('default', () => {
          beforeEach(() => {
            createComponent();
          });

          it('passes search param to query on search', async () => {
            findListWrapper().vm.$emit('search', ['foo']);
            await waitForPromises();

            expect(mockCatalogItemsQueryHandler).toHaveBeenCalledWith(
              expect.objectContaining({ search: 'foo' }),
            );
          });

          it('updates URL query param when searching', async () => {
            findListWrapper().vm.$emit('search', ['foo']);
            await waitForPromises();

            expect(mockRouter.replace).toHaveBeenCalledWith({ query: { search: 'foo' } });
          });

          it('clears search param when clear-search is emitted', async () => {
            findListWrapper().vm.$emit('search', ['foo']);
            await waitForPromises();

            findListWrapper().vm.$emit('clear-search');
            await waitForPromises();

            expect(mockCatalogItemsQueryHandler).toHaveBeenCalledWith(
              expect.objectContaining({ search: '' }),
            );
          });

          it('removes search param from URL when clearing search', async () => {
            mockRoute.query = { search: 'foo' };
            findListWrapper().vm.$emit('clear-search');
            await waitForPromises();

            expect(mockRouter.replace).toHaveBeenCalledWith({ query: {} });
          });

          it('does not update URL when search term has not changed', async () => {
            mockRoute.query = { search: 'foo' };

            findListWrapper().vm.$emit('search', ['foo']);
            await waitForPromises();

            expect(mockRouter.replace).not.toHaveBeenCalled();
          });
        });

        it('initializes search term from URL query param', async () => {
          await createComponent({ routeQuery: { search: 'initial' } });
          await waitForPromises();

          expect(findListWrapper().props('searchTerm')).toBe('initial');
          expect(mockCatalogItemsQueryHandler).toHaveBeenCalledWith(
            expect.objectContaining({ search: 'initial' }),
          );
        });
      });

      describe('tracking events', () => {
        describe('when component is mounted', () => {
          beforeEach(() => {
            createComponent();
          });

          it(`tracks ${TRACK_EVENT_VIEW_AI_CATALOG_ITEM_INDEX} event with correct label`, () => {
            const { trackEventSpy } = bindInternalEventDocument(wrapper.element);

            expect(trackEventSpy).toHaveBeenCalledWith(
              TRACK_EVENT_VIEW_AI_CATALOG_ITEM_INDEX,
              { label: trackLabel },
              undefined,
            );
          });
        });
      });

      describe('when catalog items query fails', () => {
        it('reports error to Sentry', async () => {
          const error = new Error('GraphQL error');
          mockCatalogItemsQueryHandler.mockRejectedValue(error);
          createComponent();
          await waitForPromises();

          expect(Sentry.captureException).toHaveBeenCalledWith(error);
        });
      });
    },
  );

  describe('when itemType is AGENT and aiCatalogThirdPartyFlows feature flag is off', () => {
    it('fetches without third-party flow types', () => {
      const handler = jest.fn().mockResolvedValue(mockCatalogItemsResponse);
      isLoggedIn.mockReturnValue(true);
      const mockApollo = createMockApollo([[aiCatalogItemsQuery, handler]]);

      shallowMountExtended(AiCatalogItemsIndex, {
        apolloProvider: mockApollo,
        propsData: { itemType: AI_CATALOG_TYPE_AGENT },
        mocks: { $router: { replace: jest.fn() }, $route: { query: {} } },
        provide: { glFeatures: { aiCatalogThirdPartyFlows: false } },
      });

      expect(handler).toHaveBeenCalledWith(
        expect.objectContaining({ itemTypes: [AI_CATALOG_TYPE_AGENT] }),
      );
    });
  });
});
