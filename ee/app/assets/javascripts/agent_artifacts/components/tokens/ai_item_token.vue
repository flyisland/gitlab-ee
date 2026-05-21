<script>
import { GlFilteredSearchSuggestion } from '@gitlab/ui';
import * as Sentry from '~/sentry/sentry_browser_wrapper';
import { createAlert } from '~/alert';
import { s__ } from '~/locale';
import BaseToken from '~/vue_shared/components/filtered_search_bar/tokens/base_token.vue';
import {
  AI_CATALOG_TYPE_AGENT,
  AI_CATALOG_TYPE_FLOW,
  AI_CATALOG_TYPE_THIRD_PARTY_FLOW,
} from 'ee/ai/catalog/constants';
import getAvailableAiItemNamesQuery from '../../graphql/queries/get_available_ai_item_names.query.graphql';

export default {
  name: 'AiItemToken',
  components: {
    BaseToken,
    GlFilteredSearchSuggestion,
  },
  inject: ['groupId', 'projectId'],
  props: {
    config: {
      type: Object,
      required: true,
    },
    value: {
      type: Object,
      required: true,
    },
    active: {
      type: Boolean,
      required: true,
    },
  },
  data() {
    return {
      items: [],
      loading: true,
    };
  },
  methods: {
    async fetchSuggestions() {
      if (this.items.length === 0 && this.active) {
        await this.fetchItems();
      }
    },
    async fetchItems() {
      this.loading = true;
      try {
        const { data } = await this.$apollo.query({
          query: getAvailableAiItemNamesQuery,
          variables: {
            groupId: this.groupId || null,
            projectId: this.projectId || null,
            itemTypes: [
              AI_CATALOG_TYPE_AGENT,
              AI_CATALOG_TYPE_FLOW,
              AI_CATALOG_TYPE_THIRD_PARTY_FLOW,
            ],
          },
        });
        const nodes = data?.aiCatalogConfiguredItems?.nodes || [];
        const validNodes = nodes.filter((node) => {
          if (!node?.item) {
            // eslint-disable-next-line @gitlab/require-i18n-strings
            Sentry.captureException(new Error('AI catalog configured item missing item field'), {
              extra: { nodeId: node?.id },
            });
            return false;
          }
          return true;
        });
        this.items = validNodes.map((node) => ({
          value: node.item.name,
          title: node.item.name,
        }));
      } catch {
        createAlert({
          message: s__('AgentArtifacts|Failed to load AI item names.'),
        });
        this.items = [];
      } finally {
        this.loading = false;
      }
    },
  },
};
</script>

<template>
  <base-token
    v-bind="$attrs"
    :active="active"
    :config="config"
    :value="value"
    :suggestions-loading="loading"
    :suggestions="items"
    v-on="$listeners"
    @fetch-suggestions="fetchSuggestions"
  >
    <template #suggestions-list="{ suggestions }">
      <gl-filtered-search-suggestion
        v-for="item in suggestions"
        :key="item.value"
        :value="item.value"
      >
        {{ item.title }}
      </gl-filtered-search-suggestion>
    </template>
  </base-token>
</template>
