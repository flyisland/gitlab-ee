import dateFormat from 'dateformat';
import { dateFormats } from '~/analytics/shared/constants'; // eslint-disable-line @jihu-fe/prefer-ee-modules
import { convertObjectPropsToCamelCase } from '~/lib/utils/common_utils';
import { getIdFromGraphQLId } from '~/graphql_shared/utils';

export const performanceAnalyticsRequestParams = (state) => {
  const {
    selectDate: { startDate, endDate },
    selectedProjects,
    isGroup,
    fullPath,
    branch,
  } = state;

  const groupParams = {};
  const projectParams = {};

  if (isGroup) {
    groupParams.projectIds = (selectedProjects || []).map((project) =>
      getIdFromGraphQLId(project.id),
    );
  } else {
    projectParams.branchName = branch;
  }

  return {
    startDate: startDate ? dateFormat(startDate, dateFormats.isoDate) : null,
    endDate: endDate ? dateFormat(endDate, dateFormats.isoDate) : null,
    requestPath: fullPath,
    ...groupParams,
    ...projectParams,
  };
};

export const performanceTableData = (state) => {
  if (!state.performanceTable?.length) {
    return [];
  }

  return state.performanceTable.map((item) => {
    const { user, ...performanceInfo } = item;
    let rowDetail = { ...performanceInfo, ...user };
    rowDetail = convertObjectPropsToCamelCase(rowDetail, { deep: true });

    return rowDetail;
  });
};
