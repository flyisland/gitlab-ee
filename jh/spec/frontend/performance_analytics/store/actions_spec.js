import MockAdapter from 'axios-mock-adapter';
import axios from '~/lib/utils/axios_utils';
import * as actions from 'jh/analytics/performance_analytics/store/actions';
import * as types from 'jh/analytics/performance_analytics/store/mutation_types';
import * as getters from 'jh/analytics/performance_analytics/store/getters';
import createState from 'jh/analytics/performance_analytics/store/state';
import {
  currentGroup,
  mockSelectedDate,
  mockSelectedProjects,
  mockSummaryData,
  mockRankList,
  mockPerformanceTable,
  mockReportSummary,
} from '../mock';

describe('Performance Analytics actions', () => {
  let state;
  let store;
  let mock;

  beforeEach(() => {
    state = createState({
      groupId: currentGroup.groupId,
      fullPath: currentGroup.fullPath,
      isGroup: currentGroup.isGroup,
      projectId: null,
    });
    store = {
      state,
      getters,
    };
    mock = new MockAdapter(axios);
  });

  afterEach(() => {
    mock.restore();
  });

  describe('refreshPerformanceData', () => {
    const mockDispatch = jest.fn((actionName) => {
      const mockData = {
        updatePerformanceSummary: Promise.resolve({ data: mockSummaryData }),
        updateMemberRankList: Promise.resolve({ data: mockRankList }),
        updatePerformanceTable: Promise.resolve({
          data: mockPerformanceTable,
          headers: { 'x-page': 1, 'x-total': 10 },
        }),
        updateReportSummary: Promise.resolve({ data: mockReportSummary }),
      };

      return mockData[actionName];
    });
    const mockCommit = jest.fn();

    beforeEach(() => {
      store.dispatch = mockDispatch;
      store.commit = mockCommit;
    });

    it('dispatches "updatePerformanceSummary" "updateMemberRankList" "updatePerformanceTable" and "updateReportSummary"', async () => {
      await actions.refreshPerformanceData(store, {
        projects: mockSelectedProjects,
        ...mockSelectedDate,
      });
      expect(mockDispatch).toHaveBeenCalledWith('updatePerformanceSummary');
      expect(mockDispatch).toHaveBeenCalledWith('updateMemberRankList');
      expect(mockDispatch).toHaveBeenCalledWith('updatePerformanceTable');
      expect(mockDispatch).toHaveBeenCalledWith('updateReportSummary');
    });

    it('commits mutations', async () => {
      await actions.refreshPerformanceData(store, {
        projects: mockSelectedProjects,
        ...mockSelectedDate,
      });
      expect(mockCommit).toHaveBeenCalledWith(types.SET_LOADING_TOGGLE, true);
      expect(mockCommit).toHaveBeenCalledWith(types.SET_DATE, mockSelectedDate);
      expect(mockCommit).toHaveBeenCalledWith(types.SET_SELECTED_PROJECTS, mockSelectedProjects);
      expect(mockCommit).toHaveBeenCalledWith(types.SET_SUMMARY_DATA, mockSummaryData);
      expect(mockCommit).toHaveBeenCalledWith(types.SET_RANK_LIST, mockRankList);
      expect(mockCommit).toHaveBeenCalledWith(types.SET_PERFORMANCE_TABLE, mockPerformanceTable);
      expect(mockCommit).toHaveBeenCalledWith(types.SET_REPORT_SUMMARY, mockReportSummary);
      expect(mockCommit).toHaveBeenCalledWith(types.SET_TABLE_PAGINATION, {
        'x-page': 1,
        'x-total': 10,
      });
      expect(mockCommit).toHaveBeenCalledWith('SET_LOADING_TOGGLE', false);
    });
  });
});
