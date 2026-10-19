<script>
import {
  GlLink,
  GlButton,
  GlLoadingIcon,
  GlPagination,
  GlTable,
  GlTooltipDirective,
} from '@gitlab/ui';
import { escape, get } from 'lodash';
import { mapActions, mapGetters, mapMutations, mapState } from 'vuex';
import { downloadCsv } from 'jh/analytics/performance_analytics/utils';
import { s__ } from '~/locale';
import { createAlert } from '~/alert';
import { convertObjectPropsToCamelCase } from '~/lib/utils/common_utils';
import { downloadGroupPerformanceReport, downloadProjectPerformanceReport } from 'jh/rest_api';
import {
  SET_TABLE_PAGINATION,
  SET_PERFORMANCE_TABLE,
} from 'jh/analytics/performance_analytics/store/mutation_types';
import {
  DEFAULT_PER_PAGE,
  PERFORMANCE_TYPE_COMMITS_NUMBER,
  PUSH_COLUMNS_TEXT,
  PERFORMANCE_TABLE_COLUMNS,
  PERFORMANCE_TABLE_TITLE,
  EXPORT_AS_CSV_BUTTON_TEXT,
  PREV,
  NEXT,
  EMPTY_TABLE_TEXT,
  ERROR_MSG,
  PERFORMANCE_TABLE_FULLNAME,
} from 'jh/analytics/performance_analytics/constants';
import Tracking from '~/tracking';

const trackingMixin = Tracking.mixin();

export default {
  name: 'PerformanceTable',
  components: {
    GlTable,
    GlButton,
    GlPagination,
    GlLoadingIcon,
    GlLink,
  },
  directives: {
    GlTooltip: GlTooltipDirective,
  },
  mixins: [trackingMixin],
  data() {
    return {
      sortOptions: {
        sortBy: PERFORMANCE_TABLE_COLUMNS[0].key,
        sortDesc: true,
      },
      tableLoading: false,
      isDownloading: false,
    };
  },
  computed: {
    ...mapGetters(['performanceTableData', 'performanceAnalyticsRequestParams']),
    ...mapState({
      isGroup: (state) => state.isGroup,
      currentPage: (state) => state.tablePagination.page,
      totalItems: (state) => state.tablePagination.total,
      reportSummary: (state) => state.reportSummary,
    }),
    exportButtonDisabled() {
      return this.tableLoading || !this.performanceTableData.length || this.isDownloading;
    },
    columns() {
      if (this.isGroup) {
        return PERFORMANCE_TABLE_COLUMNS.map((column) => {
          return column.key === PERFORMANCE_TYPE_COMMITS_NUMBER
            ? { ...column, label: PUSH_COLUMNS_TEXT }
            : column;
        });
      }

      return PERFORMANCE_TABLE_COLUMNS;
    },
    summaryRow() {
      const summaryRowData = convertObjectPropsToCamelCase(this.reportSummary);

      return this.columns.map((column) => {
        if (column.key === PERFORMANCE_TABLE_FULLNAME) {
          return {
            key: 'summary',
            value: s__('JH|PerformanceAnalytics|Total'),
          };
        }
        return {
          key: column.key,
          value: get(summaryRowData, column.key, '--'),
        };
      });
    },
  },
  perPage: DEFAULT_PER_PAGE,
  i18n: {
    performanceTableTitle: PERFORMANCE_TABLE_TITLE,
    exportAsCsvButtonText: EXPORT_AS_CSV_BUTTON_TEXT,
    pagination: {
      next: NEXT,
      prev: PREV,
    },
    emptyState: EMPTY_TABLE_TEXT,
  },
  methods: {
    ...mapActions(['updatePerformanceTable']),
    ...mapMutations({
      setPerformanceTable: SET_PERFORMANCE_TABLE,
      setTablePagination: SET_TABLE_PAGINATION,
    }),
    onSortChange({ sortBy, sortDesc }) {
      this.sortOptions.sortBy = sortBy;
      this.sortOptions.sortDesc = sortDesc;
      if (this.totalItems > this.$options.perPage) {
        this.getTableData();
      }
    },
    sanitisedMemberLink(memberLink) {
      return escape(memberLink);
    },
    // The following is used by upstream component, we are simply overriding it
    // eslint-disable-next-line vue/no-unused-properties
    onSelectPage(page) {
      this.currentPage = page;
      this.getTableData();
    },
    downloadPerformanceReport(payload) {
      if (this.isGroup) {
        return downloadGroupPerformanceReport(payload);
      }
      return downloadProjectPerformanceReport(payload);
    },
    downloadCsv() {
      const { requestPath, ...params } = this.performanceAnalyticsRequestParams;
      this.isDownloading = true;

      this.track('click_button', {
        label: 'download_csv_button',
      });
      this.downloadPerformanceReport({ requestPath, ...params })
        .then((res) => {
          downloadCsv({
            fileData: encodeURIComponent(res.data),
            fileName: 'performance_report.csv',
          });

          this.isDownloading = false;
        })
        .catch(() => {
          createAlert({
            message: s__(
              'JH|PerformanceAnalytics|There was an error while export performance report data',
            ),
          });

          this.isDownloading = false;
        });
    },
    getTableData(page) {
      this.tableLoading = true;
      const pageNumber = page || this.currentPage;
      this.updatePerformanceTable({
        page: pageNumber,
        sort: this.sortOptions.sortBy,
        direction: this.sortOptions.sortDesc ? 'desc' : 'asc',
      })
        .then((res) => {
          this.setPerformanceTable(res.data);
          this.setTablePagination(res.headers);

          this.tableLoading = false;
        })
        .catch(() => {
          createAlert({
            message: ERROR_MSG,
          });
        });
    },
  },
};
</script>

