export default ({ isGroup, groupId, projectId, fullPath, branch, rankList = [] }) => ({
  selectedProjects: [],
  summaryData: {},
  rankList,
  performanceTable: [],
  reportSummary: {},
  loading: true,
  tablePagination: {
    page: 1,
    total: 0,
  },
  selectDate: {
    startDate: '',
    endDate: '',
  },
  branch,
  isGroup,
  projectId,
  fullPath,
  groupId,
});
