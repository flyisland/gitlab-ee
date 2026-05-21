<script>
import { fetchPolicies } from '~/lib/graphql';
import * as Sentry from '~/sentry/sentry_browser_wrapper';
import { InternalEvents } from '~/tracking';
import glFeatureFlagsMixin from '~/vue_shared/mixins/gl_feature_flags_mixin';
import ErrorsAlert from '~/vue_shared/components/errors_alert.vue';
import AiCatalogListHeader from '../components/ai_catalog_list_header.vue';
import AiCatalogListWrapper from '../components/ai_catalog_list_wrapper.vue';
import {
  AI_CATALOG_TYPE_AGENT,
  AI_CATALOG_TYPE_THIRD_PARTY_FLOW,
  PAGE_SIZE,
  TRACK_EVENT_VIEW_AI_CATALOG_ITEM_INDEX,
  AI_CATALOG_APOLLO_LIST_QUERY,
} from '../constants';
import { getRegistryItem, itemTypeValidator } from '../item_type_registry';
import { paginationMethodsFor } from '../pagination_utils';

export default {
  name: 'AiCatalogItemsIndex',
  components: {
    AiCatalogListHeader,
    AiCatalogListWrapper,
    ErrorsAlert,
  },
  mixins: [glFeatureFlagsMixin(), InternalEvents.mixin()],
  props: {
    itemType: {
      type: String,
      required: true,
      validator: itemTypeValidator,
    },
  },
  data() {
    return {
      aiCatalogItems: [],
      pageInfo: {},
      searchTerm: this.$route.query.search || '',
      errors: [],
    };
  },
  apollo: {
    aiCatalogItems: {
      query: AI_CATALOG_APOLLO_LIST_QUERY,
      variables() {
        return {
          itemTypes: this.resolvedItemTypes,
          before: null,
          after: null,
          first: PAGE_SIZE,
          last: null,
          search: this.searchTerm,
        };
      },
      fetchPolicy: fetchPolicies.CACHE_AND_NETWORK,
      update: (data) => data?.aiCatalogItems?.nodes || [],
      result({ data }) {
        this.pageInfo = data?.aiCatalogItems?.pageInfo || {};
      },
      error(error) {
        this.errors = [this.itemRegistry.index.errorMessage];
        Sentry.captureException(error);
      },
    },
  },
  computed: {
    itemRegistry() {
      return getRegistryItem(this.itemType);
    },
    resolvedItemTypes() {
      if (this.itemType === AI_CATALOG_TYPE_AGENT && this.glFeatures.aiCatalogThirdPartyFlows) {
        return [AI_CATALOG_TYPE_AGENT, AI_CATALOG_TYPE_THIRD_PARTY_FLOW];
      }
      return [this.itemType];
    },
    isLoading() {
      return this.$apollo.queries.aiCatalogItems.loading;
    },
    itemTypeConfig() {
      return {
        showRoute: this.itemRegistry.routes.show,
        visibilityTooltip: this.itemRegistry.visibilityDescriptions,
      };
    },
  },
  watch: {
    '$route.query.search': {
      handler(newSearch) {
        this.searchTerm = newSearch || '';
      },
    },
  },
  mounted() {
    this.trackEvent(TRACK_EVENT_VIEW_AI_CATALOG_ITEM_INDEX, {
      label: this.itemRegistry.trackLabel,
    });
  },
  methods: {
    ...paginationMethodsFor('aiCatalogItems'),
    handleSearch(filters) {
      [this.searchTerm] = filters;
      const newSearch = this.searchTerm || undefined;
      if (this.$route.query.search !== newSearch) {
        this.$router.replace({
          query: { ...this.$route.query, search: newSearch },
        });
      }
    },
    handleClearSearch() {
      this.searchTerm = '';
      const { search, ...rest } = this.$route.query;
      this.$router.replace({ query: rest });
    },
    dismissErrors() {
      this.errors = [];
    },
  },
};
</script>

<template>
  <div>
    <ai-catalog-list-header />
    <errors-alert class="gl-mt-5" :errors="errors" @dismiss="dismissErrors" />

    <ai-catalog-list-wrapper
      :is-loading="isLoading"
      :items="aiCatalogItems"
      :item-type-config="itemTypeConfig"
      :page-info="pageInfo"
      :search-term="searchTerm"
      @next-page="handleNextPage"
      @prev-page="handlePrevPage"
      @search="handleSearch"
      @clear-search="handleClearSearch"
    />
  </div>
</template>