<template>
  <div class="performance-table" data-testid="performance-table">
    <div
      class="gl-flex gl-items-center gl-justify-between gl-border-b-1 gl-border-t-1 gl-border-gray-100 gl-bg-gray-10 gl-px-5 gl-py-3 gl-border-b-solid gl-border-t-solid"
    >
      <h4>{{ $options.i18n.performanceTableTitle }}</h4>
      <gl-button
        v-gl-tooltip="$options.i18n.exportAsCsvButtonText"
        data-testid="export-performance-table-as-csv"
        icon="export"
        :aria-label="$options.i18n.exportAsCsvButtonText"
        :disabled="exportButtonDisabled"
        @click="downloadCsv"
      >
        {{ $options.i18n.exportAsCsvButtonText }}
      </gl-button>
    </div>

    <gl-table
      head-variant="white"
      :items="performanceTableData"
      :fields="columns"
      thead-class="border-bottom"
      :sort-by.sync="sortOptions.sortBy"
      :sort-desc.sync="sortOptions.sortDesc"
      stacked="lg"
      :busy="tableLoading"
      show-empty
      @sort-changed="onSortChange"
    >
      <template #top-row>
        <th v-for="item in summaryRow" :key="item.key" data-test-id="performance-summary-cell">
          {{ item.value }}
        </th>
      </template>
      <template #table-busy>
        <gl-loading-icon size="lg" color="dark" class="gl-mt-5" />
      </template>
      <template #cell(fullname)="{ item }">
        <gl-link target="_blank" :href="sanitisedMemberLink(item.userWebUrl)">{{
          item.fullname
        }}</gl-link>
      </template>
      <template #empty>
        <p class="gl-my-3 gl-py-3 gl-text-gray-400">{{ $options.i18n.emptyState }}</p>
      </template>
    </gl-table>
    <gl-pagination
      :value="currentPage"
      :per-page="$options.perPage"
      :total-items="totalItems"
      :prev-text="$options.i18n.pagination.prev"
      :next-text="$options.i18n.pagination.next"
      align="center"
      @input="getTableData"
    />
  </div>
</template>
