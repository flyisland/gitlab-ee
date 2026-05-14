<script>
import { defineComponent } from 'vue';
import { GlBadge, GlButton, GlLoadingIcon } from '@gitlab/ui';
import { s__ } from '~/locale';
import { downloadCsv } from '../utils/csv_export';
import QueryResultsTable from './query_results_table.vue';

export default defineComponent({
  name: 'ExplorerTablePanel',
  compatConfig: { MODE: 3 },
  components: {
    GlBadge,
    GlButton,
    GlLoadingIcon,
    QueryResultsTable,
  },
  props: {
    queryResponse: {
      type: Object,
      required: false,
      default: null,
    },
    generatedSql: {
      type: String,
      required: false,
      default: '',
    },
    resultCount: {
      type: Number,
      required: true,
    },
    loading: {
      type: Boolean,
      required: false,
      default: false,
    },
    expanded: {
      type: Boolean,
      required: false,
      default: false,
    },
  },
  emits: ['toggle-expand', 'row-click'],
  data() {
    return {
      showSql: false,
    };
  },
  computed: {
    hasResults() {
      return this.resultCount > 0;
    },
    hasSql() {
      return Boolean(this.generatedSql);
    },
    expandIcon() {
      return this.expanded ? 'minimize' : 'maximize';
    },
    expandLabel() {
      return this.expanded ? s__('Orbit|Minimize') : s__('Orbit|Maximize');
    },
    sqlToggleLabel() {
      return this.showSql ? s__('Orbit|Hide SQL') : s__('Orbit|Show SQL');
    },
  },
  methods: {
    toggleSql() {
      this.showSql = !this.showSql;
    },
    handleDownloadCsv() {
      if (!this.queryResponse) return;
      downloadCsv(this.queryResponse);
    },
  },
});
</script>

<template>
  <div
    class="gl-border-l gl-flex gl-flex-1 gl-flex-col gl-overflow-hidden gl-border-default"
    :class="{ 'gl-border-l-0': expanded }"
    data-testid="explorer-table-panel"
  >
    <gl-loading-icon v-if="loading" size="lg" class="gl-my-6" />

    <template v-else-if="hasResults">
      <div
        class="gl-flex gl-items-center gl-gap-3 gl-bg-strong gl-px-4 gl-py-2"
        data-testid="table-results-header"
      >
        <span class="gl-text-sm gl-font-bold">{{ s__('Orbit|Results') }}</span>
        <gl-badge size="sm">{{ resultCount }} {{ s__('Orbit|rows') }}</gl-badge>
        <gl-button
          size="small"
          :icon="expandIcon"
          :aria-label="expandLabel"
          category="tertiary"
          data-testid="table-expand-btn"
          @click="$emit('toggle-expand')"
        />
        <div class="gl-flex-1"></div>
        <gl-button
          v-if="hasSql"
          size="small"
          category="tertiary"
          data-testid="toggle-sql-btn"
          @click="toggleSql"
        >
          {{ sqlToggleLabel }}
        </gl-button>
        <gl-button
          size="small"
          icon="download"
          data-testid="download-csv-btn"
          @click="handleDownloadCsv"
        >
          {{ s__('Orbit|Download CSV') }}
        </gl-button>
      </div>

      <div
        v-if="showSql && generatedSql"
        class="gl-bg-subtle gl-px-4 gl-py-2"
        data-testid="sql-display"
      >
        <pre class="gl-mb-0 gl-whitespace-pre-wrap gl-break-all gl-text-sm">{{ generatedSql }}</pre>
      </div>

      <div class="gl-flex-1 gl-overflow-auto">
        <query-results-table :results="queryResponse" @row-click="$emit('row-click', $event)" />
      </div>
    </template>

    <div v-else class="gl-flex gl-flex-1 gl-items-center gl-justify-center gl-text-subtle">
      <p data-testid="table-empty-state">
        {{ s__('Orbit|No results. Execute a query to see data.') }}
      </p>
    </div>
  </div>
</template>
