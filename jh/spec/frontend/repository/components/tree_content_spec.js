import { shallowMount } from '@vue/test-utils';
import Vue, { nextTick } from 'vue';
import VueApollo from 'vue-apollo';
import createMockApollo from 'helpers/mock_apollo_helper';
import TreeContent from 'jh_else_ce/repository/components/tree_content.vue';
import waitForPromises from 'helpers/wait_for_promises';
import ContentBlocked from 'jh/vue_shared/components/content_blocked.vue';
import { getTreeContentBlockedState } from 'jh/rest_api';
import paginatedTreeQuery from 'shared_queries/repository/paginated_tree.query.graphql';
import projectPathQuery from '~/repository/queries/project_path.query.graphql';
import { paginatedTreeResponseFactory } from '../../../../../spec/frontend/repository/mock_data';

jest.mock('jh/rest_api');

let vm;

function factory(path) {
  const apolloProvider = createMockApollo([
    [paginatedTreeQuery, jest.fn().mockResolvedValue(paginatedTreeResponseFactory())],
  ]);

  apolloProvider.clients.defaultClient.cache.writeQuery({
    query: projectPathQuery,
    data: {
      projectPath: path,
    },
  });

  vm = shallowMount(TreeContent, {
    apolloProvider,
    propsData: {
      path,
    },
    provide: {
      refType: 'heads',
    },
  });
}

describe('Repository table component', () => {
  Vue.use(VueApollo);

  let originalGon;
  const dummyGon = {
    content_validation_enabled: true,
  };

  beforeEach(() => {
    originalGon = window.gon;
    window.gon = { ...dummyGon };
  });

  afterEach(() => {
    window.gon = originalGon;
    getTreeContentBlockedState.mockReset();
  });

  it('render contentBlocked component when blocked by content validation service', async () => {
    factory('/');
    getTreeContentBlockedState.mockReturnValue(
      Promise.resolve({
        data: {
          id: 1,
          project_full_path: '/test/test',
          path: 'test',
        },
      }),
    );

    await waitForPromises();
    await waitForPromises();
    await nextTick();

    expect(vm.findComponent(ContentBlocked).exists()).toBe(true);
  });
});
