import { assign } from 'lodash-es';
import {
  getGroupPerformanceSummary,
  getGroupRankList,
  getGroupPerformanceTable,
  getProjectPerformanceSummary,
  getProjectRankList,
  getProjectPerformanceTable,
  getGroupReportSummary,
  getProjectReportSummary,
} from 'jh/rest_api';
import { createAlert } from '~/alert';
import { s__ } from '~/locale';
import { mapTableRequest, mapRankRequest } from 'jh/analytics/performance_analytics/mappers';
import * as types from './mutation_types';

export const refreshPerformanceData = (
  { commit, dispatch },
  { startDate, endDate, projects, branch },
) => {
  commit(types.SET_LOADING_TOGGLE, true);
  commit(types.SET_DATE, { startDate, endDate });
  commit(types.SET_SELECTED_PROJECTS, projects);
  commit(types.SET_SELECTED_BRANCH, branch);
  return Promise.all([
    dispatch('updatePerformanceSummary'),
    dispatch('updateMemberRankList'),
    dispatch('updatePerformanceTable'),
    dispatch('updateReportSummary'),
  ])
    .then((res) => {
      const [summaryRes, rankRes, tableRes, reportSummaryRes] = res;
      commit(types.SET_SUMMARY_DATA, summaryRes.data);
      commit(types.SET_RANK_LIST, rankRes.data);
      commit(types.SET_PERFORMANCE_TABLE, tableRes.data);
      commit(types.SET_REPORT_SUMMARY, reportSummaryRes.data);
      commit(types.SET_TABLE_PAGINATION, tableRes.headers);
      commit(types.SET_LOADING_TOGGLE, false);
    })
    .catch(() => {
      createAlert({
        message: s__('JH|There was an error while fetching performance analytics data.'),
      });
      commit(types.SET_LOADING_TOGGLE, false);
    });
};

export const updatePerformanceSummary = ({ getters, state }) => {
  const params = { ...getters.performanceAnalyticsRequestParams };

  if (state.isGroup) {
    return getGroupPerformanceSummary(params);
  }
  return getProjectPerformanceSummary(params);
};

export const updateMemberRankList = ({ getters, state }, payload) => {
  let params = { ...getters.performanceAnalyticsRequestParams };
  const rankParams = mapRankRequest(payload);
  params = assign(params, rankParams);

  if (state.isGroup) {
    return getGroupRankList(params);
  }
  return getProjectRankList(params);
};

export const updatePerformanceTable = ({ getters, state }, payload) => {
  let params = { ...getters.performanceAnalyticsRequestParams };
  const tableParams = mapTableRequest(payload);
  params = assign(params, tableParams);

  if (params.sort === 'fullname') {
    params.sort = 'username';
  }

  if (state.isGroup) {
    return getGroupPerformanceTable(params);
  }
  return getProjectPerformanceTable(params);
};

export const updateReportSummary = ({ getters, state }) => {
  const params = { ...getters.performanceAnalyticsRequestParams };

  return state.isGroup ? getGroupReportSummary(params) : getProjectReportSummary(params);
};
