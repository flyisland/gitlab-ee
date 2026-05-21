<script>
import { GlTab, GlAlert, GlLoadingIcon, GlEmptyState } from '@gitlab/ui';
import EMPTY_SVG_URL from '@gitlab/svgs/dist/illustrations/empty-state/empty-catalog-md.svg';
import { InternalEvents } from '~/tracking';
import getCatalogResourceUsage from '../../graphql/queries/get_resource_usage.query.graphql';
import getCatalogResourceUsagePermissions from '../../graphql/queries/get_resource_usage_permissions.query.graphql';
import UsageDetails from './usage_details.vue';

const ITEMS_PER_PAGE = 20;

export default {
  name: 'CiResourceAnalytics',
  components: {
    GlTab,
    GlAlert,
    GlLoadingIcon,
    GlEmptyState,
    UsageDetails,
  },
  mixins: [InternalEvents.mixin()],
  props: {
    resourcePath: {
      type: String,
      required: true,
    },
  },
  data() {
    return {
      componentUsages: [],
      pageInfo: {},
      paginationParams: { first: ITEMS_PER_PAGE },
      hasError: false,
      isFeatureAvailable: false,
    };
  },
  apollo: {
    isFeatureAvailable: {
      query: getCatalogResourceUsagePermissions,
      variables() {
        return {
          fullPath: this.resourcePath,
        };
      },
      update(data) {
        const userPermissions = data?.project?.userPermissions?.readProjectComponentUsages ?? false;
        const featureAvailable = data?.project?.licensedFeatureAvailability?.available ?? false;
        return userPermissions && featureAvailable;
      },
    },
    componentUsages: {
      query: getCatalogResourceUsage,
      variables() {
        return {
          fullPath: this.resourcePath,
          ...this.paginationParams,
        };
      },
      update(data) {
        return data?.ciCatalogResource?.projectComponentUsages?.nodes || [];
      },
      result({ data }) {
        this.pageInfo = data?.ciCatalogResource?.projectComponentUsages?.pageInfo || {};
      },
      skip() {
        return !this.isFeatureAvailable;
      },
      error() {
        this.hasError = true;
      },
    },
  },
  computed: {
    isLoading() {
      return this.$apollo.queries.componentUsages.loading;
    },
    isEmpty() {
      return this.componentUsages.length === 0;
    },
  },
  methods: {
    handleNextPage() {
      this.paginationParams = { first: ITEMS_PER_PAGE, after: this.pageInfo.endCursor };
    },
    handlePrevPage() {
      this.paginationParams = { last: ITEMS_PER_PAGE, before: this.pageInfo.startCursor };
    },
    onTabClick() {
      this.trackEvent('click_component_usage_tab_on_ci_catalog');
    },
  },
  EMPTY_SVG_URL,
};
</script>
<template>
  <gl-tab v-if="isFeatureAvailable" :title="s__('CiCatalog|Usage')" lazy @click="onTabClick">
    <gl-loading-icon v-if="isLoading" size="lg" />
    <gl-alert v-else-if="hasError" variant="danger" :dismissible="false">{{
      s__(
        'CiCatalog|An error occurred while fetching usage statistics. Refresh the page or try again later.',
      )
    }}</gl-alert>
    <gl-empty-state
      v-else-if="isEmpty"
      :title="s__('CiCatalog|No usage data available')"
      :description="
        s__(
          'CiCatalog|There are no projects using this resource in the last 30 days, or you don\'t have permission to view them.',
        )
      "
      :svg-path="$options.EMPTY_SVG_URL"
    />

    <usage-details
      v-else
      :component-usages="componentUsages"
      :page-info="pageInfo"
      @next-page="handleNextPage"
      @prev-page="handlePrevPage"
    />
  </gl-tab>
</template>
