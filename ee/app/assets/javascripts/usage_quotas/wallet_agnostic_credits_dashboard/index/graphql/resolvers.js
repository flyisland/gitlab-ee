import { mockSubscriptionCreditsUsageData } from './mock_data';

export const resolvers = {
  Query: {
    subscriptionCreditsUsage: () => {
      return mockSubscriptionCreditsUsageData.data.subscriptionCreditsUsage;
    },
  },
};
