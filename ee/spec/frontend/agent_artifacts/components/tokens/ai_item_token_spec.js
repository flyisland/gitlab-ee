import Vue from 'vue';
import VueApollo from 'vue-apollo';
import { mount } from '@vue/test-utils';
import createMockApollo from 'helpers/mock_apollo_helper';
import waitForPromises from 'helpers/wait_for_promises';
import AiItemToken from 'ee/agent_artifacts/components/tokens/ai_item_token.vue';
import {
  AI_CATALOG_TYPE_AGENT,
  AI_CATALOG_TYPE_FLOW,
  AI_CATALOG_TYPE_THIRD_PARTY_FLOW,
} from 'ee/ai/catalog/constants';
import BaseToken from '~/vue_shared/components/filtered_search_bar/tokens/base_token.vue';
import getAvailableAiItemNamesQuery from 'ee/agent_artifacts/graphql/queries/get_available_ai_item_names.query.graphql';
import { createAlert } from '~/alert';
import * as Sentry from '~/sentry/sentry_browser_wrapper';

Vue.use(VueApollo);

jest.mock('~/alert');
jest.mock('~/sentry/sentry_browser_wrapper');

const mockAiItemsResponse = {
  data: {
    aiCatalogConfiguredItems: {
      nodes: [
        {
          item: {
            name: 'False Positive Detection',
          },
        },
        {
          item: {
            name: 'Code Review Assistant',
          },
        },
        {
          item: {
            name: 'Security Scanner',
          },
        },
      ],
      __typename: 'AiCatalogConfiguredItemConnection',
    },
  },
};

const AI_CATALOG_TYPES = [
  AI_CATALOG_TYPE_AGENT,
  AI_CATALOG_TYPE_FLOW,
  AI_CATALOG_TYPE_THIRD_PARTY_FLOW,
];

describe('AiItemToken', () => {
  let wrapper;
  let apolloQuerySpy;

  const createComponent = ({
    queryResponse = mockAiItemsResponse,
    propsData = {},
    provide = {},
  } = {}) => {
    const apolloProvider = createMockApollo();

    wrapper = mount(AiItemToken, {
      propsData: {
        config: {
          type: 'name',
          icon: 'tanuki-ai',
          title: 'AI Item',
        },
        value: {},
        active: false,
        cursorPosition: 'start',
        ...propsData,
      },
      provide: {
        groupId: 'gid://gitlab/Group/1',
        projectId: null,
        portalName: 'fake target',
        alignSuggestions: jest.fn(),
        suggestionsListClass: () => 'custom-class',
        termsAsTokens: () => false,
        ...provide,
      },
      apolloProvider,
      stubs: {
        Portal: true,
        BaseToken,
        GlFilteredSearchSuggestionList: {
          template: '<div></div>',
          methods: {
            getValue: () => '=',
          },
        },
      },
    });

    if (queryResponse instanceof Error) {
      apolloQuerySpy = jest.spyOn(wrapper.vm.$apollo, 'query').mockRejectedValue(queryResponse);
    } else {
      apolloQuerySpy = jest.spyOn(wrapper.vm.$apollo, 'query').mockResolvedValue(queryResponse);
    }
  };

  const findBaseToken = () => wrapper.findComponent(BaseToken);

  describe('when component is initially rendered', () => {
    beforeEach(() => {
      createComponent();
    });

    it('renders BaseToken component', () => {
      expect(findBaseToken().exists()).toBe(true);
    });
  });

  describe('when fetching AI item names', () => {
    it('calls query with correct variables', async () => {
      createComponent({ propsData: { active: true } });
      await wrapper.vm.fetchItems();
      await waitForPromises();

      expect(apolloQuerySpy).toHaveBeenCalledWith({
        query: getAvailableAiItemNamesQuery,
        variables: {
          groupId: 'gid://gitlab/Group/1',
          projectId: null,
          itemTypes: AI_CATALOG_TYPES,
        },
      });
    });
  });

  describe('when using projectId instead of groupId', () => {
    it('passes projectId to query', async () => {
      createComponent({
        propsData: { active: true },
        provide: {
          groupId: null,
          projectId: 'gid://gitlab/Project/123',
        },
      });

      await wrapper.vm.fetchItems();
      await waitForPromises();

      expect(apolloQuerySpy).toHaveBeenCalledWith({
        query: getAvailableAiItemNamesQuery,
        variables: {
          groupId: null,
          projectId: 'gid://gitlab/Project/123',
          itemTypes: AI_CATALOG_TYPES,
        },
      });
    });
  });

  describe('when fetch fails', () => {
    it('shows error alert', async () => {
      createComponent({
        queryResponse: new Error('GraphQL error'),
        propsData: { active: true },
      });
      await wrapper.vm.fetchItems();
      await waitForPromises();

      expect(createAlert).toHaveBeenCalledWith({
        message: 'Failed to load AI item names.',
      });
    });
  });

  describe('fetchSuggestions', () => {
    it('does not call fetchItems if token is not active', async () => {
      createComponent({ propsData: { active: false } });

      await wrapper.vm.fetchSuggestions();

      expect(apolloQuerySpy).not.toHaveBeenCalled();
    });

    it('does not call fetchItems if items already exist', async () => {
      createComponent({ propsData: { active: true } });

      wrapper.vm.items = [{ value: 'existing', title: 'existing' }];

      await wrapper.vm.fetchSuggestions();

      expect(apolloQuerySpy).not.toHaveBeenCalled();
    });

    it('calls fetchItems if token is active and items are empty', async () => {
      createComponent({ propsData: { active: true } });

      await wrapper.vm.fetchSuggestions();
      await waitForPromises();

      expect(apolloQuerySpy).toHaveBeenCalledTimes(1);
    });
  });

  describe('when catalog item nodes have null items', () => {
    it('filters out nodes with null items and logs to Sentry', async () => {
      const responseWithNulls = {
        data: {
          aiCatalogConfiguredItems: {
            nodes: [
              {
                id: 'gid://gitlab/Ai::Catalog::ItemConsumer/1',
                item: {
                  name: 'Valid Item',
                },
              },
              {
                id: 'gid://gitlab/Ai::Catalog::ItemConsumer/2',
                item: null,
              },
              {
                id: 'gid://gitlab/Ai::Catalog::ItemConsumer/3',
                item: {
                  name: 'Another Valid Item',
                },
              },
            ],
            __typename: 'AiCatalogConfiguredItemConnection',
          },
        },
      };

      createComponent({ queryResponse: responseWithNulls, propsData: { active: true } });
      await wrapper.vm.fetchItems();
      await waitForPromises();

      expect(wrapper.vm.items).toHaveLength(2);
      expect(wrapper.vm.items).toEqual([
        { value: 'Valid Item', title: 'Valid Item' },
        { value: 'Another Valid Item', title: 'Another Valid Item' },
      ]);
      expect(Sentry.captureException).toHaveBeenCalledWith(
        expect.any(Error),
        expect.objectContaining({
          extra: { nodeId: 'gid://gitlab/Ai::Catalog::ItemConsumer/2' },
        }),
      );
    });
  });
});
