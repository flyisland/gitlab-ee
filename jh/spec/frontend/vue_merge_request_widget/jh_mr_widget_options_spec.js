// eslint-disable @jihu-fe/prefer-ee-modules
import MockAdapter from 'axios-mock-adapter';
import Vue, { nextTick } from 'vue';
import VueApollo from 'vue-apollo';
import { createMockSubscription as createMockApolloSubscription } from 'mock-apollo-client';

import approvedByCurrentUser from 'test_fixtures/graphql/merge_requests/approvals/approvals.query.graphql.json';
import getStateQueryResponse from 'test_fixtures/graphql/merge_requests/get_state.query.graphql.json';
import readyToMergeResponse from 'test_fixtures/graphql/merge_requests/states/ready_to_merge.query.graphql.json';
import { shallowMountExtended } from 'helpers/vue_test_utils_helper';

import MrWidgetOptions from 'jh/vue_merge_request_widget/mr_widget_options.vue';

// EE Widget Extensions

import createMockApollo from 'helpers/mock_apollo_helper';
import waitForPromises from 'helpers/wait_for_promises';

import axios from '~/lib/utils/axios_utils';
import { HTTP_STATUS_OK } from '~/lib/utils/http_status';

// Force Jest to transpile and cache
// eslint-disable-next-line no-unused-vars
import _Deployment from '~/vue_merge_request_widget/components/deployment/deployment.vue';

import getStateQuery from '~/vue_merge_request_widget/queries/get_state.query.graphql';
import getStateSubscription from '~/vue_merge_request_widget/queries/get_state.subscription.graphql';
import mergeChecksSubscription from '~/vue_merge_request_widget/queries/merge_checks.subscription.graphql';
import readyToMergeSubscription from '~/vue_merge_request_widget/queries/states/ready_to_merge.subscription.graphql';
import readyToMergeQuery from '~/vue_merge_request_widget/queries/states/ready_to_merge.query.graphql';
import mergeQuery from '~/vue_merge_request_widget/queries/states/new_ready_to_merge.query.graphql';
import approvalsQuery from 'ee_else_ce/vue_merge_request_widget/components/approvals/queries/approvals.query.graphql';
import approvedBySubscription from 'ee_else_ce/vue_merge_request_widget/components/approvals/queries/approvals.subscription.graphql';
import MrWidgetMonorepo from 'jh/vue_merge_request_widget/components/monorepo_mr_widget.vue';
import blockingMergeRequestsQuery from 'ee/vue_merge_request_widget/queries/blocking_merge_requests.query.graphql';

import mockData from './mock_data';

jest.mock('~/vue_shared/components/help_popover.vue');

Vue.use(VueApollo);

describe('ee merge request widget options', () => {
  const allSubscriptions = {};
  let wrapper;
  let mock;

  const findMonoRepoWidget = () => wrapper.findComponent(MrWidgetMonorepo);

  const createComponent = ({ mountFn = shallowMountExtended, propsData = {} }) => {
    const queryHandlers = [
      [approvalsQuery, jest.fn().mockResolvedValue(approvedByCurrentUser)],
      [getStateQuery, jest.fn().mockResolvedValue(getStateQueryResponse)],
      [readyToMergeQuery, jest.fn().mockResolvedValue(readyToMergeResponse)],
      [
        mergeQuery,
        jest.fn().mockResolvedValue({
          data: {
            project: { id: 1, mergeRequest: { id: 1, userPermissions: { canMerge: true } } },
          },
        }),
      ],
      [
        blockingMergeRequestsQuery,
        jest.fn().mockResolvedValue({
          data: { project: { id: 1, mergeRequest: { id: 1, blockingMergeRequests: null } } },
        }),
      ],
    ];
    const subscriptionHandlers = [
      [
        approvedBySubscription,
        () => {
          // Please see https://github.com/Mike-Gibson/mock-apollo-client/blob/c85746f1433b42af83ef6ca0d2904ccad6076666/README.md#multiple-subscriptions
          // for why subscriptions must be mocked this way, in this context
          // Note that the keyed object -> array structure is so that:
          //  A) when necessary, we can publish (.next) events into the stream
          //  B) we can do that by name (per subscription) rather than as a single array of all subscriptions
          const sym = Symbol.for('approvedBySubscription');
          const newSub = createMockApolloSubscription();
          const container = allSubscriptions[sym] || [];

          container.push(newSub);
          allSubscriptions[sym] = container;

          return newSub;
        },
      ],
      [getStateSubscription, () => createMockApolloSubscription()],
      [readyToMergeSubscription, () => createMockApolloSubscription()],
      [mergeChecksSubscription, () => createMockApolloSubscription()],
    ];
    const apolloProvider = createMockApollo(queryHandlers);

    subscriptionHandlers.forEach(([query, stream]) => {
      apolloProvider.defaultClient.setRequestHandler(query, stream);
    });

    wrapper = mountFn(MrWidgetOptions, {
      propsData,
      apolloProvider,
      data() {
        return {
          loading: false,
        };
      },
    });
  };

  beforeEach(() => {
    gon.features = { asyncMrWidget: true };
    gl.mrWidgetData = { ...mockData };

    mock = new MockAdapter(axios);

    mock.onGet(mockData.merge_request_widget_path).reply(() => [HTTP_STATUS_OK, gl.mrWidgetData]);
    mock
      .onGet(mockData.merge_request_cached_widget_path)
      .reply(() => [HTTP_STATUS_OK, gl.mrWidgetData]);
  });

  afterEach(() => {
    // This is needed because the `fetchInitialData` is triggered while
    // the `mock.restore` is trying to clean up, causing a bunch of
    // unmocked requests...
    // This is not ideal and will be cleaned up in
    // https://gitlab.com/gitlab-org/gitlab/-/issues/214032
    return waitForPromises().then(() => {
      wrapper?.destroy();
      wrapper = null;
      mock.restore();
    });
  });

  describe('MR widget monorepo', () => {
    afterEach(() => {
      gon.jh_monorepo_enabled = undefined;
    });

    it('renders monorepo widget while enabled', async () => {
      gon.jh_monorepo_enabled = true;
      createComponent({ propsData: { mrData: mockData } });
      await nextTick();

      expect(findMonoRepoWidget().exists()).toBe(true);
    });

    it('does not render monorepo widget while disabled', async () => {
      createComponent({ propsData: { mrData: mockData } });
      await nextTick();

      expect(findMonoRepoWidget().exists()).toBe(false);
    });
  });
});
