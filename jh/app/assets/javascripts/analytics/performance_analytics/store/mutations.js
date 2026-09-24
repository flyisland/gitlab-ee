import { normalizeHeaders, parseIntPagination } from '~/lib/utils/common_utils';
import * as types from './mutation_types';

export default {
  [types.SET_SELECTED_PROJECTS](state, projects) {
    state.selectedProjects = projects;
  },
  [types.SET_IS_GROUP](state, isGroup) {
    state.isGroup = isGroup;
  },
  [types.SET_SUMMARY_DATA](state, summaryData) {
    state.summaryData = summaryData;
  },
  [types.SET_RANK_LIST](state, rankList) {
    state.rankList = rankList;
  },
  [types.SET_PERFORMANCE_TABLE](state, performanceTable) {
    state.performanceTable = performanceTable;
  },
  [types.SET_REPORT_SUMMARY](state, reportSummary) {
    state.reportSummary = reportSummary;
  },
  [types.SET_LOADING_TOGGLE](state, isLoading) {
    state.loading = isLoading;
  },
  [types.SET_DATE](state, selectDate) {
    state.selectDate = selectDate;
  },
  [types.SET_TABLE_PAGINATION](state, headers) {
    state.tablePagination = parseIntPagination(normalizeHeaders(headers));
  },
  [types.SET_SELECTED_BRANCH](state, branchName) {
    state.branch = branchName;
  },
};
