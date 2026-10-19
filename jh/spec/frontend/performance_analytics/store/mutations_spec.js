import initialState from 'jh/analytics/performance_analytics/store/state';
import * as types from 'jh/analytics/performance_analytics/store/mutation_types';
import mutations from 'jh/analytics/performance_analytics/store/mutations';
import {
  mockSelectedProjects,
  mockSummaryData,
  mockRankList,
  mockDefaultBranch,
  mockPerformanceTable,
  mockSelectedDate,
  currentGroup,
  mockReportSummary,
} from '../mock';

describe('Performance Analytics mutations', () => {
  let state;

  beforeEach(() => {
    state = initialState({
      groupId: currentGroup.groupId,
      fullPath: currentGroup.fullPath,
      isGroup: currentGroup.isGroup,
      projectId: null,
    });
  });

  afterEach(() => {
    state = null;
  });

  const pagination = {
    page: 1,
    total: 10,
  };

  const header = {
    'x-page': 1,
    'x-total': 10,
  };

  it.each`
    mutation                       | payload                 | stateKey              | value
    ${types.SET_SELECTED_PROJECTS} | ${mockSelectedProjects} | ${'selectedProjects'} | ${mockSelectedProjects}
    ${types.SET_IS_GROUP}          | ${false}                | ${'isGroup'}          | ${false}
    ${types.SET_SUMMARY_DATA}      | ${mockSummaryData}      | ${'summaryData'}      | ${mockSummaryData}
    ${types.SET_RANK_LIST}         | ${mockRankList}         | ${'rankList'}         | ${mockRankList}
    ${types.SET_PERFORMANCE_TABLE} | ${mockPerformanceTable} | ${'performanceTable'} | ${mockPerformanceTable}
    ${types.SET_LOADING_TOGGLE}    | ${false}                | ${'loading'}          | ${false}
    ${types.SET_DATE}              | ${mockSelectedDate}     | ${'selectDate'}       | ${mockSelectedDate}
    ${types.SET_TABLE_PAGINATION}  | ${header}               | ${'tablePagination'}  | ${pagination}
    ${types.SET_SELECTED_BRANCH}   | ${mockDefaultBranch}    | ${'branch'}           | ${mockDefaultBranch}
    ${types.SET_REPORT_SUMMARY}    | ${mockReportSummary}    | ${'reportSummary'}    | ${mockReportSummary}
  `('$mutation will set $stateKey to $value', ({ mutation, payload, stateKey, value }) => {
    mutations[mutation](state, payload);

    expect(state).toMatchObject({ [stateKey]: value });
  });
});
