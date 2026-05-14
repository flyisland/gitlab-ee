import { subgroupsAndProjects, namespaceSecurityProjectsResponse } from './mock_data';

export const mockData = subgroupsAndProjects.data;
export const mockSearchData = namespaceSecurityProjectsResponse.data;

export const createGroupResponse = ({
  subgroups = mockData.group.descendantGroups.nodes || [],
  projects = mockData.group.projects.nodes || [],
  subgroupsPageInfo = { hasNextPage: false, endCursor: null },
  projectsPageInfo = { hasNextPage: false, endCursor: null },
} = {}) => ({
  data: {
    group: {
      ...mockData.group,
      descendantGroups: {
        nodes: subgroups,
        pageInfo: subgroupsPageInfo,
      },
      projects: {
        nodes: projects,
        pageInfo: projectsPageInfo,
      },
    },
  },
});

export const createSearchResponse = ({
  namespaceSecurityProjects = mockSearchData.namespaceSecurityProjects.edges || [],
  projectsPageInfo = {
    hasNextPage: false,
    endCursor: null,
  },
} = {}) => ({
  data: {
    group: {
      id: mockSearchData.group.id,
    },
    namespaceSecurityProjects: {
      edges: namespaceSecurityProjects,
      pageInfo: projectsPageInfo,
    },
  },
});

export const createPaginatedHandler = ({ first, second }) => {
  const handler = jest.fn();
  handler.mockResolvedValueOnce(createGroupResponse(first));
  handler.mockResolvedValueOnce(createGroupResponse(second));
  return handler;
};

export const createPaginatedSearchHandler = ({ first, second }) => {
  const handler = jest.fn();
  handler.mockResolvedValueOnce(createSearchResponse(first));
  handler.mockResolvedValueOnce(createSearchResponse(second));
  return handler;
};
