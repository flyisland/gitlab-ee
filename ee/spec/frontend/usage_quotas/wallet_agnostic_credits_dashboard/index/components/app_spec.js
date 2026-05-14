import Vue from 'vue';
import VueApollo from 'vue-apollo';
import { GlTab } from '@gitlab/ui';
import typeDefs from 'ee/usage_quotas/wallet_agnostic_credits_dashboard/index/graphql/typedefs.graphql';
import GitlabCreditsDashboardApp from 'ee/usage_quotas/wallet_agnostic_credits_dashboard/index/components/app.vue';
import { shallowMountExtended } from 'helpers/vue_test_utils_helper';
import waitForPromises from 'helpers/wait_for_promises';
import createApolloClient from '~/lib/graphql';
import { logError } from '~/lib/logger';
import { captureException } from '~/sentry/sentry_browser_wrapper';
import UsageCards from 'ee/usage_quotas/wallet_agnostic_credits_dashboard/index/components/usage_cards.vue';
import ProductsList from 'ee/usage_quotas/wallet_agnostic_credits_dashboard/index/components/products_list.vue';
import UsersList from 'ee/usage_quotas/wallet_agnostic_credits_dashboard/index/components/users_list.vue';
import { mockSubscriptionCreditsUsage } from '../mock_data';

jest.mock('~/lib/logger');
jest.mock('~/sentry/sentry_browser_wrapper');

Vue.use(VueApollo);

describe('WalletAgnosticCreditsDashboard', () => {
  /** @type {import('helpers/vue_test_utils_helper').ExtendedWrapper} */
  let wrapper;

  /** @type { jest.Mock} */
  let subscriptionCreditsUsageResolver;

  const createComponent = ({ provide = {} } = {}) => {
    const resolvers = {
      Query: {
        subscriptionCreditsUsage: subscriptionCreditsUsageResolver,
      },
    };

    const apolloProvider = new VueApollo({
      defaultClient: createApolloClient(resolvers, { typeDefs }),
    });

    wrapper = shallowMountExtended(GitlabCreditsDashboardApp, {
      apolloProvider,
      provide: {
        userUsagePath: '/test-group/-/usage_quotas/usage_billing/users/__USERNAME__',
        ...provide,
      },
    });
  };

  const findErrorAlert = () => wrapper.findByTestId('error-alert');
  const findLoadingIndicator = () => wrapper.findByTestId('skeleton-loaders');
  const findTabs = () => wrapper.findAllComponents(GlTab);
  const findProductsList = () => wrapper.findComponent(ProductsList);
  const findUsersList = () => wrapper.findComponent(UsersList);

  beforeEach(() => {
    subscriptionCreditsUsageResolver = jest.fn().mockReturnValue(mockSubscriptionCreditsUsage);
  });

  describe('loading state', () => {
    beforeEach(async () => {
      subscriptionCreditsUsageResolver = jest.fn().mockImplementation(() => new Promise(() => {}));
      createComponent();
      await waitForPromises();
    });

    it('shows loading state when fetching data', () => {
      expect(findLoadingIndicator().exists()).toBe(true);
    });

    it('calls the apollo query', () => {
      expect(subscriptionCreditsUsageResolver).toHaveBeenCalledTimes(1);
    });
  });

  describe('rendering elements', () => {
    beforeEach(async () => {
      createComponent();
      await waitForPromises();
    });

    it('renders the heading', () => {
      expect(wrapper.find('h1').text()).toBe('GitLab Credits Overview');
    });

    it('does not show the error alert', () => {
      expect(findErrorAlert().exists()).toBe(false);
    });

    it('does not show loading state after data is loaded', () => {
      expect(findLoadingIndicator().exists()).toBe(false);
    });

    it('renders the UsageCards component', () => {
      expect(wrapper.findComponent(UsageCards).props()).toEqual({
        activeUsersCount: 215,
        dailyAverage: 616,
        peakDayDate: '2026-02-03',
        peakDayUsage: 920,
        totalUsedCredits: 13800,
      });
    });

    it('renders the Usage by user tab first', () => {
      expect(findTabs().at(0).attributes('title')).toBe('Usage by user');
    });

    it('renders the Usage by product tab second', () => {
      expect(findTabs().at(1).attributes('title')).toBe('Usage by product');
    });

    it('renders UsersList with users data', () => {
      expect(findUsersList().props('users')).toEqual(mockSubscriptionCreditsUsage.users);
    });

    it('renders ProductsList with products data', () => {
      expect(findProductsList().props('products')).toEqual(mockSubscriptionCreditsUsage.products);
    });

    it('renders ProductsList with totalUsedCredits', () => {
      expect(findProductsList().props('totalUsedCredits')).toBe(
        mockSubscriptionCreditsUsage.creditsUsed,
      );
    });
  });

  describe('group dashboard', () => {
    beforeEach(async () => {
      createComponent({ provide: { namespacePath: 'test-namespace' } });
      await waitForPromises();
    });

    it('passes namespacePath to the query', () => {
      expect(subscriptionCreditsUsageResolver).toHaveBeenCalledWith(
        expect.anything(),
        expect.objectContaining({
          namespacePath: 'test-namespace',
        }),
        expect.anything(),
        expect.anything(),
      );
    });
  });

  describe('error state', () => {
    beforeEach(async () => {
      subscriptionCreditsUsageResolver.mockRejectedValue(new Error('Failed to fetch data'));
      createComponent();
      await waitForPromises();
    });

    it('logs the error to console and Sentry', () => {
      expect(logError).toHaveBeenCalledWith(expect.any(Error));
      expect(captureException).toHaveBeenCalledWith(expect.any(Error));
    });

    it('shows an error alert', () => {
      expect(findErrorAlert().exists()).toBe(true);
    });

    it('does not show the loading indicator', () => {
      expect(findLoadingIndicator().exists()).toBe(false);
    });
  });

  describe('users pagination', () => {
    beforeEach(async () => {
      createComponent();
      await waitForPromises();
      subscriptionCreditsUsageResolver.mockClear();
    });

    it('refetches when UsersList emits next-page', async () => {
      findUsersList().vm.$emit('next-page', 'usersEndCursor');
      await waitForPromises();

      expect(subscriptionCreditsUsageResolver).toHaveBeenCalled();
    });

    it('refetches when UsersList emits prev-page', async () => {
      findUsersList().vm.$emit('prev-page', 'usersStartCursor');
      await waitForPromises();

      expect(subscriptionCreditsUsageResolver).toHaveBeenCalled();
    });
  });

  describe('products pagination', () => {
    beforeEach(async () => {
      createComponent();
      await waitForPromises();
      subscriptionCreditsUsageResolver.mockClear();
    });

    it('refetches when ProductsList emits next-page', async () => {
      findProductsList().vm.$emit('next-page', 'endCursorValue');
      await waitForPromises();

      expect(subscriptionCreditsUsageResolver).toHaveBeenCalled();
    });

    it('refetches when ProductsList emits prev-page', async () => {
      findProductsList().vm.$emit('prev-page', 'startCursorValue');
      await waitForPromises();

      expect(subscriptionCreditsUsageResolver).toHaveBeenCalled();
    });
  });
});
