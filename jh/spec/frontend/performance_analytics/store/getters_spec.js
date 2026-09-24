import dateFormat from 'dateformat';
import * as getters from 'jh/analytics/performance_analytics/store/getters';
import { dateFormats } from '~/analytics/shared/constants'; // eslint-disable-line @jihu-fe/prefer-ee-modules
import {
  currentGroup,
  mockSelectedDate,
  mockSelectedProjects,
  mockPerformanceTable,
} from '../mock';

describe('Performance Analytics getters', () => {
  let state;

  beforeEach(() => {
    state = {
      selectDate: mockSelectedDate,
      selectedProjects: mockSelectedProjects,
      isGroup: currentGroup.isGroup,
      fullPath: currentGroup.fullPath,
      performanceTable: mockPerformanceTable,
    };
  });

  describe('performanceAnalyticsRequestParams', () => {
    it('return formatted request params for group', () => {
      expect(getters.performanceAnalyticsRequestParams(state)).toEqual({
        startDate: dateFormat(mockSelectedDate.startDate, dateFormats.isoDate),
        endDate: dateFormat(mockSelectedDate.endDate, dateFormats.isoDate),
        requestPath: currentGroup.fullPath,
        projectIds: [1, 2],
      });
    });

    it('return formatted request params for project', () => {
      state = { ...state, isGroup: false, branch: 'master' };
      expect(getters.performanceAnalyticsRequestParams(state)).toEqual({
        startDate: dateFormat(mockSelectedDate.startDate, dateFormats.isoDate),
        endDate: dateFormat(mockSelectedDate.endDate, dateFormats.isoDate),
        requestPath: currentGroup.fullPath,
        branchName: 'master',
      });
    });
  });

  describe('performanceTableData', () => {
    it('return formatted params for group', () => {
      expect(getters.performanceAnalyticsRequestParams(state)).toEqual({
        startDate: dateFormat(mockSelectedDate.startDate, dateFormats.isoDate),
        endDate: dateFormat(mockSelectedDate.endDate, dateFormats.isoDate),
        requestPath: currentGroup.fullPath,
        projectIds: [1, 2],
      });
    });
  });
});
