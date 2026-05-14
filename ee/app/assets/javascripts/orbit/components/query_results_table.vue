<script>
import { defineComponent } from 'vue';
import { GlTable, GlLoadingIcon, GlEmptyState } from '@gitlab/ui';
import { flattenNodesToRows } from '../utils/graph_transform';

export default defineComponent({
  name: 'QueryResultsTable',
  compatConfig: { MODE: 3 },
  components: {
    GlTable,
    GlLoadingIcon,
    GlEmptyState,
  },
  props: {
    results: {
      type: Object,
      required: true,
    },
    loading: {
      type: Boolean,
      required: false,
      default: false,
    },
  },
  emits: ['row-click'],
  computed: {
    rows() {
      return flattenNodesToRows(this.results);
    },
    fields() {
      return Object.keys(this.rows[0] ?? {}).map((key) => ({
        key,
        label: key.replace(/_/g, ' '),
        sortable: true,
      }));
    },
  },
});
</script>

<template>
  <div data-testid="query-results-table">
    <gl-loading-icon v-if="loading" size="lg" class="gl-my-6" />

    <gl-empty-state
      v-else-if="rows.length === 0"
      :title="s__('Orbit|No results')"
      :description="s__('Orbit|Run a query to see results here.')"
    />

    <gl-table
      v-else
      :items="rows"
      :fields="fields"
      striped
      hover
      stacked="md"
      class="gl-mb-0"
      @row-clicked="$emit('row-click', $event)"
    />
  </div>
</template>
