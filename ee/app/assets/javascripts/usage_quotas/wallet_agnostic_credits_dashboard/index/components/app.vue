<script>
import { GlAlert, GlTab, GlTabs } from '@gitlab/ui';
import { logError } from '~/lib/logger';
import { captureException } from '~/sentry/sentry_browser_wrapper';
import { PAGE_SIZE } from '../../../usage_billing/constants';
import subscriptionCreditsUsageQuery from '../graphql/get_usage_overview.query.graphql';
import ProductsList from './products_list.vue';
import UsageCards from './usage_cards.vue';
import UsersList from './users_list.vue';

export default {
  name: 'WalletAgnosticCreditsDashboard',
  components: {
    GlAlert,
    GlTab,
    GlTabs,
    ProductsList,
    UsageCards,
    UsersList,
  },
  inject: {
    namespacePath: {
      default: null,
    },
    userUsagePath: 'userUsagePath',
  },
  data() {
    return {
      subscriptionCreditsUsage: {},
      hasError: false,
      productsPageInfo: {
        productsListAfter: null,
        productsListBefore: null,
        productsListFirst: PAGE_SIZE,
        productsListLast: null,
      },
      usersPageInfo: {
        usersListAfter: null,
        usersListBefore: null,
        usersListFirst: PAGE_SIZE,
        usersListLast: null,
      },
    };
  },
  apollo: {
    subscriptionCreditsUsage: {
      query: subscriptionCreditsUsageQuery,
      variables() {
        return {
          namespacePath: this.namespacePath,
          ...this.productsPageInfo,
          ...this.usersPageInfo,
        };
      },
      update({ subscriptionCreditsUsage }) {
        return subscriptionCreditsUsage ?? {};
      },
      error(error) {
        this.hasError = true;
        logError(error);
        captureException(error);
      },
    },
  },
  computed: {
    isLoading() {
      return this.$apollo.queries.subscriptionCreditsUsage.loading;
    },
    totalUsedCredits() {
      return this.subscriptionCreditsUsage.creditsUsed ?? 0;
    },
    activeUsersCount() {
      return this.subscriptionCreditsUsage.users?.totalCount ?? 0;
    },
    dailyAverage() {
      return this.subscriptionCreditsUsage.dailyAverage ?? 0;
    },
    peakDayUsage() {
      return this.subscriptionCreditsUsage.peakDay?.creditsUsed ?? 0;
    },
    peakDayDate() {
      return this.subscriptionCreditsUsage.peakDay?.date ?? '';
    },
    products() {
      return this.subscriptionCreditsUsage.products ?? { nodes: [], pageInfo: {} };
    },
    users() {
      return this.subscriptionCreditsUsage.users ?? { nodes: [], pageInfo: {} };
    },
  },
  methods: {
    onProductsNextPage(cursor) {
      this.productsPageInfo = {
        productsListFirst: PAGE_SIZE,
        productsListAfter: cursor,
        productsListLast: null,
        productsListBefore: null,
      };
    },
    onProductsPrevPage(cursor) {
      this.productsPageInfo = {
        productsListFirst: null,
        productsListAfter: null,
        productsListLast: PAGE_SIZE,
        productsListBefore: cursor,
      };
    },
    onUsersNextPage(cursor) {
      this.usersPageInfo = {
        usersListFirst: PAGE_SIZE,
        usersListAfter: cursor,
        usersListLast: null,
        usersListBefore: null,
      };
    },
    onUsersPrevPage(cursor) {
      this.usersPageInfo = {
        usersListFirst: null,
        usersListAfter: null,
        usersListLast: PAGE_SIZE,
        usersListBefore: cursor,
      };
    },
  },
};
</script>

<template>
  <section>
    <div class="gl-mb-5">
      <h1 class="gl-mb-2">{{ s__('UsageBilling|GitLab Credits Overview') }}</h1>
      <p class="gl-text-subtle">
        {{
          s__('UsageBilling|Track monthly credit consumption and the main drivers of credit usage.')
        }}
      </p>
    </div>

    <gl-alert v-if="hasError" variant="danger" :dismissible="false" data-testid="error-alert">
      {{ s__('UsageBilling|An error occurred while fetching data') }}
    </gl-alert>

    <div v-else-if="isLoading" data-testid="skeleton-loaders">
      <div class="gl-animate-skeleton-loader gl-h-5 gl-rounded-base"></div>
    </div>

    <div v-else>
      <usage-cards
        :total-used-credits="totalUsedCredits"
        :active-users-count="activeUsersCount"
        :daily-average="dailyAverage"
        :peak-day-usage="peakDayUsage"
        :peak-day-date="peakDayDate"
      />

      <gl-tabs class="gl-mt-5">
        <gl-tab :title="s__('UsageBilling|Usage by user')">
          <users-list
            :users="users"
            :user-usage-path="userUsagePath"
            @next-page="onUsersNextPage"
            @prev-page="onUsersPrevPage"
          />
        </gl-tab>

        <gl-tab :title="s__('UsageBilling|Usage by product')">
          <products-list
            :products="products"
            :total-used-credits="totalUsedCredits"
            @next-page="onProductsNextPage"
            @prev-page="onProductsPrevPage"
          />
        </gl-tab>
      </gl-tabs>
    </div>
  </section>
</template>
