import { GlLoadingIcon } from '@gitlab/ui';
import Vue, { nextTick } from 'vue';
import VueApollo from 'vue-apollo';
import { shallowMountExtended } from 'helpers/vue_test_utils_helper';
import createMockApollo from 'helpers/mock_apollo_helper';
import waitForPromises from 'helpers/wait_for_promises';
import * as Sentry from '~/sentry/sentry_browser_wrapper';
import BoardView from '~/work_items/board/board_view.vue';
import ColumnGroup from '~/work_items/board/components/column_group.vue';
import getBoardNamespaceStatusesQuery from 'ee_else_ce/work_items/board/graphql/get_namespace_statuses.query.graphql';
import { buildStatus, buildNamespaceStatusesResponse } from 'jest/work_items/board/mock_data';

jest.mock('~/sentry/sentry_browser_wrapper');

Vue.use(VueApollo);

describe('BoardView', () => {
  let wrapper;

  const statusesQueryHandler = jest.fn();

  const defaultStatuses = [
    buildStatus(1, 'To do'),
    buildStatus(2, 'In progress'),
    buildStatus(3, 'Done'),
  ];
  const queryVariables = { state: 'opened', sort: 'CREATED_DESC' };

  const findLoadingIcon = () => wrapper.findComponent(GlLoadingIcon);
  const findColumnGroups = () => wrapper.findAllComponents(ColumnGroup);

  const createComponent = ({ props = {} } = {}) => {
    const apolloProvider = createMockApollo([
      [getBoardNamespaceStatusesQuery, statusesQueryHandler],
    ]);

    wrapper = shallowMountExtended(BoardView, {
      apolloProvider,
      propsData: {
        rootPageFullPath: 'full/path',
        queryVariables,
        ...props,
      },
    });
  };

  beforeEach(() => {
    statusesQueryHandler.mockResolvedValue(buildNamespaceStatusesResponse(defaultStatuses));
  });

  describe('loading state', () => {
    it('renders the loading icon while the query is loading and no values are present', () => {
      createComponent();

      expect(findLoadingIcon().exists()).toBe(true);
      expect(findColumnGroups()).toHaveLength(0);
    });

    it('hides the loading icon once the query resolves', async () => {
      createComponent();
      await waitForPromises();

      expect(findLoadingIcon().exists()).toBe(false);
    });
  });

  describe('column groups', () => {
    beforeEach(async () => {
      createComponent();
      await waitForPromises();
    });

    it('renders one ColumnGroup per status node', () => {
      expect(findColumnGroups()).toHaveLength(defaultStatuses.length);
    });

    it('passes value, groupProperty, rootPageFullPath, and baseQueryVariables to each ColumnGroup', () => {
      findColumnGroups().wrappers.forEach((columnGroup, index) => {
        expect(columnGroup.props()).toMatchObject({
          value: defaultStatuses[index],
          groupProperty: 'status',
          rootPageFullPath: 'full/path',
          baseQueryVariables: queryVariables,
        });
      });
    });

    it('renders no ColumnGroups when the query returns no statuses', async () => {
      statusesQueryHandler.mockResolvedValue(buildNamespaceStatusesResponse([]));
      createComponent();
      await waitForPromises();

      expect(findColumnGroups()).toHaveLength(0);
    });
  });

  describe('statuses query', () => {
    it('calls the statuses query with rootPageFullPath', async () => {
      createComponent({ props: { rootPageFullPath: 'group/subgroup' } });
      await nextTick();

      expect(statusesQueryHandler).toHaveBeenCalledWith({ fullPath: 'group/subgroup' });
    });
  });

  describe('when the statuses query errors', () => {
    const queryError = new Error('GraphQL failure');

    beforeEach(async () => {
      statusesQueryHandler.mockRejectedValue(queryError);
      createComponent();
      await waitForPromises();
    });

    it('captures the error in Sentry', () => {
      expect(Sentry.captureException).toHaveBeenCalledWith(queryError);
    });

    it('emits set-error with a user-facing message', () => {
      expect(wrapper.emitted('set-error')).toEqual([
        ['Something went wrong when fetching the board columns. Please try again.'],
      ]);
    });

    it('renders no ColumnGroups', () => {
      expect(findColumnGroups()).toHaveLength(0);
    });

    it('hides the loading icon', () => {
      expect(findLoadingIcon().exists()).toBe(false);
    });
  });
});
