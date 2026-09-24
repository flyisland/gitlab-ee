import {
  mockBranchesData,
  mockUsersData,
  mockPeopleSummary,
  mockChartData,
  mockTableData,
} from './mock_data';

export const fetchBranches = () => {
  const result = mockBranchesData.data.map(({ name }) => {
    return {
      text: name,
      value: name,
    };
  });
  return Promise.resolve(result);
};

export const fetchMembers = () => {
  const result = mockUsersData.data.map((userData) => {
    return {
      ...userData,
      text: userData.name,
      value: userData.id,
    };
  });

  return Promise.resolve(result);
};

export const fetchPeopleSummary = () => {
  return Promise.resolve(mockPeopleSummary.data);
};

export const fetchChartData = () => {
  return Promise.resolve(mockChartData.data);
};

export const fetchTableData = () => {
  return Promise.resolve(mockTableData.data);
};
