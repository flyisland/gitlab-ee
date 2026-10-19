import { GlTable } from '@gitlab/ui';
import Vue, { nextTick } from 'vue';
import Vuex from 'vuex';
import { mountExtended } from 'helpers/vue_test_utils_helper';
import PerformanceTable from 'jh/analytics/performance_analytics/components/performance_table.vue';
import createState from 'jh/analytics/performance_analytics/store/state';
import mutations from 'jh/analytics/performance_analytics/store/mutations';
import * as getters from 'jh/analytics/performance_analytics/store/getters';
import * as types from 'jh/analytics/performance_analytics/store/mutation_types';
import {
  PERFORMANCE_TABLE_COLUMNS,
  PERFORMANCE_TABLE_FULLNAME,
} from 'jh/analytics/performance_analytics/constants';
import { currentGroup, mockReportSummaryState } from '../mock';

Vue.use(Vuex);

const fakeStore = () =>
  new Vuex.Store({
    state: createState({
      groupId: currentGroup.groupId,
      fullPath: currentGroup.fullPath,
      isGroup: currentGroup.isGroup,
      reportSummary: {},
      projectId: null,
    }),
    getters,
    mutations,
  });

function createComponent(state = {}) {
  const store = fakeStore(state);

  return mountExtended(PerformanceTable, {
    store,
  });
}

describe('PerformanceTable', () => {
  let wrapper;

  const findExportButton = () => wrapper.findComponentByTestId('export-performance-table-as-csv');
  const findTable = () => wrapper.findComponent(GlTable);

  beforeEach(() => {
    wrapper = createComponent();
  });

  describe('renders', () => {
    describe('export csv button', () => {
      it('has correct text', () => {
        expect(findExportButton().exists()).toBe(true);
        expect(findExportButton().text()).toBe('Export as CSV');
      });

      it('has export icon', () => {
        expect(findExportButton().props('icon')).toBe('export');
      });
    });

    describe('statement table', () => {
      it('with correct table header in group analytics page', async () => {
        wrapper.vm.$store.commit(types.SET_IS_GROUP, true);
        await nextTick();

        expect(findTable().exists()).toBe(true);

        const tableHeaders = [
          'Name',
          'Pushes',
          'Created issues',
          'Closed issues',
          'Created MRs',
          'Approved MRs',
          'Merged MRs',
          'Closed MRs',
          'Comments',
        ];
        const headerEls = findTable().findAll('[data-testid="headers"]');
        expect(headerEls).toHaveLength(tableHeaders.length);

        tableHeaders.forEach((item, index) => {
          expect(headerEls.at(index).text()).toContain(item);
        });
      });

      it('with correct table header in project analytics page', async () => {
        wrapper.vm.$store.commit(types.SET_IS_GROUP, false);
        await nextTick();

        const tableHeaders = [
          'Name',
          'Commits',
          'Created issues',
          'Closed issues',
          'Created MRs',
          'Approved MRs',
          'Merged MRs',
          'Closed MRs',
          'Comments',
        ];
        const headerEls = findTable().findAll('[data-testid="headers"]');
        expect(headerEls).toHaveLength(tableHeaders.length);

        tableHeaders.forEach((item, index) => {
          expect(headerEls.at(index).text()).toContain(item);
        });
      });

      it('should has summary row', async () => {
        wrapper.vm.$store.commit(types.SET_IS_GROUP, false);
        wrapper.vm.$store.commit(types.SET_REPORT_SUMMARY, mockReportSummaryState);
        await nextTick();

        const summaryCells = findTable().findAll('[data-test-id="performance-summary-cell"');

        expect(summaryCells).toHaveLength(PERFORMANCE_TABLE_COLUMNS.length);

        PERFORMANCE_TABLE_COLUMNS.forEach((item, index) => {
          const summaryCellValue =
            item.key === PERFORMANCE_TABLE_FULLNAME
              ? 'Total'
              : `${mockReportSummaryState[item.key]}`;
          expect(summaryCells.at(index).text()).toBe(summaryCellValue);
        });
      });
    });
  });
});
