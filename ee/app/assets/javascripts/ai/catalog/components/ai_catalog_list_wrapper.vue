<script>
import { GlFilteredSearch } from '@gitlab/ui';
import { s__ } from '~/locale';
import { FILTERED_SEARCH_TERM } from '~/vue_shared/components/filtered_search_bar/constants';
import AiCatalogList from './ai_catalog_list.vue';

export default {
  name: 'AiCatalogListWrapper',
  components: {
    AiCatalogList,
    GlFilteredSearch,
  },
  props: {
    items: {
      type: Array,
      required: true,
    },
    isLoading: {
      type: Boolean,
      required: false,
      default: false,
    },
    pageInfo: {
      type: Object,
      required: true,
    },
    itemTypeConfig: {
      type: Object,
      required: true,
      validator(item) {
        return item.showRoute && item.visibilityTooltip;
      },
    },
    emptyStateTitle: {
      type: String,
      required: false,
      default: s__('AICatalog|Get started with the AI Catalog'),
    },
    emptyStateDescription: {
      type: String,
      required: false,
      default: s__(
        'AICatalog|Build agents and flows to automate tasks and solve complex problems.',
      ),
    },
    emptyStateButtonHref: {
      type: String,
      required: false,
      default: null,
    },
    emptyStateButtonText: {
      type: String,
      required: false,
      default: null,
    },
    searchTerm: {
      type: String,
      required: false,
      default: '',
    },
  },
  emits: ['search', 'clear-search', 'empty-state-click', 'next-page', 'prev-page'],
  computed: {
    showSearch() {
      const hasItems = this.items && this.items.length > 0;
      return hasItems || Boolean(this.searchTerm);
    },
    filteredSearchValue() {
      return [
        {
          type: FILTERED_SEARCH_TERM,
          value: { data: this.searchTerm },
        },
      ];
    },
  },
  methods: {
    handleSearch(filters) {
      this.$emit('search', filters);
    },
    handleClearSearch() {
      this.$emit('clear-search');
    },
  },
};
</script>

<template>
  <div>
    <div v-if="showSearch" class="gl-border-b gl-bg-subtle gl-p-5">
      <gl-filtered-search
        :value="filteredSearchValue"
        @submit="handleSearch"
        @clear="handleClearSearch"
      />
    </div>

    <ai-catalog-list
      :is-loading="isLoading"
      :items="items"
      :item-type-config="itemTypeConfig"
      :page-info="pageInfo"
      :search="searchTerm"
      :empty-state-title="emptyStateTitle"
      :empty-state-description="emptyStateDescription"
      :empty-state-button-href="emptyStateButtonHref"
      :empty-state-button-text="emptyStateButtonText"
      @empty-state-click="$emit('empty-state-click')"
      @next-page="$emit('next-page')"
      @prev-page="$emit('prev-page')"
    />
  </div>
</template>
