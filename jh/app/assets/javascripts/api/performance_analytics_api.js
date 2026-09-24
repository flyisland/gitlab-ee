import { buildApiUrl } from '~/api/api_utils';
import axios from '~/lib/utils/axios_utils';

const GROUP_PERFORMANCE_SUMMARY_PATH =
  '/groups/:request_path/-/analytics/performance_analytics/summary.json';
const GROUP_RANK_LIST_PATH =
  '/groups/:request_path/-/analytics/performance_analytics/leaderboard.json';
const GROUP_PERFORMANCE_TABLE_PATH =
  '/groups/:request_path/-/analytics/performance_analytics/report.json';

const PROJECT_PERFORMANCE_SUMMARY_PATH =
  '/:request_path/-/analytics/performance_analytics/summary.json';
const PROJECT_RANK_LIST_PATH = '/:request_path/-/analytics/performance_analytics/leaderboard.json';
const PROJECT_PERFORMANCE_TABLE_PATH =
  '/:request_path/-/analytics/performance_analytics/report.json';

const GROUP_PERFORMANCE_REPORT_EXPORT_PATH =
  '/groups/:request_path/-/analytics/performance_analytics/report.csv';
const PROJECT_PERFORMANCE_REPORT_EXPORT_PATH =
  '/:request_path/-/analytics/performance_analytics/report.csv';

const GROUP_REPORT_SUMMARY_PATH =
  '/groups/:request_path/-/analytics/performance_analytics/report_summary.json';
const PROJECT_REPORT_SUMMARY_PATH =
  '/:request_path/-/analytics/performance_analytics/report_summary.json';

export const getGroupReportSummary = ({ requestPath, projectIds = [], startDate, endDate }) => {
  const url = buildApiUrl(GROUP_REPORT_SUMMARY_PATH).replace(':request_path', requestPath);

  return axios.get(url, {
    params: {
      project_ids: projectIds,
      start_date: startDate,
      end_date: endDate,
    },
  });
};

export const getGroupPerformanceSummary = ({
  requestPath,
  projectIds = [],
  startDate,
  endDate,
}) => {
  const url = buildApiUrl(GROUP_PERFORMANCE_SUMMARY_PATH).replace(':request_path', requestPath);

  return axios.get(url, {
    params: {
      project_ids: projectIds,
      start_date: startDate,
      end_date: endDate,
    },
  });
};

export const getGroupRankList = ({
  requestPath,
  projectIds = [],
  startDate,
  endDate,
  rankType,
}) => {
  const url = buildApiUrl(GROUP_RANK_LIST_PATH).replace(':request_path', requestPath);

  return axios.get(url, {
    params: {
      project_ids: projectIds,
      start_date: startDate,
      end_date: endDate,
      leaderboard_type: rankType,
    },
  });
};

export const getGroupPerformanceTable = ({
  requestPath,
  projectIds = [],
  startDate,
  endDate,
  page,
  sort,
  direction,
}) => {
  const url = buildApiUrl(GROUP_PERFORMANCE_TABLE_PATH).replace(':request_path', requestPath);

  return axios.get(url, {
    params: {
      project_ids: projectIds,
      start_date: startDate,
      end_date: endDate,
      page,
      sort,
      direction,
    },
  });
};

export const getProjectReportSummary = ({ requestPath, branchName, startDate, endDate }) => {
  const url = buildApiUrl(PROJECT_REPORT_SUMMARY_PATH).replace(':request_path', requestPath);

  return axios.get(url, {
    params: {
      branch_name: branchName,
      start_date: startDate,
      end_date: endDate,
    },
  });
};

export const getProjectPerformanceSummary = ({ requestPath, branchName, startDate, endDate }) => {
  const url = buildApiUrl(PROJECT_PERFORMANCE_SUMMARY_PATH).replace(':request_path', requestPath);

  return axios.get(url, {
    params: {
      branch_name: branchName,
      start_date: startDate,
      end_date: endDate,
    },
  });
};

export const getProjectRankList = ({ requestPath, branchName, startDate, endDate, rankType }) => {
  const url = buildApiUrl(PROJECT_RANK_LIST_PATH).replace(':request_path', requestPath);

  return axios.get(url, {
    params: {
      branch_name: branchName,
      start_date: startDate,
      end_date: endDate,
      leaderboard_type: rankType,
    },
  });
};

export const getProjectPerformanceTable = ({
  requestPath,
  branchName,
  startDate,
  endDate,
  page,
  sort,
  direction,
}) => {
  const url = buildApiUrl(PROJECT_PERFORMANCE_TABLE_PATH).replace(':request_path', requestPath);

  return axios.get(url, {
    params: {
      branch_name: branchName,
      start_date: startDate,
      end_date: endDate,
      page,
      sort,
      direction,
    },
  });
};

export const downloadGroupPerformanceReport = ({
  requestPath,
  startDate,
  endDate,
  projectIds = [],
}) => {
  const url = buildApiUrl(GROUP_PERFORMANCE_REPORT_EXPORT_PATH).replace(
    ':request_path',
    requestPath,
  );

  return axios.get(url, {
    params: {
      project_ids: projectIds,
      start_date: startDate,
      end_date: endDate,
    },
  });
};

export const downloadProjectPerformanceReport = ({
  requestPath,
  startDate,
  endDate,
  branchName,
}) => {
  const url = buildApiUrl(PROJECT_PERFORMANCE_REPORT_EXPORT_PATH).replace(
    ':request_path',
    requestPath,
  );

  return axios.get(url, {
    params: {
      branch_name: branchName,
      start_date: startDate,
      end_date: endDate,
    },
  });
};
