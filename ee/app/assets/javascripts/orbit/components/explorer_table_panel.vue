<script>
import { defineComponent } from 'vue';
import { GlButton, GlIcon, GlLoadingIcon } from '@gitlab/ui';
import { n__, s__, sprintf } from '~/locale';
import { downloadCsv } from '../utils/csv_export';
import QueryResultsTable from './query_results_table.vue';

const i18n = {
  hideSql: s__('Orbit|Hide SQL'),
  showSql: s__('Orbit|Show SQL'),
  csv: s__('Orbit|CSV'),
  emptyState: s__('Orbit|Run a query to see results'),
};

export default defineComponent({
  name: 'ExplorerTablePanel',
  compatConfig: { MODE: 3 },
  components: {
    GlButton,
    GlIcon,
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
      required: false,
      default: null,
    },
    loading: {
      type: Boolean,
      required: false,
      default: false,
    },
  },
  i18n,
  emits: ['row-click'],
  data() {
    return {
      showSql: false,
    };
  },
  computed: {
    hasResults() {
      return this.resultCount != null && this.resultCount > 0 && this.queryResponse != null;
    },
    hasSql() {
      return Boolean(this.generatedSql);
    },
    resultsLabel() {
      return sprintf(n__('%{count} result', '%{count} results', this.resultCount ?? 0), {
        count: this.resultCount ?? 0,
      });
    },
    canDownloadCsv() {
      return this.queryResponse != null;
    },
  },
  methods: {
    toggleSql() {
      this.showSql = !this.showSql;
    },
    handleDownloadCsv() {
      downloadCsv(this.queryResponse);
    },
  },
});
</script>

<template>
  <div class="gl-flex gl-flex-1 gl-flex-col gl-overflow-hidden" data-testid="explorer-table-panel">
    <gl-loading-icon v-if="loading" size="lg" class="gl-my-6" />

    <template v-else-if="hasResults">
      <div
        class="gl-flex gl-items-center gl-gap-2 gl-px-4 gl-py-2"
        data-testid="table-results-header"
      >
        <span class="gl-font-semibold">{{ resultsLabel }}</span>
        <div class="gl-flex-1"></div>
        <gl-button
          v-if="hasSql"
          size="small"
          category="tertiary"
          data-testid="toggle-sql-btn"
          @click="toggleSql"
        >
          {{ showSql ? $options.i18n.hideSql : $options.i18n.showSql }}
        </gl-button>
        <gl-button
          size="small"
          category="tertiary"
          icon="download"
          :disabled="!canDownloadCsv"
          data-testid="download-csv-btn"
          @click="handleDownloadCsv"
        >
          {{ $options.i18n.csv }}
        </gl-button>
      </div>

      <div
        v-if="showSql && generatedSql"
        class="gl-border-b gl-border-default gl-bg-strong gl-px-4 gl-py-3"
        data-testid="sql-display"
      >
        <pre
          class="gl-mb-0 gl-whitespace-pre-wrap gl-break-all gl-font-monospace gl-text-xs gl-text-subtle"
          >{{ generatedSql }}</pre
        >
      </div>

      <div class="gl-flex-1 gl-overflow-auto">
        <query-results-table :results="queryResponse" @row-click="$emit('row-click', $event)" />
      </div>
    </template>

    <div v-else class="gl-flex gl-flex-1 gl-flex-col gl-items-center gl-justify-center gl-p-5">
      <gl-icon name="table" :size="24" class="gl-mb-2 gl-text-subtle" aria-hidden="true" />
      <p class="gl-mb-0 gl-text-sm gl-text-subtle" data-testid="table-empty-state">
        {{ $options.i18n.emptyState }}
      </p>
    </div>
  </div>
</template>
