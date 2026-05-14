import VueApollo from 'vue-apollo';
import typeDefs from 'ee/usage_quotas/wallet_agnostic_credits_dashboard/index/graphql/typedefs.graphql';
import { mockSubscriptionCreditsUsageData } from 'ee/usage_quotas/wallet_agnostic_credits_dashboard/index/graphql/mock_data';
import createApolloClient from '~/lib/graphql';
import WalletAgnosticCreditsDashboard from './app.vue';

const meta = {
  title: 'ee/usage_quotas/wallet_agnostic_credits_dashboard/app',
  component: WalletAgnosticCreditsDashboard,
};

export default meta;

/**
 * Creates a Storybook template for the App component
 *
 * @param {Object} config
 * @param {Object} [config.provide] - Provide options for the component
 * @param {Function} [config.subscriptionCreditsUsageResolver] - Custom resolver for the query
 */
const createTemplate = (config = {}) => {
  let { subscriptionCreditsUsageResolver } = config;

  if (!subscriptionCreditsUsageResolver) {
    subscriptionCreditsUsageResolver = () =>
      mockSubscriptionCreditsUsageData.data.subscriptionCreditsUsage;
  }

  const resolvers = {
    Query: {
      subscriptionCreditsUsage: subscriptionCreditsUsageResolver,
    },
  };

  const apolloProvider = new VueApollo({
    defaultClient: createApolloClient(resolvers, { typeDefs }),
  });

  return (args, { argTypes }) => ({
    apolloProvider,
    components: {
      WalletAgnosticCreditsDashboard,
    },
    provide: {
      namespacePath: 'gitlab-org',
      userUsagePath: '/gitlab-org/-/usage_quotas/usage_billing/users/__USERNAME__',
      ...config.provide,
    },
    props: Object.keys(argTypes),
    template: `<wallet-agnostic-credits-dashboard />`,
  });
};

export const Default = {
  render: createTemplate(),
};

export const EmptyPeakDay = {
  render: (...args) => {
    const subscriptionCreditsUsageResolver = () => ({
      ...mockSubscriptionCreditsUsageData.data.subscriptionCreditsUsage,
      peakDay: null,
    });

    return createTemplate({
      subscriptionCreditsUsageResolver,
    })(...args);
  },
};

export const LoadingState = {
  render: (...args) => {
    const subscriptionCreditsUsageResolver = () => new Promise(() => {});

    return createTemplate({
      subscriptionCreditsUsageResolver,
    })(...args);
  },
};

export const ErrorState = {
  render: (...args) => {
    const subscriptionCreditsUsageResolver = () =>
      Promise.reject(new Error('Failed to fetch credit usage data'));

    return createTemplate({
      subscriptionCreditsUsageResolver,
    })(...args);
  },
};
