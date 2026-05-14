/* eslint-disable @gitlab/require-i18n-strings */
export const mockSubscriptionCreditsUsageData = {
  data: {
    subscriptionCreditsUsage: {
      __typename: 'SubscriptionCreditsUsage',
      lastEventTransactionAt: '2026-01-31T00:00:00Z',
      startDate: '2026-02-01',
      endDate: '2026-02-28',
      creditsUsed: 13800,
      dailyAverage: 616,
      peakDay: {
        __typename: 'SubscriptionCreditsDailyUsage',
        creditsUsed: 920,
        date: '2026-02-03',
      },
      dailyUsage: [
        { __typename: 'SubscriptionCreditsDailyUsage', creditsUsed: 320, date: '2026-02-01' },
        { __typename: 'SubscriptionCreditsDailyUsage', creditsUsed: 540, date: '2026-02-02' },
        { __typename: 'SubscriptionCreditsDailyUsage', creditsUsed: 920, date: '2026-02-03' },
        { __typename: 'SubscriptionCreditsDailyUsage', creditsUsed: 610, date: '2026-02-04' },
        { __typename: 'SubscriptionCreditsDailyUsage', creditsUsed: 480, date: '2026-02-05' },
        { __typename: 'SubscriptionCreditsDailyUsage', creditsUsed: 760, date: '2026-02-06' },
        { __typename: 'SubscriptionCreditsDailyUsage', creditsUsed: 680, date: '2026-02-07' },
      ],
      users: {
        __typename: 'SubscriptionCreditsUserConnection',
        totalCount: 215,
        pageInfo: {
          __typename: 'PageInfo',
          hasNextPage: true,
          hasPreviousPage: false,
          startCursor: 'usersStartCursor',
          endCursor: 'usersEndCursor',
        },
        nodes: [
          {
            __typename: 'SubscriptionCreditsUser',
            id: 'user_1',
            name: 'Alice Johnson',
            username: 'ajohnson',
            avatarUrl:
              'https://www.gravatar.com/avatar/00000000000000000000000000000001?d=identicon',
            usage: { __typename: 'SubscriptionCreditsUserUsage', totalCreditsUsed: 1240 },
          },
          {
            __typename: 'SubscriptionCreditsUser',
            id: 'user_2',
            name: 'Bob Smith',
            username: 'bsmith',
            avatarUrl:
              'https://www.gravatar.com/avatar/00000000000000000000000000000002?d=identicon',
            usage: { __typename: 'SubscriptionCreditsUserUsage', totalCreditsUsed: 890 },
          },
          {
            __typename: 'SubscriptionCreditsUser',
            id: 'user_3',
            name: 'Carol White',
            username: 'cwhite',
            avatarUrl:
              'https://www.gravatar.com/avatar/00000000000000000000000000000003?d=identicon',
            usage: { __typename: 'SubscriptionCreditsUserUsage', totalCreditsUsed: 670 },
          },
          {
            __typename: 'SubscriptionCreditsUser',
            id: 'user_4',
            name: 'Dan Lee',
            username: 'dlee',
            avatarUrl:
              'https://www.gravatar.com/avatar/00000000000000000000000000000004?d=identicon',
            usage: { __typename: 'SubscriptionCreditsUserUsage', totalCreditsUsed: 510 },
          },
          {
            __typename: 'SubscriptionCreditsUser',
            id: 'user_5',
            name: 'Eve Chen',
            username: 'echen',
            avatarUrl:
              'https://www.gravatar.com/avatar/00000000000000000000000000000005?d=identicon',
            usage: { __typename: 'SubscriptionCreditsUserUsage', totalCreditsUsed: 1000 },
          },
        ],
      },
      products: {
        __typename: 'SubscriptionCreditsProductConnection',
        nodes: [
          {
            __typename: 'SubscriptionCreditsProduct',
            id: 'hosted_runners',
            name: 'Hosted Runners',
            category: 'top_level',
            creditsUsed: 3200,
          },
          {
            __typename: 'SubscriptionCreditsProduct',
            id: 'compute_minutes',
            name: 'Compute Minutes',
            category: 'top_level',
            creditsUsed: 2800,
          },
          {
            __typename: 'SubscriptionCreditsProduct',
            id: 'product_analytics',
            name: 'Product Analytics',
            category: 'top_level',
            creditsUsed: 1600,
          },
          {
            __typename: 'SubscriptionCreditsProduct',
            id: 'storage',
            name: 'Storage',
            category: 'top_level',
            creditsUsed: 1460,
          },
          {
            __typename: 'SubscriptionCreditsProduct',
            id: 'code_review_summary',
            name: 'Code Review Summary',
            category: 'duo',
            creditsUsed: 1240,
          },
        ],
        pageInfo: {
          __typename: 'PageInfo',
          hasNextPage: true,
          hasPreviousPage: false,
          startCursor: 'startCursorValue',
          endCursor: 'endCursorValue',
        },
      },
    },
  },
};
